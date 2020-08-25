-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_inventory",cRP)
vSERVER = Tunnel.getInterface("vrp_inventory")
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVCLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("invClose",function()
	TriggerEvent("vrp_sound:source","unzip",0.15)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	SendNUIMessage({ action = "hideMenu" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.closeInventory()
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	SendNUIMessage({ action = "hideMenu" })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESSED BUTTON "
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	while true do
		if IsControlJustPressed(0,243) and not IsPlayerFreeAiming(PlayerId()) and GetEntityHealth(PlayerPedId()) >= 102 and not vRP.isHandcuff() then
			SetNuiFocus(true,true)
			SetCursorLocation(0.5,0.5)
			SendNUIMessage({ action = "showMenu" })

			
			local identity = false
			if identity then
				identity = false
				SendNUIMessage({ type = 'close' })
			else
				local  carteira,banco,coins,nome,sobrenome,idade,user_id,identidade,telefone,job,cargo,vip,faturas,multas,mypaypal = vSERVER.Identidade()
				SendNUIMessage({
					type = 'open',
					nome = nome,
					sobrenome = sobrenome,
					carteira = carteira,
					banco = banco,
					vip = vip,
					emprego = job,
					cargo = cargo,
					id = user_id,
					documento = identidade,
					idade = idade,
					telefone = telefone,
					multas = multas,
					mypaypal = mypaypal

				})
				identity = true
			end
		end
		Citizen.Wait(5)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("dropItem",function(data)
	vSERVER.dropItem(data.item,data.amount)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendItem",function(data)
	vSERVER.sendItem(data.item,data.amount)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- USEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("useItem",function(data)
	vSERVER.useItem(data.item,data.type,data.amount)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVE WEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DoSomething",function(data)
	if data.tDrop == "roubar" then
		vSERVER.roubItem(data.item,data.amount)
	elseif data.tDrop == "armamento" then
		vSERVER.getWeapon(data.item)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOCHILA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestMochila",function(data,cb)
	local inventario,peso,maxpeso,slots = vSERVER.Mochila()
	vSERVER.Armamento()
	if inventario then
		cb({ inventario = inventario, peso = peso, maxpeso = maxpeso, slots = slots })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEARMOCHILA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestNearMochila",function(data,cb)
	local nearinventario = vSERVER.NearMochila()
	if nearinventario then
		cb({ nearinventario = nearinventario })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestArmamento",function(data,cb)
	local armamento = vSERVER.Armamento()
	if armamento then
		cb({ armamento = armamento })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP_INVENTORY:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_inventory:Update")
AddEventHandler("vrp_inventory:Update",function(action)
	SendNUIMessage({ action = action })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTFREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
local inRadio = false
function cRP.startFrequency(frequency)
	TriggerEvent("radio:outServers")
	exports.tokovoip_script:addPlayerToRadio(frequency)
	inRadio = true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVGCPHONE:USEDISCARDNUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("invgcPhone:useDiscardNumber")
AddEventHandler("invgcPhone:useDiscardNumber",function()
	TriggerServerEvent("gcPhone:useDiscardNumber")
	TriggerServerEvent("gcPhone:allUpdate")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:OUTSERVERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radio:outServers")
AddEventHandler("radio:outServers",function()
	for i = 1,999 do
		if exports.tokovoip_script:isPlayerInChannel(i) == true then
			exports.tokovoip_script:removePlayerFromRadio(i)
		end
	end
	inRadio = false
	TriggerEvent("vrp_hud:RadioDisplay",0)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:THREADCHECKRADIO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if inRadio and vSERVER.checkRadio() then
			TriggerEvent("radio:outServers")
			inRadio = false
		end
		Citizen.Wait(10000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLATE - FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.plateDistance()
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped) then
		local vehicle = GetVehiclePedIsUsing(ped)
		if GetPedInVehicleSeat(vehicle,-1) == ped then
			FreezeEntityPosition(GetVehiclePedIsUsing(ped),true)
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLATE - COLORS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.plateApply(plate)
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsUsing(ped)
	if IsEntityAVehicle(vehicle) then
		SetVehicleNumberPlateText(vehicle,plate)
		FreezeEntityPosition(vehicle,false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPAIRVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.repairVehicle(index,status)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			SetEntityAsMissionEntity(v,true,true)
			local fuel = GetVehicleFuelLevel(v)
			if status then
				SetVehicleFixed(v)
				SetVehicleFuelLevel(v,fuel)
				SetVehicleDeformationFixed(v)
				SetVehicleUndriveable(v,false)
			else
				SetVehicleEngineHealth(v,1000.0)
				SetVehicleBodyHealth(v,1000.0)
				SetVehicleFuelLevel(v,fuel)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPAIRVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.repairTires(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			for i = 0,8 do
				SetVehicleTyreFixed(v,i)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCKPICKVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.lockpickVehicle(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			SetEntityAsMissionEntity(v,true,true)
			if GetVehicleDoorsLockedForPlayer(v,PlayerId()) == 1 then
				SetVehicleDoorsLocked(v,false)
				SetVehicleDoorsLockedForAllPlayers(v,false)
			else
				SetVehicleDoorsLocked(v,true)
				SetVehicleDoorsLockedForAllPlayers(v,true)
			end
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
			Wait(200)
			SetVehicleLights(v,2)
			Wait(200)
			SetVehicleLights(v,0)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
local blockButtons = false
function cRP.blockButtons(status)
	blockButtons = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if blockButtons then
			timeDistance = 4
			BlockWeaponWheelThisFrame()
			DisableControlAction(0,56,true)
			DisableControlAction(0,57,true)
			DisableControlAction(0,73,true)
			DisableControlAction(0,29,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,38,true)
			DisableControlAction(0,20,true)
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,105,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,327,true)
			DisableControlAction(0,311,true)
			DisableControlAction(0,344,true)
			DisableControlAction(0,182,true)
			DisableControlAction(0,245,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,243,true)
		end
		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARACHUTECOLORS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.parachuteColors()
	GiveWeaponToPed(PlayerPedId(),"GADGET_PARACHUTE",1,false,true)
	SetPedParachuteTintIndex(PlayerPedId(),math.random(7))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkObjects(prop)
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))

	if DoesObjectOfTypeExistAtCoords(x,y,z,0.7,GetHashKey(prop),true) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKFOUNTAIN
-----------------------------------------------------------------------------------------------------------------------------------------
local cowCoords = {
	{ 2519.27,4737.13,34.31 },
	{ 2511.97,4746.31,34.31 },
	{ 2503.51,4754.91,34.31 },
	{ 2494.99,4762.82,34.38 },
	{ 2472.8,4761.66,34.31 },
	{ 2464.73,4770.15,34.38 },
	{ 2457.19,4777.66,34.5 },
	{ 2448.75,4786.42,34.64 },
	{ 2441.27,4793.63,34.67 },
	{ 2432.51,4802.7,34.83 },
	{ 2400.45,4777.87,34.55 },
	{ 2409.17,4767.99,34.31 },
	{ 2416.74,4761.18,34.31 },
	{ 2424.82,4752.49,34.31 },
	{ 2433.06,4745.04,34.31 },
	{ 2440.76,4736.46,34.31 }
}

function cRP.checkFountain()
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))

	if DoesObjectOfTypeExistAtCoords(x,y,z,0.7,GetHashKey("prop_watercooler"),true) or DoesObjectOfTypeExistAtCoords(x,y,z,0.7,GetHashKey("prop_watercooler_dark"),true) then
		return true,"fountain"
	end

	if IsEntityInWater(ped) then
		return true,"floor"
	end

	for k,v in pairs(cowCoords) do
		local distance = GetDistanceBetweenCoords(x,y,z,v[1],v[2],v[3],true)
		if distance <= 1 then
			return true,"cow"
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CASHREGISTER
-----------------------------------------------------------------------------------------------------------------------------------------
local registerCoords = {}
function cRP.cashRegister()
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))

	for k,v in pairs(registerCoords) do
		local distance = GetDistanceBetweenCoords(x,y,z,v[1],v[2],v[3],true)
		if distance <= 1 then
			return false,v[1],v[2],v[3]
		end
	end

	local object = GetClosestObjectOfType(x,y,z,0.4,GetHashKey("prop_till_01"),0,0,0)
	if DoesEntityExist(object) then
		local x2,y2,z2 = table.unpack(GetEntityCoords(object))
		SetEntityHeading(ped,GetEntityHeading(object)-360.0)
		SetPedComponentVariation(ped,5,45,0,2)
		return true,x2,y2,z2
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEREGISTER
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.updateRegister(status)
	registerCoords = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADFISH
-----------------------------------------------------------------------------------------------------------------------------------------
local fishingX = -1306.9
local fishingY = 5823.34
local fishingZ = 2.31
-----------------------------------------------------------------------------------------------------------------------------------------
-- FISHINGSTATUS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.fishingStatus()
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))
	local distance = GetDistanceBetweenCoords(x,y,z,fishingX,fishingY,fishingZ,true)
	if distance <= 400 then
		return true
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FISHINGANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.fishingAnim()
	local ped = PlayerPedId()
	if IsEntityPlayingAnim(ped,"amb@world_human_stand_fishing@idle_a","idle_c",3) then
		return true
	end
	return false
end