local internet = require("internet")
local secrets = require("secrets")
local M = {};

function M.sendMetric(metric, tags, values)
    local handle = internet.request(
        "http://localhost:8086/api/v2/write?org=netblock&bucket=minecraft",
        lineProtocol(metric, tags, values),
        { Authorization = "Token " .. secrets.apiToken },
        "POST"
    )

    local result = ""
    for chunk in handle do
        result = result .. chunk
    end
    print(result)
end

function lineProtocol(metric, tags, values)
    local result = formatMetric(metric);

    -- Start with empty string to add a , after the metric
    local tagParts = {''}
    for k,v in pairs(tags) do
        local part = formatPart(k) .. "=" .. formatPart(v)
        table.insert(tagParts, part)
    end
    result = result .. table.concat(tagParts, ",")

    local valueParts = {}
    for k,v in pairs(values) do
        local part = formatPart(k) .. "=" .. formatValue(v)
        table.insert(valueParts, part)
    end
    result = result .. ' ' .. table.concat(valueParts, ",")

    return result
end

function formatPart(part)
    local res = part:gsub("([, =])", "\\%1");
    return res
end

function formatValue(value)
    local type = type(value)
    print(res)
    -- Types: nil, boolean, number, string, userdata, function, thread, and table
    if type == "boolean" then
        return value and "TRUE" or "FALSE"
    elseif type == "number" then
        -- If we don't set the decimal places, influx will complain about mixing "integers" and "floats"
        return string.format("%.5f",value)
    elseif type == "string" then
        return '"' .. value .. '"'
    else
        error("Don't know how to handle " .. value .. " (" .. type .. ")")
    end
end

-- Replace , and spaces with \%1
function formatMetric(metric)
    local res = metric:gsub("([, ])", "\\%1");
    return res
end

return M;
