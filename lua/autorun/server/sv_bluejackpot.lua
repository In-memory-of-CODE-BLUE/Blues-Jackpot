include("bluejackpot.lua")

local JackpotPot = 0
local numberOfPlayers = 0
local TimeUntilNextGame = 0

local JackpotPlayerInfo = {}

local JackpotCurrentRoundTime
local JackpotTimerActive = false
local CanDepositeToJackpot = false

local meta = FindMetaTable("Player")
	
--Network String

util.AddNetworkString("UpdateJackpotPercent")
util.AddNetworkString("UpdateJackpotDeposite")
util.AddNetworkString("UpdateJackpot")
util.AddNetworkString("DepositeJackpotAmount")
util.AddNetworkString("UpdateBetters")

util.AddNetworkString("OpenJackpotWindow")


util.AddNetworkString("BeginJackpotTimer")
util.AddNetworkString("SendJackpotTime")

util.AddNetworkString("GetJackpotTimer")

util.AddNetworkString("AddLiveFeedNot")

hook.Add("PlayerInitialSpawn" , "SendCurrentTime" , function(ply)

	net.Send("SendJackpotTime")
		net.WriteFloat(JackpotCurrentRoundTime)
	net.Send(ply)

	UpdateBetters()
	SendJackpotUpdate()

end)

hook.Add("PlayerSay" , "OpenJackpotWindowHook" , function(ply , text)

	if string.lower(text) == "!bet" or string.lower(text) == "/bet" then
		
		net.Start("OpenJackpotWindow")
		net.Send(ply)

	end

end)

net.Receive("DepositeJackpotAmount" , function(len , ply)

	local num = net.ReadInt(32)

	print(num)

	if num >= JackpotConfig.MinBet and num <= JackpotConfig.MaxBet then

		ply:DepositeToJackpot(num)

	else

		ply:ChatPrint("You cannot bet that amount. The minimum bet is $"..JackpotConfig.MinBet.." and the max is $".. JackpotConfig.MaxBet )

	end

end)

net.Receive("GetJackpotTimer" , function(len , ply)

	net.Send("SendJackpotTime")
		net.WriteFloat(JackpotCurrentRoundTime)
	net.Send(ply)

end)

function UpdateBetters()

	local count = table.Count(JackpotPlayerInfo)

	for k , v in pairs(player.GetAll()) do
		
		net.Start("UpdateBetters")
			net.WriteInt(count , 16)
		net.Send(v)

	end


end

function CalcualteJackpotWinner()

	PrintTable(JackpotPlayerInfo)

	print("Table count : " , table.Count(JackpotPlayerInfo))

	local winnerID = -1

	if table.Count(JackpotPlayerInfo) > 0 then

		local total = 10000

		local num = math.random(10000)

		local prevCheck = 0
 
		winnerID = -1 

		for k ,v in pairs(JackpotPlayerInfo) do
			 
			local chance = v.percent * 100

			if num > prevCheck  and num < prevCheck + chance then
				
				winnerID = k

				break
 
			end

			prevCheck = prevCheck + chance 

		end

		local winner = player.GetByUniqueID(winnerID)
		winner:addMoney(JackpotPot)

		SendJackpotNotification(winner:Nick() , JackpotPot , 1 , JackpotPlayerInfo[winnerID].percent)

		JackpotPot = 0

	end

end 

function BeginNewJackpotRound()

	CalcualteJackpotWinner()

	JackpotPlayerInfo = {}

	CanDepositeToJackpot = true
	JackpotTimerActive = true
	JackpotCurrentRoundTime = 0

	for k , v in pairs(player.GetAll()) do
		
		net.Start("BeginJackpotTimer")
		net.Send(v)

	end

	UpdateBetters()

end

BeginNewJackpotRound()

hook.Add("Think" , "JackpotTimerTracker" , function()

	if JackpotTimerActive then

		JackpotCurrentRoundTime = JackpotCurrentRoundTime + FrameTime()

		if JackpotCurrentRoundTime >= 60 then
			
			CanDepositeToJackpot = false
			JackpotTimerActive = false
			--Here do some kind of winning system

			timer.Simple(3 , BeginNewJackpotRound)

		end

	end

end)



function meta:DepositeToJackpot(amount)

	local didDeposite = false

	if self:canAfford(amount) then

		if JackpotPlayerInfo[self:UniqueID()] == nil then

			JackpotPlayerInfo[self:UniqueID()] = {}
			JackpotPlayerInfo[self:UniqueID()].amountDeposited = amount
			JackpotPlayerInfo[self:UniqueID()].ply = self

			self:addMoney(amount * -1)

			UpdateBetters()

			didDeposite = true

		else

			if JackpotPlayerInfo[self:UniqueID()].amountDeposited + amount <= JackpotConfig.MaxBet then

				JackpotPlayerInfo[self:UniqueID()].amountDeposited = JackpotPlayerInfo[self:UniqueID()].amountDeposited + amount

				self:addMoney(amount * -1)

				didDeposite = true

			else

				self:ChatPrint("You cannot bet that amount. The minimum bet is $"..JackpotConfig.MinBet.." and the max is $".. JackpotConfig.MaxBet )

			end

		end

		if didDeposite == true then

			JackpotPot = JackpotPot + amount

			self:SendDepositUpdate()

			SendJackpotUpdate()

			CalculateJackpotPercentages()

			SendJackpotPercentUpdate()

			SendJackpotNotification(self:Name() , amount , 0)

		end

	else

		self:ChatPrint("You cannot afford to bet that amount.")


	end

end

function SendJackpotNotification(name , amount , isWinner , chance)

	for k ,v in pairs(player.GetAll()) do

		if chance ~= nil then

			net.Start("AddLiveFeedNot")
				net.WriteString(name)
				net.WriteInt(isWinner , 8)
				net.WriteInt(amount , 32)
				net.WriteFloat(chance)
			net.Send(v)

		else

			net.Start("AddLiveFeedNot")
				net.WriteString(name)
				net.WriteInt(isWinner , 8)
				net.WriteInt(amount , 32)
			net.Send(v)

		end

	end

end



function CalculateJackpotPercentages()

	for k ,v in pairs(JackpotPlayerInfo) do	

		JackpotPlayerInfo[k].percent = (100 / JackpotPot) * JackpotPlayerInfo[k].amountDeposited

	end

end

function SendJackpotPercentUpdate()

	for k , v in pairs(JackpotPlayerInfo) do
		
		net.Start("UpdateJackpotPercent")

			net.WriteFloat(v.percent)

		net.Send(v.ply) 

	end

end

function meta:SendDepositUpdate()

	

	net.Start("UpdateJackpotDeposite")

		net.WriteInt(JackpotPlayerInfo[self:UniqueID()].amountDeposited,32)

	net.Send(self)

end



function SendJackpotUpdate()

	for k , v in pairs(player.GetAll()) do

		net.Start("UpdateJackpot")

			net.WriteInt(JackpotPot,32)

		net.Send(v)

	end

end

resource.AddFile( "resource/fonts/Nexa Light.ttf" )


