local serial = require "serial"

local nmea = require "nmea"


-- plug your GPS on a serial port, configure the SERIALPORTNAME
-- and watch the incoming data printed on the console
function main()
    local SERIALPORTNAME = "/dev/ttyUSB0"
    local SERIALPORTCONFIGURATION = {
        baudRate    = 9600,
        flowControl = "none",
        numDataBits = 8,
        parity      = "none",
        numStopBits = 1
    }

    print "Opening GPS serial port"

    local serialdev = assert(serial.open(SERIALPORTNAME, SERIALPORTCONFIGURATION))

    repeat
        local line = serialdev:read("*l")
        
        local data = split(line,",")
        local result = nmea.decode(line)
        print("decoded data : ")

        for i,v in pairs(result) do print(i.." => "..v) end
        
    until false
    os.exit(0)
end

sched.run(main)
sched.loop()
