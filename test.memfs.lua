
local fs = require "memfs"()

for _, pre in ipairs {
	"",
	"./",
	"/",
} do

for _, post in ipairs {
	"",
	"/",
} do

for _, p in ipairs {
"a////b",
"a/./b",
"a/x/../b",
"x/../a/b",
"",
} do
	local p = pre .. p .. post
	print( p, fs:cleanpath(p) )
end
end
end

