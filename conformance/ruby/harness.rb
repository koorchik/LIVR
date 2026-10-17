# Runs the LIVR test suite against the "ruby-livr" gem.
# Comparison mirrors ruby-livr's own specs (RSpec eq, i.e. ==):
# "1" != 1, but 1 == 1.0; key order does not matter.
require 'json'
require 'livr'

SUITE_DIR = ENV.fetch('TEST_SUITE_DIR', '../../test_suite')
SUITES = %w[positive negative aliases_positive aliases_negative].freeze

def read_json(dir, name)
  file = File.join(dir, "#{name}.json")
  File.exist?(file) ? JSON.parse(File.read(file, encoding: 'utf-8')) : nil
end

def show(value)
  s = begin
    JSON.generate(value)
  rescue StandardError
    value.inspect
  end
  s.length > 300 ? "#{s[0, 300]}…" : s
end

def run_case(suite, dir)
  rules = read_json(dir, 'rules')
  input = read_json(dir, 'input')
  aliases = read_json(dir, 'aliases') || []

  validator = LIVR::Validator.new(rules)
  aliases.each { |a| validator.register_aliased_rule(a) }

  output = validator.validate(input)
  errors = validator.get_errors

  if suite.end_with?('positive')
    expected = read_json(dir, 'output')
    return "expected no errors, got #{show(errors)}" if errors && !errors.empty?
    return "expected output #{show(expected)}, got #{show(output)}" unless output == expected
  else
    expected = read_json(dir, 'errors')
    return "expected validation to fail, got output #{show(output)}" if output
    return "expected errors #{show(expected)}, got #{show(errors)}" unless errors == expected
  end
  nil
end

result = {
  id: 'ruby',
  package: 'ruby-livr',
  version: Gem.loaded_specs['ruby-livr'].version.to_s,
  source: 'rubygems',
  total: 0,
  passed: 0,
  failures: [],
  error: nil
}

SUITES.each do |suite|
  suite_dir = File.join(SUITE_DIR, suite)
  Dir.children(suite_dir).reject { |n| n.start_with?('.') }.sort.each do |name|
    result[:total] += 1
    message = begin
      run_case(suite, File.join(suite_dir, name))
    rescue StandardError, ScriptError => e
      "exception: #{e.class}: #{e.message}"
    end
    if message
      result[:failures] << { case: "#{suite}/#{name}", message: message }
    else
      result[:passed] += 1
    end
  end
end

out = JSON.pretty_generate(result) + "\n"
if ENV['OUT_FILE']
  File.write(ENV['OUT_FILE'], out)
else
  print out
end
