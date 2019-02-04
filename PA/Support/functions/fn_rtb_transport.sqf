/*
V1.1 By: Ghost - tells helicopter when to rtb
ghst_rtb_transport = _air1 addAction ["<t size='1.5' shadow='2' color='#00FFFF'>Helicopter RTB<</t> <img size='3' color='#00ff00'", "call SUPP_fnc_rtb_transport", [_air1,_flyheight,_spawnmark,_escortgrp,[_air1,_air2,_air3]], 5, false, true, "","alive _target"];
*/
_args = _this select 3;
_air1 = _args select 0;
_flyheight = _args select 1;
_spawnmark = _args select 2;
_escortgrp = _args select 3;
_heloarray = _args select 4;
_transportgrp = group _air1;

_transportgrp move _spawnmark;
_escortgrp move _spawnmark;
_air1 flyInHeight _flyheight;
_air1 sidechat "Returning to Base";

waituntil { (_spawnmark distance2D _air1 < 100) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};

_air1 land "LAND";

waituntil { (unitReady _air1) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};	

_air1 flyInHeight 0;

if (!(alive _air1) or !(canmove _air1) or !(alive (driver _air1))) then {
	player groupChat "We lost our transport helicopter.";
} else {
	_air1 sidechat "At Base";
};
	
sleep 5;

{if !(isnil "_x") then {deletevehicle _x;};} foreach units _transportgrp;
{if !(isnil "_x") then {deletevehicle _x;};} foreach units _escortgrp;
{if !(isnil "_x") then {deletevehicle _x;};} foreach _heloarray;
deletegroup _transportgrp;
deletegroup _escortgrp;
