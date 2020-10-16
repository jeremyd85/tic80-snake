-- title:  Snake
-- author: jeremyd85
-- desc:   Snake Game
-- script: lua

function print_table(tab)
	for k, v in ipairs(tab) do
		trace(k..": ", v)
	end
end

Directions = {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}

InputControl = {_btn = {}}
function InputControl:new()
	setmetatable({}, InputControl)
	self._btn = {}
	for _, i in pairs(Directions) do
		self._btn[i] = {pressed = 0, released = 0}
	end
	return self
end

function InputControl:update()
	local curr_time = time()
	for _, i in pairs(Directions) do
		if btn(i) then
			self._btn[i].released = curr_time
		end
		if btnp(i) then
			self._btn[i].pressed = curr_time
		end
	end
end

function InputControl:last_pressed()
	local max_dir = -1
	local max_time = -1
	for _, i in pairs(Directions) do
		if self._btn[i].pressed > max_time then
			max_dir = i
			max_time = self._btn[i].pressed
		end
	end
	return max_dir
end

function InputControl:display()
	for k, v in ipairs(Directions) do
		trace(string.format("%s: pressed = %.3f, released = %.3f", k, self._btn[v].pressed, self._btn[v].released))
	end
end

function next_pos_mod(direction)
	local dir_mod = {}
	dir_mod[Directions.UP] = {x = 0, y = -1}
	dir_mod[Directions.DOWN] = {x = 0, y = 1}
	dir_mod[Directions.LEFT] = {x = -1, y = 0}
	dir_mod[Directions.RIGHT] = {x = 1, y = 0}
	return dir_mod[direction].x, dir_mod[direction].y
end


Snake = {length = 1, trail = {}}
function Snake:new(head)
	setmetatable({}, Snake)
	self.length = 1
	self.trail = {}
	self.trail[1] = head
	return self
end

function Snake:extend(n)
	self.length = self.length + 1
end

function Snake:update(direction)
	local x_mod, y_mod = next_pos_mod(direction)
	local new_head = {}
	new_head.x = self:head().x + (x_mod)
	new_head.y = self:head().y + (y_mod)
	table.insert(self.trail, 1, new_head)
	local last_index = #self.trail
	if last_index > self.length then
		table.remove(self.trail, last_index)
	end
end

function Snake:head()
	return self.trail[1]
end

function Snake:tail()
	return self.trail[table.maxn(self.trail)]
end


GameState = {width = 10, height = 10, size = 8}
function GameState:new(width, height, size)
	setmetatable({}, GameState)
	self.width = width
	self.height = height
	self.game_over = false
	self.score = 0
	self.size = size
	self.ic = InputControl:new()
	self.snake = Snake:new({x = width//2, y = height//2})
	self.curr_tick = 0
	self.prev_tick = 0
	return self
end

function GameState:draw_background()
	cls()
	local disp_width = self.width * self.size
	local disp_height = self.height * self.size
	for i = 0, disp_width, self.size do
		line(i, disp_height, i, 0, 15)
	end
	for i = 0, disp_height, self.size do
		line(disp_width, i, 0, i, 15)
	end
end

function GameState:draw_snake()
	for _, pos in pairs(self.snake.trail) do
		rect(pos.x*self.size+1, pos.y*self.size+1, self.size-1, self.size-1, 12)
	end
end

function GameState:update()
	self.ic:update()
	direction = self.ic:last_pressed()
	self.ic:display()
	self.curr_tick = time()//(1000//2.5)
	if self.curr_tick > self.prev_tick then
		if math.random(20) == 5 then
			self.snake:extend(1)
		end
		self.snake:update(direction)
	end
	self.prev_tick = self.curr_tick
end


gs = GameState:new(15, 15, 8)


function TIC()
	gs:draw_background()
	gs:draw_snake()
	gs:update()
end

function game_tick()
	return time()//(1000//UPDATE_SPEED)
end



-- <TILES>
-- 000:000000000cccccc00cccccc00cccccc00cccccc00cccccc00cccccc000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

-- <TILES>
-- 000:000000000cccccc00cccccc00cccccc00cccccc00cccccc00cccccc000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
