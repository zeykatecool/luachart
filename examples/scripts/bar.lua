local Chart = require("luachart.init")

local chart = Chart.new({
    width   = 800,
    height  = 500,
    type    = "bar",
    theme   = "dark",
    title   = "Quarterly Sales by Region",
    xlabel  = "Quarter",
    ylabel  = "Units Sold",
    xLabels = {"Q1", "Q2", "Q3", "Q4"},
})

chart:addSeries({
    label = "North",
    data  = {340, 420, 390, 510},
})

chart:addSeries({
    label = "South",
    data  = {280, 310, 350, 400},
})

chart:addSeries({
    label = "East",
    data  = {410, 460, 480, 530},
})

chart:render("bar.png")
print("Done in:", os.clock())
