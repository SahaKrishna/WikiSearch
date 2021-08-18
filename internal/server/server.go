package server

import (
	"fmt"
	"html/template"
	"path/filepath"

	"net/http"
	"os"
	"regexp"
	"strconv"
	"time"

	// GORM :  DB ORM
	"github.com/jinzhu/gorm"
	// Gorm backend unknown at compile time
	// support MySQL
	_ "github.com/jinzhu/gorm/dialects/mysql"
	// Support SQLite3
	_ "github.com/jinzhu/gorm/dialects/sqlite"

	// Prometheus monitoring
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	// JSON logging
	log "github.com/sirupsen/logrus"

	// Our database schema
	"github.com/scalefactory-hiring/technical-test/internal/schema"
)

// template path validator
var validPath = regexp.MustCompile("^/(pageview)/(new|search|search/.*|edit/.*|save/.*|show/.*)$")

// metrics
var (
	pageRenders = promauto.NewCounter(prometheus.CounterOpts{
		Name: "page_renders",
		Help: "The total number of page render events",
	})
	searchTimeHistogram = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name: "search_duration_seconds",
		Help: "Time taken to search",
	}, []string{"code"})
)

type serviceHelper struct {
	db        *gorm.DB
	templates *template.Template
}

func renderPageViewTemplate(w http.ResponseWriter, t string, p *[]schema.PageView, s *serviceHelper) {
	err := s.templates.ExecuteTemplate(w, t, p)
	pageRenders.Inc()
	if err != nil {
		log.Error(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// ensures valid page name and calls handler
func makeHandler(fn func(http.ResponseWriter, *http.Request, *serviceHelper), s *serviceHelper) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		m := validPath.FindStringSubmatch(r.URL.Path)
		if m == nil && r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		fn(w, r, s)
	}
}

func saveHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	projectcode := template.HTMLEscapeString(r.FormValue("projectcode"))
	pagename := template.HTMLEscapeString(r.FormValue("pagename"))
	pageviews, _ := strconv.Atoi(template.HTMLEscapeString(r.FormValue("pageviews")))
	bytes, _ := strconv.Atoi(template.HTMLEscapeString(r.FormValue("bytes")))

	var p schema.PageView
	var id string

	newPage := r.URL.Path == "/pageview/new"
	if newPage {
		p := schema.PageView{
			ProjectCode: projectcode,
			PageName:    pagename,
			PageViews:   pageviews,
			Bytes:       bytes,
		}
		s.db.Create(&p)
		id = fmt.Sprintf("%d", p.ID)
	} else {
		id = r.URL.Path[len("/pageview/save/"):]
		if err := s.db.Where("id = ?", id).Find(&p).Error; err == nil {
			p.ProjectCode = projectcode
			p.PageName = pagename
			p.PageViews = pageviews
			p.Bytes = bytes
			s.db.Save(&p)
		} else {
			log.Error(err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
	http.Redirect(w, r, "/pageview/show/"+id, http.StatusFound)

}

func searchHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	if r.Method == "GET" {
		// search request metrics
		start := time.Now()
		code := http.StatusOK

		defer func() { // Make sure we record a status.
			duration := time.Since(start)
			searchTimeHistogram.WithLabelValues(fmt.Sprintf("%d", code)).Observe(duration.Seconds())
		}()

		var pageViews []schema.PageView
		var projectViews []schema.ProjectView
		searchTerm := r.URL.Path[len("/pageview/search/"):] + "%"

		if err := s.db.Where("page_name LIKE ?", searchTerm).Find(&pageViews).Error; err == nil {
			s.db.Where("project_code LIKE ?", pageViews[0].ProjectCode).Find(&projectViews)
			renderPageViewTemplate(w, "pageviews", &pageViews, s)
		} else {
			code = http.StatusInternalServerError
			log.Error(err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	} else if r.Method == "POST" {
		http.Redirect(w, r, "/pageview/search/"+r.FormValue("pagename"), http.StatusFound)
	}
}

func showHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	var pageViews []schema.PageView
	id := r.URL.Path[len("/pageview/show/"):]

	if err := s.db.Where("id = ?", id).Find(&pageViews).Error; err == nil {
		renderPageViewTemplate(w, "pageview", &pageViews, s)
	} else {
		log.Error(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func editHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	var pageViews []schema.PageView
	match := r.URL.Path[len("/pageview/edit/"):]

	if err := s.db.Where("id = ?", match).Find(&pageViews).Error; err == nil {
		renderPageViewTemplate(w, "editpageview", &pageViews, s)
	} else {
		log.Error(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func newHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	if r.Method == "GET" {
		err := s.templates.ExecuteTemplate(w, "newpageview", s)
		if err != nil {
			log.Error(err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	} else if r.Method == "POST" {
		saveHandler(w, r, s)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request, s *serviceHelper) {
	err := s.templates.ExecuteTemplate(w, "index", s)
	if err != nil {
		log.Error(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// DatabaseConnect configures the database for you
func DatabaseConnect() *gorm.DB {
	//load config yaml and build connection string
	connectionDetails := map[string]string{
		"SQL_TYPE":              "sqlite3",
		"SQL_CONNECTION_STRING": "tech_test.db",
	}
	for key := range connectionDetails {
		env, ok := os.LookupEnv(key)
		if ok {
			connectionDetails[key] = env
		}
	}
	// Connection to database
	// MySQL "mysql", "root:secretsauce@/dbname?charset=utf8&parseTime=True&loc=Local"
	// SQLite "sqlite3", "test.db"
	var db *gorm.DB
	var err error

	// we sleep here because docker-compose may not be ready/up.
	for i, l := 0, 10; i <= l; i++ {
		db, err = gorm.Open(connectionDetails["SQL_TYPE"], connectionDetails["SQL_CONNECTION_STRING"])

		if err != nil {
			if i == l {
				log.Error(err)
				panic("failed to connect database:" + err.Error())
			}
			time.Sleep(time.Duration(i) * time.Second)
		} else {
			break
		}
	}

	// create db and add missing schema elements
	// note there are limits on AutoMigrate
	schema.AutoMigrate(db)
	return db
}

// Run the server and listen for requests
func Run() {
	log.SetFormatter(&log.JSONFormatter{})
	log.SetLevel(log.InfoLevel)

	// Database connection
	db := DatabaseConnect()
	defer db.Close()

	// load all templates in when starts
	pattern := filepath.Join("web/template/", "*.html")
	templates := template.Must(template.ParseGlob(pattern))

	// register prometheus metrics
	// prometheus.MustRegister(searchTimeHistogram)
	// prometheus.MustRegister(prometheus.NewBuildInfoCollector())

	log.Info("Web Corp Server Ready to Serve")

	// a service Helper
	s := serviceHelper{
		db:        db,
		templates: templates,
	}

	// http Handler mappings
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./web/static/"))))
	http.HandleFunc("/pageview/new", makeHandler(newHandler, &s))
	http.HandleFunc("/pageview/search", makeHandler(searchHandler, &s))
	http.HandleFunc("/pageview/search/", makeHandler(searchHandler, &s))
	http.HandleFunc("/pageview/show/", makeHandler(showHandler, &s))
	http.HandleFunc("/pageview/edit/", makeHandler(editHandler, &s))
	http.HandleFunc("/pageview/save/", makeHandler(saveHandler, &s))
	http.HandleFunc("/", makeHandler(rootHandler, &s))

	// Expose the registered metrics via HTTP.
	http.Handle("/metrics", promhttp.Handler())

	// Run webserver
	log.Fatal(http.ListenAndServe(":8080", nil))

}
