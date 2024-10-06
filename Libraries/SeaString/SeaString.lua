--[[

Sea String (mostly Sea.string)

A Mini-Library for string functions.

Compiler:
	AnduinLothar (karlkfi@cosmosui.org)

Contributors:
	Thott (thott@thottbot.com)
	Legorol (legorol@cosmosui.org)
	Mugendai (mugekun@gmail.com)
	Iriel (iriel@vigilance-committee.org)
	

==Installation/Utilization==

Embedding:
- Drop the SeaString folder into your Interface\AddOns\YourAddon\ folder
- Add Sea and SeaString as optional dependancies
- Add the following line to the end of your TOC file, before your addon files:
SeaString\SeaString.lua

Standard:
- Drop the SeaString folder into your Interface\AddOns\ directory
- Add SeaString as a required dependancy


Change Log:
v0.2
- Changed lua file name
v0.1 (Alpha)
- SeaString Forked into Mini-Library from the main Sea. Still backwards compatible.


	$LastChangedBy: karlkfi $
	$Rev: 2577 $
	$Date: 2005-10-10 14:44:01 -0700 (Mon, 10 Oct 2005) $
]]--

local SEA_STRING_VERSION = 0.11;
local loadThisEmbeddedInstance;
SEA_STRING_DEBUG = nil;
------------------------------------------------------------------------------
--[[ Embedded Sub-Library Load Algorithm ]]--
------------------------------------------------------------------------------

if(not Sea) then
	Sea = {};
	Sea.versions = {};
	Sea.versions.SeaString = SEA_STRING_VERSION;
	loadThisEmbeddedInstance = true;
	Sea.string = {};
else
	if(not Sea.versions) then
		Sea.versions = {};
	end
	if (not Sea.versions.SeaString) or (Sea.versions.SeaString < SEA_STRING_VERSION) then
		Sea.versions.SeaString = SEA_STRING_VERSION;
		loadThisEmbeddedInstance = true;
	end
	if(not Sea.string) then
		Sea.string = {};
	end
end

if (loadThisEmbeddedInstance) then
	loadThisEmbeddedInstance = nil;


------------------------------------------------------------------------------
	--[[ Function Definitions - User Functions ]]--
------------------------------------------------------------------------------

	--
	-- byte(string)
	--
	--	Converts a character to its bytecode
	--
	-- Args:
	-- 	string - the string
	--
	-- Returns:
	-- 	(string)
	-- 	string - the string in byte code with format <##>
	--
	Sea.string.byte = function(c)
		return string.format("<%02X>",string.byte(c));
	end

	--
	--	byteSum (string s)
	--		returns the bytecode sum for s
	--
	-- Args:
	-- 	s - the string
	--
	-- Returns:
	-- 	(number)
	-- 	number - the value of the string with all of its
	-- 	chars summed together. 
	--		
	
	Sea.string.byteSum = function(s)
		local sum = 0;
		local len = string.len(s);
		local sbyte = string.byte;
		for i=1,len do
			sum = sum + sbyte(s,i);
		end
		return sum;
	end
	
	--
	-- toInt (string s)
	--
	-- 	Converts the specified string to an int
	--
	-- Returns: 
	-- 	(Number int)
	-- 	int - the string S as a number
	--
	Sea.string.toInt = tonumber;

	-- 
	-- fromTime(Number time, Number decimalplaces)
	--
	-- 	Creates a readable time from a number time in WoW
	-- 	Decimal places gives the number of .### to display
	--
	-- Returns:
	-- 	(String timeString)
	-- 	timeString - the time
	-- 	
	
	Sea.string.fromTime = function (time, decimalplaces)
		if (time < 0)   then
			time = 0;
		end
		if ( not decimalplaces ) then 
			decimalplaces = 0;
		end
		
		local floor = math.floor;
		local mod = math.mod;
		
		local seconds = mod(time, 60);
		local minutes = mod(floor(time/60), 60);
		local hours = floor(time/(3600));
		local spfx = '';
		if (seconds < 10) then
			spfx = '0';
		end
		
		if (hours > 0) then
			return string.format("%d:%.2d:%s%."..decimalplaces.."f", hours, minutes, spfx, seconds);
		else
			return string.format("%d:%s%."..decimalplaces.."f", minutes, spfx, seconds);
		end
	end
	
	--
	-- capitalizeWords(String phrase)
	--
	--	Takes a string like "hello world" and turns 
	--	it into "Hello World". 
	--
	-- Returns:
	-- 	(String capitalizedPhrase)
	-- 
	
	Sea.string.capitalizeWords = function ( text )
		if (not text) then
			return text;
		end
		local capitalizedPhrase = "";
		local value, mend;
	   	local mstart = 1;
		local regexKey = "([^%s]+[%s]*)";
		local sfind = strfind;	-- string.find if not in WoW (n calls)
		local supper = strupper;
		local slower = strlower;
		local ssub = strsub;
		
		-- Using string.find instead of string.gfind to avoid garbage generation
		mstart, mend, value = sfind(text, regexKey, mstart);
	   	while (value) do
			if( sfind(text, "^[a-zA-Z].*") ) then
				capitalizedPhrase = capitalizedPhrase..supper(ssub(value,1,1))..slower(ssub(value,2));
			else
				capitalizedPhrase = capitalizedPhrase..supper(ssub(value,1,2))..slower(ssub(value,3));
			end
			mstart = mend + 1;
			mstart, mend, value = sfind(text, regexKey, mstart);
	   	end		

		return capitalizedPhrase;
	end


	--
	-- objectToString( value, [name] )
	--
	-- 	Converts a value to a serialized string. 
	-- 	Cannot serialize functions.
	-- 	
	-- returns:
	--	A string which represents the object, 
	--	minus functions. 
	-- 	
	-- 
	Sea.string.objectToString = function( value, name ) 
		local output = "";

		if ( name == nil ) then name = ""; 
		else
			-- Serialize the name
			name = Sea.string.objectToString(name);
			-- Remove the <>
			name = string.gsub(name, "<(.*)>", "%1");
		end
		
		if (type(value) == "nil" ) then 
			output = name.."<".."nil:nil"..">";
		elseif ( type(value) == "string" ) then
			value = string.gsub(value, "<", "&lt;");
			value = string.gsub(value, ">", "&gt;");
			output = name.."<".."s:"..value..">";
		elseif ( type(value) == "number" ) then
			output = name.."<".."n:"..value..">";
		elseif ( type(value) == "boolean" ) then
			if ( value ) then 
				output = name.."<".."b:".."true"..">";
			else
				output = name.."<".."b:".."false"..">";
			end
		elseif ( type(value) == "function" ) then
			output = name.."<".."func:".."*invalid*"..">";
		elseif ( type(value) == "table" ) then
			output = name.."<".."t:";
			for k,v in value do 
				output = output.." "..Sea.string.objectToString(v,k);
			end
			output = output .. ">";
		end

		return output;
	end

	--
	-- stringToObject(string)
	--
	-- 	Turns a string serialized by objectToString into 
	-- 	and object. 
	--
	-- returns:
	-- 	nil or number or string or boolean or table
	--
	--
	Sea.string.stringToObject = function ( str ) 
		-- check for the format "keytype:keyvalue<valuetype:value>"
		-- take the stuff in <>
		typevalue = string.gsub(str, "%s*(%w*:?%w*)%s*(<.*>)","%2");
	
		local value = nil;
		local typeString = string.gsub(typevalue, "<%s*(%w*):(.*)>","%1");
		local valueString = string.gsub(typevalue, "<%s*(%w*):(.*)>","%2");

		
		--print("str: ", str, " typevalue: ", typevalue);
		--print("valueString: (", valueString, ") typeString: (", typeString,")");

		-- Error!
		if ( typeString == typevalue ) then 
			Sea.io.error ( "Unparsable string passed to stringToObject: ", str );
			return nil;
		end
	
		-- Maybe no error!
		if ( typeString == "nil" ) then 
			value = nil;
		
		elseif ( typeString == "n" ) then 
			value = tonumber(valueString);
	
		elseif ( typeString == "b" ) then 
			if ( valueString == "true" ) then
				value = true;
			else
				value = false;
			end
		
		elseif ( typeString == "s" ) then 
			value = valueString;
			-- Parse the <> back in
			value = string.gsub(value, "&lt;", "<");
			value = string.gsub(value, "&gt;", ">");

		elseif ( typeString == "f" ) then
			-- Functions are not supported, but if they were..

			-- ...this is how it should work
			-- value = getglobal(typeString);
			value = Sea.io.error;
		
		elseif ( typeString == "t" ) then 
			-- Here's the hard part
			-- I have to extract each set of <>
			-- which might have nested tables!
			-- 
			-- So I start off by tracking < until I get 0
			--
			value = {};

			local left = 1;
			local right = 1;

			local count = 0;
			
			while ( valueString and valueString ~= "" ) do
				local object = nil;
				local key = nil;

				-- Extract the key and convert it
				key = string.gsub(valueString, "%s*(%w*:?.-)<.*>", "%1" );
				key = Sea.string.stringToObject("<"..key..">");

			
				left = string.find(valueString, "<", 1 );
				right = string.find(valueString, ">", 1 );

				if ( left < right ) then 
					nextleft = string.find(valueString, "<", left+1 );
					while ( nextleft and nextleft < right ) do
						nextleft = string.find(valueString, "<", nextleft+1 );
						right = string.find(valueString, ">", right+1 );
					end
				else
					--error ( "we all die." );
				end

				objectString = string.sub(valueString, left, right);
			
				-- Create the object
				object = Sea.string.stringToObject(objectString);

				-- Add it to the table
				value[key] = object;

				-- See if there's another entry
				valueString = string.sub(valueString, right+1);
			end
		end

		return value;
	end
	
	--
	-- startsWith(String text, String prefix)
	--
	--	Looks for 'prefix' at the beginning of 'text' 
	--
	-- Returns:
	-- 	boolean
	-- 
	
	Sea.string.startsWith = function ( text, prefix )
		if ( strfind(text, "^"..prefix, 1) ) then
			return true;
		else
			return false;
		end
	end
	
	--
	-- endsWith(String text, String suffix)
	--
	--	Looks for 'suffix' at the end of 'text' 
	--
	-- Returns:
	-- 	boolean
	-- 
	
	Sea.string.endsWith = function ( text, suffix )
		if ( strfind(text, suffix.."$") ) then
			return true;
		else
			return false;
		end
	end

	--
	-- colorToString(Table{r,g,b,a})
	--
	--	Converts a table to a Blizzard color code
	--
	-- Returns:
	-- 	string 
	-- 		The blizzard color code AARRGGBB
	-- 
	
	Sea.string.colorToString = function ( color )
		if ( not color ) then 
			return "FFFFFFFF";
		end
		return string.format("%.2X%.2X%.2X%.2X",
			(color.a or color.opacity or 1) * 255,
			(color.r or 0) * 255, 
			(color.g or 0) * 255, 
			(color.b or 0) * 255
		);
	end

	-- stringToColor(String colorCode)
	--
	--	Converts a Blizzard color code to a table
	--
	-- Returns:
	-- 	table{r,g,b,a,opacity}
	--
	-- 	a & opacity are the same thing here (this could change)
	-- 
	Sea.string.stringToColor = function ( colorCode ) 
		local red, green, blue, alpha = Sea.math.rgbaFromHex( colorCode );
		return { r = red; g = green; b = blue; a = alpha; opacity = alpha };
	end

	
end

