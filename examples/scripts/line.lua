local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 800,
    height = 500,
    type   = "line",
    theme  = "dark",
    title  = "Monthly Revenue",
    xlabel = "Month",
    ylabel = "Revenue (USD)",
    xLabels = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
})

chart:addSeries({
    label = "2023",
    data = {
        {x = 1, y = 12000}, {x = 2,  y = 15000}, {x = 3,  y = 13500},
        {x = 4, y = 17000}, {x = 5,  y = 19500}, {x = 6,  y = 22000},
        {x = 7, y = 21000}, {x = 8,  y = 24000}, {x = 9,  y = 22500},
        {x = 10, y = 26000}, {x = 11, y = 28000}, {x = 12, y = 31000},
    },
})

chart:addSeries({
    label = "2024",
    data = {
        {x = 1, y = 14000}, {x = 2,  y = 16500}, {x = 3,  y = 15000},
        {x = 4, y = 20000}, {x = 5,  y = 23000}, {x = 6,  y = 25500},
        {x = 7, y = 24000}, {x = 8,  y = 27500}, {x = 9,  y = 26000},
        {x = 10, y = 30000}, {x = 11, y = 33000}, {x = 12, y = 37000},
    },
})

chart:render("line.png")
print("Done in:", os.clock())
