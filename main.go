package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"
)

type ScoreState int

const (
	StateAgain ScoreState = iota
	StateHard
	StateGood
	StateEasy
)

type Word struct {
	Word         string     `json:"word"`
	Context      string     `json:"context"`
	Score        ScoreState `json:"score"`
	LastRecalled string     `json:"last_recalled"`
}

type JsonList struct {
	Data []Word `json:"data"`
}

func checkFileExists(filePath string) bool {
	_, err := os.Stat(filePath)
	return !errors.Is(err, os.ErrNotExist)
}

func main() {
	// read txt file
	var txtFile string = "words.txt"
	var jsonFile string = "words.json"

	content, err := os.ReadFile(txtFile)
	if err != nil {
		fmt.Printf("Failed to read file: %s", err)
		return
	}

	// split by new line
	content_list := strings.Split(string(content), "\n")

	// check if json file exists
	if !checkFileExists(jsonFile) {
		recallFile, err := os.Create(jsonFile)
		if err != nil {
			fmt.Printf("Failed to create file: %s", err)
			return
		}

		defer recallFile.Close()
	}

	// process file, add new words if they aren't registered
	recall_list, err := os.ReadFile(jsonFile)
	if err != nil {
		fmt.Printf("Failed to read json file: %s", err)
		return
	}

	var wordlist JsonList

	err = json.Unmarshal(recall_list, &wordlist)
	if err != nil {
		fmt.Printf("Failed to parse json file: %s", err)
		return
	}

	// check for duplicate
	for i := range content_list {
		var alreadyIncluded bool = false

		for j := range wordlist.Data {
			if wordlist.Data[j].Word == content_list[i] {
				alreadyIncluded = true
			}
		}

		if !alreadyIncluded {
			time := time.Now().Format("2006-01-02")
			new := Word{content_list[i], "", 0, time}
			wordlist.Data = append(wordlist.Data, new)
		}
	}

	b, err := json.MarshalIndent(wordlist, "", "  ")
	if err != nil {
		fmt.Printf("Failed to marshal: %s", err)
		return
	}

	err = os.WriteFile(jsonFile, b, 0644)
	if err != nil {
		fmt.Printf("Failed to write file: %s", err)
		return
	}

	fmt.Println("JSON file successfully created!")

	// typst preview

}
