// Runs the LIVR test suite against io.github.vlbaluk:validator-livr (Maven Central).
// java-validator-livr's own tests use JSONAssert in lenient mode (extra fields
// allowed, array order ignored). This harness is stricter on structure, because
// dropping unknown fields and keeping list order are part of the specification,
// but compares numbers by value (json-simple parses 1 as Long and 1.0 as Double).
// The library returns every error as {"code": …, "fieldValue": …} instead of a plain
// error code, and its own copy of the test suite expects that format, so the harness
// compares only the codes.
import livr.LIVR;
import livr.Validator;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import org.json.simple.parser.JSONParser;

import java.io.File;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Harness {
    static Object readJson(File dir, String name) throws Exception {
        Path file = dir.toPath().resolve(name + ".json");
        if (!Files.exists(file)) return null;
        return new JSONParser().parse(Files.readString(file, StandardCharsets.UTF_8));
    }

    static boolean same(Object a, Object b) {
        if (a == null || b == null) return a == b;
        if (a instanceof Map && b instanceof Map) {
            Map<?, ?> ma = (Map<?, ?>) a, mb = (Map<?, ?>) b;
            if (ma.size() != mb.size()) return false;
            for (Map.Entry<?, ?> e : ma.entrySet()) {
                if (!mb.containsKey(e.getKey()) || !same(e.getValue(), mb.get(e.getKey()))) return false;
            }
            return true;
        }
        if (a instanceof List && b instanceof List) {
            List<?> la = (List<?>) a, lb = (List<?>) b;
            if (la.size() != lb.size()) return false;
            for (int i = 0; i < la.size(); i++) {
                if (!same(la.get(i), lb.get(i))) return false;
            }
            return true;
        }
        if (a instanceof Number && b instanceof Number) {
            return ((Number) a).doubleValue() == ((Number) b).doubleValue();
        }
        return a.equals(b);
    }

    // Replaces {"code": …, "fieldValue": …} errors, also nested ones, with their codes.
    static Object codes(Object errors) {
        if (errors instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) errors;
            if (map.size() == 2 && map.containsKey("fieldValue") && map.get("code") instanceof String) {
                return map.get("code");
            }
            JSONObject result = new JSONObject();
            for (Map.Entry<?, ?> e : map.entrySet()) result.put(e.getKey(), codes(e.getValue()));
            return result;
        }
        if (errors instanceof List) {
            JSONArray result = new JSONArray();
            for (Object item : (List<?>) errors) result.add(codes(item));
            return result;
        }
        return errors;
    }

    static String show(Object value) {
        String s = JSONValue.toJSONString(value);
        return s.length() > 300 ? s.substring(0, 300) + "…" : s;
    }

    // LIVR 2.5: schemas that must not build
    static final String SCHEMA_ERRORS = "schema_errors";

    // LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
    // tomorrow. validator-livr with LIVR 2.5 takes it as Validator.setClock(Clock), like its own
    // tests, set before the validator is prepared. It is called by reflection, so the harness also
    // runs against 2.0.x, which has no clock: there the case runs with the system time.
    static void setClock(Validator validator, File dir) throws Exception {
        JSONObject options = (JSONObject) readJson(dir, "options");
        if (options == null || options.get("now") == null) return;
        Clock clock = Clock.fixed(Instant.parse((String) options.get("now")), ZoneOffset.UTC);
        Method setClock;
        try {
            setClock = Validator.class.getMethod("setClock", Clock.class);
        } catch (NoSuchMethodException e) {
            return;
        }
        setClock.invoke(validator, clock);
    }

    static Validator buildValidator(File dir) throws Exception {
        JSONObject rules = (JSONObject) readJson(dir, "rules");
        JSONArray aliases = (JSONArray) readJson(dir, "aliases");

        Validator validator = LIVR.validator();
        setClock(validator, dir);
        validator.init(rules, false);
        if (aliases != null) {
            for (Object alias : aliases) validator.registerAliasedRule((JSONObject) alias);
        }
        return validator;
    }

    // The library reports a wrong schema with an exception (IllegalArgumentException in 2.5) from
    // prepare(), which validate() also calls on the first validation.
    static String runSchemaErrorCase(File dir) {
        try {
            buildValidator(dir).prepare();
        } catch (Throwable e) {
            return null;
        }
        return "expected building the validator to fail";
    }

    static String runCase(String suite, File dir) throws Exception {
        if (suite.equals(SCHEMA_ERRORS)) return runSchemaErrorCase(dir);

        JSONObject input = (JSONObject) readJson(dir, "input");
        Validator validator = buildValidator(dir);

        JSONObject output = validator.validate(input);
        Object errors = codes(validator.getErrors());
        boolean hasErrors = errors != null && !((Map<?, ?>) errors).isEmpty();

        if (suite.endsWith("positive")) {
            Object expected = readJson(dir, "output");
            if (hasErrors) return "expected no errors, got " + show(errors);
            if (!same(expected, output)) return "expected output " + show(expected) + ", got " + show(output);
        } else {
            Object expected = readJson(dir, "errors");
            if (output != null) return "expected validation to fail, got output " + show(output);
            if (!same(expected, errors)) return "expected errors " + show(expected) + ", got " + show(errors);
        }
        return null;
    }

    public static void main(String[] args) throws Exception {
        String suiteDir = System.getenv().getOrDefault("TEST_SUITE_DIR", "../../test_suite");

        List<Map<String, Object>> failures = new ArrayList<>();
        int total = 0, passed = 0;

        List<String> suites = new ArrayList<>(List.of("positive", "negative", "aliases_positive", "aliases_negative"));
        if (new File(suiteDir, SCHEMA_ERRORS).isDirectory()) suites.add(SCHEMA_ERRORS);

        for (String suite : suites) {
            String[] names = new File(suiteDir, suite).list((d, n) -> !n.startsWith(".") && new File(d, n).isDirectory());
            Arrays.sort(names);
            for (String name : names) {
                total++;
                String message;
                try {
                    message = runCase(suite, new File(new File(suiteDir, suite), name));
                } catch (Throwable e) {
                    message = "exception: " + e;
                }
                if (message != null) {
                    Map<String, Object> f = new LinkedHashMap<>();
                    f.put("case", suite + "/" + name);
                    f.put("message", message);
                    failures.add(f);
                } else {
                    passed++;
                }
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", "java");
        result.put("package", "io.github.vlbaluk:validator-livr");
        result.put("version", System.getenv().getOrDefault("LIVR_VERSION", "unknown"));
        result.put("source", "maven");
        result.put("total", total);
        result.put("passed", passed);
        result.put("failures", failures);
        result.put("error", null);

        String out = JSONValue.toJSONString(result) + "\n";
        String outFile = System.getenv("OUT_FILE");
        if (outFile != null) Files.writeString(Path.of(outFile), out, StandardCharsets.UTF_8);
        else System.out.print(out);
    }
}
