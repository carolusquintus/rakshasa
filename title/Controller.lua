local music = require("music")

local Controller = class("title.Controller", prox.Entity)

local options = {
	"START",
	"CONFIG",
	"QUIT"
}

local START_LEVEL = 2

function Controller:enter()
	self:setName("titlecontroller")
	self:reset()

	self.ready = false
	self.selection = 1

	local bindings = {}
	for i,v in ipairs(love.joystick.getJoysticks()) do
		if v:isGamepad() then
			local joystick = prox.JoystickBinding(i)
			joystick:add("confirm", "a")
			joystick:add("up", "dpup")
			joystick:add("down", "dpdown")
			joystick:add("left", "dpleft")
			joystick:add("right", "dpright")
			joystick:add("leftshoot", "leftshoulder")
			joystick:add("rightshoot", "rightshoulder")
			joystick:add("leftretract", "leftstick")
			joystick:add("rightretract", "rightstick")
			table.insert(bindings, joystick)
		end
	end

	local keyboard = prox.KeyboardBinding()
	keyboard:add("confirm", "return")
	keyboard:add("up", "up")
	keyboard:add("down", "down")
	keyboard:add("left", "left")
	keyboard:add("right", "right")
	keyboard:add("leftshoot", "lshift")
	keyboard:add("rightshoot", "-")
	keyboard:add("leftretract", "e")
	keyboard:add("rightretract", "u")
	keyboard:addAxis("leftx", "a", "d")
	keyboard:addAxis("lefty", "w", "s")
	keyboard:addAxis("rightx", "j", "l")
	keyboard:addAxis("righty", "i", "k")
	keyboard:addAxis("triggerleft", nil, nil)
	keyboard:addAxis("triggerright", nil, "space")
	table.insert(bindings, keyboard)

	self.binding = prox.MultiBinding(bindings)

	self.title_image = prox.resources.getImage("data/images/title.png")

	self.serif_font = prox.resources.getImageFont("data/fonts/serif.png")
	self.sans_font = prox.resources.getImageFont("data/fonts/large_sans.png")

	self.sfx_blip = prox.resources.getSound("data/sounds/blip.wav")
	self.sfx_confirm = prox.resources.getSound("data/sounds/weird_bang.wav")

	local monkey1 = self:getScene():add(require("bg.models.Monkey")())
	local monkey2 = self:getScene():add(require("bg.models.Monkey")())
	monkey2:setRotation(0, math.pi, 0)
end

function Controller:update(dt, rt)
	local yaxis = self.binding:getAxis("lefty")

	if self.ready then
		if self.binding:wasPressed("down") then
			self.selection = prox.math.wrap(self.selection + 1, 1, #options)
			self.sfx_blip:play()
		elseif self.binding:wasPressed("up") then
			self.selection = prox.math.wrap(self.selection - 1, 1, #options)
			self.sfx_blip:play()
		end
	end

	if self.ready and self.binding:wasPressed("confirm") then
		self.sfx_confirm:play()
		if options[self.selection] == "START" then
			self:hide()
			music.stop()
			self:getScene():add(require("game.Controller")(START_LEVEL, self.binding))
		elseif options[self.selection] == "CONFIG" then
			self:hide()
			self:getScene():add(require("title.OptionsMenu")(self.binding))
		elseif options[self.selection] == "QUIT" then
			self:hide()
			prox.timer.after(1, function() love.event.quit() end)
		end
	end
end

function Controller:gui()
	love.graphics.setColor(255, 255, 255, self.title_alpha)
	love.graphics.draw(self.title_image, prox.window.getWidth()/2, self.title_y, 0, 1, 1, 159, 28)

	local midx = prox.window.getWidth()/2

	love.graphics.setFont(self.sans_font)
	for i,v in ipairs(options) do
		local alpha = prox.math.cap(self.menu_alpha - math.abs(i-self.selection)*80, 0, 255)
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.printf(v, midx-149, 260+(i-1)*30, 300, "center")

		if self.ready and self.selection == i then
			local w = self.sans_font:getWidth(v)
			love.graphics.line(midx-150, 268+(i-1)*30, midx-w/2-14, 268+(i-1)*30)
			love.graphics.line(midx+150, 268+(i-1)*30, midx+w/2+14, 268+(i-1)*30)
		end
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function Controller:reset(keep_music)
	self:setEnabled(true)

	if not keep_music then
		music.playFile("data/music/dots.ogg")
	end

	self.title_y = 172
	self.title_alpha = 0
	prox.timer.after(1, function()
		prox.timer.tween(2, self, {title_y = 164, title_alpha = 255}, "out-cubic")
	end)

	self.menu_alpha = 0
	prox.timer.after(2, function()
		prox.timer.tween(2, self, {menu_alpha = 255 + (#options-1)*80}, "out-quad")
	end)

	prox.timer.after(3, function() self.ready = true end)
end

function Controller:hide()
	self.ready = false

	prox.timer.clear()
	prox.timer.tween(1, self, {title_alpha = 0, menu_alpha = 0}, "out-quad",
		function()
			self:setEnabled(false)
		end
	)
end

function Controller:keepAlive()
	return true
end

return Controller
