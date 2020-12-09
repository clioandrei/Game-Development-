Pipe = Class{}

-- loads the picture of the pipe
local PIPE_IMAGE = love.graphics.newImage('pictures/pipe.png')

function Pipe:init(orientation, y)
    -- randomizes the position of the pipe
    self.x = VIRTUAL_WIDTH + 64
    self.y = y

    -- gets the width of the picture
    self.width = PIPE_IMAGE:getWidth()
    self.height = PIPE_HEIGHT

    self.orientation = orientation
end

function Pipe:update(dt)
    
end

function Pipe:render()
    -- draws the pipe
    love.graphics.draw(PIPE_IMAGE, self.x,
    (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y),
    0, 1, self.orientation == 'top' and -1 or 1)
end