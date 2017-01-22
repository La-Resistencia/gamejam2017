require("animation")

currentState = 0

love.window.setTitle("Wave Paths")
love.graphics.setDefaultFilter('nearest','nearest')

inicio = love.graphics.newImage('start.png')
fin = love.graphics.newImage('end.png')
clockimg = newAnimation(love.graphics.newImage('clock.png'),16,16,0.1,2)
scoreimg = love.graphics.newImage('score.png')

dropimg = love.graphics.newImage('drop.png')
enoughdropimg = love.graphics.newImage('enoughdrop.png')
playButtonImg = love.graphics.newImage('play.jpg')
gameOverImg = love.graphics.newImage('gameOver.jpg')

maranim = newAnimation(love.graphics.newImage('Mar.png'),144,256,0.28,4)

windowHeight = 600
windowWidth = 338
success = love.window.setMode(338,600)

backsound = love.audio.newSource('When The Wind Blows.mp3')
backsound:setLooping(true)

walkstone = love.audio.newSource('walk_stone.mp3')
walkwater = love.audio.newSource('walk_water.mp3')
win = love.audio.newSource('winning.mp3')
gameover = love.audio.newSource('game-over.mp3')
dropaudio = {love.audio.newSource('drop1.mp3'),love.audio.newSource('drop2.mp3'), love.audio.newSource('drop3.mp3'), love.audio.newSource('drop4.mp3'),love.audio.newSource('drop5.mp3'),love.audio.newSource('drop6.mp3'),love.audio.newSource('drop7.mp3')}

izquierdapj1 = newAnimation(love.graphics.newImage('pjleft.png'),29,34,0.1,4)
derechapj1 = newAnimation(love.graphics.newImage('pjright.png'),29,34,0.1,4)
arribapj1 = newAnimation(love.graphics.newImage('pjback.png'),29,34,0.1,4)
abajopj1 = newAnimation(love.graphics.newImage('pjfront.png'),29,34,0.1,4)

function love.load()
	player = {}
	player.x = 159
	player.y = 556
	player.speed = 3
	player.animation = abajopj1
	player.alive = true

	cursor = {}
	cursor.x = 0
	cursor.y = 0
	cursor.cd = 0
	cursor.cddrop = 0

	droped = true

	drops = {}

	contador=10
	countdropimg = dropimg

	insertDrop = function (x, y)
		drop = {}
		drop.x = x
		drop.y = y
        drop.t = 0
        drop.sound = dropaudio[math.random(7)]
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

    validateDrop = function(drop)
        if drop.t == 0 then
        	drop.sound = dropaudio[math.random(7)]
        	love.audio.play(drop.sound)
    	end
        drop.t = drop.t + 1.5
        if drop.t > 1800 then
            drop.t = 0
        end
	end

	validatePlayerPosition = function()
		for i, path in pairs(paths) do
			discriminant = (path.y2 - path.y1)* (path.y2 - path.y1) + (path.x2 - path.x1)* (path.x2 - path.x1)

			if discriminant > 0 then
				segmentLength = math.sqrt(discriminant)

				distance = math.abs((path.y2 - path.y1)*player.x - (path.x2 - path.x1)*player.y + path.x2*path.y1 - path.y2*path.x1)/segmentLength

				if distance <= 15 then
					segmentx = path.x2 - path.x1
					segmenty = path.y2 - path.y1

					factor = (player.x - path.x1)*segmentx/discriminant + (player.y - path.y1)*segmenty/discriminant

					projectionx = factor*segmentx
					projectiony = factor*segmenty

					projectionLength = math.sqrt(projectionx*projectionx + projectiony*projectiony)
					cosineOfProjection = (segmentx*projectionx + segmenty*projectiony)/segmentLength/projectionLength

					if cosineOfProjection > 0 and projectionLength < segmentLength then
						player.alive = true
						return
					end
				end
			end

			player.alive = false
		end
	end

    fpsCounter = 0

	font = love.graphics.newImageFont("font.png"," 1234567890")
	counterFont = love.graphics.newImageFont("font1.png"," 1234567890")

	time = 60

end

function love.update(dt)
	if currentState == 0 then
		if love.mouse.isDown(1) then
			cursor.x = love.mouse.getX()
			cursor.y = love.mouse.getY()
			if cursor.x > 121 and cursor.x < 241 and cursor.y > 300 and cursor.y < 400 then
				currentState = 1
				fpsCounter = 10
				return
			end
		end	
	end

	if currentState == 2 then

	end

	if currentState == 1 then
		fpsCounter = fpsCounter-1
		if fpsCounter > 0 then return end

		maranim:update(dt)
		love.audio.play(backsound)

		player.alive = false

		---PLATAFORMAS
		paths = {}

		for i, drop in pairs(drops) do
			radio = math.floor(drop.t/10)
			-- detect a interception with another drop wave
			for j, drop2 in pairs(drops) do
				if i ~= j then
					radio2 = math.floor(drop2.t/10)
					discriminator = (drop.x - drop2.x)*(drop.x - drop2.x) + (drop.y - drop2.y)*(drop.y - drop2.y)

					if discriminator > 0 then
						d = math.sqrt(discriminator)
						l = (radio*radio - radio2*radio2 + d*d)/(2*d)
						h = math.sqrt(radio*radio - l*l)

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

		if player.x >= 63 and player.x <= 274 and player.y >= 30 and player.y <= 96 then
			love.audio.play(win)
			player.alive = true
		end
		if player.x >= 14 and player.x <= 337 and player.y >= 524 and player.y <= 630 then
			player.alive = true
		end

		if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and player.x < 322 then
			player.x = player.x + player.speed
			love.audio.play(walkstone)
			derechapj1:update(dt)
			player.animation = derechapj1
		end
		if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and player.x > 15 then
			player.x = player.x - player.speed
			love.audio.play(walkstone)
			izquierdapj1:update(dt)
			player.animation = izquierdapj1
		end
		if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) and player.y < 595 then
			player.y = player.y + player.speed
			love.audio.play(walkstone)
			abajopj1:update(dt)
			player.animation = abajopj1
		end
		if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and player.y > 31 then
			player.y = player.y - player.speed
			love.audio.play(walkstone)
			arribapj1:update(dt)
			player.animation = arribapj1
		end
		if love.mouse.isDown(1) then
			cursor.x = love.mouse.getX()
			cursor.y = love.mouse.getY()
			for _,v in pairs(drops) do
				if cursor.x >= v.x-3 and cursor.x <= v.x+3 and cursor.y >= v.y-3 and cursor.y <= v.y+3 then
					droped = false
				end
			end
			if droped and cursor.cddrop <= 0 then
				if contador > 0 then
					contador=contador-1
				end
				if countdropimg == dropimg and contador == 0 then
					countdropimg = enoughdropimg
				end
				insertDrop(cursor.x,cursor.y);
				cursor.cddrop = 2
			end
			droped = true
		end
		if cursor.cddrop > 0 then
			cursor.cddrop = cursor.cddrop - 4*dt
		end
		if cursor.cd > 0 then
			cursor.cd = cursor.cd - 4*dt
		end
		for i, drop in pairs(drops) do
			validateDrop(drop)
		end

		if time <= 15 then
			clockimg:update(dt)
		end

		if time <= 0 or player.alive == false then
			time = 0
			love.audio.play(gameover)
		else
			time = time - dt
		end
	end
end

function love.draw()
	if currentState == 0 then
		love.graphics.setLineWidth(1)
		love.graphics.setColor(4, 121, 251)
		love.graphics.draw(playButtonImg,118,300)

	end

	if currentState == 2 then
		love.graphics.setColor(4, 121, 251)
		love.graphics.draw(gameOverImg,10,300,0,0.5,0.5)
	end

	if currentState == 1 then
		love.graphics.setColor(255,255,255)
		maranim:draw(0,0,0,4)
		for i, drop in pairs(drops) do
			love.graphics.setLineWidth(1)
			love.graphics.setColor(4, 121, 251)
			love.graphics.rectangle("fill", drop.x, drop.y, 2, 2)
			radio = math.floor(drop.t/10)
			love.graphics.circle("line", drop.x, drop.y, radio)
		end

		love.graphics.setLineWidth(30)
		love.graphics.setColor(0, 0, 180)
		for i, path in pairs(paths) do
			love.graphics.line(path.x1, path.y1, path.x2, path.y2)
		end

		love.graphics.setColor(255,255,255)

		love.graphics.draw(inicio,0,525,0,2.347)
		love.graphics.draw(fin,49,0,0,3)

		player.animation:draw(player.x,player.y,0,1,1,14,30)
		love.graphics.rectangle("fill",player.x, player.y,2,2)

		------ HUD ----------

		clockimg:draw(1,290,0,4.8)
		love.graphics.draw(countdropimg,34,232,0,2)
		love.graphics.draw(scoreimg,230,270,0,2)

		timeInteger = math.floor(time);
		timeString = timeInteger;
		if timeInteger < 10 then
			timeString = "0"..timeString
		end

		love.graphics.setFont(font)
		love.graphics.print(timeString, 18, 322,0,0.5)
		love.graphics.setFont(counterFont)
		love.graphics.setColor(0, 35, 20)
		love.graphics.print(contador, 10, 232)
		love.graphics.print("9999", 250, 275)
	end
end