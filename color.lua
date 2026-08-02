local Color = {}

Color.themes = {
    dark = {
        background = {12, 12, 20},
        plot_bg    = {20, 20, 35},
        grid       = {38, 38, 58},
        axis       = {100, 100, 130},
        text       = {200, 200, 225},
        title      = {240, 240, 255},
        subtitle   = {150, 150, 190},
        series = {
            {100, 180, 255}, {100, 255, 160}, {255, 140, 100},
            {220, 100, 255}, {255, 220,  80}, {100, 230, 230},
            {255, 100, 140}, {160, 255, 100},
        },
    },
    light = {
        background = {248, 248, 255},
        plot_bg    = {255, 255, 255},
        grid       = {215, 215, 230},
        axis       = { 80,  80, 110},
        text       = { 50,  50,  80},
        title      = { 20,  20,  50},
        subtitle   = {100, 100, 140},
        series = {
            { 30, 120, 220}, { 30, 180, 100}, {220,  80,  30},
            {160,  30, 220}, {200, 160,   0}, {  0, 160, 180},
            {220,  30, 100}, { 80, 180,  30},
        },
    },
}

function Color.fromHSL(h, s, l)
    h = h % 360; s = s / 100; l = l / 100
    local c = (1 - math.abs(2*l - 1)) * s
    local x = c * (1 - math.abs((h/60) % 2 - 1))
    local m = l - c/2
    local r, g, b
    if     h < 60  then r,g,b = c,x,0
    elseif h < 120 then r,g,b = x,c,0
    elseif h < 180 then r,g,b = 0,c,x
    elseif h < 240 then r,g,b = 0,x,c
    elseif h < 300 then r,g,b = x,0,c
    else               r,g,b = c,0,x end
    return {
        math.floor((r+m)*255+0.5),
        math.floor((g+m)*255+0.5),
        math.floor((b+m)*255+0.5),
    }
end

function Color.interpolate(c1, c2, t)
    return {
        math.floor(c1[1]+(c2[1]-c1[1])*t+0.5),
        math.floor(c1[2]+(c2[2]-c1[2])*t+0.5),
        math.floor(c1[3]+(c2[3]-c1[3])*t+0.5),
    }
end

function Color.palette(n, hueStart)
    hueStart = hueStart or 210
    local cols = {}
    for i = 1, n do
        cols[i] = Color.fromHSL((hueStart + (i-1)*(360/n)) % 360, 72, 62)
    end
    return cols
end

function Color.withAlpha(c, a)
    return {c[1], c[2], c[3], a or 255}
end

function Color.resolveSeries(series, index, theme)
    if series and series.color then
        local c = series.color
        return {c[1], c[2], c[3], c[4] or 255}
    end
    if theme and theme.series and theme.series[index] then
        local c = theme.series[index]
        return {c[1], c[2], c[3], 255}
    end
    local pal = Color.palette(8)
    local c = pal[((index-1) % 8) + 1]
    return {c[1], c[2], c[3], 255}
end

return Color
