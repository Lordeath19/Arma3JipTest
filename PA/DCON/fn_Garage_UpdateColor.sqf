
comment "no idea why this doesn't work ¯\_(ツ)_/¯";

_veh = DCON_Garage_Vehicle;
_color = DCON_Garage_Color;

hint str _color;

_color2 = format ["#(rgb,8,8,3)color(%1,%2,%3,%4)",_color select 0,_color select 1,_color select 2,_color select 3];

_veh setObjectTexture [0, _color2];
_veh setObjectTexture [1, _color2];
_veh setObjectTexture [2, _color2];
_veh setObjectTexture [3, _color2];
_veh setObjectTexture [4, _color2];
_veh setObjectTexture [5, _color2];