// Runs the LIVR test suite against io.github.vlbaluk:validator-livr (Maven Central).
// java-validator-livr's own tests use JSONAssert in lenient mode (extra fields
// allowed, array order ignored). This harness is stricter on structure, because
// dropping unknown fields and keeping list order are part of the specification,
// but compares numbers by value (json-simple parses 1 as Long and 1.0 as Double).
import livr.LIVR;
import livr.Validator;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import org.json.simple.parser.JSONParser;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
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

    static String show(Object value) {
        String s = JSONValue.toJSONString(value);
        return s.length() > 300 ? s.substring(0, 300) + "…" : s;
    }

    static String runCase(String suite, File dir) throws Exception {
        JSONObject rules = (JSONObject) readJson(dir, "rules");
        JSONObject input = (JSONObject) readJson(dir, "input");
        JSONArray aliases = (JSONArray) readJson(dir, "aliases");

        Validator validator = LIVR.validator().init(rules, false);
        if (aliases != null) {
            for (Object alias : aliases) validator.registerAliasedRule((JSONObject) alias);
        }

        JSONObject output = validator.validate(input);
        JSONObject errors = validator.getErrors();
        boolean hasErrors = errors != null && !errors.isEmpty();

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

        for (String suite : new String[] {"positive", "negative", "aliases_positive", "aliases_negative"}) {
            String[] names = new File(suiteDir, suite).list((d, n) -> !n.startsWith("."));
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
