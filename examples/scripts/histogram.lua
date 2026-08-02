local Chart = require("luachart.init")

-- Generate normally distributed samples using the Box-Muller transform.
math.randomseed(7)
local function normal(mean, std, n)
    local out = {}
    for i = 1, n do
        local u1 = math.random()
        local u2 = math.random()
        local z  = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
        out[i] = mean + z * std
    end
    return out
end

local chart = Chart.new({
    width  = 800,
    height = 500,
    type   = "histogram",
    theme  = "dark",
    title  = "Test Score Distribution",
    xlabel = "Score",
    ylabel = "Frequency",
})

chart:addSeries({
    label = "Scores",
    data  = normal(72, 12, 500),
})

chart:render("histogram.png")
print("Done in:", os.clock())
