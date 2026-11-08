-- Runs the LIVR test suite against the "lua-livr" rock.
-- Comparison mirrors lua-LIVR's own test/02-livr_test_suite.lua (Test.Assertion
-- `same` on dkjson-decoded data): deep equality with ==, so 1 == 1.0 but
-- "1" ~= 1; key order does not matter.
local livr   = require 'LIVR'
local lfs    = require 'lfs'
local dkjson = require 'dkjson'

local suite_dir = os.getenv('TEST_SUITE_DIR') or '../../test_suite'
local suites = { 'positive', 'negative', 'aliases_positive', 'aliases_negative' }
-- LIVR 2.5: schemas that must not build
local SCHEMA_ERRORS = 'schema_errors'

local function read_json (dir, name)
    local f = io.open(dir .. '/' .. name .. '.json')
    if not f then return nil end
    local content = f:read('*a')
    f:close()
    local data = assert(dkjson.decode(content))  -- one value: decode also returns a position
    return data
end

local function same (a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then
        return a == b
    end
    for k, v in pairs(a) do
        if not same(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

local function show (value)
    local ok, s = pcall(dkjson.encode, value)
    s = ok and s or tostring(value)
    if #s > 300 then s = s:sub(1, 300) .. '...' end
    return s
end

-- LIVR 2.5: options.json {"now": "..."} is the current time for the bounds today, yesterday and
-- tomorrow. lua-LIVR reads os.time(), so it is replaced while the case runs, like in lua-LIVR's own
-- test/11-livr_test_suite_2_5.lua, and restored after it
local os_time = os.time

local function parse_now (now)
    local year, month, day, hour, min, sec = tostring(now):match'^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)Z$'
    if not year then error('options.json: a wrong "now": ' .. show(now)) end
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    if month <= 2 then
        year = year - 1
        month = month + 12
    end
    -- days since 1970-01-01
    local days = 365 * year + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400)
               + math.floor((153 * (month - 3) + 2) / 5) + day - 719469
    return ((days * 24 + tonumber(hour)) * 60 + tonumber(min)) * 60 + tonumber(sec)
end

local function with_clock (options, fn, ...)
    if type(options) ~= 'table' or options.now == nil then return fn(...) end
    local epoch = parse_now(options.now)
    os.time = function (t)  -- luacheck: ignore 122
        if t then return os_time(t) end
        return epoch
    end
    local ok, message = pcall(fn, ...)
    os.time = os_time       -- luacheck: ignore 122
    if not ok then error(message, 0) end
    return message
end

local function new_validator (dir)
    local validator = livr.new(read_json(dir, 'rules'))
    local aliases = read_json(dir, 'aliases') or {}
    for i = 1, #aliases do
        validator:register_aliased_rule(aliases[i])
    end
    return validator
end

-- passes when building the validator fails (lua-LIVR raises an error); a version without
-- prepare() builds on the first validation
local function run_schema_error_case (dir)
    local ok = pcall(function ()
        local validator = new_validator(dir)
        if validator.prepare then
            validator:prepare()
        else
            validator:validate({})
        end
    end)
    if ok then return 'expected building the validator to fail' end
    return nil
end

local function run_validation_case (suite, dir)
    local input     = read_json(dir, 'input')
    local validator = new_validator(dir)

    local output, errors = validator:validate(input)

    if suite:match('positive$') then
        local expected = read_json(dir, 'output')
        if errors then return 'expected no errors, got ' .. show(errors) end
        if not same(output, expected) then
            return 'expected output ' .. show(expected) .. ', got ' .. show(output)
        end
    else
        local expected = read_json(dir, 'errors')
        if output then return 'expected validation to fail, got output ' .. show(output) end
        if not same(errors, expected) then
            return 'expected errors ' .. show(expected) .. ', got ' .. show(errors)
        end
    end
    return nil
end

local function run_case (suite, dir)
    local run = suite == SCHEMA_ERRORS and run_schema_error_case or function (d)
        return run_validation_case(suite, d)
    end
    return with_clock(read_json(dir, 'options'), run, dir)
end

local result = {
    id = 'lua', package = 'lua-livr', version = livr._VERSION, source = 'luarocks',
    total = 0, passed = 0, failures = setmetatable({}, { __jsontype = 'array' }), error = dkjson.null,
}

if lfs.attributes(suite_dir .. '/' .. SCHEMA_ERRORS, 'mode') == 'directory' then
    suites[#suites + 1] = SCHEMA_ERRORS
end

for _, suite in ipairs(suites) do
    local names = {}
    for name in lfs.dir(suite_dir .. '/' .. suite) do
        if name:sub(1, 1) ~= '.' and lfs.attributes(suite_dir .. '/' .. suite .. '/' .. name, 'mode') == 'directory' then
            names[#names + 1] = name
        end
    end
    table.sort(names)

    for _, name in ipairs(names) do
        result.total = result.total + 1
        local ok, message = pcall(run_case, suite, suite_dir .. '/' .. suite .. '/' .. name)
        if not ok then message = 'exception: ' .. tostring(message) end
        if message then
            result.failures[#result.failures + 1] = { case = suite .. '/' .. name, message = message }
        else
            result.passed = result.passed + 1
        end
    end
end

local out = dkjson.encode(result, { indent = true }) .. '\n'
local out_file = os.getenv('OUT_FILE')
if out_file then
    local f = assert(io.open(out_file, 'w'))
    f:write(out)
    f:close()
else
    io.write(out)
end
