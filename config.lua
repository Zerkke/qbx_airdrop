Config = {}

-- Comando para administradores
Config.AdminCommand = 'airdrop'
Config.AdminGroup = 'admin'

-- Sistema de Airdrop Automático
Config.AutoAirdrop = true -- 'true' para ativar o sistema automático / 'false' para apenas manual via comando
Config.AutoAirdropInterval = 1 -- Tempo em MINUTOS entre cada Airdrop automático (Ex: 60 = a cada 1 hora)

-- Modelos do Airdrop
Config.PlaneModel = `titan`
Config.CrateModel = `prop_mil_crate_01`
Config.ParachuteModel = `p_cargo_chute_s` -- Paraquedas militar de carga ABERTO (velame)

Config.FlightAltitude = 120.0 -- Altura do avião em relação ao chão
Config.DropSpeed = 8.0 -- Velocidade de queda da caixa
Config.UnlockTimer = 60 -- Tempo em segundos para desbloquear a caixa após cair
Config.DespawnTimer = 900 -- 15 minutos (Desaparece se ninguém o abrir/recolher)

-- Zona PvP no Mapa (Sempre Vermelha)
Config.BlipRadius = 200.0
Config.RedBlipColor = 1
Config.BlipAlpha = 110

-- Áudio do Bip Tático (Beep-Beep com Volume Dinâmico)
Config.SoundName = 'Beep_Red'
Config.SoundSet = 'DLC_HEIST_HACKING_SNAKE_SOUNDS'
Config.BeepInterval = 2000 -- Toca a cada 2 segundos
Config.MaxBeepDistance = 80.0 -- Distância máxima audível
Config.MaxVolume = 60 -- Volume máximo próximo da caixa

-- Locais de queda configuráveis
Config.DropLocations = {
    vector3(2348.17, 3371.51, 47.67), -- Sandy Shores Airfield
    vector3(-2135.03, 1859.79, 233.49), -- Grapeseed
    vector3(575.95, 2248.73, 62.79), -- Base do Chiliad
    vector3(2455.61, -1648.61, 38.39) -- Paleto Bay
}

-- Loot Configurável
Config.LootTable = {
    { item = 'weapon_pistol', min = 1, max = 1, chance = 100 },
    { item = 'ammo-9', min = 50, max = 150, chance = 100 },
    { item = 'medkit', min = 2, max = 5, chance = 80 },
    { item = 'armor', min = 1, max = 3, chance = 70 },
    { item = 'lockpick', min = 5, max = 10, chance = 90 },
    { item = 'black_money', min = 5000, max = 20000, chance = 50 }
}