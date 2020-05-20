-- This Version
-- 3.12 - 03/05/2020
-- ChangeLogs
-- 2.04 - Adding Left or Right Support
-- 2.05 - Changing Lot Code For Some Stable And Cleaner Code
-- 2.06 - Ops Forget Fuel Chcking Code after rewrtitting
-- 2.07 - Woops My Bad i wrote back() not Back()
-- 2.08 - Fixing Imputs
-- 2.09 - Forget That i change remove line of code since i use local function now
-- 2.10 - Minor error with back that it leave one block in wall
--	  Change: Torch spacing to 8 from 10
-- 2.11 - Change: Right to left and Left to Right better understand
-- 2.12 - Add Stop Code when item are gone
-- 2.13 - i made big mistake i forget to end to new stop code

-- 3.00 - Add EnderChest ability
-- 3.01 - Add ability to suck up torches from first row in EnderChest
-- 3.02 - More degug output and better wording of help messages.
-- 3.03 - Don't stop mining after using 64 torches dummy!
-- 3.04 - Drop Cobble instead of putting in chest, Get torches from enderchest in slot 5 instead of from item deposit chest.
-- 3.05 - Adjustments to fuelling system - Use all Coal in slot 3 but one to optimise coal that will be collected.
-- 3.06 - Place items abobe if there is no block there to build ceiling
-- 3.10 - Major changes to dig up detected ores that are directly next to the turtle. Many other changes/bugfixes.
-- 3.11 - Fix torch placement and blocking of main hall by the wall builder.
-- 3.12 - Fix floor and wall placement - Including placement in corridor. Improve console output messages.
-- 3.13 - Prevent turtle from running out of cobble by always retaining one in slot 4.

-- Known Bugs:
-- - If gravel is encountered on the main hallway (Between strips), the turtle may ascend for some reason and mine the next shaft one level higher.

-- ToDoList:
-- - Store total ores found over lifetime out to file
-- - Don't fill opposing tunnel walls

--Local
local distance = 0 -- How Far Did User Pick
local onlight = 0 -- When to Place Torch
local torch = turtle.getItemCount(1) -- How many items are in slot 1 (torch)
local chest = turtle.getItemCount(2) -- How many items are in slot 2 (chest)
local ItemFuel = turtle.getItemCount(3) -- How many items are in slot 3 (Fuel)
local MD = 3 -- How Many Blocks Apart From Each Mine
local MineTimes = 0 -- If Multi Mines Are ON then This will keep Count
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error
local Way = 0 -- 0 = Left and 1 = Right
local OresFoundTotal = 0 -- Pre-Define that no ores have been found yet.
-- Define blocks that we want to dig out of the walls, floor and ceiling:
local OreBlocks = {
	["minecraft:coal_ore"] = true,
	["minecraft:diamond_ore"] = true,
	["minecraft:gold_ore"] = true,
	["minecraft:iron_ore"] = true,
	["minecraft:lapis_ore"] = true,
	["thermalfoundation:ore"] = true,
}

--Checking
local function Check()
	if torch == 0 then
		print("There are no torches in Turtle")
		Error = 1
	else
		print("Torches are present.")
	end
	if chest == 0 then
		print("There are no chests")
		Error = 1
	else
		print("Chest is present.")
	end
	if ItemFuel == 0 then
		print("No Fuel. Place Coal in slot 3")
		Error = 1
	else
		print("Fuel is present.")
	end
	repeat
		if turtle.getFuelLevel() == "unlimited" then 
			print("NO NEED FOR FUEL")
			Needfuel = 0
        elseif turtle.getFuelLevel() < 200 then
            CurrentFuelLevel = turtle.getFuelLevel()
            print("Refuelling. Fuel level was:", CurrentFuelLevel)
            turtle.select(3)
            CoalRemaining = turtle.getItemCount(3) -- Count remaining Coal in slot 3
            CoalToUse = CoalRemaining - 1 -- Take one away - We want to leave one coal in slot 3 so future Coal we mine is collected here first.
			turtle.refuel(CoalToUse) -- Refuel with all the coal in the slot minus one.
			CurrentFuelLevel = turtle.getFuelLevel()
			print("Fuel level is now:", CurrentFuelLevel)
			Needfuel = 1
		elseif NeedFuel == 1 then
			Needfuel = 0
		end
	until NeedFuel == 0
end

-- Recheck if user forget something turtle will check after 15 sec
local function Recheck()
	torch = turtle.getItemCount(1)
	chest = turtle.getItemCount(2)
	ItemFuel = turtle.getItemCount(3)
	Error = 0
end

local function FillCobble()
	turtle.select(4)
	RemainingCobble = turtle.getItemCount(4)
	if RemainingCobble >= 2 then
		turtle.place()
		turtle.select(3)
	else
		print("Ran out of Cobble! Can't fill hole ;)")
	end
end

local function FillCobbleUp()
	turtle.select(4)
	RemainingCobble = turtle.getItemCount(4)
	if RemainingCobble >= 2 then
		turtle.placeUp()
		turtle.select(3)
	else
		print("Ran out of Cobble! Can't fill hole ;)")
	end
end

local function FillCobbleDown()
	turtle.select(4)
	RemainingCobble = turtle.getItemCount(4)
	if RemainingCobble >= 2 then
		turtle.placeDown()
		turtle.select(3)
	else
		print("Ran out of Cobble! Can't fill hole ;)")
	end
end

-- Ore Detection

-- Detects if facing an ore present in the OreBlocks table.
local function DetectOresFront()
    local IsBlock,BlockInfo = turtle.inspect()
    if IsBlock and OreBlocks[BlockInfo.name] then
		OresFoundTotal = OresFoundTotal + 1
		print("Found ", OresFoundTotal, "ores so far")
        turtle.select(3)
		turtle.dig()
		FillCobble()
    elseif IsBlock then
		--# there is a block and it is not in the table. We will attempt to put cobble there anyway because we want to fill lava and water.
		FillCobble()
    else
        FillCobble()
    end
end

local function DetectOresDown()
    local IsBlock,BlockInfo = turtle.inspectDown()
    if IsBlock and OreBlocks[BlockInfo.name] then
		OresFoundTotal = OresFoundTotal + 1
		print("Found ", OresFoundTotal, "ores so far")
        turtle.select(3)
		turtle.digDown()
		FillCobbleDown()
    elseif IsBlock then
		--# there is a block and it is not in the table
		FillCobbleDown()
    else
        FillCobbleDown()
    end
end

local function DetectOresUp()
    local IsBlock,BlockInfo = turtle.inspectUp()
    if IsBlock and OreBlocks[BlockInfo.name] then
		OresFoundTotal = OresFoundTotal + 1
		print("Found ", OresFoundTotal, "ores so far")
        turtle.select(3)
		turtle.digUp()
		FillCobbleUp()
    elseif IsBlock then
		--# there is a block and it is not in the table
		FillCobbleUp()
    else
        FillCobbleUp()
    end
end

--Mining
local function ForwardM()
	repeat
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then -- sometimes sand and gravel and block and mix-up distance
			TF = TF - 1
			onlight = onlight + 1
		end
		if turtle.detectUp() then
			turtle.digUp()
		end
		DetectOresDown()
		turtle.turnLeft()
		DetectOresFront()
		turtle.turnRight()
		turtle.turnRight()
		DetectOresFront()
		turtle.turnLeft()
		turtle.select(3)
		if onlight == 14 then -- Every 15 Block turtle place torch
			if torch > 0 then
				turtle.turnLeft()
				turtle.turnLeft()
				turtle.select(1)
				turtle.place()
				turtle.turnLeft()
				turtle.turnLeft()
				onlight = onlight - 14
				turtle.select(3)
			else
				error("Ran out of torches. Quitting")
			end
		end
		if turtle.getItemCount(16)>0 then -- If slot 16 contains an item, the turtle is full. Drop slots 6 to 16 into chest.
			if chest > 0 then
				turtle.select(2)
                turtle.digDown()
                print("Placing down chest and dropping items")
				turtle.placeDown()
				for slot = 6, 16 do
                    turtle.select(slot)
                    ItemDetails = turtle.getItemDetail()
                        if ItemDetails.name == "minecraft:cobblestone" then 
                            turtle.drop() -- If the slot contains cobble, drop it on the ground.
                        else
					        turtle.dropDown() -- Drop all non-cobblestone items into the chest below me.
                            sleep(1.5)
                    end
                end
                turtle.select(2)  -- Reselect the empty slot to put the EnderChest back into.
                turtle.digDown() -- Dig the EnderChest back up.
                sleep(2)
                print("Collecting torches")
                RemainingTorches = 0
                TorchesNeeded = 0
                turtle.select(5) -- Select slot 5, this should contain the crate or EnderChest full of only torches.
                turtle.placeDown()
                turtle.select(1) -- Select slot for torches...
                RemainingTorches = turtle.getItemCount(1) -- And count them
                TorchesNeeded = 64 - RemainingTorches
                turtle.suckDown(TorchesNeeded) -- Pull only enough torches to refill slot 1.
                print("Done. Collected this many torches:")
                print(TorchesNeeded)
                print("Collect EnderChest and continue.")
                turtle.select(5) -- Select empty slot for Torch storage EnderChest
                turtle.digDown()  -- And pick the Torch Storage EnderChest back up again.
                turtle.select(4)
                turtle.placeDown()
				turtle.select(3)
			else
				error("turtle run out of Chests. Quitting")
			end
		end
		repeat
			if turtle.getFuelLevel() == "unlimited" then 
				print("NO NEED FOR FUEL")
				Needfuel = 0
			elseif turtle.getFuelLevel() < 200 then
				CurrentFuelLevel = turtle.getFuelLevel()
				print("Refuelling. Fuel level was:", CurrentFuelLevel)
				turtle.select(3)
				CoalRemaining = turtle.getItemCount(3) -- Count remaining Coal in slot 3
				CoalToUse = CoalRemaining - 1 -- Take one away - We want to leave one coal in slot 3 so future Coal we mine is collected here first.
				turtle.refuel(CoalToUse) -- Refuel with all the coal in the slot minus one.
				CurrentFuelLevel = turtle.getFuelLevel()
				print("Fuel level is now:", CurrentFuelLevel)
				Needfuel = 1
				elseif ItemFuel == 0 then
				print("turtle run out of fuel")
			elseif NeedFuel == 1 then
				Needfuel = 0
			end
		until NeedFuel == 0
	until TF == 0
end

--Warm Up For Back Program
local function WarmUpForBackProgram() -- Turns the turtle around to return to beginning of shaft.
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.up()
end

--Back Program
local function Back()
	repeat
		if turtle.forward() then -- sometimes sand and gravel and block and mix-up distance
			TB = TB - 1
			RemainingCobble = turtle.getItemCount(4)
			if RemainingCobble > 3 == true then
				DetectOresUp()
				turtle.turnLeft()
				DetectOresFront()
				turtle.turnRight()
				turtle.turnRight()
				DetectOresFront()
				turtle.turnLeft()
				turtle.select(3)
			else
			end
		end
		if turtle.detect() then -- Sometimes sand and gravel can happen and this will fix it
			if TB ~= 0 then
				turtle.dig()
			end
		end
	until TB == 0
end

-- Multimines Program
local function MultiMines()
	if Way == 1 then
		turtle.turnRight()
		turtle.dig()
		turtle.select(1)
		turtle.place()
		turtle.select(3)
		turtle.turnLeft()
		turtle.turnLeft()
	else
		turtle.turnLeft()
		turtle.dig()
		turtle.select(1)
		turtle.place()
		turtle.select(3)
		turtle.turnRight()
		turtle.turnRight()
	end
	repeat
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then
			FillCobbleUp()
			turtle.turnLeft()
			FillCobble()
			turtle.turnRight()
			turtle.turnRight()
			FillCobble()
			turtle.turnLeft()
			turtle.digDown()
			turtle.down()
			FillCobbleDown()
			turtle.turnLeft()
			FillCobble()
			turtle.turnRight()
			turtle.turnRight()
			FillCobble()
			turtle.turnLeft()
			turtle.up()
			MD = MD - 1
		end
		if turtle.detectDown() then
			turtle.digDown()
		end
	until MD == 0
	if Way == 1 then
		turtle.turnLeft()
		turtle.down()
		print("Starting strip", MineTimes)
	else
		turtle.turnRight()
		turtle.down()
		print("Starting strip", MineTimes)
	end
	if MineTimes == 0 then
		print("Turtle is done")
	else
		MineTimes = MineTimes - 1
	end
end

-- Restart 
local function Restart()
	TF = distance
	TB = distance
	MD = 3
	onlight = 0
end

-- Starting 
function Start()
	repeat
		ForwardM() -- Go forward until TF is 0
		WarmUpForBackProgram() -- Turn around and go up 1 block
		Back() -- Go back the distance of the shaft defined by the user
		MultiMines() -- Move forward and start next mine
		Restart() -- Start the process again for the next strip.
	until MineTimes == 0
	if MineTimes == 0 then
		print("All strips complete!")
	end
end

-- Start
print("Program Start.")
print("How long should each shaft be?")
input = io.read()
distance = tonumber(input)
TF = distance
TB = distance
print("Go left or right?")
print("0 = Left and 1 = Right")
input2 = io.read()
Way = tonumber(input2)
print("How many shafts to dig?")
input3 = io.read()
MineTimes = tonumber(input3)
print("Digging ", input3, " shafts")
print("Each will be ", input, " long")
Check()
if Error == 1 then 
	repeat
		sleep(10)
		Recheck()
		Check()
	until Error == 0
end
Start()
