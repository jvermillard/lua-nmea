-- nmea.lua
--
-- module for decoding the NMEA GPS protocol
--
local M = {} -- public interface

-- looks like there is no standard split string function in lua
function split(s,re)
    local i1 = 1
    local ls = {}
    local append = table.insert
    if not re then re = '%s+' end
    if re == '' then return {s} end
    while true do
        local i2,i3 = s:find(re,i1)
        if not i2 then
            local last = s:sub(i1)
            if last ~= '' then append(ls,last) end
            if #ls == 1 and ls[1] == '' then
                return {}
            else
                return ls
            end
        end
        append(ls,s:sub(i1,i2-1))
        i1 = i3+1
    end
end

-- decode a NMEA line and return a table with the understood values
function M.decode(line) 
    local data = split(line,",")
    local result = {}
    if data[1] == "$GPGGA" then
        result["type"] = "position"
        result["satelite"] = tonumber(data[8])
        if data[3] ~= ""  and data[5] ~= "" then
            local long = tonumber(string.sub(data[3],1,2)) + ( tonumber(string.sub(data[3],3)) / 60 )
            if data[4] ~= "N" then
                long = long * -1
            end
            result["longitude"] = long

            local lat = tonumber(string.sub(data[5],1,3)) + ( tonumber(string.sub(data[5],4)) /60 )
            if data[6] ~= "E" then
                lat = lat * -1
            end

            result["latitude"] = lat
            result["altitude"] = tonumber(data[10])
            result["map"] = "https://maps.google.fr/maps?q="..long..","..lat
        end
    elseif data[1] == "$GPRMC" then
        result["type"] = "date"

        if data[2] ~= "" then 
            local time = data[2]
            result["hour"] = tonumber(string.sub(time,1,2))
            result["minute"] = tonumber(string.sub(time,3,4))
            result["second"] = tonumber(string.sub(time,5,10))

            local date = data[10]
            result["day"] = tonumber(string.sub(date,1,2))
            result["month"] = tonumber(string.sub(date,3,4))
            result["year"] = tonumber(string.sub(date,5))
        end
    end
    return result
end

return M
