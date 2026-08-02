local Canvas = require("luachart.canvas")
local Scale = require("luachart.scale")
local Color = require("luachart.color")

local BarChart = {}

function BarChart.render(chart, img, layout, theme)
    local numCategories = 0
    local minY, maxY = 0, -math.huge

    for _, series in ipairs(chart.series) do
        if #series.data > numCategories then
            numCategories = #series.data
        end
        for _, val in ipairs(series.data) do
            local y = type(val) == "table" and (val.y or val[2]) or val
            if y < minY then minY = y end
            if y > maxY then maxY = y end
        end
    end

    if numCategories == 0 then return end

    local numSeries = #chart.series
    local niceMinY, niceMaxY, yTicks = Scale.niceTicks(minY, maxY, 5)
    local scaleY = Scale.Linear({ niceMinY, niceMaxY }, { layout.plotY + layout.plotH, layout.plotY })

    for _, tick in ipairs(yTicks) do
        local ty = scaleY:mapInt(tick)
        if ty >= layout.plotY and ty <= layout.plotY + layout.plotH then
            Canvas.drawLine(img, layout.plotX, ty, layout.plotX + layout.plotW, ty, theme.grid, 1)
            Canvas.drawString(img, Scale.format(tick), layout.plotX - 10, ty, theme.text, 2, "right", "center")
        end
    end

    local groupWidth = layout.plotW / numCategories
    local barWidth = (groupWidth * 0.8) / numSeries
    local barPadding = barWidth * 0.1
    local maxWidth = groupWidth * 0.9

    local zeroY = scaleY:mapInt(0)

    for c = 1, numCategories do
        local groupX = layout.plotX + (c - 1) * groupWidth + (groupWidth * 0.1)

        local label = chart.xLabels and chart.xLabels[c] or tostring(c)
        Canvas.drawString(img, label, groupX + (groupWidth * 0.4), layout.plotY + layout.plotH + 10, theme.text, 2,
            "center", "top", maxWidth)

        for s, series in ipairs(chart.series) do
            local val = series.data[c]
            if val then
                local y = type(val) == "table" and (val.y or val[2]) or val
                local barY = scaleY:mapInt(y)
                local bx = groupX + (s - 1) * barWidth + barPadding
                local bw = barWidth - barPadding * 2

                local col = Color.resolveSeries(series, s, theme)

                local startY = zeroY
                local endY = barY
                if startY < endY then startY, endY = endY, startY end

                Canvas.fillRect(img, bx, endY, bw, startY - endY, col)
            end
        end
    end

    Canvas.drawLine(img, layout.plotX, layout.plotY + layout.plotH, layout.plotX + layout.plotW,
        layout.plotY + layout.plotH, theme.axis, 2)
    Canvas.drawLine(img, layout.plotX, layout.plotY, layout.plotX, layout.plotY + layout.plotH, theme.axis, 2)
end

return BarChart
