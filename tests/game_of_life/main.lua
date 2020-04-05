local primitives = require('forma.primitives')
local subpattern = require('forma.subpattern')
local automata   = require('forma.automata')
local neighbourhood = require('forma.neighbourhood')

local pixels = 128

local domain = primitives.square(pixels,pixels)
--local sample = subpattern.random(domain, math.floor(domain:size()/2))
--local moore  = automata.rule(neighbourhood.moore(), "B3/S23")
--local ruleset = {moore}
--
-- Complicated ruleset, try leaving out or adding more rules
local sample = subpattern.random(domain, 1)
--local moore = automata.rule(neighbourhood.moore(),      "B12/S012345678")
--local diag  = automata.rule(neighbourhood.diagonal_2(), "B01/S01234")
--local vn    = automata.rule(neighbourhood.von_neumann(),"B12/S01234")
local vn    = automata.rule(neighbourhood.von_neumann(),"B24/S23")
local ruleset = {moore, diag}

function love.load()
    love.window.setMode(pixels, pixels)
end

function love.update()
    for _=1, 10, 1 do
    sample = automata.async_iterate(sample, domain, ruleset)
    end
end

function love.draw()
    local points = {}
    for x, y in sample:cell_coordinates() do
        table.insert(points, {x, y})
    end
   love.graphics.points (points)
end

