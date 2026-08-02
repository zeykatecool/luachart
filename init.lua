local Image      = require("luaPNG.init")
local Layout     = require("luachart.layout")
local Color      = require("luachart.color")
local Canvas     = require("luachart.canvas")
local Font       = require("luachart.font")

local ChartTypes = {
    line      = require("luachart.charts.line"),
    bar       = require("luachart.charts.bar"),
    scatter   = require("luachart.charts.scatter"),
    histogram = require("luachart.charts.histogram"),
    heatmap   = require("luachart.charts.heatmap"),
}

local Chart      = {}
local Chart_mt   = { __index = Chart }

function Chart.new(options)
    options          = options or {}
    local self       = setmetatable({}, Chart_mt)

    self.width       = options.width or 800
    self.height      = options.height or 600
    self.theme       = Color.themes[options.theme] or Color.themes.dark
    self.title       = options.title
    self.titleAlign  = options.titleAlign
    self.xlabel      = options.xlabel
    self.ylabel      = options.ylabel
    self.footer      = options.footer or options.subtext or options.note or options.caption or options.footerText
    self.footerAlign = options.footerAlign or "center"
    self.legend      = options.legend ~= false

    self.type        = options.type or "line"
    self.series      = {}
    self.xLabels     = options.xLabels

    local defaultTop = 60
    if self.title and (self.title ~= "") and self.legend then
        defaultTop = 75
    elseif (self.title and self.title ~= "") or self.legend then
        defaultTop = 60
    end

    local defaultBottom = 70
    if self.footer and (self.footer ~= "") then
        defaultBottom = 80
    end

    self.padding = options.padding or { top = defaultTop, right = 40, bottom = defaultBottom, left = 110 }

    return self
end

function Chart:addSeries(options)
    table.insert(self.series, {
        label      = options.label or ("Series " .. (#self.series + 1)),
        data       = options.data or {},
        color      = options.color,
        markerSize = options.markerSize,
        markerType = options.markerType,
        thickness  = options.thickness,
        rowLabels  = options.rowLabels,
        colLabels  = options.colLabels,
        colorRamp  = options.colorRamp,
        showValues = options.showValues,
        valueScale = options.valueScale,
        format     = options.format,
        domainMin  = options.domainMin,
        domainMax  = options.domainMax,
        cellGap    = options.cellGap,
    })
    return self
end

function Chart:render(path)
    local basePadding = self.padding or { top = 60, right = 40, bottom = 70, left = 110 }
    local plotW = self.width - (basePadding.left or 110) - (basePadding.right or 40)

    local header = Layout.computeHeader(self, plotW)
    local footerInfo = Layout.computeFooter(self, plotW)

    local padding = {
        top    = math.max(basePadding.top or 60, header.height),
        right  = basePadding.right or 40,
        bottom = math.max(basePadding.bottom or 70, footerInfo.height),
        left   = basePadding.left or 110,
    }

    local img = Image.new(self.width, self.height, "rgba")

    Canvas.fillRect(img, 0, 0, self.width, self.height, self.theme.background)

    local layout = Layout.compute(self.width, self.height, padding)

    Canvas.fillRect(img, layout.plotX, layout.plotY, layout.plotW, layout.plotH, self.theme.plot_bg)

    if ChartTypes[self.type] then
        ChartTypes[self.type].render(self, img, layout, self.theme)
    else
        error("Unsupported chart type: " .. tostring(self.type))
    end

    local hasTitle = (self.title and self.title ~= "")
    local hasLegend = (self.legend and #self.series > 0)

    if hasTitle then
        local titleX, alignX
        if self.titleAlign then
            alignX = self.titleAlign
            if alignX == "center" then
                titleX = math.floor(layout.plotX + layout.plotW / 2)
            elseif alignX == "right" then
                titleX = layout.plotX + layout.plotW
            else
                titleX = layout.plotX
            end
        else
            titleX = layout.plotX
            alignX = "left"
        end

        Canvas.drawStringLines(
            img, header.titleLines, titleX, header.titleY,
            self.theme.title, header.titleScale, alignX, 4
        )
    end

    if hasLegend then
        local legY = header.legendY
        local startX = layout.plotX
        local maxX = layout.plotX + layout.plotW

        for _, row in ipairs(header.legendRows) do
            local legX = startX
            for _, item in ipairs(row.items) do
                local series = self.series[item.index]
                local itemWidth = 15 + Font.stringWidth(item.label, 2)

                if legX + itemWidth > maxX then
                    break
                end

                local col = Color.resolveSeries(series, item.index, self.theme)
                Canvas.fillRect(img, legX, legY + 2, 10, 10, col)
                Canvas.drawString(img, item.label, legX + 15, legY, self.theme.text, 2, "left", "top")
                legX = legX + itemWidth + 25
            end
            legY = legY + 20
        end
    end

    if self.xlabel then
        Canvas.drawString(img, self.xlabel, layout.xlabelX, layout.xlabelY, self.theme.title, 2, "center", "bottom")
    end

    if self.ylabel then
        Canvas.drawTextRotated(img, self.ylabel, layout.ylabelX, layout.ylabelY, self.theme.title, 2, "center", "center")
    end

    if footerInfo.lines and #footerInfo.lines > 0 then
        local fAlign = self.footerAlign or "center"
        local fx
        if fAlign == "left" then
            fx = layout.plotX
        elseif fAlign == "right" then
            fx = layout.plotX + layout.plotW
        else
            fx = layout.footerX
        end

        local lineH = Font.charHeight(1) + 2
        local startY = layout.footerY - (#footerInfo.lines - 1) * lineH
        for i, line in ipairs(footerInfo.lines) do
            Canvas.drawString(
                img, line, fx, startY + (i - 1) * lineH,
                self.theme.subtitle or self.theme.text, 1, fAlign, "bottom"
            )
        end
    end

    img:save(path)
end

return Chart
