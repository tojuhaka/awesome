module(..., package.seeall);

require("vicious")
require("awful")

modkey = "Mod4"
ENABLE_CONKY = false
HOME = os.getenv("HOME")
-- display widget for down/up network
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, 
    'N: <span color="#CC9393">${eth0 down_kb}</span>/<span color="#7F9F7F">${eth0 up_kb}</span>',
    3)

-- cpuwidget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, 'CPU: <span>$1%  </span>')

--cpuwidget with graph
--

-- mem widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, 'Mem: <span>$1%  </span>')


-- run only once
function run_once(command)
    if not command then
        do return nil end
    end
    local program = command:match("[^ ]+")

    -- If program is not running
    if math.fmod(os.execute("pgrep -x " .. program),255) == 1 then
        awful.util.spawn(command)
    end
end

-- autostart programs
function autostart (screen)
    if ENABLE_CONKY then    
        awful.util.spawn(HOME .. "/.config/awesome/utility/conky_start.sh")
    end
end

-- function to determine coldness
function get_temperature_color(num)
  if num < 10 then
    return '#00FFFF'
  end
  if num > 20 then return 'red'
  end
  if num > 10  then
    return 'yellow'
  end
end 

function check_connection ()
    data = awful.util.pread("curl www.google.com | awk '{print $1}'")
    if data == "" then
        return false
    end
    return true
end

--Create a weather widget
weatherwidget = widget({ type = "textbox" })

-- IF INTERNET CONNECTION
if check_connection() then
    weatherwidget.text = awful.util.pread(
        "weather -i EFJY --headers=Temperature --quiet -m | awk '{print $2}'"
    ) -- replace METARID with the metar ID for your area. This uses metric. If you prefer Fahrenheit remove the "-m" in "--quiet -m".

    color = get_temperature_color(tonumber(weatherwidget.text))
    weatherwidget.text = string.format("C: <span color='%s'>" .. weatherwidget.text .. "</span>    ", color)


    weathertimer = timer(
       { timeout = 900 } -- Update every 15 minutes. 
    ) 
    weathertimer:add_signal(
       "timeout", function() 
          weatherwidget.text = awful.util.pread(
         "weather -i EFJY --headers=Temperature --quiet -m | awk '{print $2, $3}' &"
       ) --replace METARID and remove -m if you want Fahrenheit
     end)

    weathertimer:start() -- Start the timer
    weatherwidget:add_signal(
    "mouse::enter", function() 
      weather = naughty.notify(
        {title="Weather",text=awful.util.pread("weather -i EFJY -m")})
      end) -- this creates the hover feature. replace METARID and remove -m if you want Fahrenheit
    weatherwidget:add_signal(
      "mouse::leave", function() 
        naughty.destroy(weather) 
      end)
    -- I added some spacing because on my computer it is right next to my clock.
    awful.widget.layout.margins[weatherwidget] = {right = 5}
end

-- Battery widget
-- Hex converter, for RGB colors
function hex(inp)
    return inp > 16 and string.format("%X", inp) or string.format("0%X", inp)
end

-- Battery monitor
mybattmon = widget({ type = "textbox", name = "mybattmon", align = "right" })
function battery_status ()
    local output={} -- output buffer
    local fd=io.popen("acpitool -b", "r") -- list present batteries
    local line=fd:read()
    while line do -- there might be several batteries
        local battery_num = string.match(line, "Battery \#(%d+)")
        local battery_load = string.match(line, " (%d*)\.%d+%%")
        local time_rem = string.match(line, "(%d+\:%d+)\:%d+")
        if battery_num and battery_load and time_rem then
            table.insert(output, "<span color=\"#"
                .. hex(170 * (100 - tonumber(battery_load)) / 100)
                .. hex(170 * tonumber(battery_load) / 100)
                .. "00\">" .. time_rem .. " " .. battery_load .. "%</span>")
        elseif battery_num and battery_load then -- remaining time unavailable
            table.insert(output, "<span color=\"#00AA00\">" .. battery_load.."%</span>")
        end
        line=fd:read() -- read next line
    end
    return table.concat(output," ")
end
mybattmon.text = " " .. battery_status() .. " "
my_battmon_timer=timer({timeout=17})
my_battmon_timer:add_signal("timeout", function()
    mybattmon.text = " " .. battery_status() .. " "
end)
my_battmon_timer:start()

