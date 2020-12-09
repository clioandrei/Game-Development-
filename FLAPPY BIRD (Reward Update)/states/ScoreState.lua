ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    -- getting images of medals
    self.goldMedal = love.graphics.newImage('pictures/gold.png')
    self.silverMedal = love.graphics.newImage('pictures/silver.png')
    self.bronzeMedal = love.graphics.newImage('pictures/bronze.png')
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oh no! You lost!', 0, 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 70, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 210, VIRTUAL_WIDTH, 'center')
    
    -- receiving a medal (3rd Assignment)
    local receivedMedal = nil
    local medalType = nil

    if self.score >= 10  then 
        receivedMedal = self.goldMedal
        medalType = 'gold medal'
    elseif self.score >= 5 then 
        receivedMedal = self.silverMedal
        medalType = 'silver medal'
    elseif self.score >= 3 then
        receivedMedal = self.bronzeMedal
        medalType = 'bronze medal'
    end

    if receivedMedal ~= nil then
        love.graphics.printf('Congrats! You have earned a '.. medalType .. '!', 0, 90, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(receivedMedal, VIRTUAL_WIDTH / 2 - receivedMedal:getWidth() / 2, 115)
        
        sounds.award:play()
    end
end