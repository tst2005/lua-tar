
--- A pure-Lua implementation of untar (unpacking .tar archives)
--module("luarocks.tools.tar", package.seeall)
local tar = {}

local blocksize = 512

local function get_typeflag(flag)
	if flag == "0" or flag == "\0" then return "file"
	elseif flag == "1" then return "link"
	elseif flag == "2" then return "symlink" -- "reserved" in POSIX, "symlink" in GNU
	elseif flag == "3" then return "character"
	elseif flag == "4" then return "block"
	elseif flag == "5" then return "directory"
	elseif flag == "6" then return "fifo"
	elseif flag == "7" then return "contiguous" -- "reserved" in POSIX, "contiguous" in GNU
	elseif flag == "x" then return "next file"
	elseif flag == "g" then return "global extended header"
	elseif flag == "L" then return "long name"
	elseif flag == "K" then return "long link name"
	end
	return "unknown"
end

local function octal_to_number(octal)
	local exp = 0
	local number = 0
	for i = #octal,1,-1 do
		local digit = tonumber(octal:sub(i,i)) 
		if digit then
			number = number + (digit * 8^exp)
			exp = exp + 1
		end
	end
	return number
end

local function checksum_header(block)
	local sum = 256
	for i = 1,148 do
		sum = sum + block:byte(i)
	end
	for i = 157,500 do
		sum = sum + block:byte(i)
	end
	return sum
end

local function nullterm(s)
	return s:match("^[^%z]*")
end

local function read_header_block(block)
	local header = {}
	header.name = nullterm(block:sub(1,100))
	header.mode = nullterm(block:sub(101,108))
	header.uid = octal_to_number(nullterm(block:sub(109,116)))
	header.gid = octal_to_number(nullterm(block:sub(117,124)))
	header.size = octal_to_number(nullterm(block:sub(125,136)))
	header.mtime = octal_to_number(nullterm(block:sub(137,148)))
	header.chksum = octal_to_number(nullterm(block:sub(149,156)))
	header.typeflag = get_typeflag(block:sub(157,157))
	header.linkname = nullterm(block:sub(158,257))
	header.magic = block:sub(258,263)
	header.version = block:sub(264,265)
	header.uname = nullterm(block:sub(266,297))
	header.gname = nullterm(block:sub(298,329))
	header.devmajor = octal_to_number(nullterm(block:sub(330,337)))
	header.devminor = octal_to_number(nullterm(block:sub(338,345)))
	header.prefix = block:sub(346,500)
	if header.magic ~= "ustar " and header.magic ~= "ustar\0" then
		return false, "Invalid header magic "..header.magic
	end
	if header.version ~= "00" and header.version ~= " \0" then
		return false, "Unknown version "..header.version
	end
	if not checksum_header(block) == header.chksum then
		return false, "Failed header checksum"
	end
	return header
end

local function tarstream(tar_handle, handle)
	assert(handle)
	local long_name, long_link_name
	while true do
		local block
		repeat 
			block = tar_handle:read(blocksize)
		until (not block) or checksum_header(block) > 256
		if not block then break end
		local header, err = read_header_block(block)
		if not header then
			error(err, 2)
		end

		local file_data = tar_handle:read(math.ceil(header.size / blocksize) * blocksize):sub(1,header.size)

		if header.typeflag == "long name" then
			long_name = nullterm(file_data)
		elseif header.typeflag == "long link name" then
			long_link_name = nullterm(file_data)
		else
			if long_name then
				header.name = long_name
				long_name = nil
			end
			if long_link_name then
				header.name = long_link_name
				long_link_name = nil
			end
		end

		handle(header)

		--[[
		local util = require("luarocks.util")
		for k,v in pairs(header) do
			util.printout("[\""..tostring(k).."\"] = "..(type(v)=="number" and v or "\""..v:gsub("%z", "\\0").."\""))
		end
		util.printout()
		--]]
	end
	return true
end

if false then

local fs = require("luarocks.fs")
--fs.make_dir
--fs.set_time
--fs.chmod
--io.open
local dir = require("luarocks.dir")

local function write_to_fs(header, destdir)
		local pathname = dir.path(destdir, header.name)
		if header.typeflag == "directory" then
			local ok, err = fs.make_dir(pathname)
			if not ok then return nil, err end
		elseif header.typeflag == "file" then
			local dirname = dir.dir_name(pathname)
			if dirname ~= "" then
				local ok, err = fs.make_dir(dirname)
				if not ok then return nil, err end
			end
			local file_handle = io.open(pathname, "wb")
			file_handle:write(file_data)
			file_handle:close()
			fs.set_time(pathname, header.mtime)
			if fs.chmod then
				fs.chmod(pathname, header.mode)
			end
		end
end


function tar.untar(filename, destdir)
	assert(type(filename) == "string")
	assert(type(destdir) == "string")

	local tar_handle = io.open(filename, "r")
	if not tar_handle then return nil, "Error opening file "..filename end
	local action = function(header)
		return write_to_fs(header, destdir)
	end
	tarstream(tar_handle, action)
	tar_handle:close()
end
end -- if

local function write_to_fs(header, destdir)
		local pathname = dir.path(destdir, header.name)
		if header.typeflag == "directory" then
			local ok, err = fs.make_dir(pathname)
			if not ok then return nil, err end
		elseif header.typeflag == "file" then
			local dirname = dir.dir_name(pathname)
			if dirname ~= "" then
				local ok, err = fs.make_dir(dirname)
				if not ok then return nil, err end
			end
			local file_handle = io.open(pathname, "wb")
			file_handle:write(file_data)
			file_handle:close()
			fs.set_time(pathname, header.mtime)
			if fs.chmod then
				fs.chmod(pathname, header.mode)
			end
		end
end
local floor = math.floor
local function num2str(n)
        n = floor(n)
        if n < 0 or n > 512 then
                return nil
        end
        local a = floor(n/64) % 8
        local b = floor(n/8) % 8
        local c = floor(n) % 8
        if a % 8 ~= a or b % 8 ~= b or c % 8 ~= c then
                return nil
        end
        local conv = {
                [0] = "---",
                [1] = "--x",
                [2] = "-w-",
                [3] = "-wx",
                [4] = "r--",
                [5] = "r-x",
                [6] = "rw-",
                [7] = "rwx",
        }
        return conv[a]..conv[b]..conv[c]
end

local function show_the_file(header, destdir)
	local fmode = function(mode)
		return num2str(tonumber(mode, 8))
	end
	local unixtime2txt = function(u)
		return os.date("%Y-%m-%d %H:%M", u)
	end
	if header.typeflag == "file" then
		print( ("%10s %s %s %5s %s %s"):format(
			"-"..tostring(fmode(header.mode)),
			header.uname,
			header.gname,
			header.size,
			unixtime2txt(header.mtime),
			header.name
		))
	elseif header.typeflag == "directory" then
		print( ("%10s %s %s %5s %s %s"):format(
			"d"..tostring(fmode(header.mode)),
			header.uname,
			header.gname,
			header.size,
			unixtime2txt(header.mtime),
			header.name
		))
	elseif header.typeflag == "symlink" then
		print( ("%10s %s %s %5s %s %s -> %s"):format(
			"l"..tostring(fmode(header.mode)),
			header.uname,
			header.gname,
			header.size,
			unixtime2txt(header.mtime),
			header.name,
			header.linkname
		))
	else
		for k,v in pairs(header) do
			print("[\""..tostring(k).."\"] = "..(type(v)=="number" and v or "\""..v:gsub("%z", "\\0").."\""))
		end
		print("")
	end
end

function tar.untarstream(filename, destdir)
	assert(type(filename) == "string")
	--assert(type(destdir) == "string")

	local tar_handle = io.open(filename, "r")
	if not tar_handle then return nil, "Error opening file "..filename end
	local action = function(header)
		return show_the_file(header, destdir)
	end
	tarstream(tar_handle, action)
	tar_handle:close()
end


return tar
