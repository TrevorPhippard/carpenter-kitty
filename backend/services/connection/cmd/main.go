package main

import (
	"connections/internal/config"
	"connections/internal/server"
	"log"
	"os"
)

func main() {
	uri := os.Getenv("NEO4J_URI")
	username := os.Getenv("NEO4J_USER")
	password := os.Getenv("NEO4J_PASSWORD")

	if uri == "" || username == "" || password == "" {
		log.Fatal("Missing Neo4j environment variables")
	}

	config.ConnectNeo4j(uri, username, password)
	server.Run()
}
