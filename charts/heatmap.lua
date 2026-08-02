local Canvas = require("luachart.canvas")
local Color = require("luachart.color")
local Font = require("luachart.font")

local HeatmapChart = {}


local RAMPS = {
    hot       = { low = { 20, 0, 0 }, high = { 255, 220, 100 } },
    cool      = { low = { 10, 10, 80 }, high = { 80, 230, 255 } },
    viridis   = { low = { 68, 1, 84 }, high = { 253, 231, 37 } },
    plasma    = { low = { 13, 8, 135 }, high = { 240, 249, 33 } },
    blues     = { low = { 222, 235, 247 }, high = { 8, 81, 156 } },
    greens    = { low = { 229, 245, 224 }, high = { 0, 109, 44 } },
    reds      = { low = { 254, 229, 217 }, high = { 165, 15, 21 } },
    diverging = { low = { 69, 117, 180 }, mid = { 255, 255, 255 }, high = { 215, 48, 39 } },
    greys     = { low = { 240, 240, 240 }, high = { 30, 30, 30 } },
}

local function rampColor(ramp, t)
    t = math.max(0, math.min(1, t))
    if ramp.mid then
        if t <= 0.5 then
            return Color.interpolate(ramp.low, ramp.mid, t * 2)
        else
            return Color.interpolate(ramp.mid, ramp.high, (t - 0.5) * 2)
        end
    end
    return Color.interpolate(ramp.low, ramp.high, t)
end

local function resolveRamp(opt)
    if type(opt) == "string" then
        return RAMPS[opt] or RAMPS.hot
    elseif type(opt) == "table" and opt.low and opt.high then
        return opt
    end
    return RAMPS.hot
end


local function autoFormat(v)
    if v == 0 then return "0" end
    local av = math.abs(v)
    if av >= 1000 then
        return string.format("%.0f", v)
    elseif av >= 100 then
        return string.format("%.0f", v)
    elseif av >= 10 then
        return string.format("%.1f", v)
    elseif av >= 1 then
        return string.format("%.2f", v)
    elseif av >= 0.01 then
        return string.format("%.3f", v)
    else
        return string.format("%.1e", v)
    end
end


function HeatmapChart.render(chart, img, layout, theme)
    if #chart.series == 0 then return end
    local series = chart.series[1]

    local grid = series.data or {}
    local nRows = #grid
    if nRows == 0 then return end
    local nCols = #grid[1]
    if nCols == 0 then return end

    local rowLabels  = series.rowLabels
    local colLabels  = series.colLabels
    local showVals   = (series.showValues ~= false)
    local valScale   = series.valueScale or 1
    local fmtStr     = series.format
    local cellGap    = series.cellGap or 1
    local ramp       = resolveRamp(series.colorRamp or "hot")

    local dMin, dMax = series.domainMin, series.domainMax
    if not dMin or not dMax then
        local mn, mx = math.huge, -math.huge
        for r = 1, nRows do
            for c = 1, nCols do
                local v = grid[r][c]
                if type(v) == "number" then
                    if v < mn then mn = v end
                    if v > mx then mx = v end
                end
            end
        end
        if mn == math.huge then
            mn = 0; mx = 1
        end
        if mn == mx then
            mn = mn - 1; mx = mx + 1
        end
        dMin = dMin or mn
        dMax = dMax or mx
    end
    local dSpan = dMax - dMin
    if dSpan == 0 then dSpan = 1 end

    local labelPad  = 4
    local charH     = Font.charHeight(2)

    local rowLabelW = 0
    if rowLabels then
        for _, lbl in ipairs(rowLabels) do
            local w = Font.stringWidth(tostring(lbl), 2)
            if w > rowLabelW then rowLabelW = w end
        end
        rowLabelW = rowLabelW + labelPad * 2
    end

    local colLabelH   = colLabels and (charH + labelPad * 2) or 0

    local colorBarW   = 14
    local colorBarPad = 20

    local cellAreaX   = layout.plotX + rowLabelW
    local cellAreaY   = layout.plotY + colLabelH
    local cellAreaW   = layout.plotW - rowLabelW - colorBarPad - colorBarW
    local cellAreaH   = layout.plotH - colLabelH

    local cellW       = math.floor((cellAreaW - math.max(0, nCols - 1) * cellGap) / nCols)
    local cellH       = math.floor((cellAreaH - math.max(0, nRows - 1) * cellGap) / nRows)
    if cellW < 1 then cellW = 1 end
    if cellH < 1 then cellH = 1 end

    for r = 1, nRows do
        for c = 1, nCols do
            local v = grid[r][c]
            if type(v) == "number" then
                local t   = (v - dMin) / dSpan
                local col = rampColor(ramp, t)

                local cx  = cellAreaX + (c - 1) * (cellW + cellGap)
                local cy  = cellAreaY + (r - 1) * (cellH + cellGap)
                Canvas.fillRect(img, cx, cy, cellW, cellH, col)

                if showVals and cellW >= 8 and cellH >= 8 then
                    local label
                    if fmtStr then
                        label = string.format(fmtStr, v)
                    else
                        label = autoFormat(v)
                    end

                    local lum    = col[1] * 0.299 + col[2] * 0.587 + col[3] * 0.114
                    local txtCol = lum > 128
                        and { 20, 20, 20, 210 }
                        or { 230, 230, 230, 210 }

                    local tw     = Font.stringWidth(label, valScale)
                    local th     = Font.charHeight(valScale)
                    if tw <= cellW - 2 and th <= cellH - 2 then
                        Canvas.drawString(
                            img, label,
                            cx + cellW / 2, cy + cellH / 2,
                            txtCol, valScale, "center", "center"
                        )
                    end
                end
            end
        end
    end

    if rowLabels then
        for r = 1, math.min(#rowLabels, nRows) do
            local lbl = tostring(rowLabels[r] or "")
            local cy  = cellAreaY + (r - 1) * (cellH + cellGap) + cellH / 2
            Canvas.drawString(
                img, lbl,
                cellAreaX - labelPad, cy,
                theme.text, 2, "right", "center"
            )
        end
    end

    if colLabels then
        for c = 1, math.min(#colLabels, nCols) do
            local lbl = tostring(colLabels[c] or "")
            local cx  = cellAreaX + (c - 1) * (cellW + cellGap) + cellW / 2
            Canvas.drawString(
                img, lbl,
                cx, cellAreaY - labelPad,
                theme.text, 2, "center", "bottom"
            )
        end
    end

    local cbX = cellAreaX + cellAreaW + colorBarPad - colorBarW
    local cbY = cellAreaY
    local cbH = nRows * cellH + math.max(0, nRows - 1) * cellGap
    if cbH < 4 then cbH = 4 end

    for py = 0, cbH - 1 do
        local t   = 1 - py / math.max(cbH - 1, 1)
        local col = rampColor(ramp, t)
        for px = 0, colorBarW - 1 do
            img:setPixel(cbX + px, cbY + py, col[1], col[2], col[3], 255)
        end
    end

    Canvas.strokeRect(img, cbX, cbY, colorBarW, cbH, theme.axis)

    local tbX = cbX + colorBarW + 3
    local function cbTick(val, py)
        Canvas.drawString(img, autoFormat(val), tbX, cbY + py, theme.text, 1, "left", "center")
    end
    cbTick(dMax, 0)
    cbTick((dMin + dMax) / 2, math.floor(cbH / 2))
    cbTick(dMin, cbH)

    local gridW = nCols * cellW + math.max(0, nCols - 1) * cellGap
    local gridH = nRows * cellH + math.max(0, nRows - 1) * cellGap
    Canvas.strokeRect(img, cellAreaX, cellAreaY, gridW, gridH, theme.axis)
end

HeatmapChart.ramps = {}
for k in pairs(RAMPS) do
    HeatmapChart.ramps[#HeatmapChart.ramps + 1] = k
end
table.sort(HeatmapChart.ramps)

return HeatmapChart
