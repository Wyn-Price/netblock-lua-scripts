influx = require("influx");
influx.sendMetric("metric", { tag = 'reactor' }, { value = 'value' })
