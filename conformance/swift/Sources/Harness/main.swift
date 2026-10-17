// Runs the LIVR test suite against livr-swift-validator.
//
// Comparison mirrors the library's own tests (NSDictionary.isEqual): numbers
// are compared by value, strings exactly, key order does not matter.
// Each case runs in a child process, because the library can hit a fatalError
// (e.g. NSPredicate(format:) is unavailable in Foundation on Linux), which
// would otherwise abort the whole run.
import Foundation
import Livr

let suites = ["positive", "negative", "aliases_positive", "aliases_negative"]

func readJSON(_ dir: String, _ name: String) -> Any? {
    let path = dir + "/" + name + ".json"
    guard let data = FileManager.default.contents(atPath: path) else { return nil }
    return try! JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
}

func unwrap(_ value: Any?) -> Any? {
    guard let value = value else { return nil }
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        return mirror.children.first.map { unwrap($0.value) } ?? nil
    }
    return value
}

func number(_ value: Any) -> Double? {
    if value is Bool { return nil }
    switch value {
    case let n as Int: return Double(n)
    case let n as Double: return n
    case let n as Float: return Double(n)
    case let n as Decimal: return NSDecimalNumber(decimal: n).doubleValue
    case let n as NSNumber: return n.doubleValue
    default: return nil
    }
}

func same(_ a: Any?, _ b: Any?) -> Bool {
    let a = unwrap(a), b = unwrap(b)
    let aNull = a == nil || a is NSNull, bNull = b == nil || b is NSNull
    if aNull || bNull { return aNull && bNull }
    let x = a!, y = b!

    if let dx = x as? [String: Any?], let dy = y as? [String: Any?] {
        guard dx.count == dy.count else { return false }
        for (k, v) in dx {
            guard let w = dy[k], same(v, w) else { return false }
        }
        return true
    }
    if let lx = x as? [Any?], let ly = y as? [Any?] {
        return lx.count == ly.count && zip(lx, ly).allSatisfy { same($0, $1) }
    }
    if let bx = x as? Bool, let by = y as? Bool { return bx == by }
    if let nx = number(x), let ny = number(y) { return nx == ny }
    if let sx = x as? String, let sy = y as? String { return sx == sy }
    return false
}

func jsonable(_ value: Any?) -> Any {
    let value = unwrap(value)
    switch value {
    case nil: return NSNull()
    case let d as [String: Any?]: return d.mapValues { jsonable($0) }
    case let l as [Any?]: return l.map { jsonable($0) }
    case let s as String: return s
    case let b as Bool: return b
    default:
        if let n = number(value!) { return n }
        return String(describing: value!)
    }
}

func show(_ value: Any?) -> String {
    let obj = jsonable(value)
    var s: String
    if JSONSerialization.isValidJSONObject(obj),
       let data = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]) {
        s = String(decoding: data, as: UTF8.self)
    } else {
        s = String(describing: obj)
    }
    if s.count > 300 { s = String(s.prefix(300)) + "…" }
    return s
}

// Runs one case in this process and returns a failure message (nil = passed).
func runCase(suite: String, dir: String) -> String? {
    guard let rules = readJSON(dir, "rules") as? [String: Any?],
          let input = readJSON(dir, "input") as? [String: Any?] else {
        return "could not load case files"
    }
    let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
    if let aliases = readJSON(dir, "aliases") as? [[String: Any?]] {
        do { try validator.registerRule(aliases: aliases) } catch { return "exception: \(error)" }
    }

    let output: Validator.Output?
    do { output = try validator.validate(data: input) } catch { return "exception: \(error)" }
    let errors = validator.errors

    if suite.hasSuffix("positive") {
        let expected = readJSON(dir, "output")
        if let errors = errors, !errors.isEmpty { return "expected no errors, got " + show(errors) }
        if !same(expected, output) { return "expected output \(show(expected)), got \(show(output))" }
    } else {
        let expected = readJSON(dir, "errors")
        if output != nil { return "expected validation to fail, got output " + show(output) }
        if !same(expected, errors) { return "expected errors \(show(expected)), got \(show(errors))" }
    }
    return nil
}

let args = CommandLine.arguments
if args.count == 4 && args[1] == "--case" {
    let message = runCase(suite: args[2], dir: args[3])
    let data = try! JSONSerialization.data(withJSONObject: ["message": message as Any? ?? NSNull()], options: [])
    FileHandle.standardOutput.write(data)
    exit(0)
}

let env = ProcessInfo.processInfo.environment
let suiteDir = env["TEST_SUITE_DIR"] ?? "../../test_suite"
var failures: [[String: Any]] = []
var total = 0, passed = 0

for suite in suites {
    let names = try! FileManager.default.contentsOfDirectory(atPath: suiteDir + "/" + suite)
        .filter { !$0.hasPrefix(".") }.sorted()
    for name in names {
        total += 1
        let child = Process()
        child.executableURL = URL(fileURLWithPath: args[0])
        child.arguments = ["--case", suite, suiteDir + "/" + suite + "/" + name]
        let stdout = Pipe(), stderr = Pipe()
        child.standardOutput = stdout
        child.standardError = stderr
        try! child.run()
        let outData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errData = stderr.fileHandleForReading.readDataToEndOfFile()
        child.waitUntilExit()

        var message: String?
        if child.terminationStatus == 0,
           let parsed = try? JSONSerialization.jsonObject(with: outData),
           let obj = parsed as? [String: Any] {
            message = obj["message"] as? String
        } else {
            let lines = String(decoding: errData, as: UTF8.self)
                .split(separator: "\n").filter { $0.contains("Fatal error") || $0.contains("error:") }
            message = "crashed: " + (lines.first.map(String.init) ?? "exit status \(child.terminationStatus)")
        }

        if let message = message {
            failures.append(["case": suite + "/" + name, "message": message])
        } else {
            passed += 1
        }
    }
}

let result: [String: Any] = [
    "id": "swift",
    "package": "livr-swift-validator",
    "version": env["LIVR_VERSION"] ?? "unknown",
    "source": "git",
    "total": total,
    "passed": passed,
    "failures": failures,
    "error": NSNull(),
]
var out = try! JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
out.append(0x0A)
if let path = env["OUT_FILE"] {
    FileManager.default.createFile(atPath: path, contents: out)
} else {
    FileHandle.standardOutput.write(out)
}
