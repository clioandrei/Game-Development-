Bird = Class{}

local GRAVITY = 20

function Bird:init()
    -- loads the picture of the bird
    self.image = love.graphics.newImage('pictures/bird.png')

    -- gets the width and height of the image
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    -- sets the bird in the middle of the screen
    self.x = VIRTUAL_WIDTH / 2 - 8
    self.y = VIRTUAL_HEIGHT / 2 - 8

    -- starting y velocity 
    self.dy = 0
end

-- detects collision of bird from the pipes
function Bird:collides(pipe)
    -- the 2's are left and top offsets
    -- the 4's are right and bottom offsets
    -- both offsets are used to shrink the bounding box to give the player
    -- a little bit of leeway with the collision
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end
    
    return false
end

function Bird:update(dt)
    -- apply the gravity to velocity
    self.dy = self.dy + GRAVITY * dt
    
    -- makes the bird fly because of negative value
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        self.dy = -5

        -- jump sound
        sounds.jump:play()
    end

    -- apply gravity to position of the bird
    self.y = self.y + self.dy
end

function Bird:render()
    -- draws the bird 
    love.graphics.draw(self.image, self.x, self.y)
end