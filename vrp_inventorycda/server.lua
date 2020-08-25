-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
local idgens = Tools.newIDGenerator()
local cfg = module("vrp","cfg/groups")
tcRP = {}
Tunnel.bindInterface("vrp_inventory",tcRP)
Proxy.addInterface("vrp_inventory",tcRP)

vCLIENT = Tunnel.getInterface("vrp_inventory")
vGARAGE = Tunnel.getInterface("vrp_garages")
vHOSPITAL = Tunnel.getInterface("vrp_hospital")
vSURVIVAL = Tunnel.getInterface("vrp_survival")
vPLAYER = Tunnel.getInterface("vrp_player")
vPLAYER2 = Tunnel.getInterface("vrp_player2")
vPOLICIA = Tunnel.getInterface("vrp_policia")
vWEPLANTS = Tunnel.getInterface("vrp_weplants")
vHUD = Tunnel.getInterface("vrp_hud")
vHOMES = Tunnel.getInterface("vrp_homes")
vNOTEPAD = Tunnel.getInterface("vrp_notepad")
vRPclient = Tunnel.getInterface("vRP")

local slots = {
	["Admin"] = 100,
	["SlotP"] = 9,
	["SlotM"] = 12,
	["SlotG"] = 15
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookvipiniciado = "https://discordapp.com/api/webhooks/734305392817078382/eaXsnQYXPIrgHAi44F48tIogtIXcmEEBK4FWJxdCvmBvIriJ3g4JqeixL-d3YIsG-HID"
local webhookchangenumber = "https://discordapp.com/api/webhooks/734649512764899334/5gHsKt5W0eTH8N9om3vPeo6JvDV9nlkM1DPIgF7e9_PAkVl8CLSebKLT0swNxoLwh_Ug"

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local active = {}
local bandage = {}
local amountUse = {}
local syringeTime = {}
local blips = {}
local groups = cfg.groups

-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERTIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
local registerBlips = {}
local registerTimers = {}
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(registerTimers) do
			if v[4] > 0 then
				v[4] = v[4] - 1
				if v[4] <= 0 then
					table.remove(registerTimers,k)
					vCLIENT.updateRegister(-1,registerTimers)
				end
			end
		end
		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANDAGE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(bandage) do
			if v > 0 then
				bandage[k] = v - 1
			end
		end
		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYRINGETIME
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(syringeTime) do
			if v > 0 then
				syringeTime[k] = v - 1
			end
		end
		Citizen.Wait(60000)
	end
end)




function tcRP.Identidade()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local cash = vRP.getMoney(user_id)
		local banco = vRP.getBankMoney(user_id)
		local coins = vRP.getCoins(user_id)
		local identity = vRP.getUserIdentity(user_id)
		local foto = identity.foto
		local multas = vRP.getUData(user_id,"vRP:multas")
		local mymultas = json.decode(multas) or 0
		local paypal = vRP.getUData(user_id,"vRP:paypal")
		local mypaypal = json.decode(paypal) or 0
		local bills = vRP.getBills(user_id)
		local job = tcRP.getUserGroupByType(user_id,"job")
		local cargo = tcRP.getUserGroupByType(user_id,"cargo")
		local vip = tcRP.getUserGroupByType(user_id,"vip")
		if identity then
			return vRP.format(parseInt(cash)),vRP.format(parseInt(banco)),vRP.format(parseInt(coins)),identity.name,identity.firstname,identity.age,identity.user_id,identity.registration,identity.phone,job,cargo,vip,vRP.format(parseInt(mybills)),multas,mypaypal
		end
	end
end

function tcRP.getUserGroupByType(user_id,gtype)
	local user_groups = vRP.getUserGroups(user_id)
	for k,v in pairs(user_groups) do
		local kgroup = groups[k]
		if kgroup then
			if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
				return kgroup._config.title
			end
		end
	end
	return ""
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(active) do
			if v > 0 then
				active[k] = v - 1
			end
		end
		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FISHS
-----------------------------------------------------------------------------------------------------------------------------------------
local fishs = {
	[1] = { "octopus" },
	[2] = { "shrimp" },
	[3] = { "carp" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOCHILA
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.Mochila()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local inventory = {}
		local inv = vRP.getInventory(user_id)
		if inv then
			local tSlot = tcRP.verifySlots(user_id)
			if tSlot ~= nil then
				tSlot = tSlot
			else
				tSlot = 11
			end
			for k,v in pairs(inv) do
				tSlot = tSlot - 1
				if vRP.itemBodyList(k) then
					if tSlot >= 0 then
						table.insert(inventory,{
							amount = parseInt(v.amount),
							name = vRP.itemNameList(k),
							index = vRP.itemIndexList(k),
							key = k,
							type = vRP.itemTypeList(k),
							peso = vRP.getItemWeight(k),
							desc = vRP.itemDescList(k)
						})
					end
				end
			end
			return inventory,vRP.getInventoryWeight(user_id),vRP.getInventoryMaxWeight(user_id),tSlot
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEAR MOCHILA
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.NearMochila()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local nplayer = vRPclient.nearestPlayer(source,2)
		if nplayer then
			local nearinventory = {}
			local nuser_id = vRP.getUserId(nplayer)
			local nearinv = vRP.getInventory(nuser_id)
			if nearinv then
				for k,v in pairs(nearinv) do
					if vRP.itemBodyList(k) then
						table.insert(nearinventory,{
							amount = parseInt(v.amount),
							name = vRP.itemNameList(k),
							index = vRP.itemIndexList(k),
							key = k,
							type = vRP.itemTypeList(k),
							peso = vRP.getItemWeight(k),
							desc = vRP.itemDescList(k)
						})
					end
				end
				return nearinventory
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.Armamento()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local armamento = {}
		local armas = vRPclient.getWeapons(source)
		if armas then
			for k,v in pairs(armas) do
				table.insert(armamento,{
					weapon = vRP.itemNameList("wbody|"..k),
					wammo = vRP.format(parseInt(v.ammo)),
					index = vRP.itemIndexList("wbody|"..k),
					type = vRP.itemTypeList(k),
					key = "wbody|"..k
				})
			end
			return armamento
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('arma',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
    if user_id then
        if args[1] then
            if vRP.hasPermission(user_id,"CEO") then
            vRPclient.giveWeapons(source,{[args[1]] = { ammo = 250 }})
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.sendItem(itemName,amount)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		local nplayer = vRPclient.getNearestPlayer(source,2)
		local nuser_id = vRP.getUserId(nplayer)
		local identity = vRP.getUserIdentity(user_id)
		local identitynu = vRP.getUserIdentity(nuser_id)
		if nuser_id and vRP.itemIndexList(itemName) and item ~= vRP.itemIndexList("identidade") then
			if parseInt(amount) > 0 then
				if vRP.getInventoryWeight(nuser_id) + vRP.getItemWeight(itemName) * amount <= vRP.getInventoryMaxWeight(nuser_id) then
					if vRP.tryGetInventoryItem(user_id,itemName,amount) then
						vRP.giveInventoryItem(nuser_id,itemName,amount)
						vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
						TriggerClientEvent("Notify",source,"sucesso","Enviou <b>"..vRP.format(amount).."x "..vRP.itemNameList(itemName).."</b>.",8000)
						TriggerClientEvent("Notify",nplayer,"sucesso","Recebeu <b>"..vRP.format(amount).."x "..vRP.itemNameList(itemName).."</b>.",8000)
						vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
						TriggerClientEvent('Creative:Update',source,'updateMochila')
						TriggerClientEvent('Creative:Update',nplayer,'updateMochila')
						return true
					end
				end
			else
				local data = vRP.getUserDataTable(user_id)
				for k,v in pairs(data.inventory) do
					if itemName == k then
						if vRP.getInventoryWeight(nuser_id) + vRP.getItemWeight(itemName) * parseInt(v.amount) <= vRP.getInventoryMaxWeight(nuser_id) then
							if vRP.tryGetInventoryItem(user_id,itemName,parseInt(v.amount)) then
								vRP.giveInventoryItem(nuser_id,itemName,parseInt(v.amount))
								vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
								TriggerClientEvent("Notify",source,"sucesso","Enviou <b>"..vRP.format(parseInt(v.amount)).."x "..vRP.itemNameList(itemName).."</b>.",8000)
								TriggerClientEvent("Notify",nplayer,"sucesso","Recebeu <b>"..vRP.format(parseInt(v.amount)).."x "..vRP.itemNameList(itemName).."</b>.",8000)
								vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)
								TriggerClientEvent('Creative:Update',source,'updateMochila')
								TriggerClientEvent('Creative:Update',nplayer,'updateMochila')
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
	end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUB
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.roubItem(itemName,amount)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		if user_id and tcRP.getRemaingSlots(user_id) > 0 then
				local nplayer = vRPclient.nearestPlayer(source,1.5)
				local nuser_id = vRP.getUserId(nplayer)
				if nuser_id and vRP.itemBodyList(itemName) then
					if parseInt(amount) > 0 then
						if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(itemName) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
							if vRP.tryGetInventoryItem(nuser_id,itemName,parseInt(amount)) then
								vRP.giveInventoryItem(user_id,itemName,parseInt(amount))
								vRPclient._playAnim(source,true,{"mp_common","givetake1_a"},false)
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								TriggerClientEvent("vrp_inventory:Update",nplayer,"updateMochila")
								TriggerClientEvent("vrp_inventory:Update",source,"updateNearMochila")
								TriggerClientEvent("vrp_inventory:Update",nplayer,"updateNearMochila")
							end
						else
							TriggerClientEvent("Notify",source,"negado","Espaço insuficiente")
						end
					else
						local inv = vRP.getInventory(nuser_id)
						if inv and inv[itemName] ~= nil then
							if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(itemName) * parseInt(inv[itemName].amount) <= vRP.getInventoryMaxWeight(user_id) then
								if vRP.tryGetInventoryItem(nuser_id,itemName,parseInt(inv[itemName].amount)) then
									vRP.giveInventoryItem(user_id,itemName,parseInt(inv[itemName].amount))
									vRPclient._playAnim(source,true,{"mp_common","givetake1_a"},false)
									TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
									TriggerClientEvent("vrp_inventory:Update",nplayer,"updateMochila")
									TriggerClientEvent("vrp_inventory:Update",source,"updateNearMochila")
									TriggerClientEvent("vrp_inventory:Update",nplayer,"updateNearMochila")
								end
							else
								TriggerClientEvent("Notify",source,"negado","Espaço insuficiente")
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.dropItem(itemName,amount)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local x,y,z = vRPclient.getPosition(source)
		if parseInt(amount) > 0 and vRP.tryGetInventoryItem(user_id,itemName,amount) then
			TriggerEvent("DropSystem:create",itemName,amount,x,y,z,3600)
			TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
			vRPclient._playAnim(source,true,{{"pickup_object","pickup_low"}},false)
			TriggerClientEvent('Creative:Update',source,'updateMochila')
			return true
		else
			local data = vRP.getUserDataTable(user_id)
			for k,v in pairs(data.inventory) do
				if itemName == k then
					if vRP.tryGetInventoryItem(user_id,itemName,parseInt(v.amount)) then
						TriggerEvent("DropSystem:create",itemName,parseInt(v.amount),x,y,z,3600)
						TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
						vRPclient._playAnim(source,true,{{"pickup_object","pickup_low"}},false)
						TriggerClientEvent('Creative:Update',source,'updateMochila')
						return true
					end
				end
			end
		end
	end
	return false
	end







-----------------------------------------------------------------------------------------------------------------------------------------
-- GETWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.getWeapon(itemName)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		if user_id and tcRP.getRemaingSlots(user_id) > 0 then
			local uWeapons = vRPclient.getWeapons(source)
			local iName = string.gsub(itemName,"wbody|","")
			if uWeapons[iName] then
				vRP.giveInventoryItem(user_id,"wammo|"..iName,parseInt(uWeapons[iName].ammo))
				vRP.giveInventoryItem(user_id,"wbody|"..iName,1)
				local uTest = uWeapons
				uTest[iName] = nil
				vRPclient._giveWeapons(source,uTest,true)
				TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
				TriggerClientEvent("vrp_inventory:Update",source,"updateArmamento")
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.useItem(itemName,modeType,rAmount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id and parseInt(rAmount) >= 0 then
		if active[parseInt(user_id)] == nil then
			active[parseInt(user_id)] = 0
		end

		if active[parseInt(user_id)] <= 0 then
			if modeType == "use" then
				if itemName == "bandage" then
					if vRPclient.getHealth(source) > 101 and vRPclient.getHealth(source) < 200 then
						if bandage[parseInt(user_id)] == 0 or not bandage[parseInt(user_id)] then
							active[parseInt(user_id)] = 10
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,10000)
							vRPclient._createObjects(source,"amb@world_human_clipboard@male@idle_a","idle_c","v_ret_ta_firstaid",49,60309)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) then
										vRPclient._removeObjects(source)
										bandage[parseInt(user_id)] = 600
										vCLIENT.blockButtons(source,false)
										TriggerClientEvent("bandage",source)
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						else
							TriggerClientEvent("Notify",source,"importante","Aguarde <b>"..bandage[parseInt(user_id)].." segundos</b>.",5000)
						end
					else
						TriggerClientEvent("Notify",source,"alerta","Você não pode usar com a vida cheia ou nocauteado.",5000)
					end
				end

				if itemName == "weed" then
					active[parseInt(user_id)] = 3
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,3000)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							vCLIENT.blockButtons(source,false)
							if vRP.getInventoryItemAmount(user_id,"weed") >= 3 and vRP.getInventoryItemAmount(user_id,"silk") >= 3 then
								if vRP.tryGetInventoryItem(user_id,"weed",3) and vRP.tryGetInventoryItem(user_id,"silk",3) then
									vRP.giveInventoryItem(user_id,"joint",3)
									TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								end
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "skol" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",120)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",120)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "loveshot" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",225)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",225)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "vodka" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",110)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",110)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "vacapreta" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",145)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",145)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "pinga" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",90)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",90)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "corote" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",60)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",60)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "catuaba" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",125)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",125)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "blackvelvet" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",180)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",180)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "mojito" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",200)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",200)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "redlabel"  then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",260)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",260)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "caipirinha"  then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",160)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",160)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "jackdaniel" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",250)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",250)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				if itemName == "tequila" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vRPclient.playScreenEffect(source,"RaceTurbo",210)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",210)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "joint" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._playAnim(source,true,{"mp_player_int_uppersmoke","mp_player_int_smoke"},true)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.setHunger(user_id,20)
								vRP.setThirst(user_id,20)
								vRPclient.playScreenEffect(source,"RaceTurbo",120)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",120)
								vRPclient.setArmour(source,15)
								vRPclient._stopAnim(source,false)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "metanfetamina" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._playAnim(source,true,{"mp_player_int_uppersmoke","mp_player_int_smoke"},true)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.setHunger(user_id,20)
								vRP.setThirst(user_id,20)
								vRPclient.playScreenEffect(source,"RaceTurbo",120)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",120)
								vRPclient.setArmour(source,15)
								vRPclient._stopAnim(source,false)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "cocaina" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._playAnim(source,true,{"mp_player_int_uppersmoke","mp_player_int_smoke"},true)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.setHunger(user_id,20)
								vRP.setThirst(user_id,20)
								vRPclient.setArmour(source,15)
								vRPclient.playScreenEffect(source,"RaceTurbo",120)
								vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",120)
								vRPclient._stopAnim(source,false)
								vCLIENT.blockButtons(source,false)
								vPLAYER2.movementClip(source,"move_m@shadyped@a")
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "warfarin" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vHOSPITAL.resetWarfarin(source)
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "nitro" then
					if not vRPclient.inVehicle(source) then
						local vehicle,vehNet = vRPclient.vehList(source,5)
						if vehicle then
							active[parseInt(user_id)] = 10
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,10000)
							vRPclient._playAnim(source,false,{"mini@repair","fixing_a_player"},true)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) then
										vRPclient._stopAnim(source,false)
										vCLIENT.blockButtons(source,false)
										vHUD.updateNitroClient(-1,vehNet,1000)
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						end
					end
				end

				if itemName == "cellphone" then
					TriggerClientEvent("gcPhone:activePhone",source)
					vCLIENT.closeInventory(source)
				end

				if itemName == "chip" then
					TriggerClientEvent("invgcPhone:useDiscardNumber",source)
					vCLIENT.closeInventory(source)
				end

				if itemName == "newchip" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						local newNumber = vRP.generatePhoneNumber()
						local oldNumber = vRP.query("vRP/get_vrp_users",{ id = parseInt(user_id) })
						local identity = vRP.getUserIdentity(user_id)
						vCLIENT.closeInventory(source)
						vRP.giveInventoryItem(user_id,"chip",1)
						vRP.execute("vRP/change_discardnumber",{ id = parseInt(user_id), phone2 = newNumber })
						TriggerClientEvent("Notify",source,"importante","Seu novo número descartável é :<b>"..newNumber.."</b>")
						TriggerClientEvent("invgcPhone:useDiscardNumber",source)
						if oldNumber.phone2 then
							SendWebhookMessage(webhookchangenumber,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[ANTIGO NÚMERO]: "..oldNumber[1].phone2.."\n[NOVO NÚMERO DESCARTÁVEL]: "..newNumber.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
						else
							SendWebhookMessage(webhookchangenumber,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[PRIMEIRO NÚMERO DESCARTÁVEL]: "..newNumber.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
						end
					end
				end

				if itemName == "adrenaline" then
					local parAmount = vRP.numPermission("Paramedico")
					if parseInt(#parAmount) > 3 then
						TriggerClientEvent("Notify",source,"negado","Existem mais de 3 paramédicos em serviço")
						return
					end

					local nplayer = vRPclient.nearestPlayer(source,2)
					if nplayer then
						local nuser_id = vRP.getUserId(nplayer)
						if nuser_id then
							if vSURVIVAL.deadPlayer(nplayer) then
								active[parseInt(user_id)] = 3
								vRPclient.stopActived(source)
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								TriggerClientEvent("Progress",source,3000)
								vRPclient._playAnim(source,false,{"mini@cpr@char_a@cpr_str","cpr_pumpchest"},true)

								repeat
									if active[parseInt(user_id)] == 0 then
										active[parseInt(user_id)] = -1
										if vRP.tryGetInventoryItem(user_id,itemName,1) then
											vRP.updateThirst(nuser_id,10)
											vRP.updateHunger(nuser_id,10)
											vSURVIVAL._reverseRevive(source)
											vCLIENT.blockButtons(source,false)
											vSURVIVAL._revivePlayer(nplayer,110)
											TriggerClientEvent("resetBleeding",nplayer)
										end
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1
							end
						end
					end
				end

				if itemName == "syringe" then
					local nplayer = vRPclient.nearestPlayer(source,1)
					if nplayer then
						local nuser_id = vRP.getUserId(nplayer)
						if syringeTime[parseInt(nuser_id)] == 0 or not syringeTime[parseInt(nuser_id)] then
							local identity = vRP.getUserIdentity(user_id)
								active[parseInt(user_id)] = 10
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								syringeTime[parseInt(nuser_id)] = 180
								TriggerClientEvent("Progress",source,10000)

								repeat
									local health = vRPclient.getHealth(nplayer)
									if active[parseInt(user_id)] == 0 then
										active[parseInt(user_id)] = -1
										if vRP.tryGetInventoryItem(user_id,itemName,1) then
											vRP.giveInventoryItem(user_id,"bloodbag",3)
											vRPclient.setHealth(nplayer,health-80)
											vCLIENT.blockButtons(source,false)
										end
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1
							end
						else
							TriggerClientEvent("Notify",source,"importante","Aguarde "..vRP.getTimers(parseInt(syringeTime[parseInt(nuser_id)]*60))..".",5000)
						
					end
				end

				if itemName == "bloodbag" then
					if vRP.hasPermission(user_id,"Paramedico") then
						local nplayer = vRPclient.nearestPlayer(source,2)
						if nplayer then
							if not vSURVIVAL.deadPlayer(nplayer) then
								if vRP.tryGetInventoryItem(user_id,itemName,1) then
									vSURVIVAL._startCure(nplayer)
									TriggerClientEvent("resetBleeding",nplayer)
									TriggerClientEvent("resetDiagnostic",nplayer)
									TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
									TriggerClientEvent("Notify",source,"sucesso","Transfusão de sangue iniciada.",10000)
								end
							end
						end
					end
				end

				if itemName == "vest" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRPclient.setArmour(source,100)
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "wbody|GADGET_PARACHUTE" then
					active[parseInt(user_id)] = 10
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vCLIENT.blockButtons(source,false)
								vCLIENT.parachuteColors(source)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "toolbox" then
					if not vRPclient.inVehicle(source) then
						local vehicle,vehNet = vRPclient.vehList(source,5)
						if vehicle then
							if vRP.hasPermission(user_id,"Mecanico") then
								active[parseInt(user_id)] = 30
								vRPclient.stopActived(source)
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								TriggerClientEvent("Progress",source,30000)
								vRPclient._playAnim(source,false,{"mini@repair","fixing_a_player"},true)

								repeat
									if active[parseInt(user_id)] == 0 then
										active[parseInt(user_id)] = -1
										vCLIENT.blockButtons(source,false)
										vRPclient._stopAnim(source,false)
										vCLIENT.repairVehicle(-1,vehNet,true)
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1
							else
								active[parseInt(user_id)] = 30
								vRPclient.stopActived(source)
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								TriggerClientEvent("Progress",source,30000)
								vRPclient._playAnim(source,false,{"mini@repair","fixing_a_player"},true)

								repeat
									if active[parseInt(user_id)] == 0 then
										active[parseInt(user_id)] = -1
										if vRP.tryGetInventoryItem(user_id,itemName,1) then
											vCLIENT.blockButtons(source,false)
											vRPclient._stopAnim(source,false)
											vCLIENT.repairVehicle(-1,vehNet,true)
											TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
										end
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1
							end
						end
					end
				end

				if itemName == "masterpick" then
					local vehicle,vehNet,vehPlate,vehName = vRPclient.vehList(source,2)
					if vehicle then
						if vRPclient.inVehicle(source) then
							active[parseInt(user_id)] = 30
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,30000)
							vGARAGE.startAnimHotwired(source)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									vCLIENT.blockButtons(source,false)
									vGARAGE.stopAnimHotwired(source,vehicle)

									TriggerEvent("setPlateEveryone",vehPlate)
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						else
							active[parseInt(user_id)] = 30
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,30000)
							vRPclient._playAnim(source,false,{"missfbi_s4mop","clean_mop_back_player"},true)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									vCLIENT.blockButtons(source,false)
									vRPclient._stopAnim(source,false)

									vCLIENT.lockpickVehicle(-1,vehNet)
									TriggerEvent("setPlateEveryone",vehPlate)
									TriggerClientEvent("Notify",source,"sucesso","Roubo de veículo concluído com sucesso.",5000)
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						end
					end
				end

				if itemName == "lockpick" then
					local status,x,y,z = vCLIENT.cashRegister(source)
					if status then
						active[parseInt(user_id)] = 10
						vRPclient.stopActived(source)
						vCLIENT.closeInventory(source)
						vCLIENT.blockButtons(source,true)
						table.insert(registerTimers,{ x,y,z,600 })
						vCLIENT.updateRegister(-1,registerTimers)
						TriggerClientEvent("Progress",source,10000)
						vRPclient._playAnim(source,false,{"oddjobs@shop_robbery@rob_till","loop"},true)

						repeat
							if active[parseInt(user_id)] == 0 then
								active[parseInt(user_id)] = -1
								if vRP.tryGetInventoryItem(user_id,itemName,1) then
									vRPclient._removeObjects(source)
									vCLIENT.blockButtons(source,false)
									vRP.giveInventoryItem(user_id,"dirtydollars",math.random(200,400))
									
									if math.random(100) >= 90 then
										vRP.wantedTimer(parseInt(user_id),90)
										vRPclient.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
										TriggerClientEvent("Notify",source,"importante","As autoridades foram notificadas da tentativa de roubo.",3000)
										local copAmount = vRP.numPermission("Policia")
										for k,v in pairs(copAmount) do
											local player = vRP.getUserSource(v)
											if player then
												async(function()
													TriggerClientEvent("NotifyPush",player,{ code = 20, title = "Crime em progresso", x = x, y = y, z = z, badge = "Roubo a caixa registradora" })
												end)
											end
										end
									end
								end
							end
							Citizen.Wait(0)
						until active[parseInt(user_id)] == -1
					else
						if x ~= nil and y ~= nil and z ~= nil then
							for k,v in pairs(registerTimers) do
								if v[1] == x and v[2] == y and v[3] == z then
									TriggerClientEvent("Notify",source,"importante","Aguarde "..vRP.getTimers(parseInt(v[4]))..".",5000)
								end
							end
						end
					end

					local vehicle,vehNet,vehPlate,vehName = vRPclient.vehList(source,2)
					if vehicle then
						if vRPclient.inVehicle(source) then
							active[parseInt(user_id)] = 30
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,30000)
							vGARAGE.startAnimHotwired(source)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) then
										vCLIENT.blockButtons(source,false)
										vGARAGE.stopAnimHotwired(source,vehicle)

										if math.random(100) >= 20 then
											TriggerEvent("setPlateEveryone",vehPlate)
										end

										if math.random(100) >= 50 then
											TriggerClientEvent("Notify",source,"importante","As autoridades foram notificadas da tentativa de roubo.",5000)
											local x,y,z = vRPclient.getPosition(source)
											local copAmount = vRP.numPermission("Policia")
											for k,v in pairs(copAmount) do
												local player = vRP.getUserSource(v)
												if player then
													async(function()
														TriggerClientEvent("NotifyPush",player,{ code = 31, title = "Crime em progresso", x = x, y = y, z = z, badge = "Roubo de veículo", veh = vRP.vehicleName(vehName).." - "..vehPlate })
													end)
												end
											end
										end
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						else
							active[parseInt(user_id)] = 30
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,30000)
							vRPclient._playAnim(source,false,{"missfbi_s4mop","clean_mop_back_player"},true)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) then
										vCLIENT.blockButtons(source,false)
										vRPclient._stopAnim(source,false)

										if math.random(100) >= 50 then
											TriggerClientEvent("Notify",source,"importante","As autoridades foram notificadas da tentativa de roubo.",5000)
											local x,y,z = vRPclient.getPosition(source)
											local copAmount = vRP.numPermission("Policia")
											for k,v in pairs(copAmount) do
												local player = vRP.getUserSource(v)
												if player then
													async(function()
														TriggerClientEvent("NotifyPush",player,{ code = 31, title = "Crime em progresso", x = x, y = y, z = z, badge = "Roubo de veículo", veh = vRP.vehicleName(vehName).." - "..vehPlate })
													end)
												end
											end
										else
											vCLIENT.lockpickVehicle(-1,vehNet)
											TriggerEvent("setPlateEveryone",vehPlate)
											TriggerClientEvent("Notify",source,"sucesso","Roubo de veículo concluído com sucesso.",5000)
										end
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						end
					end
				end

				if itemName == "energetic" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,90)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "water" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_intdrink","loop_bottle","prop_ld_flow_bottle",49,60309)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								vRP.giveInventoryItem(user_id,"emptybottle",1)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "dirtywater" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_intdrink","loop_bottle","prop_ld_flow_bottle",49,60309)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							local health = vRPclient.getHealth(source)
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,25)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								vRPclient.setHealth(source,health-10)
								vRP.giveInventoryItem(user_id,"emptybottle",1)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "milkbottle" then
					if vHUD.getHunger(source) < 95 and vHUD.getThirst(source) < 95 then
						active[parseInt(user_id)] = 10
						vRPclient.stopActived(source)
						vCLIENT.closeInventory(source)
						vCLIENT.blockButtons(source,true)
						TriggerClientEvent("Progress",source,10000)
						vRPclient._createObjects(source,"mp_player_intdrink","loop_bottle","prop_ld_flow_bottle",49,60309)

						repeat
							if active[parseInt(user_id)] == 0 then
								active[parseInt(user_id)] = -1
								if vRP.tryGetInventoryItem(user_id,itemName,1) then
									vRP.updateThirst(user_id,10)
									vRP.updateHunger(user_id,10)
									vRPclient._removeObjects(source)
									vCLIENT.blockButtons(source,false)
									vRP.giveInventoryItem(user_id,"emptybottle",1)
								end
							end
							Citizen.Wait(0)
						until active[parseInt(user_id)] == -1
					end
				end

				if itemName == "cola" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_intdrink","loop_bottle","ng_proc_sodacan_01a",49,60309)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "fishingrod" then
					local status = vCLIENT.fishingStatus(source)
					if status then
						active[parseInt(user_id)] = 10
						vRPclient.stopActived(source)
						vCLIENT.blockButtons(source,true)
						TriggerClientEvent("Progress",source,10000)

						local fishingAnim = vCLIENT.fishingAnim(source)
						if not fishingAnim then
							vRPclient._createObjects(source,"amb@world_human_stand_fishing@idle_a","idle_c","prop_fishing_rod_01",49,60309)
						end

						repeat
							if active[parseInt(user_id)] == 0 then
								active[parseInt(user_id)] = -1
								vCLIENT.blockButtons(source,false)

								local amount = math.random(3)
								local random = math.random(#fishs)

								if vRP.getInventoryWeight(user_id) + vRP.getItemWeight(fishs[parseInt(random)][1]) * parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
									if vRP.tryGetInventoryItem(user_id,"bait",parseInt(amount)) then
										vRP.giveInventoryItem(user_id,fishs[parseInt(random)][1],parseInt(amount))
										TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
									else
										TriggerClientEvent("Notify",source,"alerta","Você precisa <b>"..vRP.format(parseInt(amount)).."x "..vRP.itemNameList(fishs[parseInt(random)][1]).."</b>.",5000)
									end
								else
									TriggerClientEvent("Notify",source,"negado","Sua <b>Mochila</b> está cheia.",5000)
								end
							end
							Citizen.Wait(0)
						until active[parseInt(user_id)] == -1
					end
				end

				if itemName == "emptybottle" then
					local status,style = vCLIENT.checkFountain(source)
					if status then
						vRPclient.stopActived(source)
						vCLIENT.blockButtons(source,true)

						if style == "fountain" then
							amountUse[user_id] = 1
							vCLIENT.closeInventory(source)
							vRPclient._playAnim(source,false,{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"},true)
						elseif style == "floor" then
							amountUse[user_id] = 1
							vCLIENT.closeInventory(source)
							vRPclient._playAnim(source,false,{"amb@world_human_bum_wash@male@high@base","base"},true)
						elseif style == "cow" then
							amountUse[user_id] = 3
							vRPclient._playAnim(source,false,{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"},true)
						end

						active[parseInt(user_id)] = parseInt(amountUse[user_id]*3)

						TriggerClientEvent("Progress",source,parseInt(amountUse[user_id]*3000))

						repeat
							if active[parseInt(user_id)] == 0 then
								active[parseInt(user_id)] = -1
								vRPclient._removeObjects(source)
								vCLIENT.blockButtons(source,false)

								if vRP.getInventoryWeight(user_id)+vRP.getItemWeight(itemName) * parseInt(amountUse[user_id]) <= vRP.getInventoryMaxWeight(user_id) then
									if vRP.tryGetInventoryItem(user_id,itemName,parseInt(amountUse[user_id])) then
										if style == "cow" then
											vRP.giveInventoryItem(user_id,"milkbottle",parseInt(amountUse[user_id]))
											TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
										elseif style == "floor" then
											vRP.giveInventoryItem(user_id,"dirtywater",parseInt(amountUse[user_id]))
										else
											vRP.giveInventoryItem(user_id,"water",parseInt(amountUse[user_id]))
										end
									end
								end
							end
							Citizen.Wait(0)
						until active[parseInt(user_id)] == -1
					end
				end

				if itemName == "coffee" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_aa_coffee@idle_a", "idle_a","prop_fib_coffee",49,28422)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,30)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "cafecleite" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_aa_coffee@idle_a", "idle_a","prop_fib_coffee",49,28422)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,30)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "cafeexpresso" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_aa_coffee@idle_a", "idle_a","prop_fib_coffee",49,28422)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,30)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "capuccino" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_aa_coffee@idle_a", "idle_a","prop_fib_coffee",49,28422)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,30)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "frappuccino" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@world_human_aa_coffee@idle_a", "idle_a","prop_fib_coffee",49,28422)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateThirst(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
								TriggerClientEvent("setEnergetic",source,30)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "hamburger" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "sanduiche" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "rosquinha" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "xburguer" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "chips" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","ng_proc_food_chips01c",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "batataf" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_food_chips",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "pizza" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "frango" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_food_chips",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "bcereal" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_choc_ego",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "bchocolate" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_choc_ego",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "taco" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_taco_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end
				
				if itemName == "yakisoba" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"mp_player_inteat@burger","mp_player_int_eat_burger","prop_cs_burger_01",49,60309)
				
					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,30)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "hotdog" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_cs_hotdog_01",49,28422)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,20)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "donut" then
					active[parseInt(user_id)] = 10
					vRPclient.stopActived(source)
					vCLIENT.closeInventory(source)
					vCLIENT.blockButtons(source,true)
					TriggerClientEvent("Progress",source,10000)
					vRPclient._createObjects(source,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_amb_donut",49,28422)

					repeat
						if active[parseInt(user_id)] == 0 then
							active[parseInt(user_id)] = -1
							if vRP.tryGetInventoryItem(user_id,itemName,1) then
								vRP.updateHunger(user_id,10)
								vRPclient._removeObjects(source,"one")
								vCLIENT.blockButtons(source,false)
							end
						end
						Citizen.Wait(0)
					until active[parseInt(user_id)] == -1
				end

				if itemName == "postit" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						vCLIENT.closeInventory(source)
						vNOTEPAD.createNotepad(source)
					end
				end

				if itemName == "backpackp" then
					local exp = vRP.getExperience(user_id,"backpack")
					if exp < 30 then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							vRP.setExperience(user_id,"backpack",30)
							TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
						end
					else
						TriggerClientEvent("Notify",source,"alerta","No momento, você não pode usar a mochila.",5000)
					end
				end

				if itemName == "backpackm" then
					local exp = vRP.getExperience(user_id,"backpack")
					if exp >= 30 and exp < 60 then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							vRP.setExperience(user_id,"backpack",60)
							TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
						end
					else
						TriggerClientEvent("Notify",source,"alerta","No momento, você não pode usar a mochila.",5000)
					end
				end

				if itemName == "backpackg" then
					local exp = vRP.getExperience(user_id,"backpack")
					if exp >= 60 and exp < 90 then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							vRP.setExperience(user_id,"backpack",90)
							TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
						end
					else
						TriggerClientEvent("Notify",source,"alerta","No momento, você não pode usar a mochila.",5000)
					end
				end

				if itemName == "compost" then
					local homeEnter = vHOMES.getHomeStatistics(source)
					if homeEnter == "" then
						local amountPlants,plantWater = vWEPLANTS.getQuantidade(source,parseInt(user_id))

						if not amountPlants then
							TriggerClientEvent("Notify",source,"negado","O limite máximo de plantações foi atingido.",3000)
							return
						end

						if plantWater then
							TriggerClientEvent("Notify",source,"negado","Só pode ser plantado em terra.",3000)
							return
						end

						local status,x,y,z = vWEPLANTS.entityInWorldCoords(source)
						if status and vRP.getInventoryItemAmount(user_id,"bucket") >= 1 then
							active[parseInt(user_id)] = 10
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,10000)
							vRPclient._playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) and vRP.tryGetInventoryItem(user_id,"bucket",1) then
										vWEPLANTS.pressPlants(source,x,y,z)
										vCLIENT.blockButtons(source,false)
										vRPclient._stopAnim(source,false)
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						end
					end
				end

				if itemName == "mapgps" then
					TriggerClientEvent("toggleGps",source)
				end

				if itemName == "tires" then
					if not vRPclient.inVehicle(source) then
						local vehicle,vehNet = vRPclient.vehList(source,5)
						if vehicle then
							active[parseInt(user_id)] = 20
							vRPclient.stopActived(source)
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,20000)
							vRPclient._playAnim(source,false,{"mini@repair","fixing_a_player"},true)

							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									if vRP.tryGetInventoryItem(user_id,itemName,1) then
										vCLIENT.repairTires(-1,vehNet)
										vCLIENT.blockButtons(source,false)
										vRPclient._stopAnim(source,false)
									end
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1
						end
					end
				end

				if itemName == "plate" then
					if vCLIENT.plateDistance(source) then
						active[parseInt(user_id)] = 10
						vCLIENT.closeInventory(source)
						vCLIENT.blockButtons(source,true)
						TriggerClientEvent("Progress",source,10000)
						TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")

						repeat
							if active[parseInt(user_id)] == 0 then
								active[parseInt(user_id)] = -1
								if vRP.tryGetInventoryItem(user_id,itemName,1) then
									local plate = vRP.genPlate()
									vCLIENT.plateApply(source,plate)
									vCLIENT.blockButtons(source,false)
									TriggerEvent("setPAtrasadoEveryone",plate)
								end
							end
							Citizen.Wait(0)
						until active[parseInt(user_id)] == -1
					end
				end

				if itemName == "radio" then
					if parseInt(rAmount) >= 1 and parseInt(rAmount) <= 999 then
						if parseInt(rAmount) == 911 then
							if vRP.hasPermission(user_id,"Policia") then
								vCLIENT.startFrequency(source,911)
								TriggerClientEvent("vrp_hud:RadioDisplay",source,911)
								TriggerClientEvent("Notify",source,"sucesso","Entrou na <b>"..parseInt(rAmount)..".0Mhz</b> Frequência da Policia.",5000)
							end
						elseif parseInt(rAmount) == 112 then
							if vRP.hasPermission(user_id,"Paramedico") then
								vCLIENT.startFrequency(source,112)
								TriggerClientEvent("vrp_hud:RadioDisplay",source,112)
								TriggerClientEvent("Notify",source,"sucesso","Entrou na <b>"..parseInt(rAmount)..".0Mhz</b> Frequência dos Paramedicos.",5000)
							end
						elseif parseInt(rAmount) == 443 then
							if vRP.hasPermission(user_id,"Mecanico") then
								vCLIENT.startFrequency(source,443)
								TriggerClientEvent("vrp_hud:RadioDisplay",source,443)
								TriggerClientEvent("Notify",source,"sucesso","Entrou na <b>"..parseInt(rAmount)..".0Mhz</b> Frequência dos Mecanicos.",5000)
							end
						else
							vCLIENT.startFrequency(source,parseInt(rAmount))
							TriggerClientEvent("vrp_hud:RadioDisplay",source,parseInt(rAmount))
							TriggerClientEvent("Notify",source,"sucesso","Entrou na <b>"..parseInt(rAmount)..".0Mhz</b> Frequência.",5000)
						end
					else
						TriggerClientEvent("radio:outServers",source)
						TriggerClientEvent("vrp_hud:RadioDisplay",source,0)
						TriggerClientEvent("Notify",source,"importante","Rádio desativado no momento.",5000)
					end
				end

				if itemName == "divingsuit" then
					if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
						local model = vRPclient.getModelPlayer(source)
						if model == "mp_m_freemode_01" then
							TriggerClientEvent("updateRoupas",source,{ 57,0,-1,0,-1,0,31,0,94,0,123,0,67,0,243,0,-1,0,-1,0,-1,0,26,0,-1,0,-1,0,-1,0 })
						elseif model == "mp_f_freemode_01" then
							TriggerClientEvent("updateRoupas",source,{ 57,0,-1,0,-1,0,18,0,97,0,153,0,70,0,251,0,-1,0,-1,0,-1,0,28,0,-1,0,-1,0,-1,0 })
						end
					end
				end

				if itemName == "uniforme1" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 0,0, 12,0, 58,0, 25,0, 208,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme2" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 0,0, 17,10, 58,0, 25,0, 208,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme3" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 0,0, 47,0, 58,0, 25,0, 208,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme4" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 47,0, 129,0, 25,0, 208,6, 7,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme5" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 47,0, 129,0, 25,0, 208,6, 7,0, 0,0, -1,-1, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme6" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 47,0, 129,0, 25,0, 208,6, 7,0, 0,0, 58,0, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme7" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 47,0, 129,0, 25,0, 51,0, 7,0, 0,0, -1,-1, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme8" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 47,0, 129,0, 25,0, 51,0, 7,0, 0,0, 58,0, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 50,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme9" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 1,0, 0,0, 49,0, 129,0, 25,0, 51,0, 7,0, 0,0, 106,20, 0,0, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme10" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then ------ bugado
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,2, 1,0, 0,0, 59,9, 129,0, 25,0, 276,0, 8,0, 0,0, -1,0, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end
				
				if itemName == "uniforme11" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then  -- bugado
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,2, 1,0, 0,0, 59,9, 129,0, 25,0, 276,0, 8,0, 0,0, -1,0, 5,1, -1,-1, -1,-1, -1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0, 0,0, 0,0, 44,0, 90,6, 35,0, 25,0, 224,6, 0,0, 0,0, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 })
							end
						end
					end	
				end

				if itemName == "uniforme15" then
					if vRP.tryGetInventoryItem(user_id,itemName,1) then  -- bugado paramedico
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source) --59,9
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 121,0 ,0,0 ,126,0, 92,1, 25,1 ,56,0, 7,0, 13,0, 0,0, -1,0, -1,0, -1,0, -1,0, -1,0, -1,0 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 121,0, 0,0, 96,0, 98,1, 23,0, 27,0, 7,3, 27,0, 0,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0 })
							end
						end
					end	
				end
				
				if itemName == "uniforme16" then -- bugado paramedico
					if vRP.tryGetInventoryItem(user_id,itemName,1) then
						if not vRP.wantedReturn(user_id) and not vRP.reposeReturn(user_id) then
							local model = vRPclient.getModelPlayer(source)
							if model == "mp_m_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0,0,0,0,0,37,0,43,0,68,0,25,0,77,0,0,0,61,0,45,0,-1,-1,-1,-1,-1,-1,-1,-1 })
							elseif model == "mp_f_freemode_01" then
								TriggerClientEvent("updateRoupas",source,{ 0,0,0,0,0,0,33,0,18,0,48,0,25,0,64,0,0,0,0,0,44,0,-1,-1,-1,-1,-1,-1,-1,-1 })
							end
						end
					end	
				end
				
				if itemName == "capuz" then
					if not vRPclient.inVehicle(source) then
						local nplayer = vRPclient.nearestPlayer(source,2)
						if nplayer then
							active[parseInt(user_id)] = 5
							vCLIENT.closeInventory(source)
							vCLIENT.blockButtons(source,true)
							TriggerClientEvent("Progress",source,5000)
							TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
							repeat
								if active[parseInt(user_id)] == 0 then
									active[parseInt(user_id)] = -1
									vRPclient.toggleCapuz(nplayer)
									TriggerClientEvent("Notify",source,"sucesso","Capuz utilizado com sucesso.",8000)
									vRPclient._stopAnim(nplayer,false)
								end
								Citizen.Wait(0)
							until active[parseInt(user_id)] == -1					
						end
					end
				end
				
				if itemName == "handcuff" then
					if not vRPclient.inVehicle(source) then
						local nplayer = vRPclient.nearestPlayer(source,2)
						if nplayer then
							if vPOLICIA.getHandcuff(nplayer) then
								active[parseInt(user_id)] = 3
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								TriggerClientEvent("Progress",source,3000)
								TriggerClientEvent('carregar',nplayer,source)
								vRPclient._playAnim(source,false,{"mp_arresting","a_uncuff"},false)
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								repeat
									if active[parseInt(user_id)] == 0 then
										vPOLICIA.toggleHandcuff(nplayer)
										TriggerClientEvent('carregar',nplayer,source)
										TriggerClientEvent("vrp_sound:source",source,'uncuff',0.1)
										TriggerClientEvent("vrp_sound:source",nplayer,'uncuff',0.1)	
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1	
							else
								active[parseInt(user_id)] = 5
								vCLIENT.closeInventory(source)
								vCLIENT.blockButtons(source,true)
								TriggerClientEvent("Progress",source,5000)
								TriggerClientEvent('cancelando',source,true)
								TriggerClientEvent('cancelando',nplayer,true)
								TriggerClientEvent('carregar',nplayer,source)
								vRPclient._playAnim(source,false,{"mp_arrest_paired","cop_p2_back_left"},false)
								vRPclient._playAnim(nplayer,false,{"mp_arrest_paired","crook_p2_back_left"},false)
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								repeat
									if active[parseInt(user_id)] == 0 then
										vRPclient._stopAnim(source,false)
										vPOLICIA.toggleHandcuff(nplayer)
										TriggerClientEvent('carregar',nplayer,source)
										TriggerClientEvent('cancelando',source,false)
										TriggerClientEvent('cancelando',nplayer,false)
										TriggerClientEvent("vrp_sound:source",source,'cuff',0.1)
										TriggerClientEvent("vrp_sound:source",nplayer,'cuff',0.1)
									end
									Citizen.Wait(0)
								until active[parseInt(user_id)] == -1	
							end
						end
					end
				end

				if itemName == "rope" then
					local nplayer = vRPclient.nearestPlayer(source,2)
					if nplayer then
						vPLAYER.toggleCarry(nplayer,source)
					end
				end
				
				if itemName == "slotp" then
					if not vRP.hasPermission(parseInt(user_id),"SlotM") and not vRP.hasPermission(parseInt(user_id),"SlotG") and not vRP.hasPermission(parseInt(user_id),"SlotP") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "SlotP" })
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você já possui <b>um bolso</b> maior ou igual.",5000)
					end
				end
				
				if itemName == "slotm" then
					if not vRP.hasPermission(parseInt(user_id),"SlotM") and not vRP.hasPermission(parseInt(user_id),"SlotG") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/del_group",{ user_id = user_id, permiss = "SlotP" })
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "SlotM" })
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você já possui <b>um bolso</b> maior ou igual.",5000)
					end
				end
				
				if itemName == "slotg" then
					if not vRP.hasPermission(parseInt(user_id),"SlotG") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/del_group",{ user_id = user_id, permiss = "SlotP" })
								vRP.execute("vRP/del_group",{ user_id = user_id, permiss = "SlotM" })
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "SlotG" })
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você já possui <b>um bolso</b> maior ou igual.",5000)
					end
				end

				if itemName == "premium01" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium01" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 3 })
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium01 = Vip de Evento"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end

				if itemName == "premium02" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium02" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								local gainGaragem = 2
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium02 = Vip Bronze"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end

				if itemName == "premium03" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium03" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								vRP.execute("vRP/set_priority",{ steam = identity.steam, priority = 30 })
								local gainGaragem = 4
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium03 = Vip Prata"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end

				if itemName == "premium04" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium04" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								vRP.execute("vRP/set_priority",{ steam = identity.steam, priority = 50 })
								local gainGaragem = 6
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium04 = Vip Gold"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end

				if itemName == "premium05" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium05" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								vRP.execute("vRP/set_priority",{ steam = identity.steam, priority = 60 })
								local gainGaragem = 8
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium05 = Vip Platina"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end
 
				if itemName == "premium06" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium06" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								vRP.execute("vRP/set_priority",{ steam = identity.steam, priority = 70 })
								local gainGaragem = 10
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium06 = Vip Diamante"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end

				if itemName == "premium07" then
					if not vRP.getPremium(user_id) and not vRP.hasPermission(parseInt(user_id),"Premium01") and not vRP.hasPermission(parseInt(user_id),"Premium02") and not vRP.hasPermission(parseInt(user_id),"Premium03") and not vRP.hasPermission(parseInt(user_id),"Premium04") and not vRP.hasPermission(parseInt(user_id),"Premium05") and not vRP.hasPermission(parseInt(user_id),"Premium06") and not vRP.hasPermission(parseInt(user_id),"Premium07") then
						if vRP.tryGetInventoryItem(user_id,itemName,1) then
							local identity = vRP.getUserIdentity(user_id)
							if identity then
								TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
								vRP.execute("vRP/add_group",{ user_id = user_id, permiss = "Premium07" })
								vRP.execute("vRP/set_premium",{ steam = identity.steam, premium = parseInt(os.time()), predays = 30 })
								vRP.execute("vRP/set_priority",{ steam = identity.steam, priority = 80 })
								local gainGaragem = 12
								while gainGaragem ~=0 do
									vRP.execute("vRP/update_garages",{  id = parseInt(user_id) })
									gainGaragem = gainGaragem - 1
								end
								SendWebhookMessage(webhookvipiniciado,"```prolog\n[=========VIP ATIVADO=========] \n[ID]: "..user_id.." "..identity.name.." "..identity.name2.." \n[VIP]: Premium07 = Vip Asgard"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
							end
						end
					else
						TriggerClientEvent("Notify",source,"importante","Você tem benefícios <b>Premium</b> atualmente ativo.",5000)
					end
				end
			end

			if modeType == "equipar" then
				if vRP.tryGetInventoryItem(user_id,itemName,1) then
					local weapons = {}
					weapons[string.gsub(itemName,"wbody|","")] = { ammo = 0 }
					vRPclient._giveWeapons(source,weapons)
					TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
				end
			end

			if modeType == "recarregar" then
				local uweapons = vRPclient.getWeapons(source)
				local weaponuse = string.gsub(itemName,"wammo|","")
				if uweapons[weaponuse] then
					if vRP.tryGetInventoryItem(user_id,"wammo|"..weaponuse,parseInt(rAmount)) then
						local weapons = {}
						weapons[weaponuse] = { ammo = parseInt(rAmount) }
						vRPclient._giveWeapons(source,weapons,false)
						TriggerClientEvent("vrp_inventory:Update",source,"updateMochila")
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERLEAVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerLeave",function(user_id,source)
	local source = source
	if not vRP.getPremium(user_id) and not vRP.hasPermission(user_id,"CEO") then
		local identity = vRP.getUserIdentity(user_id)
		if identity then
			vRP.execute("vRP/update_priority",{ steam = identity.steam })
		end
	end
	
	active[user_id] = nil
	bandage[user_id] = nil
	amountUse[user_id] = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP_INVENTORY:CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("vrp_inventory:Cancel")
AddEventHandler("vrp_inventory:Cancel",function()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if active[parseInt(user_id)] == nil then
			active[parseInt(user_id)] = 0
		end

		if active[parseInt(user_id)] > 0 then
			active[parseInt(user_id)] = -1
			TriggerClientEvent("Progress",source,1500)

			SetTimeout(1000,function()
				vRPclient._removeObjects(source)
				vCLIENT.blockButtons(source,false)
				vGARAGE.updateHotwired(source,false)
			end)
		else
			vRPclient._removeObjects(source)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKRADIO
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.checkRadio()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id,"radio") < 1 then
			return true
		end
		return false
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function tcRP.checkInventory()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if active[parseInt(user_id)] == nil then
			active[parseInt(user_id)] = 0
		end

		if active[parseInt(user_id)] > 0 then
			return false
		end
		return true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPSBUY
-----------------------------------------------------------------------------------------------------------------------------------------
local propsBuy = {
	["coffee"] = { "prop_vend_coffe_01",18 },
	["hamburger"] = { "prop_burgerstand_01",25 },
	["hotdog"] = { "prop_hotdogstand_01",18 },
	["cola"] = { "prop_vend_soda_01",18 },
	["donut"] = { "prop_vend_snak_01",9 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("buy",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		if propsBuy[tostring(args[1])] then
			if vCLIENT.checkObjects(source,propsBuy[tostring(args[1])][1]) then
				if tcRP.haveMoreSlots(user_id) and vRP.getInventoryWeight(user_id)+vRP.getItemWeight(tostring(args[1])) <= vRP.getInventoryMaxWeight(user_id) then
					if vRP.fullPayment(user_id,parseInt(propsBuy[tostring(args[1])][2])) then
						vRP.giveInventoryItem(user_id,tostring(args[1]),1)
					end
				end
			end
		end
	end
end)

function tcRP.verifySlots(user_id)
	for k,v in pairs(slots) do
		if vRP.hasPermission(user_id,k) then
			return v
		end
	end
end

function tcRP.getRemaingSlots(user_id)
	local tSlot = tcRP.verifySlots(user_id)
	if tSlot ~= nil then
		tSlot = tSlot
	else
		tSlot = 11
	end
	for k,v in pairs(vRP.getInventory(user_id)) do
		tSlot = tSlot - 1
	end
	return tSlot
end


function tcRP.haveMoreSlots(user_id)
	if tcRP.getRemaingSlots(user_id) > 0 then
		return true
	else
		return false
	end
end