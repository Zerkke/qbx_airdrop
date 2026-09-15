local qbx = exports.qbx_core
local currentAirdrop = nil

local function GenerateLoot()
    local items = {}
    for _, data in ipairs(Config.LootTable) do
        if math.random(1, 100) <= data.chance then
            local count = math.random(data.min, data.max)
            table.insert(items, { data.item, count })
        end
    end
    return items
end

-- Função centralizada para iniciar o Airdrop (Usada pelo Admin e pelo Temporizador Automático)
local function StartAirdropEvent(source)
    if currentAirdrop then
        if source and source > 0 then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Já existe um Airdrop ativo!' })
        end
        return false
    end

    local randomLoc = Config.DropLocations[math.random(1, #Config.DropLocations)]
    local dropId = 'airdrop_' .. math.random(10000, 99999)

    currentAirdrop = {
        id = dropId,
        coords = randomLoc,
        unlocked = false,
        landed = false,
        loot = GenerateLoot()
    }

    -- Criar Stash no ox_inventory
    exports.ox_inventory:RegisterStash(dropId, 'Caixa de Airdrop', 50, 100000)

    for _, itemData in ipairs(currentAirdrop.loot) do
        exports.ox_inventory:AddItem(dropId, itemData[1], itemData[2])
    end

    TriggerClientEvent('qbx_airdrop:client:startDrop', -1, dropId, randomLoc)
    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'AIRDROP EM CAMINHO',
        description = 'Um avião Titan de suprimentos entrou no espaço aéreo!',
        type = 'inform',
        duration = 10000
    })
    return true
end

-- Comando Admin para acionar o Airdrop manualmente
lib.addCommand(Config.AdminCommand, {
    help = 'Inicia uma entrega de Airdrop configurada',
    restricted = 'group.' .. Config.AdminGroup
}, function(source, args)
    StartAirdropEvent(source)
end)

-- Loop do Temporizador Automático (0% de impacto na performance)
CreateThread(function()
    if not Config.AutoAirdrop then return end

    while true do
        Wait(Config.AutoAirdropInterval * 60 * 1000) -- Converte minutos para milissegundos
        if not currentAirdrop then
            StartAirdropEvent(0)
        end
    end
end)

-- Evento ativado assim que a caixa toca no chão
RegisterNetEvent('qbx_airdrop:server:landed', function(dropId)
    if not currentAirdrop or currentAirdrop.id ~= dropId then return end
    if currentAirdrop.landed then return end

    currentAirdrop.landed = true

    CreateThread(function()
        local remaining = Config.UnlockTimer
        while remaining > 0 do
            Wait(1000)
            remaining = remaining - 1
            TriggerClientEvent('qbx_airdrop:client:updateTimer', -1, dropId, remaining, false)
        end

        currentAirdrop.unlocked = true
        TriggerClientEvent('qbx_airdrop:client:updateTimer', -1, dropId, 0, true)
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'AIRDROP DESBLOQUEADO',
            description = 'A caixa de suprimentos já pode ser aberta na zona PvP!',
            type = 'success',
            duration = 8000
        })

        -- Despawn automático por expiração de 15 minutos (caso ninguém o abra)
        SetTimeout(Config.DespawnTimer * 1000, function()
            if currentAirdrop and currentAirdrop.id == dropId then
                TriggerClientEvent('ox_lib:notify', -1, {
                    title = 'AIRDROP EXPIRADO',
                    description = 'O Airdrop desapareceu por falta de saque!',
                    type = 'error',
                    duration = 8000
                })
                TriggerClientEvent('qbx_airdrop:client:removeDrop', -1, dropId)
                currentAirdrop = nil
            end
        end)
    end)
end)

-- Verificar se o inventário do Airdrop ficou totalmente vazio ao fechar
RegisterNetEvent('ox_inventory:closedInventory', function(playerId, invId)
    if currentAirdrop and currentAirdrop.id == invId then
        local stashItems = exports.ox_inventory:GetInventoryItems(invId)
        local itemCount = 0

        if stashItems then
            for _, item in pairs(stashItems) do
                if item and item.count and item.count > 0 then
                    itemCount = itemCount + item.count
                end
            end
        end

        -- Se a caixa estiver totalmente vazia, apaga-a imediatamente
        if itemCount == 0 then
            TriggerClientEvent('ox_lib:notify', -1, {
                title = 'AIRDROP SAQUEADO',
                description = 'O Airdrop foi totalmente saqueado e desapareceu!',
                type = 'inform',
                duration = 6000
            })
            TriggerClientEvent('qbx_airdrop:client:removeDrop', -1, invId)
            currentAirdrop = nil
        end
    end
end)

lib.callback.register('qbx_airdrop:server:canOpen', function(source, dropId)
    if currentAirdrop and currentAirdrop.id == dropId and currentAirdrop.unlocked then
        return true
    end
    return false
end)

RegisterNetEvent('qbx_airdrop:server:cleanUp', function(dropId)
    if currentAirdrop and currentAirdrop.id == dropId then
        currentAirdrop = nil
        TriggerClientEvent('qbx_airdrop:client:removeDrop', -1, dropId)
    end
end)

-- ADIÇÃO: Sincronização para jogadores que chegam tarde ou entram com airdrop a decorrer
RegisterNetEvent('qbx_airdrop:server:requestActiveDrop', function()
    local src = source
    if currentAirdrop then
        TriggerClientEvent('qbx_airdrop:client:syncLateDrop', src, currentAirdrop.id, currentAirdrop.coords, currentAirdrop.unlocked, currentAirdrop.landed)
    end
end)