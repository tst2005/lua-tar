
-- dir.tree[name].tree[name]

local class = require "mini.class"
local instance = assert(class.instance)

local parentdir_is_myself = {} -- uniq value to bootstrap root directory

local dir = class("dir", {
	init = function(self, parentdir)
--		assert(parentdir, "missing parent directory object")
		self.hardcount = 1
		self.tree = {}
		self:hardlink(".", self) 				-- self["."]  = self
		if parentdir == parentdir_is_myself then
			--						-- self[""]   = self
			self:hardlink("..", self)			-- self[".."] = self
--		else
--			self:hardlink("..", parendir)			-- self[".."] = parentdir
		end
		--require "mini.class.autometa"(self, dirmt)
--		assert(tree[".."])
		return tree -- the instance returns self, tree
	end
})

function dir:_hardlinkcount(incr)
	assert(incr == 1 or incr == -1)
	self.hardcount = self.hardcount + incr
end

-- create a hardlink of <what> named <name> into <self>
function dir:hardlink(name, what)
	if not self.tree[name] then
		self.tree[name] = what
		what:_hardlinkcount(1)
	end
end

function dir:unhardlink(name)
	if self[name] then
		self[name]:_hardlinkcount(-1)
		self[name]=nil
	end
end

function dir:mkdir(name)
	if self.tree[name] then
		error("already exists", 2)
	end
	local d = dir()
	d:hardlink("..", self)
	self.tree[name] = d
	return d
end

return setmetatable({ROOTFS=parentdir_is_myself}, {__call = function(_, ...) return instance(dir, ...) end})
