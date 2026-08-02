local Scale = {}

function Scale.Linear(domain, range)
    local s = {
        domainMin = domain[1], domainMax = domain[2],
        rangeMin  = range[1],  rangeMax  = range[2],
    }
    function s:map(v)
        local span = self.domainMax - self.domainMin
        if span == 0 then return self.rangeMin end
        return self.rangeMin + (v - self.domainMin) / span * (self.rangeMax - self.rangeMin)
    end
    function s:mapInt(v) return math.floor(self:map(v) + 0.5) end
    return s
end

function Scale.niceTicks(dataMin, dataMax, targetCount)
    targetCount = targetCount or 5
    if dataMin == dataMax then
        local d = math.max(1, math.abs(dataMin) * 0.1)
        dataMin = dataMin - d; dataMax = dataMax + d
    end
    local range     = dataMax - dataMin
    local roughStep = range / targetCount
    local mag       = 10 ^ math.floor(math.log10(roughStep))
    local norm      = roughStep / mag
    local niceNorm
    if     norm <= 1   then niceNorm = 1
    elseif norm <= 2   then niceNorm = 2
    elseif norm <= 2.5 then niceNorm = 2.5
    elseif norm <= 5   then niceNorm = 5
    else                    niceNorm = 10 end
    local step    = niceNorm * mag
    local niceMin = math.floor(dataMin / step) * step
    local niceMax = math.ceil(dataMax  / step) * step
    local ticks   = {}
    local t       = niceMin
    while t <= niceMax + step * 1e-9 do
        ticks[#ticks+1] = t; t = t + step
    end
    return niceMin, niceMax, ticks, step
end


function Scale.format(n)
    if n == 0 then return "0" end
    if math.abs(n) >= 1e9  then return string.format("%.1fB", n/1e9)
    elseif math.abs(n) >= 1e6  then return string.format("%.1fM", n/1e6)
    elseif math.abs(n) >= 1e3  then return string.format("%.1fK", n/1e3)
    elseif n == math.floor(n)  then return string.format("%d", n)
    elseif math.abs(n) < 0.01  then return string.format("%.2e", n)
    elseif math.abs(n) < 1     then return string.format("%.3f", n)
    else                             return string.format("%.2f", n) end
end

return Scale
