// Tests for server
package server

import (
	"html/template"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"testing"

	"github.com/jinzhu/gorm"
	"github.com/scalefactory-hiring/technical-test/internal/schema"
	mocket "github.com/selvatico/go-mocket"
)

func SetupDatabaseMock() *gorm.DB {
	mocket.Catcher.Register()
	mocket.Catcher.Logging = true
	db, _ := gorm.Open(mocket.DriverName, "")
	replyPageDave := []map[string]interface{}{{
		"id":           27,
		"project_code": "daves",
		"page_name":    "BigDaves_House_of_Fun",
		"page_views":   2000,
		"bytes":        299,
	}}
	mocket.Catcher.NewMock().WithQuery(`SELECT * FROM "page_views"  WHERE (id = BigDaves_House_of_Fun)`).WithReply(replyPageDave)
	mocket.Catcher.NewMock().WithQuery(`SELECT * FROM "page_views"  WHERE (page_name LIKE BigDaves_House_of_Fun%)`).WithReply(replyPageDave)
	return db
}

// load all templates in when starts
var (
	pattern   = filepath.Join("../../web/template/", "*.html")
	templates = template.Must(template.ParseGlob(pattern))
)

// service helper
var (
	s = serviceHelper{
		db:        SetupDatabaseMock(),
		templates: templates,
	}
)

func TestRenderPageViewTemplate(t *testing.T) {
	t.Run("Render BigDaves_House_of_Fun", func(t *testing.T) {
		// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
		rr := httptest.NewRecorder()

		var pageViews []schema.PageView
		s.db.Where("id = ?", "BigDaves_House_of_Fun").Find(&pageViews)
		renderPageViewTemplate(rr, "pageview", &pageViews, &s)

		// Check the response body is what we expect.
		expected := `http://daves.wikipedia.org/wiki/BigDaves_House_of_Fun`

		if !strings.Contains(rr.Body.String(), expected) {
			t.Errorf("handler returned unexpected body: got %v wanted to contain %v",
				rr.Body.String(), expected)
		}
	})
}

// func makeHandler(fn func(http.ResponseWriter, *http.Request, *gorm.DB), db *gorm.DB) http.HandlerFunc {

// func saveHandler(w http.ResponseWriter, r *http.Request, db *gorm.DB) {

func TestSearchHandler(t *testing.T) {
	t.Run("Search BigDaves_House_of_Fun", func(t *testing.T) {
		req, err := http.NewRequest("GET", "/pageview/search/BigDaves_House_of_Fun", nil)
		if err != nil {
			t.Fatal(err)
		}
		// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
		rr := httptest.NewRecorder()

		handler := makeHandler(searchHandler, &s)

		// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
		// directly and pass in our Request and ResponseRecorder.
		handler.ServeHTTP(rr, req)

		// Check the status code is what we expect.
		if status := rr.Code; status != http.StatusOK {
			t.Errorf("handler returned wrong status code: got %v want %v",
				status, http.StatusOK)
		}

		// Check the response body is what we expect.
		expected := `BigDaves_House_of_Fun`

		if !strings.Contains(rr.Body.String(), expected) {
			t.Errorf("handler returned unexpected body: got %v wanted to contain %v",
				rr.Body.String(), expected)
		}
	})
}

func TestShowHandler(t *testing.T) {
	t.Run("Get BigDaves_House_of_Fun", func(t *testing.T) {
		req, err := http.NewRequest("GET", "/pageview/show/BigDaves_House_of_Fun", nil)
		if err != nil {
			t.Fatal(err)
		}
		// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
		rr := httptest.NewRecorder()

		handler := makeHandler(showHandler, &s)

		// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
		// directly and pass in our Request and ResponseRecorder.
		handler.ServeHTTP(rr, req)

		// Check the status code is what we expect.
		if status := rr.Code; status != http.StatusOK {
			t.Errorf("handler returned wrong status code: got %v want %v",
				status, http.StatusOK)
		}

		// Check the response body is what we expect.
		expected := `BigDaves_House_of_Fun`

		if !strings.Contains(rr.Body.String(), expected) {
			t.Errorf("handler returned unexpected body: got %v wanted to contain %v",
				rr.Body.String(), expected)
		}
	})
}

// func editHandler(w http.ResponseWriter, r *http.Request, db *gorm.DB) {

// func newHandler(w http.ResponseWriter, r *http.Request, db *gorm.DB) {

// func saveNewHandler(w http.ResponseWriter, r *http.Request, db *gorm.DB) {

func TestRootHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}
	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()
	handler := makeHandler(rootHandler, &s)

	// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
	// directly and pass in our Request and ResponseRecorder.
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check the response body is what we expect.
	expected := `<h1>WikiStats Search And Compare</h1>`

	if !strings.Contains(rr.Body.String(), expected) {
		t.Errorf("handler returned unexpected body: got %v wanted to contain %v",
			rr.Body.String(), expected)
	}
}
