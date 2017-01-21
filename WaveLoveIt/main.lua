require("animation")

love.window.setTitle("Wave Paths")
love.graphics.setDefaultFilter('nearest', 'nearest')

mar = love.graphics.newImage('Mar.png')
maranim = newAnimation(mar,144,256,0.28,4)

success = love.window.setMode(338,600)

backsound = love.audio.newSource('When The Wind Blows.mp3')
backsound:setLooping(true)

walkstone = love.audio.newSource('walk_stone.mp3')
walkwater = love.audio.newSource('walk_water.mp3')
dropaudio = {love.audio.newSource('drop1.mp3'),love.audio.newSource('drop2.mp3'), love.audio.newSource('drop3.mp3'), love.audio.newSource('drop4.mp3'),love.audio.newSource('drop5.mp3'),love.audio.newSource('drop6.mp3'),love.audio.newSource('drop7.mp3')}

function love.load()
	player = {}
	player.x = 165
	player.y = 568
	player.speed = 3

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

    validateDrop = function(drop)
        if drop.t == 0 then
        	drop.sound = dropaudio[math.random(7)]
        	love.audio.play(drop.sound)
    	end
        drop.t = drop.t + 1
        if drop.t > 6000 then
            drop.t = 0
        end
    end

    fpsCounter = 0
end

function love.update(dt)
	maranim:update(dt)
	love.audio.play(backsound)
	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		player.x = player.x + player.speed
		love.audio.play(walkstone)
	end
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		player.x = player.x - player.speed
		love.audio.play(walkstone)
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		player.y = player.y + player.speed
		love.audio.play(walkstone)
	end
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		player.y = player.y - player.speed
		love.audio.play(walkstone)
	end
	if love.mouse.isDown(1) then
		cursor.x = love.mouse.getX()
		cursor.y = love.mouse.getY()
		for _,v in pairs(gotas) do
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
end

function love.draw()
	love.graphics.setColor(255,255,255)
	maranim:draw(0,0,0,4)
	love.graphics.rectangle("fill",player.x,player.y,30,30)
	for _,v in pairs(gotas) do
		love.graphics.rectangle("fill",v.x-3,v.y-3,7,7)
	end
	for i, drop in pairs(drops) do
        love.graphics.setLineWidth(1)
		love.graphics.setColor(4, 121, 251)
		love.graphics.rectangle("fill", drop.x, drop.y, 2, 2)
        radio = math.floor(drop.t/100)
        love.graphics.circle("line", drop.x, drop.y, radio)

        -- detect a interception with another drop wave

        love.graphics.setLineWidth(10)
        for j, drop2 in pairs(drops) do
            if i ~= j then
                radio2 = math.floor(drop2.t/100)

                discriminator = (drop.x - drop2.x)*(drop.x - drop2.x) + (drop.y - drop2.y)*(drop.y - drop2.y)

                if discriminator > 0 then
                    love.graphics.setColor(0, 0, 0)

                    d = math.sqrt(discriminator)
                    l = (radio*radio - radio2*radio2 + d*d)/(2*d)
                    h = math.sqrt(radio*radio - l*l)

                    x1 = l/d*(drop2.x - drop.x) + h/d*(drop2.y - drop.y) + drop.x
                    y1 = l/d*(drop2.y - drop.y) - h/d*(drop2.x - drop.x) + drop.y

                    x2 = l/d*(drop2.x - drop.x) - h/d*(drop2.y - drop.y) + drop.x
                    y2 = l/d*(drop2.y - drop.y) + h/d*(drop2.x - drop.x) + drop.y

                    love.graphics.line(x1, y1, x2, y2)
                    end
                end
            end
	end
end