local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 900,
    height = 600,
    type   = "heatmap",
    theme  = "dark",
    title  = "Weekly CPU Usage (%)",
    footer = "Average CPU usage per hour block across the week.",
})

chart:addSeries({
    colorRamp  = "viridis",
    showValues = true,
    domainMin  = 0,
    domainMax  = 100,
    rowLabels  = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"},
    colLabels  = {"00-04", "04-08", "08-12", "12-16", "16-20", "20-24"},
    data = {
        {5,  10, 72, 68, 55, 20},
        {4,  12, 80, 75, 60, 18},
        {6,  11, 85, 78, 63, 22},
        {5,  10, 82, 76, 61, 19},
        {4,  13, 79, 70, 58, 25},
        {3,  8,  30, 28, 20, 15},
        {2,  6,  18, 15, 12, 10},
    },
})

chart:render("heatmap.png")
print("Done in:", os.clock())
