-- named it handler because of cool fadartim
local rS = game:GetService("ReplicatedStorage")
local event = rS:WaitForChild("Events"):WaitForChild("ToolRemoteEvent")
local invSystem = require(rS:WaitForChild("Systems"):WaitForChild("InvSystem"))
local Debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")
local trainingData = require(rS:WaitForChild("Data"):WaitForChild("TrainingData"))
local weaponData = require(rS:WaitForChild("Data"):WaitForChild("WeaponData"))
local visualSystem = require(rS:WaitForChild("Systems"):WaitForChild("VisualSystem"))

-- template name: no caps, no spaces
-- real name: the one you want to see in your inventory( capitalize it and space words )
local scrollableItems = {
	["tanzanite"] = {
		templateName = "waterscroll",
		realName = "Water Scroll"		
	},
	["jade"] = {
		templateName = "healingscroll",
		realName = "Healing Scroll"		
	},
	["blackrock"] = {
		templateName = "lavascroll",
		realName = "Lava Scroll"		
	},
	["onyx"] = {
		templateName = "firescroll",
		realName = "Fire Scroll"		
	},
}

local fusionableGems = {
	["tanzanite"] = {
		result = "Lolite",
		combines = "onyx"
	},
	["onyx"] = {
		result = "Lolite",
		combines = "tanzanite"
	},
	["jade"] = {
		result = "Chartreuse",
		combines = "ametrine"
	},
	["blackrock"] = {
		result = "Lolite",
		combines = "jade"
	},
	["ametrine"] = {
		result = "Chartreuse",
		combines = "jade"
	},
}
event.OnServerEvent:Connect(function(player, tool, arg3)
	local char = player.Character
	if not char or not char:FindFirstChild("Humanoid") then return end
	if not tool then return end
	local slotData = require(char.InstanceData)
	if tool == "Scroll Crafting" then
		if not player.Character or not player.Character.HumanoidRootPart then return end
		for i, v in pairs(workspace:GetChildren()) do
			if v:GetAttribute("Scrolling") then return end
			local item = scrollableItems[v.Name]
			if item then
				print("found a " .. v.Name)
				local itemPart = v:IsA("Model") and v.PrimaryPart or v
				local itemPos = itemPart.Position
				local distance = (player.Character.HumanoidRootPart.Position - itemPos).Magnitude
				if distance <= 10 then
					v:SetAttribute("Scrolling", true)
					if v:FindFirstChild("ClickHitbox") then v.ClickHitbox:Destroy() end
					local info = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					local tween = tweenService:Create(itemPart, info, {CFrame = itemPart.CFrame * CFrame.new(0,2.5,0)})
					-- playing this one makes the item float up
					tween:Play()
					-- only do the rest once its completed
					tween.Completed:Wait()
					-- magic ball around the thingaling
					local sphere = Instance.new("Part")
					sphere.Shape = Enum.PartType.Ball
					sphere.Size = Vector3.new(0.5,0.5,0.5)
					sphere.Anchored = true
					sphere.CanCollide = false
					sphere.Transparency = 0.5
					sphere.Material = Enum.Material.Neon
					sphere.Color = Color3.new(0.666667, 0, 0.498039)
					sphere.Position = itemPart.Position
					sphere.Parent = workspace
					local sizeChange = nil
					if v:IsA("Model") then 
						sizeChange = Vector3.new(1,1,1)
					else
						sizeChange = itemPart.Size
					end
					local tween2 = tweenService:Create(sphere, info, {Size = sizeChange + Vector3.new(2,2,2)})
					tween2:Play()
					tween2.Completed:Wait()
					-- make the scroll/new item

					local spawningItem = rS.Templates:FindFirstChild(item.templateName):Clone()
					spawningItem:PivotTo(itemPart.CFrame)
					spawningItem.Parent = workspace
					v:Destroy()
					sphere:Destroy()
					local tween3 = tweenService:Create(spawningItem, info, {CFrame = spawningItem.CFrame * CFrame.new(0,-2.5,0)})
					-- move item down
					tween3:Play()
					tween3.Completed:Wait()
					local hitbox = Instance.new("Part")
					hitbox.Name = "ClickHitbox"
					hitbox.Transparency = 1
					hitbox.CanCollide = false
					hitbox.Massless = true

					if spawningItem:IsA("Model") then
						local orientation, size = spawningItem:GetBoundingBox()
						hitbox.Size = size
						hitbox.CFrame = orientation
					else
						hitbox.Size = spawningItem.Size
						hitbox.CFrame = spawningItem.CFrame
					end

					hitbox.Parent = spawningItem

					local weld = Instance.new("WeldConstraint")
					weld.Part0 = hitbox
					weld.Part1 = spawningItem:IsA("Model") and (spawningItem.PrimaryPart or spawningItem:FindFirstChildWhichIsA("BasePart")) or spawningItem
					weld.Parent = hitbox
					spawningItem:SetAttribute(player.Name, true)
					local cd = Instance.new("ClickDetector")
					cd.MaxActivationDistance = 10
					cd.Parent = hitbox

					local clicked = false
					cd.MouseClick:Connect(function(clickingPlayer)
						if clicked then return end

						if spawningItem:GetAttribute(clickingPlayer.Name) then

							clicked = true

							local added = invSystem.AddItem(clickingPlayer, item.realName, 1)
							if added then
								Debris:AddItem(spawningItem, 0)
							else
								clicked = false
							end
						end
					end)

					Debris:AddItem(spawningItem, 120) 
					break
				end
			end
		end

	elseif tool == "Gem Fuse" then
		if not player.Character or not player.Character.HumanoidRootPart then return end
		local leftArm = player.Character:FindFirstChild("Left Arm")
		local rightArm = player.Character:FindFirstChild("Right Arm")

		local gem1 = nil
		local gem2 = nil

		for i, v in pairs(workspace:GetChildren()) do
			if v:GetAttribute("Fusing") then continue end
			local item = fusionableGems[v.Name]
			if item then
				print("found a " .. v.Name)
				local distance = (player.Character.HumanoidRootPart.Position - v.Position).Magnitude
				if distance <= 10 then
					if not gem1 then
						gem1 = v
					elseif not gem2 then
						gem2 = v
					end
					if gem1 and gem2 then
						break
					end
				end
			end
		end
		if gem1 and gem2 then
			event:FireClient(player, "Play Anim")
			if fusionableGems[gem1.Name].combines == gem2.Name then
				local newItem = fusionableGems[gem1.Name].result
				gem1:SetAttribute("Fusing", true)
				gem1.Anchored = false
				gem1.ClickHitbox:Destroy()
				gem2:SetAttribute("Fusing", true)
				gem2.Anchored = false
				gem2.ClickHitbox:Destroy()
				player.Character.HumanoidRootPart.Anchored = true
				gem1:PivotTo(leftArm.CFrame * CFrame.new(0, -1, 0))
				gem2:PivotTo(rightArm.CFrame * CFrame.new(0, -1, 0))
				local gem1Model = false
				local gem2Model = false
				if gem1:IsA("Model") then gem1Model = true end
				if gem2:IsA("Model") then gem2Model = true end

				local weld1 = Instance.new("WeldConstraint")
				weld1.Part0 = leftArm
				weld1.Part1 = gem1:IsA("Model") and gem1.PrimaryPart or gem1
				weld1.Parent = gem1
				local weld2 = Instance.new("WeldConstraint")
				weld2.Part0 = rightArm
				weld2.Part1 = gem2:IsA("Model") and gem2.PrimaryPart or gem2
				weld2.Parent = gem2

				task.wait(1)

				player.Character.HumanoidRootPart.Anchored = false
				-- incase someone somehow picks up a gem riiiight before i destroy the clickdetector, dont give them the item
				if not gem1 or not gem2 then return end
				gem1:Destroy()
				gem2:Destroy()
				invSystem.AddItem(player, newItem, 1)
			end
		end
	elseif tool == "Soul Stab" then
		print("tool used")
		if not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then return end
		if slotData.QuestProgress and slotData.QuestProgress.Barbarian and slotData.QuestProgress.Barbarian >= 5 then
			slotData.QuestProgress.Barbarian -= 5
			local prog = trainingData.ZanshiProgression
			local skillToLearn = nil
			for i, v in ipairs(prog) do
				if slotData.SkillsLearned[v] then
					continue
				end
				skillToLearn = v
				break
			end
			if not skillToLearn then print("no skills left to learn") return end
			print(skillToLearn)
			local weapon = weaponData:GetWeaponOfType(slotData.Weapons, "sword")
			if not weapon then return end
			visualSystem.putWeaponInHand(player.Character, weapon)
			event:FireClient(player, "Play Anim Barb")
			task.wait(1.5)
			local p = rS.Templates.VFXAssets.SoulStab:Clone()
			p.Parent = player.Character.HumanoidRootPart
			p:Emit()
			Debris:AddItem(p, 5)
			trainingData.LearnSkill(player, skillToLearn)
			visualSystem.withdrawWeapons(player.Character)
		end
	elseif tool == "Bolt Form" then
		for i, v in pairs(player.Character:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = arg3
				if v.Name == "FakeHead" then 
					for o, b in pairs(v:GetChildren()) do
						if b:IsA("Decal") then b.Transparency = arg3 end
					end
				end
			elseif v:IsA("Accessory")  then
				v:FindFirstChild("Handle").Transparency = arg3
			end
		end
	end
end)