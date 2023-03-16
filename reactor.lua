local reactor = require("component").br_reactor
local influx = require("influx")

local config = require("reactor_config")
while true do
    influx.sendMetric(
        "reactor_stats",
        {
            reactor = config.name
        },
        {
            energy_stored = reactor.getEnergyStored(),
            fuel_temp = reactor.getFuelTemperature(),
            casing_temp = reactor.getCasingTemperature(),
            fuel_contained = reactor.getFuelAmount(),
            waste_contained = reactor.getWasteAmount(),
            containing_max = reactor.getFuelAmountMax(),
            fuel_reactivity = reactor.getFuelReactivity(),
            energy_produced = reactor.getEnergyProducedLastTick(),
        }
    );
    -- Timeout for 20 seconds
    os.sleep(20)
end
