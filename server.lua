local component = require("component")
local event = require("event")
local internet = require("internet")
local secrets = require("secrets")

local modem = component.modem

local IN_PORT_REQUEST_ADDRESS = 9001;
local IN_PORT_SEND_INFLUX = 9002;

local OUT_PORT_SEND_ADDRESS = 8001;

function openPorts()
    print("Opening ports...")
    modem.open(IN_PORT_REQUEST_ADDRESS)
    modem.open(IN_PORT_SEND_INFLUX)
    print("Ports opened")
end

function broadcastAddress()
    print("Broadcasting address")
    modem.broadcast(OUT_PORT_SEND_ADDRESS);
end

function sendToInflux(line)
    local handle = internet.request(
        "http://localhost:8086/api/v2/write?org=netblock&bucket=minecraft",
        line,
        { Authorization = "Token " .. secrets.apiToken },
        "POST"
    )

    local result = ""
    for chunk in handle do
        result = result .. chunk
    end
    -- We need to read the result so the request get's GC'd properly
    -- ideally we would print this out if it's not empty
    if result == "invalid" then
        print("invalid")
    end
end

function processPacket()
    local _, _, from, port, _, message = event.pull("modem_message")
    if port == IN_PORT_REQUEST_ADDRESS then
        broadcastAddress()
    elseif port == IN_PORT_SEND_INFLUX then
        print(message)
        local _, err = pcall(function() sendToInflux(message) end)
        if err then
            print("Encountered an error when sending to influx")
            print(err)
        end
    end
end

openPorts()
broadcastAddress()

while true do
    processPacket()
end
