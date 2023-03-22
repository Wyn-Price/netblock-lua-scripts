
local component = require("component")
local redstone = component.redstone

redstone.setWakeThreshold(1)

local modem = component.modem
while true do
    modem.broadcast(7777, "netblock:wakeup")
    os.sleep(5)
end
