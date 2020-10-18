-- title:  Snake
-- author: jeremyd85
-- desc:   Snake Game
-- script: lua

function print_table(tab)
	for k, v in ipairs(tab) do
		trace(k..": ", v)
	end
end

Color = {BLACK = 0, PURPLE = 1, RED = 2, ORANGE = 3, YELLOW = 4, LIGHT_GREEN = 5, 
	GREEN = 6, DARK_GREEN = 7, DARK_BLUE = 8, BLUE = 9, LIGHT_BLUE = 10, 
	CYAN = 11, WHITE = 12, LIGHT_GREY = 13, GREY = 14, DARK_GREY = 15}

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

function Snake:in_snake(x, y)
	for _, pos in pairs(self.trail) do
		if x == pos.x and y == pos.y then
			return true
		end
	end
	return false
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
	self.playing = true
	self.food = {x = nil, y = nil}
	self.snake = Snake:new({x = width//2, y = height//2})
	self.curr_tick = 0
	self.prev_tick = 0
	self.growth_rate = 1
	self:_relocate_food()
	return self
end

function GameState:_is_game_over(direction)
	local x_mod, y_mod = next_pos_mod(direction)
	local new_head = {}
	new_head.x = self.snake:head().x + x_mod
	new_head.y = self.snake:head().y + y_mod
	return self.snake:in_snake(new_head.x, new_head.y) or 
		(new_head.x > self.width - 1 or 
		new_head.y > self.height - 1 or 
		new_head.x < 0 or 
		new_head.y < 0)
end

function GameState:_relocate_food()
	local valid_spots = {}
	-- Adds only coordinates on the board and not the snake
	for x = 0, self.width - 1 do
		for y = 0, self.height - 1 do
			if not self.snake:in_snake(x, y) then
				table.insert(valid_spots, {x, y})
			end
		end
	end
	local location = valid_spots[math.random(#valid_spots)]
	self.food.x = location[1]
	self.food.y = location[2]
end

function GameState:update(direction)
	self.curr_tick = time()//(1000//2.5)
	-- Check if it is a game update tick
	if self.curr_tick <= self.prev_tick or not self.playing then
		return false
	end
	-- Check for game over
	if self:_is_game_over(direction) then
		self.game_over = true
		self.playing = false
		return false
	end
	-- Update snake position
	self.snake:update(direction)
	local head = self.snake:head()
	-- Check if food is eatten
	if head.x == self.food.x and head.y == self.food.y then
		self.snake:extend(self.growth_rate)
		self.score = self.score + self.growth_rate
		self:_relocate_food()
	end
	-- Update prev_tick
	self.prev_tick = self.curr_tick
	return true
end


Display = {}
function Display:new(game_state)
	setmetatable({}, Display)
	self.WIN_WIDTH = 240
	self.WIN_HEIGHT = 136
	self.SPRITE_SIZE = 8
	self.gs = game_state
	return self
end

function Display:_draw_grid(x_offset, y_offset, color)
	local grid_width = gs.width * self.SPRITE_SIZE
	local grid_height = gs.height * self.SPRITE_SIZE
	-- Vertical Lines
	for i = 0, grid_width, self.SPRITE_SIZE do
		line(i+x_offset, grid_height+y_offset, i+x_offset, y_offset, color)
	end
	-- Horizotal Lines
	for i = 0, grid_height, self.SPRITE_SIZE do
		line(grid_width+x_offset, i+y_offset, x_offset, i+y_offset, color)
	end
end

function Display:_draw_snake(x_offset, y_offset, color)
	for _, pos in pairs(self.gs.snake.trail) do
		local x = (pos.x * self.SPRITE_SIZE) + x_offset
		local y = (pos.y * self.SPRITE_SIZE) + y_offset
		local w = self.SPRITE_SIZE - 1
		local h = w
		-- rect(x, y, w, h, color)
		spr(0, x, y)
	end
end

function Display:_draw_food(x_offset, y_offset, color)
	local x = (self.gs.food.x * self.SPRITE_SIZE + 2) + x_offset
	local y = (self.gs.food.y * self.SPRITE_SIZE + 2) + y_offset
	local w = self.SPRITE_SIZE - 3
	local h = w
	rect(x, y, w, h, color)
	
end

function Display:game_grid(x_offset, y_offset)
	cls()
	-- Display the snake
	self:_draw_snake(x_offset, y_offset, Color.WHITE)
	-- Display Food
	self:_draw_food(x_offset, y_offset, Color.RED)
	-- Display the game grid
	self:_draw_grid(x_offset, y_offset, Color.DARK_GREY)
end

math.randomseed(tstamp())

-- Global objects
gs = GameState:new(10, 10, 8)
dis = Display:new(gs)
ic = InputControl:new()


go_cnt = 0

prev_direction = Directions.UP

function TIC()
	ic:update()
	local direction = ic:last_pressed()
	gs:update(direction)
    dis:game_grid(15, 36)
end

function game_tick()
	return time() // (1000 // UPDATE_SPEED)
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
