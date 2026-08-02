-- Outputs results to CSV.

local Chart = require("luachart.init")

local ITERATIONS = 3
local WARMUP     = 1
local OUT        = "output/benchmark"
local CSV_PATH   = "output/benchmark_results.csv"
local SEED       = os.time()^os.clock()


local function memMB()
    collectgarbage("collect")
    return collectgarbage("count") / 1024
end

local function stats(t)
    if #t == 0 then return 0, 0, 0 end
    local sum, mn, mx = 0, t[1], t[1]
    for _, v in ipairs(t) do
        sum = sum + v
        if v < mn then mn = v end
        if v > mx then mx = v end
    end
    return mn, sum / #t, mx
end

local results = {}

local function bench(meta, fn)
    local name     = meta.name
    local category = meta.category or "general"
    local w        = meta.width  or 800
    local h        = meta.height or 600

    collectgarbage("collect")
    local memBefore = memMB()

    for _ = 1, WARMUP do
        local ok, err = pcall(fn)
        if not ok then
            io.write(string.format("  WARMUP FAIL [%s]: %s\n", name, tostring(err)))
            results[#results + 1] = {
                category = category, name = name, type = meta.type or "?",
                width = w, height = h, points = meta.points or 0, series = meta.series or 0,
                status = "FAIL", error = tostring(err),
            }
            return
        end
    end

    local times = {}
    for _ = 1, ITERATIONS do
        collectgarbage("collect")
        local t0 = os.clock()
        local ok, err = pcall(fn)
        local t1 = os.clock()
        if not ok then
            io.write(string.format("  FAIL [%s]: %s\n", name, tostring(err)))
            results[#results + 1] = {
                category = category, name = name, type = meta.type or "?",
                width = w, height = h, points = meta.points or 0, series = meta.series or 0,
                status = "FAIL", error = tostring(err),
            }
            return
        end
        times[#times + 1] = (t1 - t0) * 1000
    end

    collectgarbage("collect")
    local memDelta = memMB() - memBefore
    local minMs, avgMs, maxMs = stats(times)

    io.write(string.format(
        "  %-42s  avg %7.2f ms  [%6.2f / %6.2f]  mem %+6.2f MB\n",
        name, avgMs, minMs, maxMs, memDelta
    ))

    results[#results + 1] = {
        category = category, name = name, type = meta.type or "?",
        width = w, height = h, points = meta.points or 0, series = meta.series or 0,
        status = "OK",
        minMs = minMs, avgMs = avgMs, maxMs = maxMs,
        memDeltaMB = memDelta,
    }
end

local function section(title)
    io.write("\n" .. string.rep("-", 70) .. "\n")
    io.write("  " .. title .. "\n")
    io.write(string.rep("-", 70) .. "\n")
end


local function genLine(n, count, noise)
    count = count or 1; noise = noise or 10
    local all = {}
    for s = 1, count do
        local pts, v = {}, 400 + s * 30
        for i = 1, n do
            v = v + math.random(-noise, noise)
            pts[i] = { x = i, y = v }
        end
        all[s] = pts
    end
    return all
end

local function genScatter(n, count)
    count = count or 1
    local all = {}
    for s = 1, count do
        local pts, ox, oy = {}, (s - 1) * 300, (s - 1) * 200
        for i = 1, n do
            pts[i] = { x = ox + math.random(0, 400), y = oy + math.random(0, 400) }
        end
        all[s] = pts
    end
    return all
end

local function genHist(n)
    local d = {}
    for i = 1, n do
        d[i] = math.floor((math.random() + math.random() + math.random()) / 3 * 100)
    end
    return d
end

local function genBar(cats, count)
    cats = cats or 4; count = count or 2
    local all = {}
    for s = 1, count do
        local row = {}
        for c = 1, cats do row[c] = math.random(50, 500) end
        all[s] = row
    end
    return all
end

local function genHeat(rows, cols)
    local grid = {}
    for r = 1, rows do
        grid[r] = {}
        for c = 1, cols do
            local dr = (r - rows / 2) / (rows / 2)
            local dc = (c - cols / 2) / (cols / 2)
            grid[r][c] = math.exp(-(dr * dr + dc * dc) * 3) * 100 + math.random() * 15 - 7
        end
    end
    return grid
end

local function rLabels(n)
    local t = {}; for i = 1, n do t[i] = "R" .. i end; return t
end
local function cLabels(n)
    local t = {}; for i = 1, n do t[i] = "C" .. i end; return t
end


math.randomseed(SEED)

io.write("                       LUACHART BENCHMARK\n")
io.write(string.format("Lua: %s | Iterations: %d | Warmup: %d | Seed: %d\n",
    _VERSION, ITERATIONS, WARMUP, SEED))
if jit then io.write(string.format("LuaJIT: %s\n", jit.version)) end
io.write(string.format("Output: %s | CSV: %s\n", OUT, CSV_PATH))
io.write(string.rep("-", 70) .. "\n")


section("1. BASELINE  All chart types at 800x600")

bench(
    { category = "baseline", name = "Line (2 series x 50 pts)", type = "line", points = 100, series = 2 },
    function()
        local c = Chart.new({ type = "line", title = "Baseline Line" })
        local s = genLine(50, 2, 5)
        c:addSeries({ label = "A", data = s[1] })
         :addSeries({ label = "B", data = s[2] })
         :render(OUT .. "/baseline_line.png")
    end
)

bench(
    { category = "baseline", name = "Bar (4 cat x 2 series)", type = "bar", points = 4, series = 2 },
    function()
        local c = Chart.new({ type = "bar", title = "Baseline Bar", xLabels = {"Q1","Q2","Q3","Q4"} })
        local d = genBar(4, 2)
        c:addSeries({ label = "2023", data = d[1] })
         :addSeries({ label = "2024", data = d[2] })
         :render(OUT .. "/baseline_bar.png")
    end
)

bench(
    { category = "baseline", name = "Scatter (2 series x 100 pts)", type = "scatter", points = 200, series = 2 },
    function()
        local c = Chart.new({ type = "scatter", title = "Baseline Scatter" })
        local g = genScatter(100, 2)
        c:addSeries({ label = "A", data = g[1], markerType = "circle" })
         :addSeries({ label = "B", data = g[2], markerType = "cross" })
         :render(OUT .. "/baseline_scatter.png")
    end
)

bench(
    { category = "baseline", name = "Histogram (500 pts)", type = "histogram", points = 500, series = 1 },
    function()
        local c = Chart.new({ type = "histogram", title = "Baseline Histogram" })
        c:addSeries({ label = "Scores", data = genHist(500) })
         :render(OUT .. "/baseline_histogram.png")
    end
)

bench(
    { category = "baseline", name = "Heatmap 8x8 (hot ramp)", type = "heatmap", points = 64, series = 1 },
    function()
        local c = Chart.new({ type = "heatmap", title = "Baseline Heatmap" })
        c:addSeries({
            label      = "Grid",
            data       = genHeat(8, 8),
            rowLabels  = rLabels(8),
            colLabels  = cLabels(8),
            colorRamp  = "hot",
            showValues = true,
        })
        :render(OUT .. "/baseline_heatmap.png")
    end
)


section("2. HEATMAP  Color ramps & grid sizes")

local heatRamps = { "hot", "viridis", "plasma", "cool", "blues", "diverging" }
for _, ramp in ipairs(heatRamps) do
    local rampName = ramp
    bench(
        { category = "heatmap", name = string.format("Heatmap 12x12 (%s)", ramp), type = "heatmap", points = 144, series = 1 },
        function()
            local c = Chart.new({ type = "heatmap", title = "Heatmap: " .. rampName, theme = "dark" })
            c:addSeries({
                label     = rampName,
                data      = genHeat(12, 12),
                rowLabels = rLabels(12),
                colLabels = cLabels(12),
                colorRamp = rampName,
                cellGap   = 2,
            })
            :render(OUT .. "/heatmap_" .. rampName .. ".png")
        end
    )
end

bench(
    { category = "heatmap", name = "Heatmap 20x30 (viridis, no labels)", type = "heatmap", points = 600, series = 1 },
    function()
        local c = Chart.new({ width = 1000, height = 700, type = "heatmap",
            title = "Dense Heatmap 20x30" })
        c:addSeries({
            label      = "Grid",
            data       = genHeat(20, 30),
            colorRamp  = "viridis",
            showValues = false,
            cellGap    = 1,
        })
        :render(OUT .. "/heatmap_dense.png")
    end
)

bench(
    { category = "heatmap", name = "Heatmap 6x6 (values, light theme)", type = "heatmap", points = 36, series = 1 },
    function()
        local c = Chart.new({ type = "heatmap", title = "Heatmap Values", theme = "light" })
        c:addSeries({
            label      = "Grid",
            data       = genHeat(6, 6),
            rowLabels  = rLabels(6),
            colLabels  = cLabels(6),
            colorRamp  = "blues",
            showValues = true,
            format     = "%.1f",
            cellGap    = 2,
        })
        :render(OUT .. "/heatmap_values_light.png")
    end
)

section("3. RESOLUTION  Line chart at multiple resolutions")

local resolutions = {
    { 640, 480 }, { 800, 600 }, { 1280, 720 },
    { 1920, 1080 }, { 2560, 1440 }, { 3840, 2160 },
}

for _, res in ipairs(resolutions) do
    local rw, rh = res[1], res[2]
    bench(
        {
            category = "resolution",
            name     = string.format("Line %dx%d", rw, rh),
            type     = "line", width = rw, height = rh, points = 1500, series = 3,
        },
        function()
            local c = Chart.new({ width = rw, height = rh, type = "line",
                title = string.format("Resolution %dx%d", rw, rh) })
            local s = genLine(500, 3, 10)
            for i = 1, 3 do c:addSeries({ label = "Ch " .. i, data = s[i], thickness = 2 }) end
            c:render(string.format("%s/res_line_%dx%d.png", OUT, rw, rh))
        end
    )
end


section("4. DENSITY  Point count scaling (line chart)")

local densities = { 50, 200, 500, 1000, 2500, 5000, 10000, 25000 }

for _, n in ipairs(densities) do
    bench(
        {
            category = "density",
            name     = string.format("Line %d pts x 3 series", n),
            type     = "line", points = n * 3, series = 3,
        },
        function()
            local c = Chart.new({ type = "line", title = string.format("Density %d pts/series", n) })
            local s = genLine(n, 3, 12)
            for i = 1, 3 do c:addSeries({ label = "S" .. i, data = s[i] }) end
            c:render(string.format("%s/density_line_%d.png", OUT, n))
        end
    )
end

bench(
    { category = "density", name = "Scatter 5000 markers", type = "scatter", points = 5000, series = 1 },
    function()
        local c = Chart.new({ type = "scatter", title = "Scatter 5k" })
        c:addSeries({ label = "Cloud", data = genScatter(5000, 1)[1], markerType = "circle" })
         :render(OUT .. "/density_scatter_5k.png")
    end
)

bench(
    { category = "density", name = "Histogram 50k samples", type = "histogram", points = 50000, series = 1 },
    function()
        local c = Chart.new({ width = 1200, height = 800, type = "histogram", title = "Histogram 50k" })
        c:addSeries({ label = "Dist", data = genHist(50000) })
         :render(OUT .. "/density_hist_50k.png")
    end
)



section("5. STRESS  Heavy workloads")

bench(
    {
        category = "stress", name = "4K Line (4 series x 2000 pts)",
        type = "line", width = 3840, height = 2160, points = 8000, series = 4,
    },
    function()
        local c = Chart.new({
            width = 3840, height = 2160, type = "line", theme = "dark",
            title = "Ultra-HD 4K Benchmark",
        })
        for s = 1, 4 do
            local pts = {}
            for i = 1, 2000 do
                pts[i] = { x = i, y = math.sin(i / 50 + s) * 200 + 300 + s * 50 }
            end
            c:addSeries({ label = "Ch " .. s, data = pts, thickness = 4 })
        end
        c:render(OUT .. "/stress_4k_line.png")
    end
)

bench(
    {
        category = "stress", name = "Heatmap 40x60 (viridis, no gap)",
        type = "heatmap", width = 1400, height = 900, points = 2400, series = 1,
    },
    function()
        local c = Chart.new({ width = 1400, height = 900, type = "heatmap",
            title = "Stress Heatmap 40x60", theme = "dark" })
        c:addSeries({
            label      = "Grid",
            data       = genHeat(40, 60),
            colorRamp  = "viridis",
            showValues = false,
            cellGap    = 0,
        })
        :render(OUT .. "/stress_heatmap_40x60.png")
    end
)

bench(
    {
        category = "stress", name = "Scatter 20k markers",
        type = "scatter", width = 1600, height = 1000, points = 20000, series = 2,
    },
    function()
        local c = Chart.new({
            width = 1600, height = 1000, type = "scatter", theme = "dark",
            title = "Massive Scatter (20k)",
        })
        local g = genScatter(10000, 2)
        c:addSeries({ label = "A", data = g[1], markerType = "circle" })
         :addSeries({ label = "B", data = g[2], markerType = "cross" })
         :render(OUT .. "/stress_scatter_20k.png")
    end
)

bench(
    {
        category = "stress", name = "Histogram 200k samples",
        type = "histogram", width = 1400, height = 900, points = 200000, series = 1,
    },
    function()
        local c = Chart.new({ width = 1400, height = 900, type = "histogram",
            title = "Histogram 200k", theme = "dark" })
        c:addSeries({ label = "Pop", data = genHist(200000) })
         :render(OUT .. "/stress_hist_200k.png")
    end
)


section("SUMMARY")

local okCnt, failCnt = 0, 0
for _, r in ipairs(results) do
    if r.status == "OK" then okCnt = okCnt + 1 else failCnt = failCnt + 1 end
end

io.write(string.format("  Passed: %d   Failed: %d\n\n", okCnt, failCnt))

local sorted = {}
for _, r in ipairs(results) do
    if r.status == "OK" then sorted[#sorted + 1] = r end
end
table.sort(sorted, function(a, b) return a.avgMs > b.avgMs end)

if #sorted > 0 then
    io.write("  Top 5 slowest:\n")
    for i = 1, math.min(5, #sorted) do
        local r = sorted[i]
        io.write(string.format("    %d. %-42s  %.2f ms  mem %+.2f MB\n",
            i, r.name, r.avgMs, r.memDeltaMB))
    end
end


local csv = io.open(CSV_PATH, "w")
if csv then
    csv:write("category,name,type,width,height,points,series,status,min_ms,avg_ms,max_ms,mem_delta_mb\n")
    for _, r in ipairs(results) do
        if r.status == "OK" then
            csv:write(string.format(
                "%s,%s,%s,%d,%d,%d,%d,OK,%.3f,%.3f,%.3f,%.4f\n",
                r.category, r.name, r.type,
                r.width, r.height, r.points, r.series,
                r.minMs, r.avgMs, r.maxMs, r.memDeltaMB
            ))
        else
            csv:write(string.format(
                "%s,%s,%s,%d,%d,%d,%d,FAIL,,,,\n",
                r.category, r.name, r.type,
                r.width, r.height, r.points, r.series
            ))
        end
    end
    csv:close()
    io.write("\n  CSV: " .. CSV_PATH .. "\n")
else
    io.write("\n  WARNING: could not write CSV to " .. CSV_PATH .. "\n")
end

print("Done in " .. os.clock() .. " seconds")
