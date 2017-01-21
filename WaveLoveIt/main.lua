love.window.setTitle("Wave Paths")
love.graphics.setDefaultFilter('nearest','nearest')

success = love.window.setMode(338,600)

function love.load()
	drops = {}

	insertDrop = function (x, y)
		drop = {}
		drop.x = x
		drop.y = y
        drop.t = 0
		table.insert(drops, drop)
    end

    validateDrop = function(drop)
        drop.t = drop.t + 1
        if drop.t > 600 then
            drop.t = 0
        end
    end

    fpsCounter = 0
end

function love.update(dt)
	if love.mouse.isDown(1) then
		insertDrop(love.mouse.getX(), love.mouse.getY());
	end
end

function love.draw()
	-- love.graphics.rectangle("fill", player.x, player.y, 30, 30)
    -- fpsCounter = fpsCounter + 1

    -- if fpsCounter < 3 then
    --    return
    -- end

    -- fpsCounter = 0

	for i, drop in pairs(drops) do
        validateDrop(drop)
		love.graphics.rectangle("fill", drop.x, drop.y, 2, 2)
        love.graphics.circle("line", drop.x, drop.y, math.floor(drop.t/10))
	end
end