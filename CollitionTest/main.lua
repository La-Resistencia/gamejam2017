love.window.setTitle("Collition Test")
love.graphics.setDefaultFilter('nearest','nearest')

success = love.window.setMode(1000, 700)

function love.load()
	drops = {}

	insertDrop = function (x, y)
		drop = {}
		drop.x = x
		drop.y = y
        drop.t = 0
		table.insert(drops, drop)
    end

    paths = {}
	insertPath = function(x1, y1, x2, y2)
		path = {}
		path.x1 = x1
		path.y1 = y1
		path.x2 = x2
		path.y2 = y2

		table.insert(paths, path)
	end

    player = {}
	player.x = 200
	player.y = 200
	player.alive = false

	validatePlayerPosition = function()
		for i, path in pairs(paths) do
			discriminant = (path.y2 - path.y1)* (path.y2 - path.y1) + (path.x2 - path.x1)* (path.x2 - path.x1)

			if discriminant > 0 then
				segmentLength = math.sqrt(discriminant)

				distance = math.abs((path.y2 - path.y1)*player.x - (path.x2 - path.x1)*player.y + path.x2*path.y1 - path.y2*path.x1)/segmentLength

				config.lastDistance = distance

				if distance <= config.lineWidth/2 then
					projectionx = (player.x - path.x1)*(path.x2 - path.x1)/segmentLength
					projectiony = (player.y - path.y1)*(path.y2 - path.y1)/segmentLength
					segmentx = path.x2 - path.x1
					segmenty = path.y2 - path.y1

					projectionLength = math.sqrt(projectionx*projectionx + projectiony*projectiony)
					cosineOfProjection = (segmentx*projectionx + segmenty*projectiony)/segmentLength/projectionLength

					config.lastCosine = cosineOfProjection


					if cosineOfProjection > 0 and projectionLength < segmentLength then
						player.alive = true
						return
					end
				end
			end

			player.alive = false
		end
	end

	config = {}
	config.radio = 200
	config.lineWidth = 30
	config.lastCosine = 0
	config.lastDistance = 0

	--font = love.graphics.newImageFont("font.png"," 1234567890")
	--love.graphics.setFont(font)
	
end

function love.update(dt)
	if love.mouse.isDown(1) then
		insertDrop(love.mouse.getX(), love.mouse.getY())
	end

	if love.mouse.isDown(2) then
		player.x = love.mouse.getX()
		player.y = love.mouse.getY()
	end

	 paths = {}

	for i, drop in pairs(drops) do
		for j, drop2 in pairs(drops) do
			if i ~= j then
				discriminator = (drop.x - drop2.x)*(drop.x - drop2.x) + (drop.y - drop2.y)*(drop.y - drop2.y)

				if discriminator > 0 then
					d = math.sqrt(discriminator)
					l = (config.radio*config.radio - config.radio*config.radio + d*d)/(2*d)
					h = math.sqrt(config.radio*config.radio - l*l)

					x1 = l/d*(drop2.x - drop.x) + h/d*(drop2.y - drop.y) + drop.x
					y1 = l/d*(drop2.y - drop.y) - h/d*(drop2.x - drop.x) + drop.y

					x2 = l/d*(drop2.x - drop.x) - h/d*(drop2.y - drop.y) + drop.x
					y2 = l/d*(drop2.y - drop.y) + h/d*(drop2.x - drop.x) + drop.y

					insertPath(x1, y1, x2, y2)
				end
			end
		end
	end

	validatePlayerPosition()
end

function love.draw()
	for i, drop in pairs(drops) do
        love.graphics.setLineWidth(1)
		love.graphics.setColor(4, 121, 251)
		love.graphics.rectangle("fill", drop.x, drop.y, 2, 2)
        love.graphics.circle("line", drop.x, drop.y, config.radio)
	end

	love.graphics.setLineWidth(config.lineWidth)
	love.graphics.setColor(0, 0, 180)
	for i, path in pairs(paths) do
		love.graphics.line(path.x1, path.y1, path.x2, path.y2)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", player.x, player.y, 2, 2)

	if player.alive then
		love.graphics.print("1", 20, 20)
	else
		love.graphics.print("0", 20, 20)
	end

	love.graphics.print(config.lastCosine, 20, 40)
	love.graphics.print(config.lastDistance, 20, 60)
end
