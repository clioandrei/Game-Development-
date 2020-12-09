-- push library
push = require 'push'

-- class library
Class = require 'class'

-- bird class 
require 'Bird'

-- pipe class
require 'Pipe'

-- pair of pipes class
require 'PipePair'

-- game state and state machines
require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreenState'
require 'states/ScoreState'
require 'states/CountdownState'

-- physical dimension
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual dimension
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- loads the background images
local background = love.graphics.newImage('pictures/background.png')
local ground = love.graphics.newImage('pictures/ground.png') 

-- keep track of scroll amount
local backgroundScroll = 0
local groundScroll = 0

-- speed of the scrolling images, with respect to dt
BACKGROUND_SCROLL_SPEED = 30
GROUND_SCROLL_SPEED = 60

-- point where we loop the image of the background and ground
local BACKGROUND_LOOPING_POINT = 413    
local GROUND_LOOPING_POINT = 514

local scrolling = true

function love.load()
    -- nearest neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- sets the title of the application
    love.window.setTitle('Twitty Bird')

    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('fonts/flappy.ttf', 14)
    flappyFont = love.graphics.newFont('fonts/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('fonts/flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initializes the virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize sounds 
    sounds = {
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.mp3', 'static'),
        ['splat'] = love.audio.newSource('sounds/splat.mp3', 'static'),
        ['award'] = love.audio.newSource('sounds/award.mp3', 'static')
    }

    -- background music
    sounds.music:setLooping(true)
    sounds.music:play()

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
        ['countdown'] = function() return CountdownState() end
    }
    gStateMachine:change('title')

    -- keyboard input table
    love.keyboard.keysPressed = {}  

    -- mouse input table
    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    -- resizes the application
    push:resize(w, h)
end

function love.keypressed(key)
    -- added to table of keys
    love.keyboard.keysPressed[key] = true

    -- quits the application
    if key == 'escape' then
        love.event.quit()
    end
end

-- checks the global input table for keys activated
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

-- checks if mouse buttons are pressed
function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)    
    -- scrolls the background and ground
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT
        
    -- all of the update are stored in State Machine
    gStateMachine:update(dt)
        
        -- reset input table
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end


function love.draw()
    push:start()

    -- draws the background (1)
    love.graphics.draw(background, -backgroundScroll, 0)

    -- draws the bird and pipes (2)
    gStateMachine:render()

    -- draws the ground (3)
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
    push:finish()
end

