local cam = nil
local hasBeenToggled = false
local sleep = true
local playerPed
local playerId

function shuffle(table)
	for i = #table, 2, -1 do
		local j = math.random(i)
		table[i], table[j] = table[j], table[i]
	end
	return table
end

-- Boilerplate contains check function
function contains(table, element)
	if table ~= 0 then
		for k, v in pairs(table) do
			if v == element then
				return true
			end
		end
	end
	return false
end

-- Boilerplace function to create var string
function CreateVarString(p0, p1, variadic)
	return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function startCameraMovable()
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
end

-- Main thread
CreateThread(function()
	local entityCoords
	local oldPosition
	local newX
	local newY
	local newZ
	while true do

		Wait(1)

		while not sleep do

			Wait(1)

			playerId = PlayerId()
			playerPed = GetPlayerPed(playerId)
			entityCoords = GetEntityCoords(playerPed)

			if not hasBeenToggled then
				Wait(3000)
				hasBeenToggled = true
				startCameraMovable()
				SetCamCoord(cam, entityCoords.x, entityCoords.y, entityCoords.z)
				newX = entityCoords.x
				newY = entityCoords.y
				newZ = entityCoords.z
			end

			if oldPosition ~= entityCoords then
				newX = entityCoords.x
				newY = entityCoords.y
				SetCamCoord(cam, newX, newY, newZ)
			end

			oldPosition = entityCoords

			SetCamRot(cam, -90.0, 0.0, 0.0)

			while IsControlPressed(0, Config.ControlAction.ZoomOut) do
				Wait(1)
				newZ = newZ + 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newZ >= entityCoords.z + Config.MaxZoomDistance then
					newZ = entityCoords.z + Config.MaxZoomDistance
				end
			end
			while IsControlPressed(0, Config.ControlAction.ZoomIn) do
				Wait(1)
				newZ = newZ - 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newZ <= entityCoords.z then
					newZ = entityCoords.z
				end
			end
			while IsControlPressed(0, Config.ControlAction.PanUp) do
				Wait(1)
				newY = newY + 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newY >= entityCoords.y + Config.MaxPanDistance then
					newY = entityCoords.y + Config.MaxPanDistance
				end
			end
			while IsControlPressed(0, Config.ControlAction.PanDown) do
				Wait(1)
				newY = newY - 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newY <= entityCoords.y - Config.MaxPanDistance then
					newY = entityCoords.y - Config.MaxPanDistance
				end
			end
			while IsControlPressed(0, Config.ControlAction.PanRight) do
				Wait(1)
				newX = newX + 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newX >= entityCoords.x + Config.MaxPanDistance then
					newX = entityCoords.x + Config.MaxPanDistance
				end
			end
			while IsControlPressed(0, Config.ControlAction.PanLeft) do
				Wait(1)
				newX = newX - 0.09
				SetCamCoord(cam, newX, newY, newZ)
				if newX <= entityCoords.x - Config.MaxPanDistance then
					newX = entityCoords.x - Config.MaxPanDistance
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(250)
		local playerId = PlayerId()
		local playerPed = GetPlayerPed(playerId)
		if IsPedDeadOrDying(playerPed) or IsEntityDead(playerPed) or IsPlayerDead(playerId) or IsPedFatallyInjured(PlayerPedId())then
			RenderScriptCams(true, false, 0, true, true, 0)
			sleep = false
		else
			hasBeenToggled = false
			sleep = true
		end
	end
end)