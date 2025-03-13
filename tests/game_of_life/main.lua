local primitives = require('forma.primitives')
local automata   = require('forma.automata')
local neighbourhood = require('forma.neighbourhood')

local pixels = 128

-- 128*128 square
local domain = primitives.square(pixels,pixels)
-- Set half the initial possible cells to active
local sample = domain:random(math.floor(domain:size()/2))
-- GoL rule
local moore  = automata.rule(neighbourhood.moore(), "B3/S23")
local ruleset = {moore}

function love.load()
    love.window.setMode(pixels, pixels)
end

function love.update()
    sample = automata.iterate(sample, domain, ruleset)
end

function love.draw()
    local points = {}
    for x, y in sample:cell_coordinates() do
        table.insert(points, {x, y})
    end
   love.graphics.points (points)
end

