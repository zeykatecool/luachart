local Canvas = require("luachart.canvas")
local Scale  = require("luachart.scale")
local Color  = require("luachart.color")

local ScatterChart = {}

function ScatterChart.render(chart, img, layout, theme)
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    
    for _, series in ipairs(chart.series) do
        for _, pt in ipairs(series.data) do
            local x = pt.x or pt[1]
            local y = pt.y or pt[2]
            if x < minX then minX = x end
            if x > maxX then maxX = x end
            if y < minY then minY = y end
            if y > maxY then maxY = y end
        end
    end
    
    if minX == math.huge then return end
    
    local niceMinY, niceMaxY, yTicks = Scale.niceTicks(minY, maxY, 5)
    local niceMinX, niceMaxX, xTicks = Scale.niceTicks(minX, maxX, 5)
    
    local scaleX = Scale.Linear({niceMinX, niceMaxX}, {layout.plotX, layout.plotX + layout.plotW})
    local scaleY = Scale.Linear({niceMinY, niceMaxY}, {layout.plotY + layout.plotH, layout.plotY})
    
    for _, tick in ipairs(yTicks) do
        local ty = scaleY:mapInt(tick)
        if ty >= layout.plotY and ty <= layout.plotY + layout.plotH then
            Canvas.drawLine(img, layout.plotX, ty, layout.plotX + layout.plotW, ty, theme.grid, 1)
            Canvas.drawString(img, Scale.format(tick), layout.plotX - 10, ty, theme.text, 2, "right", "center")
        end
    end
    
    local maxWidth = #xTicks > 0 and (layout.plotW / #xTicks * 0.9) or nil
    for _, tick in ipairs(xTicks) do
        local tx = scaleX:mapInt(tick)
        if tx >= layout.plotX and tx <= layout.plotX + layout.plotW then
            Canvas.drawLine(img, tx, layout.plotY, tx, layout.plotY + layout.plotH, theme.grid, 1)
            Canvas.drawString(img, Scale.format(tick), tx, layout.plotY + layout.plotH + 10, theme.text, 2, "center", "top", maxWidth)
        end
    end
    
    Canvas.drawLine(img, layout.plotX, layout.plotY + layout.plotH, layout.plotX + layout.plotW, layout.plotY + layout.plotH, theme.axis, 2)
    Canvas.drawLine(img, layout.plotX, layout.plotY, layout.plotX, layout.plotY + layout.plotH, theme.axis, 2)
    
    for i, series in ipairs(chart.series) do
        local col = Color.resolveSeries(series, i, theme)
        local markerSize = series.markerSize or 4
        local markerType = series.markerType or "circle"
        
        for _, pt in ipairs(series.data) do
            local x = pt.x or pt[1]
            local y = pt.y or pt[2]
            local tx = scaleX:mapInt(x)
            local ty = scaleY:mapInt(y)
            
            if markerType == "circle" then
                Canvas.fillCircle(img, tx, ty, markerSize, col)
            elseif markerType == "cross" then
                Canvas.drawLine(img, tx - markerSize, ty - markerSize, tx + markerSize, ty + markerSize, col, 2)
                Canvas.drawLine(img, tx - markerSize, ty + markerSize, tx + markerSize, ty - markerSize, col, 2)
            elseif markerType == "diamond" then
                Canvas.drawLine(img, tx, ty - markerSize, tx + markerSize, ty, col, 2)
                Canvas.drawLine(img, tx + markerSize, ty, tx, ty + markerSize, col, 2)
                Canvas.drawLine(img, tx, ty + markerSize, tx - markerSize, ty, col, 2)
                Canvas.drawLine(img, tx - markerSize, ty, tx, ty - markerSize, col, 2)
            end
        end
    end
end

return ScatterChart
