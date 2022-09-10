local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj
            Citizen.Wait(0)
		end)
	end

end)

-- ID

RegisterCommand("bmx",function()
	local playerCoords, playerHeading = GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1))
	local model = GetHashKey('bmx')
	ESX.Game.SpawnVehicle('bmx', playerCoords, playerHeading, function(vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
		SetVehicleDirtLevel(vehicle, 0)
		SetVehicleFuelLevel(vehicle, 100.0)
	end)
end)

RegisterCommand("delbmx",function()
	local ped = GetPlayerPed( -1 )

    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
        local pos = GetEntityCoords( ped )

        if ( IsPedSittingInAnyVehicle( ped ) ) then 
            local vehicle = GetVehiclePedIsIn( ped, false )

            if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
                DeleteGivenVehicle( vehicle, numRetries )
            else 
                ESX.ShowNotification( "Vous devez être à la place du conducteur !" )
            end 
        else
            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( ped, 0.0, distanceToCheck, 0.0 )
            local vehicle = GetVehicleInDirection( ped, pos, inFrontOfPlayer )

            if ( DoesEntityExist( vehicle ) ) then 
                DeleteGivenVehicle( vehicle, numRetries )
            else 
                ESX.ShowNotification( "~y~Vous devez être dans ou près d'un véhicule pour le supprimer." )
            end 
        end 
    end
end)

function DeleteGivenVehicle( veh, timeoutMax )
    local timeout = 0 

    SetEntityAsMissionEntity( veh, true, true )
    DeleteVehicle( veh )

    if ( DoesEntityExist( veh ) ) then
        ESX.ShowNotification( "~r~Échec de la suppression du véhicule, réessayer..." )

        
        while ( DoesEntityExist( veh ) and timeout < timeoutMax ) do 
            DeleteVehicle( veh )

           
            if ( not DoesEntityExist( veh ) ) then 
                ESX.ShowNotification( "~g~Véhicule supprimée" )
            end 

            
            timeout = timeout + 1 
            Citizen.Wait( 500 )

            
            if ( DoesEntityExist( veh ) and ( timeout == timeoutMax - 1 ) ) then
                ESX.ShowNotification( "~r~Failed to delete vehicle after " .. timeoutMax .. " retries." )
            end 
        end 
    else 
        ESX.ShowNotification( "~g~Vehicle supprimée." )
    end 
end 


function GetVehicleInDirection( entFrom, coordFrom, coordTo )
	local rayHandle = StartShapeTestCapsule( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 5.0, 10, entFrom, 7 )
    local _, _, _, _, vehicle = GetShapeTestResult( rayHandle )
    
    if ( IsEntityAVehicle( vehicle ) ) then 
        return vehicle
    end 
end