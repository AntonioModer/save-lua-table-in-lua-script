function love.load(arg)
	--' version 0.60
	--' don't save userdata
	-- local testStr = [[ddsds]]
	-- print(testStr)
	
	local seen={}
	local gString = "return \n{"
	local function dump(t,i)
		
		seen[t] = true;
		
		local s={}
		local seenVar={}
		local n=0
		for k in pairs(t) do
			n=n+1
			-- if type(k) == 'string' then
				-- s[n]=k
				-- -- print(v)
			-- else
				-- s[n]=tostring(v)
				-- -- print(v)
			-- end
			s[n]=k
			seenVar[n] = t[k]
		end
		-- table.sort(s)
		-- table.sort(seenVar)
		for ip,v in ipairs(s) do
			if type(seenVar[ip]) == 'table' then
				if type(v) == 'string' then
					gString = gString.."\n"..i.."[\""..v.."\"]".." = {"
				elseif type(v) == 'number' then
					gString = gString.."\n"..i.."["..v.."]".." = {"
				end
			elseif type(v) == 'string' then															-- pairs
				if type(seenVar[ip]) == 'string' then
					-- gString = gString.."\n"..i..v.." = ".."\""..tostring(seenVar[ip]).."\""--.." - "..ip
					gString = gString.."\n"..i.."[\""..v.."\"]".." = ".."[["..tostring(seenVar[ip]).."]]"--.." - "..ip
				elseif type(seenVar[ip]) == 'number' then
					gString = gString.."\n"..i.."[\""..v.."\"]".." = "..tostring(seenVar[ip])--.." - "..ip
				elseif type(seenVar[ip]) == 'boolean' then
					gString = gString.."\n"..i.."[\""..v.."\"]".." = "..tostring(seenVar[ip])--.." - "..ip				
				elseif type(seenVar[ip]) == 'function' then
					gString = gString.."\n"..i.."[\""..v.."\"]".." = ".."assert(loadstring(".."[["..tostring(string.dump(seenVar[ip])).."]]".."))"--.." - "..ip	
					-- assert(loadstring(tab.foo))()
				end				
			elseif type(v) == 'number' then															-- ipairs
				if type(seenVar[ip]) == 'string' then
					-- gString = gString.."\n"..i.."\""..tostring(seenVar[ip]).."\""--.." - "..ip
					gString = gString.."\n"..i.."["..v.."]".." = ".."[["..tostring(seenVar[ip]).."]]"--.." - "..ip
				elseif type(seenVar[ip]) == 'number' then
					gString = gString.."\n"..i.."["..v.."]".." = "..tostring(seenVar[ip])--.." - "..ip
				elseif type(seenVar[ip]) == 'boolean' then
					gString = gString.."\n"..i.."["..v.."]".." = "..tostring(seenVar[ip])--.." - "..ip					
				end
				
			end

				
			v=t[v]
			if type(v)=="table" and not seen[v] then
				dump(v,i.."\t")
			end
			if ip == #s then			
				-- gString = gString.."\n"..i.."}"															-- закрываем таблицу
				
			else
				gString = gString..","
			end	
		end
		gString = gString.."\n"..i.."}"
	end

	local tbl = {{}, 1, two = 2, str = 'string1\"\"'..'\t2', t = nil, tbl0 = {}, ["four"] = 4, 5, --[[ {1,3,4} --]] [6] = {1,3,4},  false, tab1={1, var = 1, t = nil, tab1_1={1,t = nil, 2,3, var = 1, var2 = "str"}}, foo = function() local i=1; print("hello from function "..i);  end }			-- !!! in comment not save
	tbl[4] = 'four'
	tbl['six'] = 6
	tbl['tbl2'] = {1,2,3, four = 4}
	tbl.tbl3 = {1,2,3, four = 4}
	-- tbl.tbl4 = tbl3																					-- !!! not save
	tbl.tbl5 = {}
	tbl[5] = nil
	tbl.foo1 = function() local i=2; print("hello from function "..i);  end
	
	--' variant  1 YES
	--' save
	dump(tbl,"")
	-- dump(_G,"")
	
	--' save function
	-- foo = function() print("hello from function") end
	-- fooSaved = string.dump(foo)
	-- assert(loadstring(fooSaved))()
	-- -- print(fooSaved)
	-- gString = gString.."\n"..fooSaved
	
	love.filesystem.newFile("savedTable.lua")
	love.filesystem.write('savedTable.lua', gString, all )
	
	--' load
	local chunk = love.filesystem.load('savedTable.lua')
	local tab = chunk()
	print(tbl.six, tbl.str, tab[3], tab[4], tab.tbl0, tab.tab1.tab1_1.var, tab.tab1.tab1_1.var2 )	--> 6	string1	false	four	table: 08DE47E8	1	str
	-- assert(loadstring(tab.foo))()
	-- print(tab.foo)
	tab.foo()
	tab.foo1()
	
	--' resave and reload
	dump(tab,"")
	local chunk = love.filesystem.load('savedTable.lua')
	local tab = chunk()
	print(tbl.six, tbl.str, tab[3], tab[4], tab.tbl0, tab.tab1.tab1_1.var, tab.tab1.tab1_1.var2 )	--> 6	string1	false	four	table: 08DEF408	1	str
	-- assert(loadstring(tab.foo))()
	tab.foo()
	tab.foo1()
	
	--' variant  2 NO
	-- function forEachVarInTab(tab, tabName, func, str)
		-- for k,v in pairs(tab) do
			-- func(tab, tabName, k, v, str)
		-- end		
	-- end
	-- function funcInPairs(tab, tabName, k, v, str)
		-- print(tab, k, v)
		
		-- if type(v) == 'table' then
			-- gString = gString.."\n".."do"
			-- gString = gString.."\n\t local "..tostring(k).." = {}"
			-- gString = gString.."\n\t"..'["'..tabName..'"]'..'["'..k..'"]'.." = "..tostring(k)
			-- gString = gString.."\n".."end"
			-- forEachVarInTab(v, k, funcInPairs, gString)
		-- elseif type(v) == 'string' then
			-- gString = gString.."\n"..'["'..tabName..'"]'..'["'..tostring(v)..'"]'.." = "..tostring(k)
		-- elseif type(v) == 'number' then
			-- gString = gString.."\n"..'["'..tabName..'"]'..'['..v..']'.." = "..tostring(k)
		-- end
	-- end
	-- forEachVarInTab(tbl, 'tbl', funcInPairs, gString)
	
	--' variant  3 NO
	-- require "tableSave1_0"
	-- print(table.save( tbl , "E:/develop/gamedev/myGames/LOVE/LIB/table/serialization/tbl.lua" ))

	
	-- print(gString)
	love.event.quit()
end
