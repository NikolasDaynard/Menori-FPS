-- written by groverbuger for g3d
-- january 2021
-- MIT license

----------------------------------------------------------------------------------------------------
-- simple obj loader
----------------------------------------------------------------------------------------------------

-- stitch two tables together and return the result
local function concatTables(t1,t2,t3)
    local ret = {}

    for i,v in ipairs(t1) do
        ret[#ret +1] = v
    end

    for i,v in ipairs(t2) do
        ret[#ret +1] = v
    end

    for i,v in ipairs(t3) do
        ret[#ret +1] = v
    end

    return ret
end

-- give path of file
-- returns lines of the triangulated model
local function triangulateObj(path)
    lines = {}
    -- go line by line through the file
    for line in love.filesystem.lines(path) do
        local words = {}

        -- split the line into words
        for word in line:gmatch("([^".."%s".."]+)") do
            table.insert(words, word)
        end

        -- if the first word in this line is a "f", then this is a face
        if words[1] == "f" then
            -- verticies start at 2 for the descriptions because the first is 'f'
            -- for every face, it inserts a triangle with the verticies: iteration, iteration - 1 and starting vertex
            -- this ensures 2 verticies match and adds the third new one
            -- if iteration < 4 then it is using the original first vertex as vertex 2 and as vertex 3 in the triangle
            for i=#words, 4, -1 do
                table.insert(lines, "f " .. words[i] .. " " .. words[i-1] .. " " .. words[2])
            end
            table.insert(lines, line)
        else
            -- if it's not a face, insert it
            table.insert(lines, line)
        end
    end
    return lines
end

-- give path of file
-- returns a lua table representation
local function objLoader(path)
    local verts = {}
    local faces = {}
    local uvs = {}
    local normals = {}

    -- go line by line through the file
    for _,line in ipairs(triangulateObj(path)) do
        local words = {}

        -- split the line into words
        for word in line:gmatch("([^".."%s".."]+)") do
            table.insert(words, word)
        end

        -- if the first word in this line is a "v", then this defines a vertex
        if words[1] == "v" then
            verts[#verts+1] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
        end

        -- if the first word in this line is a "vt", then this defines a texture coordinate
        if words[1] == "vt" then
            uvs[#uvs+1] = {tonumber(words[2]), tonumber(words[3])}
        end

        -- if the first word in this line is a "vn", then this defines a vertex normal
        if words[1] == "vn" then
            normals[#normals+1] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
        end

        -- if the first word in this line is a "f", then this is a face
        -- a face takes three arguments which refer to points, each of those points take three arguments
        -- the arguments a point takes is v,vt,vn
        if words[1] == "f" then
            local store = {}

            for i=2, #words do
                local num = ""
                local word = words[i]
                local ii = 1
                local char = word:sub(ii,ii)

                while true do
                    char = word:sub(ii,ii)
                    if char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)

                local num = ""
                ii = ii + 1
                while true do
                    char = word:sub(ii,ii)
                    if ii <= #word and char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)

                local num = ""
                ii = ii + 1
                while true do
                    char = word:sub(ii,ii)
                    if ii <= #word and char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)
            end

            faces[#faces+1] = store
        end
    end

    -- put it all together in the right order
    local compiled = {}
    for i,face in pairs(faces) do
        compiled[#compiled +1] = concatTables(verts[face[1]], uvs[face[2]], normals[face[3]])
        compiled[#compiled +1] = concatTables(verts[face[4]], uvs[face[5]], normals[face[6]])
        compiled[#compiled +1] = concatTables(verts[face[7]], uvs[face[8]], normals[face[9]])
    end

    return compiled
end

return objLoader
