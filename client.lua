    local component = require("component")
    local event = require("event")
    local m = component.modem -- get primary modem component
    m.open(2122)
    local _, _, from, port, _, message = event.pull("modem_message")
    print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
