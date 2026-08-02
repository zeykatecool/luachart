local Geometry = require("luaPNG.geometry")
local Font = require("luachart.font")

local Canvas = {}

function Canvas.drawLine(img, x1, y1, x2, y2, color, thickness)
    thickness = thickness or 1
    if thickness == 1 then
        img:add(Geometry.Line{
            x1 = x1, y1 = y1, x2 = x2, y2 = y2,
            thickness = thickness, color = color
        })
    else
        img:add(Geometry.Line{
            x1 = x1, y1 = y1, x2 = x2, y2 = y2,
            thickness = thickness, color = color
        })
    end
end

function Canvas.fillRect(img, x, y, w, h, color)
    img:add(Geometry.Rectangle{
        x = math.floor(x), y = math.floor(y),
        width = math.ceil(w), height = math.ceil(h),
        color = color, mode = "fill"
    })
end

function Canvas.strokeRect(img, x, y, w, h, color)
    img:add(Geometry.Rectangle{
        x = math.floor(x), y = math.floor(y),
        width = math.ceil(w), height = math.ceil(h),
        color = color, mode = "stroke"
    })
end

function Canvas.fillCircle(img, cx, cy, r, color)
    cx, cy, r = math.floor(cx), math.floor(cy), math.floor(r)
    local col = color
    local function drawHLine(x1, x2, y)
        if x1 > x2 then x1, x2 = x2, x1 end
        for x = x1, x2 do
            img:setPixel(x, y, col[1], col[2], col[3], col[4] or 255)
        end
    end
    
    local x = r
    local y = 0
    local err = 1 - x
    
    while x >= y do
        drawHLine(cx - x, cx + x, cy + y)
        drawHLine(cx - x, cx + x, cy - y)
        drawHLine(cx - y, cx + y, cy + x)
        drawHLine(cx - y, cx + y, cy - x)
        
        y = y + 1
        if err < 0 then
            err = err + 2 * y + 1
        else
            x = x - 1
            err = err + 2 * (y - x) + 1
        end
    end
end

function Canvas.strokeCircle(img, cx, cy, r, color)
    cx, cy, r = math.floor(cx), math.floor(cy), math.floor(r)
    local col = color
    local function plot(x, y)
        img:setPixel(x, y, col[1], col[2], col[3], col[4] or 255)
    end
    
    local x = r
    local y = 0
    local err = 1 - x
    
    while x >= y do
        plot(cx + x, cy + y)
        plot(cx + y, cy + x)
        plot(cx - y, cy + x)
        plot(cx - x, cy + y)
        plot(cx - x, cy - y)
        plot(cx - y, cy - x)
        plot(cx + y, cy - x)
        plot(cx + x, cy - y)
        
        y = y + 1
        if err < 0 then
            err = err + 2 * y + 1
        else
            x = x - 1
            err = err + 2 * (y - x) + 1
        end
    end
end

function Canvas.drawStringLines(img, lines, x, y, color, scale, alignX, lineGap)
    lineGap = lineGap or (scale or 1)
    local cy = y
    for _, line in ipairs(lines) do
        Canvas.drawString(img, line, x, cy, color, scale, alignX, "top")
        cy = cy + Font.charHeight(scale) + lineGap
    end
    return cy - y
end

function Canvas.drawString(img, text, x, y, color, scale, alignX, alignY, maxWidth)
    scale = scale or 1
    
    if maxWidth then
        local w = Font.stringWidth(text, scale, scale)
        if w > maxWidth then
            local dotW = Font.stringWidth("...", scale, scale)
            if dotW >= maxWidth then
                text = ""
            else
                local newText = ""
                for i = 1, #text do
                    local sub = text:sub(1, i)
                    if Font.stringWidth(sub, scale, scale) + dotW > maxWidth then
                        break
                    end
                    newText = sub
                end
                text = newText .. "..."
            end
        end
    end
    
    local w = Font.stringWidth(text, scale, scale)
    local h = Font.charHeight(scale)
    
    if alignX == "center" then x = x - w/2
    elseif alignX == "right" then x = x - w end
    
    if alignY == "center" then y = y - h/2
    elseif alignY == "bottom" then y = y - h end
    
    x, y = math.floor(x), math.floor(y)
    local cx = x
    for i = 1, #text do
        local code = text:byte(i)
        Font.drawChar(img, code, cx, y, color[1], color[2], color[3], color[4] or 255, scale)
        cx = cx + Font.charWidth(scale) + scale
    end
end

function Canvas.drawTextRotated(img, text, x, y, color, scale, alignX, alignY)
    scale = scale or 1
    local w = Font.charHeight(scale)
    local h = Font.stringWidth(text, scale, scale)
    
    if alignX == "center" then x = x - w/2
    elseif alignX == "right" then x = x - w end
    
    if alignY == "center" then y = y + h/2
    elseif alignY == "bottom" then y = y + h end
    
    x, y = math.floor(x), math.floor(y)
    local cy = y
    for i = 1, #text do
        local code = text:byte(i)
        Font.drawCharRotated(img, code, x, cy - Font.charWidth(scale), color[1], color[2], color[3], color[4] or 255, scale)
        cy = cy - Font.charWidth(scale) - scale
    end
end

return Canvas
