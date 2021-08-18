package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/jinzhu/gorm"
	"github.com/scalefactory-hiring/technical-test/internal/schema"
	"github.com/scalefactory-hiring/technical-test/internal/server"
)

func main() {

	var filename string
	flag.StringVar(&filename, "import", "page_views.data", "space separated CSV file")
	flag.Parse()

	fmt.Println("Importing data from: " + filename)

	// Open CSV file
	f, err := os.Open(filename)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	// Read File into a Variable
	reader := csv.NewReader(f)
	reader.Comma = rune(' ')
	reader.LazyQuotes = true

	db := server.DatabaseConnect()

	batch := 100
	eof := false

	// Loop through lines & turn into object, batch 200
	for i := 0; eof == false; i += batch {
		j := i + batch
		pageViews := []schema.PageView{}
		fmt.Println("Inserting records", i, "to", j)

		for l := i; l < j; l++ {
			line, err := reader.Read()
			if err == io.EOF {
				eof = true
				break
			} else if err != nil {
				fmt.Println("Error:", err)
				return
			}
			pageviews, _ := strconv.Atoi(line[2])
			bytes, _ := strconv.Atoi(line[3])
			data := schema.PageView{
				ProjectCode: line[0],
				PageName:    line[1],
				PageViews:   pageviews,
				Bytes:       bytes,
			}
			pageViews = append(pageViews, data)
		}
		// sqlStr := "INSERT INTO page_views(project_code, page_name, page_views, bytes) VALUES "
		// vals := []interface{}{}
		// const rowSQL = "(?, ?, ?, ?)"
		// var inserts []string

		// for _, elem := range pageViews {
		// 	fmt.Println("elem", elem)
		// 	time.Sleep(2 * time.Second)
		// 	inserts = append(inserts, rowSQL)
		// 	vals = append(vals, elem.ProjectCode, elem.PageName, elem.PageViews, elem.Bytes)
		// }
		// sqlStr = sqlStr + strings.Join(inserts, ",")
		// fmt.Println("SQL", sqlStr)

		// if err := db.Exec(sqlStr, vals...).Error; err != nil {
		// 	fmt.Println(err)
		// } else {
		// 	fmt.Println("Imported record batch", i, "to", j)
		// }

		if err := batchInsert(db, pageViews); err != nil {
			fmt.Println(err)
		} else {
			fmt.Println("Imported record batch", i, "to", j)
		}

	}
	fmt.Println("Import complete")
}

func batchInsert(db *gorm.DB, objArr []schema.PageView) error {
	// If there is no data, nothing to do.
	if len(objArr) == 0 {
		return nil
	}

	mainObj := objArr[0]
	mainScope := db.NewScope(mainObj)
	mainFields := mainScope.Fields()
	quoted := make([]string, 0, len(mainFields))
	for i := range mainFields {
		// If primary key has blank value (0 for int, "" for string, nil for interface ...), skip it.
		// If field is ignore field, skip it.
		if (mainFields[i].IsPrimaryKey && mainFields[i].IsBlank) || (mainFields[i].IsIgnored) {
			continue
		}
		quoted = append(quoted, mainScope.Quote(mainFields[i].DBName))
	}

	placeholdersArr := make([]string, 0, len(objArr))

	for _, obj := range objArr {
		scope := db.NewScope(obj)
		fields := scope.Fields()
		placeholders := make([]string, 0, len(fields))
		for i := range fields {
			if (fields[i].IsPrimaryKey && fields[i].IsBlank) || (fields[i].IsIgnored) {
				continue
			}
			if fields[i].Name == "CreatedAt" && fields[i].IsBlank {
				fields[i].Set(time.Now())
			}

			if fields[i].Name == "UpdatedAt" && fields[i].IsBlank {
				fields[i].Set(time.Now())
			}
			placeholders = append(placeholders, scope.AddToVars(fields[i].Field.Interface()))
		}
		placeholdersStr := "(" + strings.Join(placeholders, ", ") + ")"
		placeholdersArr = append(placeholdersArr, placeholdersStr)
		// add real variables for the replacement of placeholders' '?' letter later.
		mainScope.SQLVars = append(mainScope.SQLVars, scope.SQLVars...)
	}

	mainScope.Raw(fmt.Sprintf("INSERT INTO %s (%s) VALUES %s",
		mainScope.QuotedTableName(),
		strings.Join(quoted, ", "),
		strings.Join(placeholdersArr, ", "),
	))

	if _, err := mainScope.SQLDB().Exec(mainScope.SQL, mainScope.SQLVars...); err != nil {
		return err
	}
	return nil
}
