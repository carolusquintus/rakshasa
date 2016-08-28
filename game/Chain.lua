local Bullet = require("game.Bullet")

local Chain = class("game.Chain", prox.Entity)

local MIN_DIST = 86
local SUPER_THRESHOLD = 0.1
local INVULNERABLE_TIME = 1

function Chain:enter(ship1, ship2)
	self:setName("chain")
	self.z = 2
	self.invulnerable = 0

	self.ship1 = ship1
	self.ship2 = ship2

	self.center_sprite = prox.Sprite("data/images/chain_center.png")
	self.center_ring = prox.Sprite("data/images/chain_ring.png")
	self.chain_link = prox.Sprite("data/images/chain_link.png", 4, 4)
end

function Chain:update(dt, rt)
	-- Move center
	self.x = math.floor((self.ship1.x + self.ship2.x) / 2)
	self.y = math.floor((self.ship1.y + self.ship2.y) / 2)

	-- Move ships apart if too close
	local xdist = self.ship2.x - self.ship1.x
	local ydist = self.ship2.y - self.ship1.y
	local dist = math.sqrt(xdist^2 + ydist^2)

	if dist < MIN_DIST then
		self.ship1.x = self.x - xdist / dist * MIN_DIST / 2
		self.ship2.x = self.x + xdist / dist * MIN_DIST / 2
		self.ship1.y = self.y - ydist / dist * MIN_DIST / 2
		self.ship2.y = self.y + ydist / dist * MIN_DIST / 2
	end

	-- Rotate center and gears
	local direction = math.atan2(ydist, xdist)
	self.center_ring:setRotation(direction)
	self.ship1:setDirection(direction)
	self.ship2:setDirection(direction)
	self.ship1:getGearSprite():setRotation(dist / 48)
	self.ship2:getGearSprite():setRotation(dist / 48)

	-- Check collision with bullets
	self.invulnerable = self.invulnerable - dt
	if self.invulnerable <= 0 then
		hc_rect = HC.rectangle(0, 0, dist, 5)
		hc_rect:moveTo(self.x, self.y)
		hc_rect:setRotation(direction)

		for i,v in ipairs(self:getScene():findAll("bullet")) do
			if not v:isPlayerBullet() and hc_rect:collidesWith(v:getHCShape()) then
				self.invulnerable = INVULNERABLE_TIME
				v:kill()
			end
		end
	end
end

function Chain:draw()
	if self.invulnerable >= 0 and prox.time.getTime() % 0.15 < 0.075 then return end

	local xdist = (self.ship2.x - self.ship1.x) / 2
	local ydist = (self.ship2.y - self.ship1.y) / 2
	local dist = math.sqrt(xdist^2 + ydist^2)
	local count = dist / 9

	for i=0, count-1 do
		self.chain_link:draw(self.x + xdist * i / count, self.y + ydist * i / count)
		self.chain_link:draw(self.x - xdist * i / count, self.y - ydist * i / count)
	end

	self.center_ring:draw(self.x, self.y)
	self.center_sprite:draw(self.x, self.y)
end

return Chain
