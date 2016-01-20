local module = {}

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    app.start()
  end
end

--
-- Loops through the SSIDs it sees, connects to 
-- the first one it has a password for (from config.lua)
-- Once it's done so, calls wifi_wait_ip which will
-- start the app once it gets a valid IP address
-- 
local function wifi_start(list_aps)  
    if list_aps then
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                wifi.setmode(wifi.STATION);
                wifi.sta.config(key,config.SSID[key])
                wifi.sta.connect()
                print("Connecting to " .. key .. " ...")
                --config.SSID = nil  -- can save memory
                tmr.alarm(1, 2500, 1, wifi_wait_ip)
            end
        end
    else
        print("Error getting AP list")
    end
end

function module.start()  
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION);

  -- Calls teh builtin function wifi.sta.getap() which takes 
  -- a function to handle all available aps, in this case wifi_start() 
  --
  wifi.sta.getap(wifi_start)
end

return module  
