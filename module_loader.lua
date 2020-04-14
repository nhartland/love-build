--- <love-build>
-- Code injected by LOVE Build to include the installed luarocks tree
-- into the require path.

--- Existing path preservation
--package.path = package.path .. ";lb_modules/share/lua/5.1/?.lua"
--package.path = package.path .. ";lb_modules/share/lua/5.1/?/init.lua"

-- Overwrites existing path
package.path = "lb_modules/share/lua/5.1/?.lua"
package.path = package.path .. ";lb_modules/share/lua/5.1/?/init.lua"
--- </love-build>
