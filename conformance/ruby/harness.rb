# Runs the LIVR test suite against the "ruby-livr" gem.
# Comparison mirrors ruby-livr's own specs (RSpec eq, i.e. ==):
# "1" != 1, but 1 == 1.0; key order does not matter.
require 'json'
require 'time'
require 'livr'

SUITE_DIR = ENV.fetch('TEST_SUITE_DIR', '../../test_suite')
SUITES = %w[positive negative aliases_positive aliases_negative].freeze
# LIVR 2.5: schemas that must not build
SCHEMA_ERRORS = 'schema_errors'.freeze

# LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
# tomorrow. ruby-livr reads Time.now; its specs fix it with travel_to of ActiveSupport (a
# dependency of the gem), so the harness does the same. Without TimeHelpers the case runs as is
begin
  require 'active_support'
  require 'active_support/testing/time_helpers'
  class Clock
    include ActiveSupport::Testing::TimeHelpers
  end
rescue LoadError
  Clock = nil
end

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

def with_clock(options)
  now = options && options['now']
  return yield if now.nil? || Clock.nil?
  Clock.new.travel_to(Time.iso8601(now)) { yield }
end

def build_validator(dir)
  validator = LIVR::Validator.new(read_json(dir, 'rules'))
  (read_json(dir, 'aliases') || []).each { |a| validator.register_aliased_rule(a) }
  validator
end

def run_schema_error_case(dir)
  begin
    validator = build_validator(dir)
    validator.respond_to?(:prepare) ? validator.prepare : validator.validate({})
  rescue StandardError, ScriptError
    return nil
  end
  'expected building the validator to fail'
end

def run_validation_case(suite, dir)
  input = read_json(dir, 'input')
  validator = build_validator(dir)

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

def run_case(suite, dir)
  with_clock(read_json(dir, 'options')) do
    suite == SCHEMA_ERRORS ? run_schema_error_case(dir) : run_validation_case(suite, dir)
  end
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

suites = File.directory?(File.join(SUITE_DIR, SCHEMA_ERRORS)) ? SUITES + [SCHEMA_ERRORS] : SUITES

suites.each do |suite|
  suite_dir = File.join(SUITE_DIR, suite)
  names = Dir.children(suite_dir).reject { |n| n.start_with?('.') }.sort
  names.select { |n| File.directory?(File.join(suite_dir, n)) }.each do |name|
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
