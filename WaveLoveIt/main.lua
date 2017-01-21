require("animation")

love.window.setTitle("Wave Paths")
love.graphics.setDefaultFilter('nearest','nearest')

inicio = love.graphics.newImage('start.png')
fin = love.graphics.newImage('end.png')

maranim = newAnimation(love.graphics.newImage('Mar.png'),144,256,0.28,4)

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
        if drop.t > 600 then
            drop.t = 0
        end
    end

    fpsCounter = 0

	font = love.graphics.newImageFont("font.png"," 1234567890")
	counterFont = love.graphics.newImageFont("font1.png"," 1234567890")

	time = 60
end

function love.update(dt)
	maranim:update(dt)
	love.audio.play(backsound)

	player.alive = false
    if player.x >= 49 and player.x <= 260 and player.y >= 0 and player.y <= 66 then
    	love.audio.play(win)
    	player.alive = true
    end
    if player.x >= 0 and player.x <= 309 and player.y >= 494 and player.y <= 600 then
    	player.alive = true
    end

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

	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and player.x < 308 then
		player.x = player.x + player.speed
		love.audio.play(walkstone)
		derechapj1:update(dt)
		player.animation = derechapj1
	end
	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and player.x > 1 then
		player.x = player.x - player.speed
		love.audio.play(walkstone)
		izquierdapj1:update(dt)
		player.animation = izquierdapj1
	end
	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) and player.y < 565 then
		player.y = player.y + player.speed
		love.audio.play(walkstone)
		abajopj1:update(dt)
		player.animation = abajopj1
	end
	if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and player.y > 1 then
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

    if time <= 0 or player.alive == false then
    	time = 0
    	love.audio.play(gameover)
    else
		time = time - dt
	end
end

function love.draw()
	love.graphics.setColor(255,255,255)
	maranim:draw(0,0,0,4)
	for i, drop in pairs(drops) do
        love.graphics.setLineWidth(1)
		love.graphics.setColor(4, 121, 251)
		love.graphics.rectangle("fill", drop.x, drop.y, 2, 2)
        radio = math.floor(drop.t/10)
        love.graphics.circle("line", drop.x, drop.y, radio)
	end

	love.graphics.setLineWidth(10)
	love.graphics.setColor(0, 0, 180)
	for i, path in pairs(paths) do
		love.graphics.line(path.x1, path.y1, path.x2, path.y2)
	end

	love.graphics.setColor(255,255,255)
	love.graphics.draw(inicio,0,525,0,2.347)
	love.graphics.draw(fin,49,0,0,3)
	timeInteger = math.floor(time);
	timeString = timeInteger;
	if timeInteger < 10 then
		timeString = "0"..timeString
	end

	love.graphics.setFont(font)
	love.graphics.print(timeString, 9, 319);
	love.graphics.setFont(counterFont)
	love.graphics.print("10", 18, 232);
	love.graphics.print("9999", 250, 275);

	player.animation:draw(player.x,player.y,0,1)
end