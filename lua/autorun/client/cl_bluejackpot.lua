


local CurrentJackpot = 0
local CurrentDeposite = 0
local CurrentChance = 0
local CurrentTime = 0
local CurrentBetters = 0
local JackpotTimerActive = true
local CurrentPos = 0
local tempJackpot = 0
local JackpotNotifications = {}

local isOpen = false

hook.Add("Think" , "LerpJackpotValue" , function()

	CurrentJackpot = math.Round(Lerp(20*FrameTime() , CurrentJackpot , tempJackpot))

end)

net.Receive("BeginJackpotTimer" , function(len)

	tempJackpot = 0
	CurrentJackpot = 0
	CurrentDeposite = 0
	CurrentChance = 0
	CurrentBetters = 0

	JackpotTimerActive = true
	CurrentTime = 0

end)

net.Receive("AddLiveFeedNot" , function(len) 

	local name = net.ReadString()
	local isWinner = net.ReadInt(8)
	local depoiteAmount = net.ReadInt(32)

	if table.Count(JackpotNotifications) > 30 then
		
		table.remove(JackpotNotifications , 1)

	end

	if isWinner == 1 then

		local chance = net.ReadFloat()

		table.insert(JackpotNotifications , 
			{
			name = name , 
			isWinner = isWinner , 
			depositeAmount = depoiteAmount,
			chance = chance
		})

	else

		table.insert(JackpotNotifications , 
			{
			name = name , 
			isWinner = isWinner , 
			depositeAmount = depoiteAmount

		})

	end

	if isWinner == 1 then

		CurrentPos = -100

	else

		CurrentPos = -55

	end

end)

hook.Add("Think" , "ClientTimerTracker" , function()

	CurrentTime = CurrentTime + FrameTime()

	if CurrentTime >= 60 then
		
		JackpotTimerActive = false


	end

end)

net.Receive("SendJackpotTime" , function(len)

	CurrentTime = net.ReadFloat()

end)

net.Receive("UpdateJackpot" , function(len)

	tempJackpot = net.ReadInt(32)

end)

net.Receive("UpdateJackpotDeposite" , function(len) 

	CurrentDeposite = net.ReadInt(32)

end)

net.Receive("UpdateJackpotPercent" , function(len) 

	CurrentChance = net.ReadFloat()

end)

net.Receive("UpdateBetters" , function(len)

	CurrentBetters = net.ReadInt(16)

end)

--UI STUFF HERE


local P = FindMetaTable("Panel")

local mainColor = Color(30,30,30 )
local secondaryColor = Color(60,60,60)
local blockedColor = Color(10,10,10)
local highlightColor = Color(219,77,80)
local ButtonColor = Color(120,255,120)


surface.CreateFont( "AG_BoxTitle", {
	font = "Nexa Light",
	size = 27,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "JackpotStats1", {
	font = "Nexa Light",
	size =30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


surface.CreateFont( "JackpotWin1", {
	font = "Nexa Light",
	size = 105,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "JackpotWin2", {
	font = "Nexa Light",
	size = 80,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "JackpotWin3", {
	font = "Nexa Light",
	size = 60,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "AG_ButtonFontOne", {
	font = "Nexa Light",
	size = 19,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "JackpotNotifications1", {
	font = "Nexa Light",
	size = 17,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "JackpotNotifications2", {
	font = "Nexa Light",
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function P:JackpotPaintBox(title)

	self.boxTitle = title
	self:SetTitle("")

	self.Paint = function(s , w, h)

		draw.RoundedBox(0,0,0,w,h,mainColor)
		draw.RoundedBox(0,0,0,w,30,highlightColor)

		draw.SimpleText(s.boxTitle , "AG_BoxTitle" , 5,0 , mainColor )



	end

end


function P:JackpotPaintPanel(title)

	self.boxTitle = title

	self.Paint = function(s , w, h)

		draw.RoundedBox(0,0,0,w,h,secondaryColor)
		draw.RoundedBox(0,0,0,w,30,highlightColor)

		draw.SimpleText(s.boxTitle , "AG_BoxTitle" , 5,0 , secondaryColor )

	end

end

function P:JackpotPaintLiveFeedPanel(title)

	self.boxTitle = title

	self.Paint = function(s , w, h)

		draw.RoundedBox(0,0,0,w,h,secondaryColor)


		local tab = table.Reverse(JackpotNotifications)

		CurrentPos = Lerp(12 * FrameTime() , CurrentPos , 0)

		local yPos = CurrentPos + 40

		for i = 1 , 30 do 

			if tab[i] ~= nil then

				if tab[i].isWinner == 1 then

					draw.RoundedBox(0,5,yPos,220,90,highlightColor)

					surface.SetFont("JackpotNotifications2")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize("WINNER!") / 2
					surface.SetTextPos(230 / 2 - x, yPos + 5 )
					surface.DrawText("WINNER!")

					surface.SetFont("JackpotNotifications1")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize(tab[i].name) / 2
					surface.SetTextPos(230 / 2 - x, yPos + 37 )
					surface.DrawText(tab[i].name)

					surface.SetFont("JackpotNotifications1")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize("$"..tab[i].depositeAmount) / 2
					surface.SetTextPos(230 / 2 - x, yPos + 58 )
					surface.DrawText("$"..tab[i].depositeAmount)

					surface.SetFont("JackpotNotifications1")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize(round(tab[i].chance , 2).."%") / 2
					surface.SetTextPos(230 / 2 - x, yPos + 76 )
					surface.DrawText(tostring(round(tab[i].chance , 2).."%"))
 
					yPos = yPos + 100

				else

					draw.RoundedBox(0,5,yPos,220,45,highlightColor)
					--draw.SimpleText(tab[i].name .. " Deposited $"..tab[i].depositeAmount , "JackpotNotifications1" , 10 , yPos + 10 , secondaryColor )

					surface.SetFont("JackpotNotifications1")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize(tab[i].name) / 2
					surface.SetTextPos(230 / 2 - x, yPos + 5 )
					surface.DrawText(tab[i].name)

					surface.SetFont("JackpotNotifications1")
					surface.SetTextColor(mainColor)
					local x = surface.GetTextSize("Deposited $"..tab[i].depositeAmount) / 2
					surface.SetTextPos(230 / 2 - x, yPos + 25 )
					surface.DrawText("Deposited $"..tab[i].depositeAmount)

					yPos = yPos + 55

				end

			end		

		end

		draw.RoundedBox(0,0,0,w,30,highlightColor)

		draw.SimpleText(s.boxTitle , "AG_BoxTitle" , 5,0 , secondaryColor )

	end

end

function round(what ,  precision)


   return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)


end

function P:JackpotPaintStatPanel(title)

	self.boxTitle = title

	self.Paint = function(s , w, h)

		draw.RoundedBox(0,0,0,w,h,secondaryColor)
		draw.RoundedBox(0,0,0,w,30,highlightColor)

		draw.SimpleText(s.boxTitle , "AG_BoxTitle" , 5,0 , secondaryColor )

		--Draw the deposit

		draw.RoundedBox(0,5 , 70 , 220 , 5 ,highlightColor)

		surface.SetFont("JackpotStats1")
		surface.SetTextColor(mainColor)
		local x = surface.GetTextSize("Deposit") / 2
		surface.SetTextPos(230 / 2 - x, 40 )
		surface.DrawText("Deposit")

		draw.SimpleText("$"..tostring(CurrentDeposite) , "JackpotStats1" , 10 , 80 , mainColor )

		--Chance

		draw.RoundedBox(0,5 , 160 , 220 , 5 ,highlightColor)

		surface.SetFont("JackpotStats1")
		surface.SetTextColor(mainColor)
		local x = surface.GetTextSize("Chance") / 2
		surface.SetTextPos(230 / 2 - x, 130 )
		surface.DrawText("Chance")
 

		draw.SimpleText(tostring(round(CurrentChance , 2)) .. "%" , "JackpotStats1" , 10 , 170 , mainColor )



		draw.RoundedBox(0,5 , 260 , 220 , 5 ,highlightColor)

		surface.SetFont("JackpotStats1")
		surface.SetTextColor(mainColor)
		local x = surface.GetTextSize("Betters") / 2
		surface.SetTextPos(230 / 2 - x, 230)
		surface.DrawText("Betters")


		draw.SimpleText(tostring(CurrentBetters) , "JackpotStats1" , 10 , 270 , mainColor )


		draw.RoundedBox(0,5 , 350 , 220 , 5 ,highlightColor)

		surface.SetFont("JackpotStats1")
		surface.SetTextColor(mainColor)
		local x = surface.GetTextSize("Round End") / 2
		surface.SetTextPos(230 / 2 - x, 320)
		surface.DrawText("Round End")


		draw.SimpleText(math.ceil(60 - CurrentTime) , "JackpotStats1" , 10 , 360 , mainColor )

	end

end

function P:CreateJackpotWheel(radius)

	self.Progress = 0
	self.TempProgress = 0

	self.Radius = radius

	self.Paint = function(self , w , h)

		local posx = w/2
		local posy = h/2


		local poly = { }
		local v = 40
		poly[1] = {x = posx, y = posy}
		for i = 0, v*100+0.5 do
			poly[i+2] = {x = math.sin(-math.rad(i/v*360)) * -self.Radius + posx , y = math.cos(-math.rad(i/v*360)) * -self.Radius + posy}
		end
		draw.NoTexture()
		surface.SetDrawColor(Color(50,50,50))
		surface.DrawPoly(poly)

		poly = { }
		v = 500
		poly[1] = {x = posx, y = posy}
		for i = 0, v*self.TempProgress+0.5 do
			poly[i+2] = {x = math.sin(-math.rad(i/v*360)) * -self.Radius + posx, y = math.cos(-math.rad(i/v*360)) * -self.Radius + posy}
		end
		draw.NoTexture()
		surface.SetDrawColor(150,150,150)
		surface.DrawPoly(poly)

		local r = self.Radius - 40

		poly = { }
		v = 40
		poly[1] = {x = posx, y = posy}
		for i = 0, v*100+0.5 do
			poly[i+2] = {x = math.sin(-math.rad(i/v*360)) * -r + posx , y = math.cos(-math.rad(i/v*360)) * -r + posy}
		end

		surface.SetDrawColor(mainColor)
		surface.DrawPoly(poly)

		if CurrentJackpot <= 99999 then
			
			surface.SetFont("JackpotWin1")

		elseif CurrentJackpot <= 99999999 then
			
			surface.SetFont("JackpotWin2")

		elseif CurrentJackpot <= 999999999999 then
			
			surface.SetFont("JackpotWin3")

		end

		//surface.SetFont("JackpotWin")
		local x = surface.GetTextSize("$" .. tostring(CurrentJackpot)) / 2

		if CurrentJackpot <= 99999 then
			
			surface.SetTextPos((self:GetWide() / 2) - x , (self:GetTall() / 2) - 45)

		elseif CurrentJackpot <= 99999999 then
			
			surface.SetTextPos((self:GetWide() / 2) - x , (self:GetTall() / 2) - 25)

		elseif CurrentJackpot <= 999999999999 then
			
			surface.SetTextPos((self:GetWide() / 2) - x , (self:GetTall() / 2) - 15)

		end
		
		surface.SetTextColor(Color(120,120,120 , 120))
		surface.DrawText("$" .. tostring(CurrentJackpot))

	end

	self.Think = function(self)

		if math.ceil(self.Progress) - 1 == math.ceil(self.TempProgress) then 

			self.TempProgress = math.ceil(self.Progress)

		end

		self.TempProgress = Lerp(3 * FrameTime() , self.TempProgress ,self.Progress)

		self.Progress = (CurrentTime / 60)

	end


end



function P:JackpotPaintButton(Text , func)

	self.DoClick = func

	self:SetText("")
	self.Text = Text

	self.IsHovering = false
	self.IsLocked = false

	self.Paint = function(s , w, h)

		surface.SetFont("AG_ButtonFontOne")
		local x  , y = surface.GetTextSize(s.Text) / 2
		surface.SetTextPos((w / 2) - x , (h/2) - 10)

		if s.IsLocked == false then

			if s.IsHovering then

				draw.RoundedBox(0,0,0,w,h,ButtonColor)
				surface.SetTextColor(secondaryColor)

			else

				draw.RoundedBox(0,0,0,w,h,highlightColor)
				surface.SetTextColor(secondaryColor)

			end

		else

			draw.RoundedBox(0,0,0,w,h,blockedColor)
			surface.SetTextColor(secondaryColor)

		end

		surface.DrawText(s.Text)


	end

	self.OnCursorEntered = function(s)

		self.IsHovering = true

	end

	self.OnCursorExited = function(s)

		self.IsHovering = false

	end


end

function P:LockButton()

	self.IsLocked = true

end

function P:UnlockButton()

	self.IsLocked = false

end

local JackpotWindow
local JackpotStats
local JackpotLivefeed
local DepositeWindow
function OpenJackpotWindow()

	if isOpen == false then

		JackpotWindow = vgui.Create("DFrame")
		JackpotWindow:SetSize(1000 , 500)
		JackpotWindow:Center()
		JackpotWindow:JackpotPaintBox("Blue's Jackpot")
		JackpotWindow:SetVisible(true)
		JackpotWindow:SetDrawOnTop(true)
		JackpotWindow:MakePopup()
		JackpotWindow.OnClose = function(self)

			isOpen = false

			if DepositeWindow ~= nil then
			
				DepositeWindow:Remove()

			end

		end

		JackpotStats = vgui.Create("DPanel" , JackpotWindow)
		JackpotStats:SetPos(10 , 40)
		JackpotStats:SetSize(250 - 20 , 500 - 40 - 10)
		JackpotStats:JackpotPaintStatPanel("Your Statistics")

			local dBut = vgui.Create("DButton" , JackpotStats)
			dBut:SetPos(10 , 410)
			dBut:SetSize(210 , 30)
			dBut:JackpotPaintButton("Deposit", ShowDepositeWindow)



		JackpotLivefeed = vgui.Create("DPanel" , JackpotWindow)
		JackpotLivefeed:SetPos(1000 - 250 + 10 , 40)
		JackpotLivefeed:SetSize(250 - 20 , 500 - 40 - 10)
		JackpotLivefeed:JackpotPaintLiveFeedPanel("Live Feed")

		local test = vgui.Create("DPanel" , JackpotWindow)
		test:SetSize(450,450)
		local x = 1000 /2
		local y = 500 / 2
		test:SetPos(x - (450 / 2) , y - (450 / 2) + 10)
		test:CreateJackpotWheel((450/2 )-10)

	end

	isOpen = true

end


function ShowDepositeWindow()

	if DepositeWindow ~= nil then
		
		DepositeWindow:Remove()

	end

	DepositeWindow = vgui.Create("DFrame")
	DepositeWindow:SetSize(350 , 80)
	DepositeWindow:SetPos(ScrW()/2 - (350 / 2) , ScrH() / 2)
	DepositeWindow:JackpotPaintPanel("Deposit")
	DepositeWindow.Open = true
	DepositeWindow:ShowCloseButton(false)
	DepositeWindow:SetDraggable(false)
	DepositeWindow:SetTitle("")
	DepositeWindow.YPos = 1
	DepositeWindow:MakePopup()
	DepositeWindow.Think = function(self)

		self:SetPos(ScrW()/2 - (350 / 2)  , ((ScrH() / 2) + 250 - 80) + self.YPos)

		if self.Open == true then

			self.YPos = Lerp(7 * FrameTime() , self.YPos , 80)

		else

			self.YPos = Lerp(6 * FrameTime() , self.YPos , 0)

			if self.YPos <= 1 then
				
				self:Remove()

			end

		end

	end

	local InputDeposite = vgui.Create("DTextEntry" , DepositeWindow)
	InputDeposite:SetPos(10,40)
	InputDeposite:SetSize(220 , 80 - 50)
	InputDeposite:SetEditable(true)
	InputDeposite:AllowInput(true)
	InputDeposite:SetText("Enter Amount")
	InputDeposite:RequestFocus()

	local SubmitDepositeBut = vgui.Create("DButton" , DepositeWindow)
	SubmitDepositeBut:SetPos(240 + 10 , 40)
	SubmitDepositeBut:SetSize(350 - 260, 80 - 50)
	SubmitDepositeBut:JackpotPaintButton("Submit" , function() 

		DepositeWindow.Open = false 

		local text = InputDeposite:GetText()

		local num = tonumber(text)
 
		if num ~= nil then
			
			num = math.Round(num)

			if num >= 1 and num <= 1000000000 then
				
				net.Start("DepositeJackpotAmount")
					net.WriteInt(num , 32)
				net.SendToServer()

				print(num)



			end

		end



	end)

end

net.Receive("OpenJackpotWindow", OpenJackpotWindow)
