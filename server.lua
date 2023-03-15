    local component = require("component")
    local event = require("event")
    local m = component.modem -- get primary modem component
    m.open(2121)
    -- Send some message.
    m.broadcast(2122, "this is a test")
    -- Wait for a message from another network card.
    local _, _, from, port, _, message = event.pull("modem_message")
    print("Got a message from " .. from .. " on port " .. port .. ": " .. tostring(message))
