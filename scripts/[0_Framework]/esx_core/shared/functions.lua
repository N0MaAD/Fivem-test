ESX = {}
ESX.PlayerData = {}
ESX.PlayerLoaded = false
ESX.Table = {}

function ESX.Table.SizeOf(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function ESX.Table.Set(t)
    local set = {}
    for _, v in ipairs(t) do set[v] = true end
    return set
end

ESX.Math = {}

function ESX.Math.Round(num, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(num * power + 0.5) / power
end

function ESX.Math.GroupDigits(value)
    local left, num, right = string.match(tostring(value), '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

function ESX.GetConfig()
    return Config
end
