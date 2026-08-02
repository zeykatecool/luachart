# Chart Rendering Library for Lua / LuaJIT

- Renders charts to PNG files using `luaPNG` as the backend.
- Written in pure Lua with no external dependencies beyond `luaPNG`.
- Supports line, bar, scatter, histogram, and heatmap chart types.
- Provides built-in dark and light themes.
- Supports multiple data series per chart with automatic color assignment.
- Check the `examples/output` for rendered images.

# Requirements

- `luaPNG` must be available and loadable as `luaPNG.init`.

# Usage

- Check the `examples` folder for more examples.

```lua
local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 800,
    height = 600,
    type   = "line",
    theme  = "dark",
    title  = "My Chart",
    xlabel = "X Axis",
    ylabel = "Y Axis",
})

chart:addSeries({
    label = "Series A",
    data  = {1, 4, 2, 8, 5, 7},
})

chart:render("output.png")
```

```lua
-- Scatter chart with two series.
local Chart = require("luachart.init")

local chart = Chart.new({
    width = 900,
    height = 600,
    type  = "scatter",
    title = "Scatter Example",
})

chart:addSeries({
    label      = "Group A",
    markerType = "circle",
    markerSize = 5,
    data = {
        {x = 1, y = 2}, {x = 3, y = 4}, {x = 5, y = 1},
    },
})

chart:addSeries({
    label      = "Group B",
    markerType = "diamond",
    data = {
        {x = 2, y = 5}, {x = 4, y = 3}, {x = 6, y = 6},
    },
})

chart:render("scatter.png")
```

```lua
-- Heatmap chart.
local Chart = require("luachart.init")

local chart = Chart.new({
    width  = 800,
    height = 600,
    type   = "heatmap",
    title  = "Heatmap Example",
})

chart:addSeries({
    colorRamp  = "viridis",
    showValues = true,
    rowLabels  = {"Row A", "Row B", "Row C"},
    colLabels  = {"Jan", "Feb", "Mar"},
    data = {
        {10, 20, 30},
        {40, 50, 60},
        {70, 80, 90},
    },
})

chart:render("heatmap.png")
```

# Chart Options

These are the options accepted by `Chart.new`.

| Option        | Default     | Description                                              |
|---------------|-------------|----------------------------------------------------------|
| `width`       | `800`       | Image width in pixels.                                   |
| `height`      | `600`       | Image height in pixels.                                  |
| `type`        | `"line"`    | Chart type. See chart types section below.               |
| `theme`       | `"dark"`    | Color theme. `"dark"` or `"light"`.                      |
| `title`       | `nil`       | Chart title text.                                        |
| `titleAlign`  | `"left"`    | Title alignment. `"left"`, `"center"`, or `"right"`.     |
| `xlabel`      | `nil`       | Label for the X axis.                                    |
| `ylabel`      | `nil`       | Label for the Y axis.                                    |
| `footer`      | `nil`       | Footer text rendered below the chart. Also accepts `subtext`, `note`, `caption`, `footerText`. |
| `footerAlign` | `"center"`  | Footer alignment. `"left"`, `"center"`, or `"right"`.   |
| `legend`      | `true`      | Set to `false` to hide the legend.                       |
| `xLabels`     | `nil`       | Table of strings used as X axis category labels.         |
| `padding`     | auto        | Table `{top, right, bottom, left}` to override margins.  |

# Series Options

These are the options accepted by `Chart:addSeries`.

| Option       | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `label`      | Series name shown in the legend.                                            |
| `data`       | Table of values. Format depends on chart type.                              |
| `color`      | RGBA table, e.g. `{255, 100, 100, 255}`. Overrides theme color.            |
| `markerSize` | Marker radius in pixels. Used by scatter charts. Default is `4`.           |
| `markerType` | Marker shape. `"circle"`, `"cross"`, or `"diamond"`. Default is `"circle"`. |
| `thickness`  | Line thickness in pixels. Used by line charts.                              |
| `rowLabels`  | Table of row label strings. Used by heatmap.                                |
| `colLabels`  | Table of column label strings. Used by heatmap.                             |
| `colorRamp`  | Color ramp name or table. Used by heatmap. See ramps section below.        |
| `showValues` | If `true`, draws value text inside each cell. Used by heatmap.             |
| `valueScale` | Font scale for value text inside cells. Used by heatmap.                   |
| `format`     | Format string passed to `string.format` for cell values. Used by heatmap.  |
| `domainMin`  | Minimum value for color mapping. Used by heatmap.                           |
| `domainMax`  | Maximum value for color mapping. Used by heatmap.                           |
| `cellGap`    | Pixel gap between cells. Used by heatmap. Default is `1`.                  |

# Chart Types

| Type        | Data Format                                                            |
|-------------|------------------------------------------------------------------------|
| `line`      | Flat array of numbers. `{1, 2, 3, 4}`                                 |
| `bar`       | Flat array of numbers. `{1, 2, 3, 4}`                                 |
| `scatter`   | Array of `{x, y}` pairs or tables with `.x` and `.y` fields.          |
| `histogram` | Flat array of numbers. The chart computes bins automatically.          |
| `heatmap`   | 2D array (array of rows, each row is an array of numbers).             |

# Heatmap Color Ramps

The heatmap chart supports the following built-in color ramps for the `colorRamp` option:

- `hot`
- `cool`
- `viridis`
- `plasma`
- `blues`
- `greens`
- `reds`
- `diverging`
- `greys`

You can also pass a custom ramp as a table:

```lua
colorRamp = { low = {0, 0, 128}, high = {255, 128, 0} }
-- or with a midpoint:
colorRamp = { low = {0, 0, 200}, mid = {255, 255, 255}, high = {200, 0, 0} }
```

# Themes

| Theme   | Description                        |
|---------|------------------------------------|
| `dark`  | Dark background with bright series colors. Default. |
| `light` | Light background with darker series colors.         |

# License

- MIT License
