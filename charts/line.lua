local Canvas = require("luachart.canvas")
local Scale  = require("luachart.scale")
local Color  = require("luachart.color")

local LineChart = {}

function LineChart.render(chart, img, layout, theme)
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
    
    local scaleX = Scale.Linear({minX, maxX}, {layout.plotX, layout.plotX + layout.plotW})
    local scaleY = Scale.Linear({niceMinY, niceMaxY}, {layout.plotY + layout.plotH, layout.plotY})
    
    for _, tick in ipairs(yTicks) do
        local ty = scaleY:mapInt(tick)
        if ty >= layout.plotY and ty <= layout.plotY + layout.plotH then
            Canvas.drawLine(img, layout.plotX, ty, layout.plotX + layout.plotW, ty, theme.grid, 1)
            Canvas.drawString(img, Scale.format(tick), layout.plotX - 10, ty, theme.text, 2, "right", "center")
        end
    end
    
    if chart.xLabels then
        local numCategories = #chart.xLabels
        local groupWidth = layout.plotW / numCategories
        local maxWidth = groupWidth * 0.9
        for c = 1, numCategories do
            local tx = layout.plotX + (c - 1) * groupWidth + (groupWidth / 2)
            Canvas.drawLine(img, tx, layout.plotY + layout.plotH, tx, layout.plotY + layout.plotH + 5, theme.axis, 1)
            Canvas.drawString(img, chart.xLabels[c], tx, layout.plotY + layout.plotH + 10, theme.text, 2, "center", "top", maxWidth)
        end
    else
        local niceMinX, niceMaxX, xTicks = Scale.niceTicks(minX, maxX, 5)
        local maxWidth = #xTicks > 0 and (layout.plotW / #xTicks * 0.9) or nil
        for _, tick in ipairs(xTicks) do
            if tick >= minX and tick <= maxX then
                local tx = scaleX:mapInt(tick)
                Canvas.drawLine(img, tx, layout.plotY + layout.plotH, tx, layout.plotY + layout.plotH + 5, theme.axis, 1)
                Canvas.drawString(img, Scale.format(tick), tx, layout.plotY + layout.plotH + 10, theme.text, 2, "center", "top", maxWidth)
            end
        end
    end
    
    Canvas.drawLine(img, layout.plotX, layout.plotY + layout.plotH, layout.plotX + layout.plotW, layout.plotY + layout.plotH, theme.axis, 2)
    Canvas.drawLine(img, layout.plotX, layout.plotY, layout.plotX, layout.plotY + layout.plotH, theme.axis, 2)
    
    for i, series in ipairs(chart.series) do
        local col = Color.resolveSeries(series, i, theme)
        local pts = {}
        local numCategories = chart.xLabels and #chart.xLabels or 0
        local groupWidth = numCategories > 0 and (layout.plotW / numCategories) or 0

        for _, pt in ipairs(series.data) do
            local x = pt.x or pt[1]
            local y = pt.y or pt[2]
            
            local px
            if chart.xLabels then
                px = layout.plotX + (x - 1) * groupWidth + (groupWidth / 2)
            else
                px = scaleX:map(x)
            end
            
            table.insert(pts, {x = px, y = scaleY:map(y)})
        end
        
        for j = 1, #pts - 1 do
            Canvas.drawLine(img, pts[j].x, pts[j].y, pts[j+1].x, pts[j+1].y, col, series.thickness or 2)
        end
        
        if series.markers ~= false then
            for j = 1, #pts do
                Canvas.fillCircle(img, pts[j].x, pts[j].y, 4, theme.background)
                Canvas.strokeCircle(img, pts[j].x, pts[j].y, 4, col)
                Canvas.strokeCircle(img, pts[j].x, pts[j].y, 3, col)
            end
        end
    end
end

return LineChart
