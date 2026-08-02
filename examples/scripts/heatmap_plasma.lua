local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 900,
    height = 600,
    type   = "heatmap",
    theme  = "dark",
    title  = "Monthly Sales Performance",
    footer = "Sales heatmap showing performance across different regions.",
})

chart:addSeries({
    colorRamp  = "plasma",
    showValues = true,
    domainMin  = 0,
    domainMax  = 1000,
    rowLabels  = {"North", "South", "East", "West", "Central"},
    colLabels  = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
    data = {
        {120, 150, 180, 200, 300, 450, 500, 480, 400, 350, 250, 300},
        {80,  90,  110, 150, 250, 320, 340, 310, 280, 200, 150, 180},
        {200, 220, 250, 300, 450, 600, 650, 620, 500, 450, 350, 400},
        {150, 170, 200, 250, 380, 500, 550, 520, 450, 380, 280, 320},
        {100, 120, 140, 180, 280, 400, 430, 410, 350, 280, 200, 220},
    },
})

chart:render("heatmap_plasma.png")
print("Done in:", os.clock())
