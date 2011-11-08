module(..., package.seeall);

require("vicious")
require("awful")

modkey = "Mod4"

-- display widget for down/up network
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, 
    'N: <span color="#CC9393">${eth0 down_kb}</span>/<span color="#7F9F7F">${eth0 up_kb}</span>',
    3)

-- cpuwidget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, 'C: <span color="#00FF00">$1% </span>')

--cpuwidget with graph
--

-- mem widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, 'M: <span color="#33FFCC">$1% </span>')


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
    run_once("konsole & htop")
    run_once("luakit")
end


