local Font = require("luachart.font")

local Layout = {}

local TITLE_SCALE       = 3
local TITLE_LINE_GAP    = 4
local TITLE_MAX_LINES   = 3
local LEGEND_SCALE      = 2
local LEGEND_ROW_HEIGHT = 20
local LEGEND_ITEM_GAP   = 25
local LEGEND_SWATCH_W   = 15
local FOOTER_SCALE      = 1
local FOOTER_LINE_GAP   = 2

function Layout.computeHeader(chart, plotW)
    local header = {
        titleLines  = {},
        titleScale  = TITLE_SCALE,
        titleY      = 12,
        legendRows  = {},
        legendY     = 12,
        height      = 12,
    }

    local cursorY = 12

    if chart.title and chart.title ~= "" then
        local lines = Font.wrapText(chart.title, plotW, TITLE_SCALE)
        if #lines > TITLE_MAX_LINES then
            local trimmed = {}
            for i = 1, TITLE_MAX_LINES - 1 do
                trimmed[i] = lines[i]
            end
            trimmed[TITLE_MAX_LINES] = Font.truncate(lines[TITLE_MAX_LINES], plotW, TITLE_SCALE)
            lines = trimmed
        end

        header.titleLines = lines
        header.titleY = cursorY
        cursorY = cursorY + #lines * (Font.charHeight(TITLE_SCALE) + TITLE_LINE_GAP) + 6
    end

    if chart.legend and #chart.series > 0 then
        local rows = {}
        local row = { items = {} }
        local rowWidth = 0

        for i, series in ipairs(chart.series) do
            local label = series.label or ("Series " .. i)
            local textW = Font.stringWidth(label, LEGEND_SCALE)
            local itemW = LEGEND_SWATCH_W + textW

            if itemW > plotW then
                label = Font.truncate(label, plotW - LEGEND_SWATCH_W, LEGEND_SCALE)
                itemW = LEGEND_SWATCH_W + Font.stringWidth(label, LEGEND_SCALE)
            end

            local gap = rowWidth > 0 and LEGEND_ITEM_GAP or 0
            if rowWidth + gap + itemW > plotW and #row.items > 0 then
                rows[#rows + 1] = row
                row = { items = {} }
                rowWidth = 0
                gap = 0
            end

            row.items[#row.items + 1] = { index = i, label = label }
            rowWidth = rowWidth + gap + itemW
        end

        if #row.items > 0 then
            rows[#rows + 1] = row
        end

        header.legendRows = rows
        header.legendY = cursorY
        cursorY = cursorY + #rows * LEGEND_ROW_HEIGHT + 6
    end

    header.height = math.max(cursorY, 40)
    return header
end

function Layout.computeFooter(chart, plotW)
    if not chart.footer or chart.footer == "" then
        return { lines = {}, height = 0 }
    end

    local lines = Font.wrapText(chart.footer, plotW, FOOTER_SCALE)
    local height = #lines * (Font.charHeight(FOOTER_SCALE) + FOOTER_LINE_GAP) + 16
    return { lines = lines, height = height }
end

function Layout.compute(width, height, padding)
    local t = padding.top    or 75
    local r = padding.right  or 40
    local b = padding.bottom or 70
    local l = padding.left   or 110

    local plotX = l
    local plotY = t
    local plotW = width  - l - r
    local plotH = height - t - b

    return {
        width   = width,
        height  = height,
        plotX   = plotX,
        plotY   = plotY,
        plotW   = plotW,
        plotH   = plotH,
        xlabelX = math.floor(plotX + plotW / 2),
        xlabelY = height - (b >= 75 and 30 or 20),
        ylabelX = math.max(20, math.floor(l * 0.2)),
        ylabelY = math.floor(plotY + plotH / 2),
        footerX = math.floor(plotX + plotW / 2),
        footerY = height - 10,
    }
end

return Layout
