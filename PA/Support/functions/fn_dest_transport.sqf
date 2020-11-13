/*
V1.1 By: Ghost - tells helicopter where to go and land
ghst_dest_transport = _air1 addAction ["<t size='1.5' shadow='2' color='#00FF00'>Helicopter Destination</t> <img size='3' color='#00ff00'", "call ghst_fnc_dest_transport", [_air1,_flyheight,_escortgrp], 5, false, true, "","alive _target"];
*/
private ["_pos"];
_args = _this select 3;
_air1 = _args select 0;
_flyheight = _args select 1;
_escortgrp = _args select 2;
_transportgrp = group _air1;

if (fuel _air1 < 0.25) exitwith {_air1 sidechat "Fuel low need to rtb";};

openMap true;

player groupChat "Left click on the map where you want to land";

mapclick = false;

onMapSingleClick "clickpos = _pos; mapclick = true; onMapSingleClick """";true;";

waituntil {mapclick or !(visiblemap)};

    if !(visibleMap) exitwith {
        player groupchat "New destination request cancelled";
    };

_pos = [clickpos select 0, clickpos select 1, (getposatl player) select 2];

sleep 1;

openMap false;

if (surfaceiswater _pos) exitwith {_air1 sidechat "Cannot land in water";};

_lzpad = "Land_HelipadEmpty_F" createVehicle _pos;
_lzpad_mark = [_pos,"ColorGreen","Drop Off","mil_end"] call SUPP_fnc_mark_point;

_transportgrp setGroupOwner clientOwner;
_escortgrp setGroupOwner clientOwner;

_transportgrp move _pos;
_escortgrp move _pos;

_air1 flyInHeight _flyheight;

_air1 sidechat "Moving to new location";

waituntil { (_pos distance2D _air1 < 100) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};

_air1 land "LAND";
//_air1 flyInHeight 0;

waituntil { (unitReady _air1) or !(alive _air1) or !(canmove _air1)};
_air1 flyInHeight 0;
deletevehicle _lzpad;
deletemarker _lzpad_mark;

if (!(alive _air1) or !(canmove _air1) or !(alive (driver _air1))) then {
    player groupChat "We lost our transport helicopter.";
    {if !(isnil "_x") then {deletevehicle _x;};} foreach units _transportgrp;
    {if !(isnil "_x") then {_x setfuel 0.2;};} foreach units _escortgrp;
    deletevehicle _air1;
    deletegroup _transportgrp;
} else {
    _air1 sidechat "Awaiting orders";
};