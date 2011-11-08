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

-- autostart programs
autostart = function(names, commands) 
    for i = 1, #tags.names do
        debug.text = tags.names[i]
    end
end

-- -


