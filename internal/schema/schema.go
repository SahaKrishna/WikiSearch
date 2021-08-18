package schema

import (
	"github.com/jinzhu/gorm"
)

//Our schema structs

// PageView schema
type PageView struct {
	ID          uint   `gorm:"primary_key"`
	ProjectCode string `gorm:"size:20;not null;index:CodeIndex"`
	PageName    string `gorm:"size:255;not null"`
	PageViews   int
	Bytes       int
}

// ProjectView schema
type ProjectView struct {
	ID          uint   `gorm:"primary_key"`
	ProjectCode string `gorm:"size:20;not null"`
	PageViews   int
	Bytes       int
}

// AutoMigrate Schema
func AutoMigrate(db *gorm.DB) {
	db.AutoMigrate(&PageView{})
	db.AutoMigrate(&ProjectView{})
}
