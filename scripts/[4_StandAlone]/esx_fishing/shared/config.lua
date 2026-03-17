Config = {}

-- ========== GÉNÉRAL ==========

Config.Key = 38                     -- Touche E pour interagir
Config.FishingTime = { min = 5000, max = 12000 }  -- Temps d'attente avant touche (ms)
Config.MinigameDuration = 4000      -- Durée du minijeu (ms)
Config.MinigameZoneSize = 20        -- Taille de la zone verte (%)

Config.RequireRod = true            -- Nécessite une canne à pêche (item: fishing_rod)
Config.RequireBait = false          -- Nécessite un appât (item: bait)

-- ========== BLIPS ==========

Config.ShowBlips = true
Config.BlipSprite = 317
Config.BlipColor = 3
Config.BlipScale = 0.8
Config.BlipName = 'Zone de pêche'

-- ========== SPOTS DE PÊCHE ==========

Config.FishingSpots = {
    { coords = vector3(-1850.5, -1248.7, 8.6),   radius = 30.0, label = 'Plage de Vespucci' },
    { coords = vector3(1300.0, 4216.7, 33.9),     radius = 25.0, label = 'Rivière Sandy Shores' },
    { coords = vector3(-3426.3, 967.0, 8.3),      radius = 35.0, label = 'Côte Nord' },
    { coords = vector3(3857.0, 4463.5, 2.7),      radius = 30.0, label = 'Plage de Paleto' },
    { coords = vector3(-1632.0, -852.0, 10.0),    radius = 20.0, label = 'Jetée Del Perro' },
    { coords = vector3(1992.0, 3842.0, 32.0),     radius = 25.0, label = 'Lac Sandy' },
    { coords = vector3(-724.0, -1346.0, 1.6),     radius = 20.0, label = 'Port de LS' },
}

-- ========== POISSONS ==========
-- chance: probabilité relative (plus c'est haut, plus c'est fréquent)
-- price: prix de vente unitaire

Config.Fish = {
    { name = 'sardine',        label = 'Sardine',          chance = 30, price = 15,   xp = 5  },
    { name = 'maquereau',      label = 'Maquereau',        chance = 25, price = 25,   xp = 8  },
    { name = 'bar',            label = 'Bar',              chance = 18, price = 45,   xp = 12 },
    { name = 'dorade',         label = 'Dorade',           chance = 12, price = 65,   xp = 18 },
    { name = 'thon',           label = 'Thon',             chance = 8,  price = 120,  xp = 25 },
    { name = 'espadon',        label = 'Espadon',          chance = 4,  price = 250,  xp = 40 },
    { name = 'requin',         label = 'Requin',           chance = 2,  price = 500,  xp = 80 },
    { name = 'vieille_botte',  label = 'Vieille botte',    chance = 15, price = 1,    xp = 1  },
    { name = 'pneu',           label = 'Pneu crevé',       chance = 8,  price = 2,    xp = 1  },
}

-- ========== POINT DE VENTE ==========

Config.SellLocations = {
    {
        coords = vector3(-1819.5, -1193.2, 14.3),
        label  = 'Poissonnier',
        ped    = 's_m_m_linecook',
        heading = 140.0,
    },
    {
        coords = vector3(1481.0, 4264.5, 36.4),
        label  = 'Marché au poisson',
        ped    = 's_m_m_linecook',
        heading = 50.0,
    },
}

Config.SellBlipSprite = 52
Config.SellBlipColor = 2
Config.SellBlipScale = 0.7
Config.SellBlipName = 'Vente de poissons'

-- ========== NIVEAUX ==========

Config.EnableLevels = true

Config.Levels = {
    { level = 1,  xpRequired = 0,    bonusChance = 0   },
    { level = 2,  xpRequired = 50,   bonusChance = 5   },
    { level = 3,  xpRequired = 150,  bonusChance = 10  },
    { level = 4,  xpRequired = 350,  bonusChance = 15  },
    { level = 5,  xpRequired = 600,  bonusChance = 20  },
    { level = 6,  xpRequired = 1000, bonusChance = 25  },
    { level = 7,  xpRequired = 1500, bonusChance = 30  },
    { level = 8,  xpRequired = 2200, bonusChance = 35  },
    { level = 9,  xpRequired = 3000, bonusChance = 40  },
    { level = 10, xpRequired = 4000, bonusChance = 50  },
}

-- ========== MESSAGES ==========

Config.Lang = {
    press_to_fish      = '~INPUT_CONTEXT~ Pêcher',
    press_to_sell      = '~INPUT_CONTEXT~ Vendre vos poissons',
    fishing_start      = 'Vous lancez votre ligne...',
    fishing_bite       = 'Ça mord ! Appuyez au bon moment !',
    fishing_success    = 'Vous avez attrapé: %s !',
    fishing_fail       = 'Le poisson s\'est échappé...',
    fishing_nothing    = 'Rien ne mord...',
    no_rod             = 'Vous n\'avez pas de canne à pêche.',
    no_bait            = 'Vous n\'avez pas d\'appât.',
    sold_fish          = 'Vous avez vendu %dx %s pour $%d.',
    sold_all           = 'Tous vos poissons ont été vendus pour $%d !',
    no_fish            = 'Vous n\'avez aucun poisson à vendre.',
    level_up           = 'Pêche niveau %d atteint !',
    xp_gained          = '+%d XP de pêche',
}
