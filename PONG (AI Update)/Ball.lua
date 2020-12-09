Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100) 
    self.dy = math.random(2) == 1 and 100 or -100
end

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.width then
        return false
    end
    
    return true
end

-- Places the ball in the middle of the screen, with intitial random velocity on both axes
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(-50, 50) 
    self.dy = math.random(2) == 1 and -100 or 100
end

-- Simply applies velocity to position, scaled by deltaTime.
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Draws the ball
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end