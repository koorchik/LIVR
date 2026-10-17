-- Runs the LIVR test suite against the "lua-livr" rock.
-- Comparison mirrors lua-LIVR's own test/02-livr_test_suite.lua (Test.Assertion
-- `same` on dkjson-decoded data): deep equality with ==, so 1 == 1.0 but
-- "1" ~= 1; key order does not matter.
local livr   = require 'LIVR'
local lfs    = require 'lfs'
local dkjson = require 'dkjson'

local suite_dir = os.getenv('TEST_SUITE_DIR') or '../../test_suite'
local suites = { 'positive', 'negative', 'aliases_positive', 'aliases_negative' }

local function read_json (dir, name)
    local f = io.open(dir .. '/' .. name .. '.json')
    if not f then return nil end
    local content = f:read('*a')
    f:close()
    return assert(dkjson.decode(content))
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

local function run_case (suite, dir)
    local rules   = read_json(dir, 'rules')
    local input   = read_json(dir, 'input')
    local aliases = read_json(dir, 'aliases') or {}

    local validator = livr.new(rules)
    for i = 1, #aliases do
        validator:register_aliased_rule(aliases[i])
    end

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

local result = {
    id = 'lua', package = 'lua-livr', version = livr._VERSION, source = 'luarocks',
    total = 0, passed = 0, failures = setmetatable({}, { __jsontype = 'array' }), error = dkjson.null,
}

for _, suite in ipairs(suites) do
    local names = {}
    for name in lfs.dir(suite_dir .. '/' .. suite) do
        if name:sub(1, 1) ~= '.' then names[#names + 1] = name end
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
