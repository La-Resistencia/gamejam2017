love.window.setTitle("Wave Paths")
love.graphics.setDefaultFilter('nearest','nearest')

success = love.window.setMode(388,600)



function love.load()
	player = {}
	player.x = 165
	player.y = 568
	player.speed = 1

	cursor = {}
	cursor.x = 0
	cursor.y = 0
	cursor.cd = 0
	cursor.cddrop = 0

	gotas = {}

	insertgota = function ()
		gota = {}
		gota.x = cursor.x
		gota.y = cursor.y
		table.insert(gotas,gota)
	end

	drop = true
end

function love.update(dt)
	if love.keyboard.isDown("right") then
		player.x = player.x + player.speed
	end
	if love.keyboard.isDown("left") then
		player.x = player.x - player.speed
	end
	if love.keyboard.isDown("down") then
		player.y = player.y + player.speed
	end
	if love.keyboard.isDown("up") then
		player.y = player.y - player.speed
	end
	if love.mouse.isDown(1) then
		cursor.x = love.mouse.getX()
		cursor.y = love.mouse.getY()
		for _,v in pairs(gotas) do
			if cursor.x >= v.x-3 and cursor.x <= v.x+3 and cursor.y >= v.y-3 and cursor.y <= v.y+3 then
				drop = false
			end
		end
		if drop and cursor.cddrop <= 0 then
			insertgota()
			cursor.cddrop = 2
		end
		drop = true
	end
	if cursor.cddrop > 0 then
		cursor.cddrop = cursor.cddrop - 4*dt
	end
	if cursor.cd > 0 then
		cursor.cd = cursor.cd - 4*dt
	end
end

function love.draw()
	love.graphics.rectangle("fill",player.x,player.y,30,30)
	for _,v in pairs(gotas) do
		love.graphics.rectangle("fill",v.x-3,v.y-3,7,7)
	end
end