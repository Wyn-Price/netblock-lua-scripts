local fluxNetwork = require("component").energy_device.getNetworkStats()
local influx = require("influx")

while true do
    influx.sendMetric(
        "flux_network_stats",
        { },
        {
            num_controllers = fluxNetwork.numControllers,
            num_senders = fluxNetwork.numPlug,
            num_recievers = fluxNetwork.numPoints,
            num_storage = fluxNetwork.numStorage,

            stored_energy = fluxNetwork.availableEnergy,
            max_energy = fluxNetwork.maxEnergy,

            tick_max_can_recieve = fluxNetwork.tickMaxRecieved,
            tick_max_can_send = fluxNetwork.tickMaxSent,
            tick_transferred = fluxNetwork.tickTransferred,
        }
    );
    -- Timeout for 20 seconds
    os.sleep(20)
end
