package main

import "fmt"

var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

func main() {
  fmt.Printf("%v, commit %v, built at %v", version, commit, date)
}