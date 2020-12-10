-- push is a library that will allow us to draw our game at a virtual
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
require 'Ball'


WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

function love.load()
    --there will be no filtering of pixels (blurriness), which is important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- sets the title of the application window
    love.window.setTitle('Pong')

    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    -- set LÖVE2D's active font to the smallFont object
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static') 
    }

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true, 
        vsync = true,
    })

    -- starting score of the players
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    
    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 6, 6)

    -- game state variable used to transition between different parts of the game
    gamestate = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gamestate == 'serve' then
        -- before switching to play, initialize ball's velocity based on player who last scored
        ball.dy = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else 
            ball.dx = -math.random(140, 200)
        end
    elseif gamestate == 'play' then
        -- detects ball collision with paddles 
        -- reversing dx if true and slighty increasing it and altering dy depending on its position
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else 
                ball.dy = math.random(10, 150)
            end

            sounds.paddle_hit:play()
        end
        
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then 
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds.paddle_hit:play()
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds.wall_hit:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds.wall_hit:play()
        end

        -- if we reach the left or right edge of the screen, go back to start and update the score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            sounds.score:play()

            if player2Score == 10 then
                winningPlayer = 2 
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end
        end
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
        
            sounds.score:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0 
    end

    if gamestate == 'play' then
        ball:update(dt)
    end
    
    player1:update(dt)
    player2:updateAI(dt, ball.y, ball.dy) 
end

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()

    -- during play mode, the ball will move in a random direction    
    elseif key == 'enter' or key == 'return' then
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            gamestate = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw different things based on the state of the game
    love.graphics.setFont(smallFont)

    -- tells you if you're in start state or play state
    if gamestate == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- displays the score 
    displayScore()

    -- render paddles, now using their class's render method
    player1:render()
    player2:render()

    -- render ball using its class's render method
    ball:render()

    -- demonstrate how to see FPS in LOVE2D
    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

-- renders current FPS
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0/255, 255/255, 0/255, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    -- shows the score of the players
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end