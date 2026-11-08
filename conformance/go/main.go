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
	"reflect"
	"runtime/debug"
	"sort"
	"strconv"
	"strings"
	"time"

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

// LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
// tomorrow. go-livr with LIVR 2.5 takes the clock as Options.Now (func() time.Time), like its own
// tests. The field is set by reflection, so the harness also compiles against go-livr v2.0.0,
// which has no clock: there the case runs with the system time.
func newOptions(rules map[string]interface{}, dir string) *livr.Options {
	opts := &livr.Options{LivrRules: rules}
	var options struct {
		Now *string `json:"now"`
	}
	if !readJSON(dir, "options", &options) || options.Now == nil {
		return opts
	}
	now, err := time.Parse(time.RFC3339, *options.Now)
	if err != nil {
		panic(fmt.Sprintf("options.json: a wrong \"now\": %q", *options.Now))
	}
	clock := func() time.Time { return now }
	if field := reflect.ValueOf(opts).Elem().FieldByName("Now"); field.IsValid() && field.CanSet() &&
		field.Type() == reflect.TypeOf(clock) {
		field.Set(reflect.ValueOf(clock))
	}
	return opts
}

func newValidator(dir string) *livr.Validator {
	var rules map[string]interface{}
	var aliases []livr.Alias
	readJSON(dir, "rules", &rules)
	readJSON(dir, "aliases", &aliases)

	v := livr.New(newOptions(rules, dir))
	for _, a := range aliases {
		v.RegisterAliasedRule(a)
	}
	return v
}

// LIVR 2.5: a schema that must not build. go-livr with LIVR 2.5 has Prepare() error (a
// *SchemaError); go-livr v2.0.0 builds the validator on the first Validate and panics on a wrong
// rule, so there the schema is validated with {} and a panic is the schema error. Field errors of
// that validation are not.
func runSchemaErrorCase(dir string) (message string) {
	defer func() {
		if r := recover(); r != nil {
			message = ""
		}
	}()

	v := newValidator(dir)
	if p, ok := interface{}(v).(interface{ Prepare() error }); ok {
		if p.Prepare() != nil {
			return ""
		}
	} else {
		v.Validate(livr.Dictionary{})
	}
	return "expected building the validator to fail"
}

func runCase(suite, dir string) (message string) {
	defer func() {
		if r := recover(); r != nil {
			message = fmt.Sprintf("exception: %v", r)
		}
	}()

	if suite == schemaErrors {
		return runSchemaErrorCase(dir)
	}

	var input map[string]interface{}
	readJSON(dir, "input", &input)
	v := newValidator(dir)

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

// LIVR 2.5: schemas that must not build
const schemaErrors = "schema_errors"

func moduleVersion() string {
	if info, ok := debug.ReadBuildInfo(); ok {
		for _, dep := range info.Deps {
			if dep.Path == "github.com/k33nice/go-livr" {
				if dep.Replace != nil {
					return "local"
				}
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

	suites := []string{"positive", "negative", "aliases_positive", "aliases_negative"}
	if info, err := os.Stat(filepath.Join(suiteDir, schemaErrors)); err == nil && info.IsDir() {
		suites = append(suites, schemaErrors)
	}

	for _, suite := range suites {
		entries, err := os.ReadDir(filepath.Join(suiteDir, suite))
		if err != nil {
			panic(err)
		}
		var names []string
		for _, e := range entries {
			if e.IsDir() && !strings.HasPrefix(e.Name(), ".") {
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
