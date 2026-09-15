local activeDrop = nil
local activeBlipRadius = nil
local activeBlipCenter = nil

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function GetRaycastGroundZ(x, y, z)
    local ray = StartExpensiveSynchronousShapeTestLosProbe(x, y, z, x, y, z - 300.0, 1, 0, 4)
    local _, hit, hitCoords, _, _ = GetShapeTestResult(ray)
    if hit == 1 then
        return hitCoords.z
    end
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if found then return groundZ end
    return z
end

local function DrawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent('qbx_airdrop:client:startDrop', function(dropId, targetCoords)
    if activeBlipRadius then RemoveBlip(activeBlipRadius) end
    if activeBlipCenter then RemoveBlip(activeBlipCenter) end

    -- Zona Vermelha PvP
    activeBlipRadius = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipRadius)
    SetBlipColour(activeBlipRadius, Config.RedBlipColor)
    SetBlipAlpha(activeBlipRadius, Config.BlipAlpha)

    activeBlipCenter = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)
    SetBlipSprite(activeBlipCenter, 478)
    SetBlipColour(activeBlipCenter, Config.RedBlipColor)
    SetBlipScale(activeBlipCenter, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Zona Airdrop (PvP)")
    EndTextCommandSetBlipName(activeBlipCenter)

    -- ALTITUDE INTELIGENTE: Garante uma altitude de voo bem alta (mínimo de 400m Z ou +220m acima do local)
    local flightZ = math.max(targetCoords.z + 220.0, 420.0)
    
    -- Trajetória de voo em linha reta no céu
    local startVector = vector3(targetCoords.x - 1500.0, targetCoords.y - 1500.0, flightZ)
    local endVector = vector3(targetCoords.x + 1500.0, targetCoords.y + 1500.0, flightZ)
    
    LoadModel(Config.PlaneModel)
    LoadModel(Config.CrateModel)
    LoadModel(Config.ParachuteModel)

    local plane = CreateVehicle(Config.PlaneModel, startVector.x, startVector.y, startVector.z, 0.0, false, false)
    SetEntityHeading(plane, GetHeadingFromVector_2d(targetCoords.x - startVector.x, targetCoords.y - startVector.y))
    SetVehicleEngineOn(plane, true, true, false)
    SetEntityVelocity(plane, 60.0, 60.0, 0.0)

    -- FÍSICA E COLISÃO REALISTA (COLISÃO ATIVA)
    SetEntityCollision(plane, true, true) -- Colisão 100% ativa para realismo visual
    SetEntityInvincible(plane, true) -- Segurança extra contra bugs de motor/explosão
    SetVehicleEngineCanDegrade(plane, false)
    SetVehicleCanBreak(plane, false)
    SetEntityLodDist(plane, 3000) -- Renderiza o avião a longa distância

    LoadModel(`s_m_m_pilot_01`)
    local pilot = CreatePedInsideVehicle(plane, 4, `s_m_m_pilot_01`, -1, false, false)
    
    -- IA DO PILOTO COM EVITAMENTO AUTOMÁTICO DE TERRENO
    SetEntityInvincible(pilot, true)
    SetDriverAbility(pilot, 1.0)
    SetDriverAggressiveness(pilot, 0.0)
    SetBlockingOfNonTemporaryEvents(pilot, true)
    SetPlaneMinHeightAboveGround(plane, 80) -- Força a IA a subir se detetar solo elevado
    
    -- Piloto executa o voo tático mantendo altitude elevada
    TaskPlaneMission(pilot, plane, 0, 0, endVector.x, endVector.y, flightZ, 6, 0.0, 0.0, 90.0, 0.0, 0.0)

    CreateThread(function()
        local dropped = false
        while not dropped do
            Wait(10)
            if DoesEntityExist(plane) then
                local pCoords = GetEntityCoords(plane)
                local dist = #(vector2(pCoords.x, pCoords.y) - vector2(targetCoords.x, targetCoords.y))

                -- Larga o airdrop no ponto exato por cima do local marcado
            if dist <= 30.0 then
                 dropped = true

    -- CORREÇÃO: Cria a caixa e o paraquedas exatamente nas coordenadas centrais do alvo
                local dropCrate = CreateObject(Config.CrateModel, targetCoords.x, targetCoords.y, pCoords.z - 3.0, true, true, false)
                local chute = CreateObject(Config.ParachuteModel, targetCoords.x, targetCoords.y, pCoords.z, true, true, false)

                    -- Força a renderização imediata da caixa e do paraquedas a 3km de distância
                    SetEntityLodDist(dropCrate, 3000)
                    SetEntityLodDist(chute, 3000)

                    -- Fixação do paraquedas aberto na caixa
                    AttachEntityToEntity(chute, dropCrate, 0, 0.0, 0.0, 3.8, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

                    -- Fumo vermelho tático anexado à caixa no momento exato em que sai do avião
                    RequestNamedPtfxAsset("core")
                    while not HasNamedPtfxAssetLoaded("core") do Wait(10) end
                    UseParticleFxAssetNextCall("core")
                    local smokeFx = StartParticleFxLoopedOnEntity("exp_grd_flare", dropCrate, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, false, false, false)

                    -- O avião continua o seu voo normal até sair do mapa e depois é removido
                    SetTimeout(15000, function()
                        if DoesEntityExist(pilot) then DeleteEntity(pilot) end
                        if DoesEntityExist(plane) then DeleteEntity(plane) end
                    end)

                    -- Descida da caixa até tocar no chão
                    CreateThread(function()
                        while true do
                            Wait(0)
                            local cCoords = GetEntityCoords(dropCrate)
                            local groundZ = GetRaycastGroundZ(cCoords.x, cCoords.y, cCoords.z)

                            if (cCoords.z - groundZ) <= 1.2 then
                                -- Desliga o efeito de fumo ao pousar
                                if DoesParticleFxLoopedExist(smokeFx) then
                                    StopParticleFxLooped(smokeFx, false)
                                end

                                if DoesEntityExist(chute) then
                                    DetachEntity(chute, true, true)
                                    SetEntityAsMissionEntity(chute, true, true)
                                    DeleteEntity(chute)
                                end

                                SetEntityCoords(dropCrate, cCoords.x, cCoords.y, groundZ, false, false, false, false)
                                PlaceObjectOnGroundProperly(dropCrate)
                                FreezeEntityPosition(dropCrate, true)

                                activeDrop = {
                                    id = dropId,
                                    entity = dropCrate,
                                    coords = vector3(cCoords.x, cCoords.y, groundZ),
                                    timer = Config.UnlockTimer,
                                    unlocked = false
                                }

                                TriggerServerEvent('qbx_airdrop:server:landed', dropId)

                                exports.ox_target:addLocalEntity(dropCrate, {
                                    {
                                        name = 'airdrop_crate_' .. dropId,
                                        icon = 'fas fa-box-open',
                                        label = 'Abrir Airdrop',
                                        onSelect = function()
                                            lib.callback('qbx_airdrop:server:canOpen', false, function(canOpen)
                                                if canOpen then
                                                    exports.ox_inventory:openInventory('stash', dropId)
                                                else
                                                    lib.notify({ type = 'error', description = 'A caixa ainda está trancada!' })
                                                end
                                            end, dropId)
                                        end
                                    }
                                })
                                break
                            else
                                SetEntityVelocity(dropCrate, 0.0, 0.0, -Config.DropSpeed)
                            end
                        end
                    end)
                end
            else
                break
            end
        end
    end)
end)

-- Thread Visual e Sonora (Beep-Beep com Volume Proporcional)
CreateThread(function()
    local lastBeepTime = 0

    while true do
        local sleep = 1000

        if activeDrop and DoesEntityExist(activeDrop.entity) then
            local pCoords = GetEntityCoords(PlayerPedId())
            local dCoords = activeDrop.coords
            local dist = #(pCoords - dCoords)

            if dist < 1200.0 then
                sleep = 0

                local r, g, b = 255, 0, 0
                local textStatus = string.format("~r~[TRANCADO]~w~\nDesbloqueia em: ~y~%d s~w~", activeDrop.timer)

                if activeDrop.unlocked then
                    r, g, b = 0, 255, 0
                    textStatus = "~g~[AIRDROP DESBLOQUEADO]~w~\nUtiliza o menu para abrir"
                end

                DrawMarker(1, dCoords.x, dCoords.y, dCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 400.0, r, g, b, 160, false, true, 2, false, nil, nil, false)
                DrawLightWithRange(dCoords.x, dCoords.y, dCoords.z + 1.0, r, g, b, 10.0, 4.0)

                if dist < 30.0 then
                    DrawText3D(vector3(dCoords.x, dCoords.y, dCoords.z + 1.4), textStatus)
                end

                -- Sinalizador Sonoro Tático ("Beep-Beep")
                if dist <= Config.MaxBeepDistance then
                    local currentTime = GetGameTimer()
                    if currentTime - lastBeepTime >= Config.BeepInterval then
                        lastBeepTime = currentTime

                        local distanceFactor = 1.0 - (dist / Config.MaxBeepDistance)
                        local dynamicVolume = math.floor(Config.MaxVolume * distanceFactor)
                        if dynamicVolume < 5 then dynamicVolume = 5 end

                        CreateThread(function()
                            PlaySoundFromCoord(-1, Config.SoundName, dCoords.x, dCoords.y, dCoords.z, Config.SoundSet, true, dynamicVolume, false)
                            Wait(150)
                            PlaySoundFromCoord(-1, Config.SoundName, dCoords.x, dCoords.y, dCoords.z, Config.SoundSet, true, dynamicVolume, false)
                        end)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('qbx_airdrop:client:updateTimer', function(dropId, remainingTime, isUnlocked)
    if activeDrop and activeDrop.id == dropId then
        activeDrop.unlocked = isUnlocked
        activeDrop.timer = remainingTime
    end
end)

RegisterNetEvent('qbx_airdrop:client:removeDrop', function(dropId)
    if activeDrop and activeDrop.id == dropId then
        if DoesEntityExist(activeDrop.entity) then
            DeleteEntity(activeDrop.entity)
        end
        activeDrop = nil
    end

    if activeBlipRadius then RemoveBlip(activeBlipRadius) end
    if activeBlipCenter then RemoveBlip(activeBlipCenter) end
end)