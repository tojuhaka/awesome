module(..., package.seeall);

require("vicious")
require("awful")
require("wicked")

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


 -- debug function
function debug(str)

 local test = io.output("/home/tojuhaka/.config/awesome/debug.txt")
 test:write(tostring(str))
 test:close()
end
    
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
    run_once('nm-applet')
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
batwidget =
   widget({type = 'textbox', name = 'batwidget', align = 'right'})
function read_acpi()
   debug_text = "MOIKAIKILLE" 
   local fh = io.popen('acpi')
   local value
   output = fh:read("*a")
   fh:close()
   value = string.gmatch(output, "(%d+)%%")
   return {value}
end
wicked.register(batwidget, read_acpi, 'B: $1% ', 60)
wicked.update(batwidget, nil)


 -- Quick launch bar widget BEGINS
 function getValue(t, key)
    _, _, res = string.find(t, key .. " *= *([^%c]+)%c")
    return res
 end
 
 function split (s,t)
    local l = {n=0}
    local f = function (s)
        l.n = l.n + 1
        l[l.n] = s
         end
    local p = "%s*(.-)%s*"..t.."%s*"
    s = string.gsub(s,p,f)
    l.n = l.n + 1
    return l
 end
 
 launchbar = { layout = awful.widget.layout.vertical.topright }
 filedir = "/home/tojuhaka/.config/awesome/launchbar/" -- Specify your folder with shortcuts here
 test = io.popen("ls " .. filedir .. "*.desktop")
 --test_text = test:read("*all")
 --files = split(io.popen("ls " .. filedir .. "*.desktop"):read("*all"),"\n")
 counter = 0
 for i in test:lines() do
    local t = io.open(i):read("*all")
    launchbar[counter] = { image = image(getValue(t,"Icon")),
                     command = getValue(t,"Exec"),
                     tooltip = getValue(t,"Name"),
                     position = tonumber(getValue(t,"Position")) or 255 }
    counter = counter + 1
 end
 table.sort(launchbar, function(a,b) return a.position < b.position end)
 for i = 0, counter-1 do
    local txt = launchbar[i].tooltip
    launchbar[i] = awful.widget.launcher(launchbar[i])
    --local tt = awful.tooltip ({ objects = { launchbar[i] } })
    --debug(tt)
    --tt:set_text (txt)
    --tt:set_timeout (0)
 end
 
 -- Quick launch bar widget ENDS
 
