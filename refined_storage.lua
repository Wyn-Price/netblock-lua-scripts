local rs = require("component").block_refinedstorage_cable
local influx = require("influx")

while true do
    local nodes = rs.getStorageNodes()

    stored = {
        [true] = { ["items"] = 0, ["fluids"] = 0 },
        [false] = { ["items"] = 0, ["fluids"] = 0 },
    }

    capacity = {
        [true] = { ["items"] = 0, ["fluids"] = 0 },
        [false] = { ["items"] = 0, ["fluids"] = 0 },
    }

    for i, node in ipairs(nodes) do
        stored[node.external][node.type] = stored[node.external][node.type] + node.stored
        capacity[node.external][node.type] = capacity[node.external][node.type] + node.capacity
    end

    for i, external in ipairs({ false, true }) do
        for i, type in ipairs({ "items", "fluids" }) do
            print(type, external, stored[external][type], capacity[external][type])

            influx.sendMetric(
                "storage_capacity",
                {
                    type = type,
                    external = tostring(external),
                },
                {
                    stored = stored[external][type],
                    capacity = capacity[external][type],
                }
            );
        end
    end

    -- Timeout for 20 seconds
    os.sleep(20)
end
