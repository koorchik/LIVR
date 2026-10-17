// Runs the LIVR test suite against github.com/k33nice/go-livr.
// Comparison mirrors go-livr's own test/helper.go (JSONDuckEqual): leaves are
// compared loosely (a number equals its string form, a bool its "true"/"false"),
// containers strictly; key order does not matter. Error values are compared by
// their message, like the indirectErrors helper in go-livr's tests.
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"runtime/debug"
	"sort"
	"strconv"
	"strings"

	livr "github.com/k33nice/go-livr"
)

type failure struct {
	Case    string `json:"case"`
	Message string `json:"message"`
}

type result struct {
	ID       string    `json:"id"`
	Package  string    `json:"package"`
	Version  string    `json:"version"`
	Source   string    `json:"source"`
	Total    int       `json:"total"`
	Passed   int       `json:"passed"`
	Failures []failure `json:"failures"`
	Error    *string   `json:"error"`
}

func readJSON(dir, name string, target interface{}) bool {
	data, err := os.ReadFile(filepath.Join(dir, name+".json"))
	if err != nil {
		return false
	}
	if err := json.Unmarshal(data, target); err != nil {
		panic(fmt.Sprintf("cannot parse %s.json: %v", name, err))
	}
	return true
}

func normalize(v interface{}) interface{} {
	switch x := v.(type) {
	case map[string]interface{}:
		out := make(map[string]interface{}, len(x))
		for k, val := range x {
			out[k] = normalize(val)
		}
		return out
	case []interface{}:
		out := make([]interface{}, len(x))
		for i, val := range x {
			out[i] = normalize(val)
		}
		return out
	case error:
		return x.Error()
	case int:
		return float64(x)
	case int64:
		return float64(x)
	case float32:
		return float64(x)
	case json.Number:
		f, _ := x.Float64()
		return f
	}
	return v
}

func formatFloat(f float64) string { return strconv.FormatFloat(f, 'f', -1, 64) }

func duckEqual(x, y interface{}) bool {
	switch a := x.(type) {
	case nil:
		return y == nil
	case map[string]interface{}:
		b, ok := y.(map[string]interface{})
		if !ok || len(a) != len(b) {
			return false
		}
		for k, av := range a {
			bv, ok := b[k]
			if !ok || !duckEqual(av, bv) {
				return false
			}
		}
		return true
	case []interface{}:
		b, ok := y.([]interface{})
		if !ok || len(a) != len(b) {
			return false
		}
		for i := range a {
			if !duckEqual(a[i], b[i]) {
				return false
			}
		}
		return true
	case bool:
		switch b := y.(type) {
		case bool:
			return a == b
		case string:
			pb, err := strconv.ParseBool(b)
			return err == nil && pb == a
		}
	case string:
		switch b := y.(type) {
		case string:
			return a == b
		case bool:
			return strconv.FormatBool(b) == a
		case float64:
			return formatFloat(b) == a
		}
	case float64:
		switch b := y.(type) {
		case float64:
			return a == b
		case string:
			return formatFloat(a) == b
		}
	}
	return false
}

func show(v interface{}) string {
	data, err := json.Marshal(v)
	s := string(data)
	if err != nil {
		s = fmt.Sprintf("%v", v)
	}
	if len(s) > 300 {
		s = s[:300] + "…"
	}
	return s
}

func runCase(suite, dir string) (message string) {
	defer func() {
		if r := recover(); r != nil {
			message = fmt.Sprintf("exception: %v", r)
		}
	}()

	var rules, input map[string]interface{}
	var aliases []livr.Alias
	readJSON(dir, "rules", &rules)
	readJSON(dir, "input", &input)
	readJSON(dir, "aliases", &aliases)

	v := livr.New(&livr.Options{LivrRules: rules})
	for _, a := range aliases {
		v.RegisterAliasedRule(a)
	}

	output, err := v.Validate(input)
	errors := normalize(map[string]interface{}(v.Errors()))

	if strings.HasSuffix(suite, "positive") {
		var expected interface{}
		readJSON(dir, "output", &expected)
		if err != nil {
			return "expected no errors, got " + show(errors)
		}
		got := normalize(map[string]interface{}(output))
		if !duckEqual(normalize(expected), got) {
			return "expected output " + show(expected) + ", got " + show(got)
		}
	} else {
		var expected interface{}
		readJSON(dir, "errors", &expected)
		if err == nil {
			return "expected validation to fail, got output " + show(output)
		}
		if !duckEqual(normalize(expected), errors) {
			return "expected errors " + show(expected) + ", got " + show(errors)
		}
	}
	return ""
}

func moduleVersion() string {
	if info, ok := debug.ReadBuildInfo(); ok {
		for _, dep := range info.Deps {
			if dep.Path == "github.com/k33nice/go-livr" {
				return dep.Version
			}
		}
	}
	return "unknown"
}

func main() {
	suiteDir := os.Getenv("TEST_SUITE_DIR")
	if suiteDir == "" {
		suiteDir = "../../test_suite"
	}

	res := result{ID: "go", Package: "github.com/k33nice/go-livr", Version: moduleVersion(), Source: "go", Failures: []failure{}}

	for _, suite := range []string{"positive", "negative", "aliases_positive", "aliases_negative"} {
		entries, err := os.ReadDir(filepath.Join(suiteDir, suite))
		if err != nil {
			panic(err)
		}
		var names []string
		for _, e := range entries {
			if !strings.HasPrefix(e.Name(), ".") {
				names = append(names, e.Name())
			}
		}
		sort.Strings(names)

		for _, name := range names {
			res.Total++
			if msg := runCase(suite, filepath.Join(suiteDir, suite, name)); msg != "" {
				res.Failures = append(res.Failures, failure{Case: suite + "/" + name, Message: msg})
			} else {
				res.Passed++
			}
		}
	}

	out, _ := json.MarshalIndent(res, "", "  ")
	out = append(out, '\n')
	if path := os.Getenv("OUT_FILE"); path != "" {
		if err := os.WriteFile(path, out, 0o644); err != nil {
			panic(err)
		}
	} else {
		os.Stdout.Write(out)
	}
}
