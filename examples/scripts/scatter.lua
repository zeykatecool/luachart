local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 800,
    height = 600,
    type   = "scatter",
    theme  = "dark",
    title  = "Height vs Weight",
    xlabel = "Height (cm)",
    ylabel = "Weight (kg)",
})

math.randomseed(os.clock()^os.time())

local function group(cx, cy, n, spread)
    local pts = {}
    for _ = 1, n do
        pts[#pts + 1] = {
            x = cx + (math.random() - 0.5) * spread,
            y = cy + (math.random() - 0.5) * spread * 0.4,
        }
    end
    return pts
end

chart:addSeries({
    label      = "Group A",
    markerType = "circle",
    markerSize = 4,
    data       = group(170, 70, 30, 20),
})

chart:addSeries({
    label      = "Group B",
    markerType = "diamond",
    markerSize = 5,
    data       = group(185, 85, 25, 18),
})

chart:addSeries({
    label      = "Group C",
    markerType = "cross",
    markerSize = 5,
    data       = group(158, 58, 20, 16),
})

chart:render("scatter.png")
print("Done in:", os.clock())
