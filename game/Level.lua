local Level = class("game.Level")

function Level:initialize(path)
	self.events = {}

	if path then
		self:parse(path)
	end
end

function Level:parse(path)
	local datastr = love.filesystem.read(path)
	local data = loadstring(datastr)()

	for i,v in ipairs(data.layers) do
		if v.type == "objectgroup" and v.visible and #v.objects > 0 then
			local layer = {}
			for j, o in ipairs(v.objects) do
				local e = {}
				e.type = o.type
				e.time = tonumber(o.name)
				e.properties = {}
				e.properties.x = math.floor(o.x + 0.5)
				e.properties.y = math.floor(o.y + 0.5)
				for key, value in pairs(o.properties) do
					e.properties[key] = value
				end
				if o.polyline then
					e.properties.points = {}
					for _, p in ipairs(o.polyline) do
						table.insert(e.properties.points, {x=o.x+p.x, y=o.y+p.y})
					end
				end
				table.insert(layer, e)
			end
			table.insert(self.events, layer)
		end
	end
end

function Level:getEvents()
	return self.events
end

return Level
