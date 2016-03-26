#!/usr/bin/lua

local function usage(fh)
	fh:write( ("%s: <mod-dir> <file>\n"):format(args[0]) )
	fh:write( "\n" )
	fh:write( "Normalizes the intra-mod require calls to '.' as a separator.\n" )
end

local mod_dir, file = ...

assert( mod_dir )
assert( file )

local function slurpFile()
	local lines = {}

	local fh = assert( io.open(file, "r") )
	for l in fh:lines() do
		table.insert(lines, l)
	end
	fh:close()

	return lines
end

local function writeFile(lines)
	local fh = assert( io.open(file, "wb") )

	for _, l in ipairs(lines) do
		fh:write(l, "\n")
	end

	fh:close()
end

local SEP = "./\\"
local function processString(str)
	local pieces = {}
	for m in str:gmatch("[^"..SEP.."]+") do
		table.insert(pieces, m)
	end
	assert(#pieces > 0)

	local MYSEP = "/"

	if os.execute( ("test -d %s/scripts/%s"):format(mod_dir, pieces[1]) ) then
		MYSEP = "."
	end

	return table.concat(pieces, MYSEP)
end

local function processLine(l)
	return l:gsub([=[require ["'](.-)["']]=], function(str)
		local ret = 'require "'..processString(str)..'"'
		print(ret)
		return ret
	end)
end

local lines = slurpFile()
for i, l in ipairs(lines) do
	lines[i] = processLine(l)
end
writeFile(lines)
