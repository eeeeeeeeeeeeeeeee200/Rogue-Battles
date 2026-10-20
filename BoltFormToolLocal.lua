local tool = script.Parent
local player = game.Players.LocalPlayer
local toolEvent = game.ReplicatedStorage.Events.ToolBindable
local toolRemote = game.ReplicatedStorage.Events.ToolRemoteEvent

local debounce = false


tool.Equipped:Connect(function()
	if debounce == true then return end
	local character = player.Character
	if character then
		debounce = true
		toolEvent:Fire("BoltForm", true)
        toolRemote:FireServer("Bolt Form", 1)
		task.wait(1)
		debounce = false
	end
end)

tool.Unequipped:Connect(function()
	local character = player.Character
	if character then
		toolEvent:Fire("BoltForm", false)
        toolRemote:FireServer("Bolt Form", 0)
	end
end)


