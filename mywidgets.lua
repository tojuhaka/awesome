module(..., package.seeall);

require("vicious")

modkey = "Mod4"

netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, 
    '<span color="#CC9393">${eth0 down_kb}</span><span color="#7F9F7F">${eth0 up_kb}</span>',
    3)
