local component = require("component")
local event = require("event")

local modem = component.modem

local OUT_PORT_REQUEST_ADDRESS = 9001
local OUT_PORT_SEND_INFLUX = 9002

local IN_PORT_SEND_ADDRESS = 8001


print("Attempting to find server...")
modem.open(IN_PORT_SEND_ADDRESS)
modem.broadcast(OUT_PORT_REQUEST_ADDRESS)
local _, _, from = event.pull("modem_message")
local serverAddress = from;
print("Server address found at " .. from)

local M = {}

function M.sendMetric(metric, tags, values)
    print("Sending metric to ")
    local text = lineProtocol(metric, tags, values)
    modem.send(serverAddress, OUT_PORT_SEND_INFLUX, text)
end

function lineProtocol(metric, tags, values)
    local result = formatMetric(metric)

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
    local res = part:gsub("([, =])", "\\%1")
    return res
end

function formatValue(value)
    local type = type(value)
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
    local res = metric:gsub("([, ])", "\\%1")
    return res
end

return M
