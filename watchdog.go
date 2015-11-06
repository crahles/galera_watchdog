package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
	"github.com/vharitonsky/iniflags"
)

var (
	db  *sql.DB
	err error

	httpHost = flag.String("HTTP_HOST", "localhost", "http address")
	httpPort = flag.String("HTTP_PORT", "9199", "http port")

	sqlHost = flag.String("MYSQL_HOST", "localhost", "address of the MySQL server")
	sqlPort = flag.String("MYSQL_PORT", "3306", "port of the MySQL server")
	sqlUser = flag.String("MYSQL_USER", "root", "Username for login to MySQL")
	sqlPass = flag.String("MYSQL_PASS", "", "Password for login to MySQL")

	donorOk = flag.Bool("DONOR_OK", false, "treat donor as regular working node")

	showVersion = flag.Bool("version", false, fmt.Sprint("Show current version: ", Commit))

	// Commit holds the git sha information on compile time
	Commit = "dev"
)

func main() {
	iniflags.Parse()
	if *showVersion {
		fmt.Println(Commit)
		return
	}
	db, err = sql.Open(
		"mysql",
		fmt.Sprintf("%s:%s@tcp(%s:%s)/mysql", *sqlUser, *sqlPass, *sqlHost, *sqlPort),
	)
	if err != nil {
		log.Fatal(err)
	}
	http.HandleFunc("/", databaseStatusHandler)
	http.HandleFunc("/status", watchdogStatusHandler)
	if err := http.ListenAndServe(*httpHost+":"+*httpPort, nil); err != nil {
		log.Fatal(err)
	}
}

func watchdogStatusHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func databaseStatusHandler(w http.ResponseWriter, r *http.Request) {
	err = db.Ping()
	if err != nil {
		http.Error(w, "Galera Node is *down*. ("+err.Error()+")", 503)
		return
	}

	var key string
	var value int64
	err = db.QueryRow("SHOW STATUS LIKE 'wsrep_local_state'").Scan(&key, &value)
	if err != nil {
		http.Error(w, "Galera Node is *down*. ("+err.Error()+")", 503)
		return
	}

	switch {
	case 4 == value:
		fmt.Fprintf(w, "Galera Node is running.")
		return
	case 2 == value && *donorOk:
		fmt.Fprintf(w, "Galera Node is running.")
		return
	default:
		http.Error(w, "Galera Node is *down*. (State Mismatch)", 503)
		return
	}
}
