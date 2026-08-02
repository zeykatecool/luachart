local Canvas = require("luachart.canvas")
local Scale = require("luachart.scale")
local Color = require("luachart.color")

local HistogramChart = {}

function HistogramChart.render(chart, img, layout, theme)
    local data = chart.series[1] and chart.series[1].data or {}
    if #data == 0 then return end

    local minVal, maxVal = math.huge, -math.huge
    for _, v in ipairs(data) do
        if v < minVal then minVal = v end
        if v > maxVal then maxVal = v end
    end

    if minVal == maxVal then
        minVal = minVal - 1
        maxVal = maxVal + 1
    end

    local binCount = chart.bins or math.ceil(math.log(#data) / math.log(2)) + 1
    local binWidth = (maxVal - minVal) / binCount

    local bins = {}
    for i = 1, binCount do bins[i] = 0 end

    for _, v in ipairs(data) do
        local binIdx = math.floor((v - minVal) / binWidth) + 1
        if binIdx > binCount then binIdx = binCount end
        bins[binIdx] = bins[binIdx] + 1
    end

    local maxFreq = 0
    for _, f in ipairs(bins) do
        if f > maxFreq then maxFreq = f end
    end

    local niceMinY, niceMaxY, yTicks = Scale.niceTicks(0, maxFreq, 5)
    local scaleY = Scale.Linear({ niceMinY, niceMaxY }, { layout.plotY + layout.plotH, layout.plotY })

    local niceMinX, niceMaxX, xTicks = Scale.niceTicks(minVal, maxVal, binCount)
    local scaleX = Scale.Linear({ minVal, maxVal }, { layout.plotX, layout.plotX + layout.plotW })

    for _, tick in ipairs(yTicks) do
        local ty = scaleY:mapInt(tick)
        if ty >= layout.plotY and ty <= layout.plotY + layout.plotH then
            Canvas.drawLine(img, layout.plotX, ty, layout.plotX + layout.plotW, ty, theme.grid, 1)
            Canvas.drawString(img, Scale.format(tick), layout.plotX - 10, ty, theme.text, 2, "right", "center")
        end
    end

    local zeroY = scaleY:mapInt(0)
    local col = Color.resolveSeries(chart.series[1], 1, theme)

    for i = 1, binCount do
        local bMin = minVal + (i - 1) * binWidth
        local bMax = minVal + i * binWidth

        local bx1 = scaleX:mapInt(bMin)
        local bx2 = scaleX:mapInt(bMax)

        local freq = bins[i]
        local by = scaleY:mapInt(freq)

        Canvas.fillRect(img, bx1, by, bx2 - bx1 - 1, zeroY - by, col)

        Canvas.drawLine(img, bx1, layout.plotY + layout.plotH, bx1, layout.plotY + layout.plotH + 5, theme.axis, 1)
        Canvas.drawString(img, Scale.format(bMin), bx1, layout.plotY + layout.plotH + 10, theme.text, 2, "center", "top")
    end

    Canvas.drawLine(img, layout.plotX, layout.plotY + layout.plotH, layout.plotX + layout.plotW,
    layout.plotY + layout.plotH, theme.axis, 2)
    Canvas.drawLine(img, layout.plotX, layout.plotY, layout.plotX, layout.plotY + layout.plotH, theme.axis, 2)
end

return HistogramChart
