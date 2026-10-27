-- initialize stuff blehh
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char.Humanoid::Humanoid
local root = char.HumanoidRootPart::Part
local animator = hum.Animator::Animator
local animationfolder = game.ReplicatedStorage.Animations
local inputservice = game:GetService("UserInputService")
local toolEvent = game.ReplicatedStorage.Events.ToolBindable
local contextservice = game:GetService("ContextActionService")
local mobilesprintevent = game:GetService("ReplicatedStorage").Events.MobileSprintEvent
local moving = false
local falling = Enum.HumanoidStateType.Freefall
local jumping = Enum.HumanoidStateType.Jumping
local landed = Enum.HumanoidStateType.Landed

local movingTable = {}
local running = false


local stopmovement = false
local joystickmove = false
local thumbx = 0
local thumby = 0
local jumpcount = 1

-- the modifiers for different speed elements in the game
local speedmods = {
	defaultwalkspeed = 16,
	running = 2,
	boltForm = 3,
	stopmovement = 0
}

-- function that resets players speed to be what it should be. Call this WHENEVER SPEED CHANGES.
local function updatespeed()
	local speed = speedmods.defaultwalkspeed
	if running then
		speed *= speedmods.running
	elseif movingTable.BoltForm == true then
		speed *= speedmods.boltForm
	end
	hum.WalkSpeed = speed
end

-- table that holds all the animations. Access the animation by typing anims.AnimationName
local anims = {}
for _, animation in ipairs(animationfolder:GetDescendants()) do
	if not animation:IsA("Animation") then continue end
	anims[animation.Name] = animator:LoadAnimation(animation)
end

local allignores = {"ToolAnim","OrbIdle"}

-- function that stops all anims given certain context. Look at the strings to see what the contexts are
local function stopanims(context)
	if context == "all" or context == nil then
		for _, anim in ipairs(animator:GetPlayingAnimationTracks()) do
			-- hi its me go- giselereal and i like added this so my fireball tools arm actually like stays up when you stop moving, sorry michael
			-- if you read this send me a message or smt would be funny
			if not table.find(allignores,anim.Name) then
				anim:Stop()
			end
			-- stops EVERY SINGLE ANIMATION. You should prob call this in battle.
		end
	elseif context == "movement" then
		anims.Walk:Stop()
		anims.Run:Stop()
		anims.Idle:Stop()
		anims.Jump:Stop()
		anims.JumpAlt:Stop()
		anims.Fall:Stop()
		anims.JumpFall:Stop()
		anims.JumpFallAlt:Stop()
		anims.Dance3:Stop()
		anims.Dance2:Stop()
		anims.Dance1:Stop()
		-- future movement anims here, kinda like beast run and whatever
	elseif context == "jump" then
		anims.Jump:Stop()
		anims.JumpAlt:Stop()
		anims.Fall:Stop()
		anims.JumpFall:Stop()
		anims.JumpFallAlt:Stop()
		anims.Dance3:Stop()
		anims.Dance2:Stop()
		anims.Dance1:Stop()
		-- future jump animations here
	end
end

-- disable arrow keys gise asked me to do this
contextservice:BindAction("ArrowKeys", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Up, Enum.KeyCode.Down)

hum.Running:Connect(function(speed)
	if speed > 0.1 then
		if running and not anims.Run.IsPlaying then
			stopanims()
			anims.Run:Play()
			anims.Run:AdjustSpeed(speed / (speedmods.defaultwalkspeed * speedmods.running))
		elseif running and anims.Run.IsPlaying then
			if speed <= 0.1 and not anims.Idle.IsPlaying then
				stopanims()
				anims.Idle:Play()
			else
				anims.Run:AdjustSpeed(speed / (speedmods.defaultwalkspeed * speedmods.running)) 
			end
		elseif not running and not anims.Walk.IsPlaying then
			stopanims()
			anims.Walk:Play()
			anims.Walk:AdjustSpeed(speed / speedmods.defaultwalkspeed)
		elseif not running and anims.Walk.IsPlaying then
			if speed <= 0.1 and not anims.Idle.IsPlaying then
				stopanims()
				anims.Idle:Play()
			else
				anims.Walk:AdjustSpeed(speed / speedmods.defaultwalkspeed)
			end
		end
	elseif not anims.Idle.IsPlaying and speed <= 0.1 then
		stopanims()
		anims.Idle:Play()
	end
end)

hum.Jumping:Connect(function(bool)
	if bool and jumpcount == 1 and not anims.JumpAlt.IsPlaying and not anims.Jump.IsPlaying then
		stopanims()
		anims.JumpAlt:Play()
		jumpcount = 1
	end
end)

anims.Jump.Stopped:Connect(function()
	if hum:GetState() == Enum.HumanoidStateType.Freefall then
		stopanims()
		anims.JumpFall:Play()
	end
end)

anims.JumpAlt.Stopped:Connect(function()
	if hum:GetState() == Enum.HumanoidStateType.Freefall then
		stopanims()
		anims.JumpFallAlt:Play()
	end
end)

hum.FreeFalling:Connect(function()
	--print("running")
	if hum:GetState() == Enum.HumanoidStateType.Freefall and not anims.Jump.IsPlaying and not anims.JumpAlt.IsPlaying and not anims.JumpFall.IsPlaying and not anims.JumpFallAlt.IsPlaying then
		--print("Hi")
		stopanims()
		anims.Fall:Play()
	end
end)

-- shift/left trigger for run.
inputservice.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
		running = true
		updatespeed()
	end
end)

-- keyboard move checker, running for keyboard and console (ended)
inputservice.InputEnded:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
		running = false
		updatespeed()
	end
end)

-- mobile sprint thing
mobilesprintevent.Event:Connect(function(targetplr)
	if targetplr ~= plr then return end
	if not running then
		running = true 
		updatespeed()
	elseif movingTable.BoltForm then 
		running = false
		updatespeed()
	end
end)

-- /e dance because if your game doesn't hve this it's chud
plr.Chatted:connect(function(msg)

	if string.find(msg, "dance1")  then
		stopanims()
		anims.Dance1:Play()
		anims.Idle:Stop()
	elseif string.find(msg, "dance2")  then
		stopanims()
		anims.Dance2:Play()
		anims.Idle:Stop()
	elseif string.find(msg, "dance3")  then
		stopanims()
		anims.Dance3:Play()
		anims.Idle:Stop()
	elseif string.find(msg, "dance") then
		stopanims()
		anims.Dance3:Play()
		anims.Idle:Stop()
	end

end)

toolEvent.Event:connect(function(tool, bool)
	movingTable[tool] = bool
	updatespeed()
end)

-- remember to not paste code in the wrong script...