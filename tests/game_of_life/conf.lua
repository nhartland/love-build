if love.filesystem then
    require 'rocks' ()
end

function love.conf(t)
    t.modules.joystick = false
    t.modules.physics = false
    t.title = 'GameOfLife'
    t.package = 'GameOfLife'
    t.loveVersion = '11.3'
    t.version = "11.3"
    t.author = "Nathan Hartland"
    t.email = "nathan@pseudorandom.dev"
    t.description = "A basic game of life"
    t.homepage = "https://github.com/nhartland/love-build"
    t.identifier = nil
    t.excludeFileList = {''}
    t.compile = false
    t.identity = "identity"
    t.dependencies = {
        "forma ~> 0.2",
    }
end
