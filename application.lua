-- file : application.lua
local module = {}  

-- Will hold the mqtt client object once mqtt_start is
-- called.
m = nil

-- Sends a simple ping to the broker
local function send_ping()  
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120,config.AIOUSERNAME,config.AIOKEY)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds.  ALARM_AUTO resets
		-- and re-calls the passed function (send_ping) at intervals 
        tmr.stop(6)
        tmr.alarm(6, 1000, tmr.ALARM_AUTO, send_ping)
    end) 

end

--
-- Called by setup.wifit_get__ip once the node is has
-- recieved an IP address and the network is up.
--
function module.start()  
  mqtt_start()
end

return module  
