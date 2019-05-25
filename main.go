package main

import (
	"flag"
	"log"
	"net/http"
)

var (
	address = flag.String("addr", ":2000", "Address to bind on")
)

func main() {
	flag.Parse()

	lights := createController()

	log.Println("Started light controller")

	go lights.process()
	defer lights.cleanup()

	http.HandleFunc("/button/api/flash_light", func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Access-Control-Allow-Origin", "*")

		if request.Method != http.MethodPost {
			http.Error(writer, "405 method not allowed", http.StatusMethodNotAllowed)
			return
		}

		lights.controlChannel <- true
	})

	log.Printf("Starting HTTP server on %s\n", *address)

	log.Fatal(http.ListenAndServe(*address, nil))
}
