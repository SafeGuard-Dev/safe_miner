Config = {}

Config.MiningLocations = {
    {x = -595.24, y = 2086.73, z = 131.38},
    {x = -590.95, y = 2071.92, z = 131.33},
    {x = -589.01, y = 2054.97, z = 130.61},
    {x = -581.16, y = 2036.54, z = 128.85},
    {x = -560.71, y = 1979.89, z = 127.0}
}

Config.MiningRadius = 3.0
Config.RequiredTool = 'pickaxe'
Config.MiningItems = {
    {name = 'stone', label = 'Pedra', chance = 50},
    {name = 'iron', label = 'Minério de Ferro', chance = 30},
    {name = 'gold', label = 'Minério de Ouro', chance = 20}
}
-------------
----NIVEL----
-------------
Config.MiningTime = 5000
Config.BaseExperience = 10
Config.BaseMoney = 50
Config.LevelMultiplier = 0.1
Config.ExpPerLevel = 500
Config.MaxLevel = 5
------------
----SELL----
------------
Config.SellLocation = {x = -600.0, y = 2090.0, z = 132.0}
Config.SellBlipName = "Venda de Minérios"
Config.SellKeybind = 38

Config.StonePrice = 300
Config.IronPrice = 800
Config.GoldPrice = 1500