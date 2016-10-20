
local function tohex(v, len)
	return ("0x%"..(len and ("0."..len) or "").."x"):format(string.byte(v,1,-1))
end

local bool = function(x) return not not x end

local class = require "mini.class"
local instance = assert(class.instance)
local fs = class("fs", {})

local parentdir_is_myself = {} -- uniq value to bootstrap root directory

local dir = class("dir", {
	init = function(self, parentdir)
		assert(parentdir)

		local mt = getmetatable(self)
		if not mt then mt={} setmetatable(self, mt) end
		mt.hardcount = 1

		self:hardlink(".", self)
		--self["."] = self
		if parentdir == parentdir_is_myself then
			--self[".."] = self
			--self[""]   = self
			self:hardlink("..", self)
		else
			self:hardlink("..", parendir)
			--self[".."] = parentdir
		end
		--require "mini.class.autometa"(self, dirmt)
	end
})

function fs:init(hand)
	self.sep = '/'
	self.rootdir = instance(dir, parentdir_is_myself)

--	self.inode2file = {} -- [inode] = (obj)file
--	self.path2file  = {} -- [path] = (obj)file
	--self.file2paths (1 or N for hardlinks)
end

function fs:hardlinkcount(incr)
	getmetatable(self).hardcount = getmetatable(self).hardcount + incr
end

-- create a hardlink of <what> named <name> into <self>
function fs:hardlink(name, what)
	if not self[name] then
		self[name] = what
		what:hardlinkcount(1)
	end
end

function fs:unhardlink(name)
	if self[name] then
		self[name]:hardlinkcount(-1)
		self[name]=nil
	end
end

function fs:mkdir(pwd, name)
	
end

local split = require "mini.string.split"


local function read_header_block(block)
	local funcs = {}										    -- SIZE
	funcs.rawname		= function(self) return nullterm(block:sub(1,100))			end -- 100
	funcs.name		= funcs.rawname

	funcs.mode		= function(self) return nullterm(block:sub(101,108))			end -- 8
	funcs.uid		= function(self) return octal_to_number(nullterm(block:sub(109,116)))	end -- 16
	funcs.gid		= function(self) return octal_to_number(nullterm(block:sub(117,124)))	end -- 8
	funcs.size		= function(self) return octal_to_number(nullterm(block:sub(125,136)))	end -- 12
	funcs.mtime		= function(self) return octal_to_number(nullterm(block:sub(137,148)))	end -- 12
	funcs.chksum		= function(self) return octal_to_number(nullterm(block:sub(149,156)))	end -- 8
	funcs.rawtypeflag	= function(self) return block:sub(157,157)				end -- 1
	funcs.typeflag		= function(self) return get_typeflag(self.rawtypeflag())			end
	funcs.linkname		= function(self) return nullterm(block:sub(158,257))			end -- 100
	funcs.magic		= function(self) return block:sub(258,263)				end -- 6
	funcs.version		= function(self) return block:sub(264,265)				end -- 2
	funcs.uname		= function(self) return nullterm(block:sub(266,297))			end -- 32
	funcs.gname		= function(self) return nullterm(block:sub(298,329))			end -- 32
	funcs.devmajor		= function(self) return octal_to_number(nullterm(block:sub(330,337)))	end -- 8
	funcs.devminor		= function(self) return octal_to_number(nullterm(block:sub(338,345)))	end -- 8
	funcs.prefix		= function(self) return block:sub(346,500)				end -- 155

	local header = setmetatable({}, {__index=function(_,k) return assert(funcs[k], "invalid field")(funcs) end})

	return header
end
-- a////b => a/b
-- a/./b  => a/b
-- a/x/../b => a/b
-- x/../a/b => a/b

function fs:cleanpath(path)
	local sep = self.sep
	assert(sep == "/", "separator is not supported")
	return (
		path
		:gsub("^$", ".")		-- if empty returns "."
		:gsub("/+", "/")		-- remove multiple '/' occurrence
		:gsub("/$", "")			-- remove ending '/' if exists
		:gsub("$", "/")			-- add ending '/'
		:gsub("/%./", "/")
--			:gsub("^", "/")			-- prefix by '/'
--			:gsub("/[^/]+/%.%./", "/")	-- reduce "/something/.." to "/"
--			:gsub("^/", "")			-- remove the '/' prefix
		:gsub("^(.+)/$", "%1")		-- remove the last ending '/' if exists
		:gsub("^%./(.+)$", "%1")	-- if "./something" keep "something"
	)
end
function fs:pathsplit(pathstr)
	return split(pathstr, "/")
end

function fs:exists(path)
	return bool(self.path2file[self:cleanpath(path)])
end
--[[
fs.mkdir = function(dir)
fs.rmdir = function(dir, recursive)

fs.copy = function(fromfile, tofile)
fs.move = function(fromfile, tofile)
fs.rename = function(file, newname)

fs.create = function(file)
fs.remove = function(file)

fs.write = function(file, data)
fs.append = function(file, data)
-- fs.touch => fs.append(file, "") ou fs.update(file, now(), now()) ?
fs.read = function(file)

fs.appendcopy = function(fromfile, tofile)
fs.appendmove = function(fromfile, tofile)
fs.update = function(file, accesstime, modificationtime)

-- file meta info
fs.size = function(file)
fs.permissions = function(file)
fs.device = function(file)
fs.type = function(file)
fs.uid = function(file)
fs.gid = function(file)
fs.accesstime = function(file)		-- getatime
fs.modificationtime = function(file)	-- getmtime
fs.changetime = function(file)		-- getctime

fs.tmpname = function(length, prefix, suffix)
fs.files = function(dir, fullpath)

fs.link = function(file, link)		-- link
-- missing: unlink
fs.symlink = function(file, link)

fs.usetmp = function(length, prefix, suffix, call, dir)
fs.usetmpdir = function(length, prefix, suffix, call)

fs.separator = function()	-- dirsep
--fs.system = function(unixtype) -- os.arch ?
]]--

return setmetatable({}, {__call = function(_, ...) return instance(fs, ...) end})
