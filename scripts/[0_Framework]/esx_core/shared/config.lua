Config = {}

Config.Locale = 'fr'

Config.Accounts = {
    { name = 'bank',        label = 'Banque',       round = true },
    { name = 'money',       label = 'Espèces',      round = true },
    { name = 'black_money', label = 'Argent sale',   round = true },
}

Config.StartingAccountMoney = {
    bank = 50000,
    money = 500,
}

Config.DefaultSpawnCoords = vector4(-269.4, -955.3, 31.2, 205.0)

Config.EnablePvP = true
Config.EnableWantedLevel = false

Config.MaxWeight = 24

Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true,
}

Config.EnableDebug = false
