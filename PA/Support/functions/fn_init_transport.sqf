/*
V1.1 By: Ghost - creates helicopter to pickup caller
ghst_transport = ["typeofhelicopter","typeofhelicopter for escort in array []","spawn pos",50 alt, include support boolean] spawn SUPP_fnc_init_transport;
*/

private ["_pos"];
_airtype = _this select 0;
_escortarray = _this select 1;
_spawnmark = _this select 2;
_flyheight = _this select 3;
_includeSupport = _this select 4;

if(_spawnmark isEqualTo [0,0,0]) then 
{
	_spawnmark = ["Mark the base's location"] call SUPP_fnc_map_click;
	if(_spawnmark isEqualTo [0,0,0]) exitwith {
		hint "Helicopter Transport Ready";
	};
};

private ["_lzpad","_lzpad2","_lzpad_mark","_lzpad2_mark","_wpgetout","_destact","_destrtb"];

openMap true;

player groupChat "Left click on the map where you want pick up";

mapclick = false;

onMapSingleClick "clickpos = _pos; mapclick = true; onMapSingleClick """";true;";

waituntil {mapclick or !(visiblemap)};
if (!visibleMap) exitwith {
	hint "Helicopter Transport Ready";
};
	
_pos = [clickpos select 0, clickpos select 1, (getposatl player) select 2];
/*
_pos = _clickpos findEmptyPosition[ 10 , 100 , _airtype ];
if (count _pos < 2) then {
_pos = clickpos;
};
*/
sleep 1;

openMap false;
if (surfaceiswater _pos) exitwith {player groupChat "Helicopter cannot land in water";};

_transportgrp = createGroup (side player);
_escortgrp = createGroup (side player);

_dir = [_spawnmark, _pos] call BIS_fnc_dirTo;

//transport helicopter
_air1_array = [_spawnmark, _dir, _airtype, _transportgrp] call BIS_fnc_spawnVehicle;
_air1 = _air1_array select 0;
_air1 setpos [getpos _air1 select 0, getpos _air1 select 1, _flyheight];
_air1 setVelocity [55 * (sin _dir), 55 * (cos _dir), 0];
_air1 flyInHeight _flyheight;
_air1 lockDriver true;
_air1 lockCargo [0, true];
{_air1 lockTurret [_x, true];} foreach allTurrets _air1;
//_crewcount = count crew _air1;

//escort helicopter 1
_airtypesel = _escortarray call BIS_fnc_selectRandom;  
_air2_array = [[(_spawnmark select 0) + (cos _dir * 100), (_spawnmark select 1) - (sin _dir * 50), _flyheight + 50], _dir, _airtypesel, _escortgrp] call BIS_fnc_spawnVehicle;
_air2 = _air2_array select 0;
//_air2 setpos [getpos _air1 select 0, getpos _air1 select 1 -20, _flyheight];
_air2 setVelocity [55 * (sin _dir), 55 * (cos _dir), 0];
_air2 flyInHeight _flyheight + 50;

//escort helicopter 2
_airtypesel2 = _escortarray call BIS_fnc_selectRandom;  
_air3_array = [[(_spawnmark select 0) + (cos _dir * 50), (_spawnmark select 1) - (sin _dir * 100), _flyheight + 50], _dir, _airtypesel2, _escortgrp] call BIS_fnc_spawnVehicle;
_air3 = _air3_array select 0;
//_air3 setpos [getpos _air1 select 0 -20, getpos _air1 select 1, _flyheight];
_air3 setVelocity [55 * (sin _dir), 55 * (cos _dir), 0];
_air3 flyInHeight _flyheight + 50;

_transportgrp setBehaviour "CARELESS";
_escortgrp setBehaviour "COMBAT";

_transportgrp move _pos;
_escortgrp move _pos;

_air1 sidechat "I am inbound to your location";

_lzpad = "Land_HelipadEmpty_F" createVehicle _pos;
_lzpad_mark = [_pos,"ColorGreen","Pick Up","mil_start"] call SUPP_fnc_mark_point;

//tracking Marker
_trackname = format ["%1 Transport", name player];
[_air1, "ColorGreen", _trackname] spawn SUPP_fnc_tracker;

//waituntil {_pos distance2D _air1 < 400};

while { ( (alive _air1) and (canmove _air1) and (alive (driver _air1)) and (_pos distance2D _air1 > 400) ) } do {
	sleep 1;
};

_smoke = "SmokeShellGreen" createVehicle _pos;

if ((alive _air1) and (canmove _air1) and (alive (driver _air1))) then {
	waituntil { (unitReady _air1) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};
	player assignAsCargo _air1;
	[player] orderGetIn true;
	_air1 land "GET IN";
	//_air1 flyInHeight 0;
	
	ghst_dest_transport = _air1 addAction ["<t size='1.5' shadow='2' color='#00FF00'>Helicopter Destination</t>", "call SUPP_fnc_dest_transport", [_air1,_flyheight,_escortgrp], 5, false, true, "","alive _target"];
	//ghst_dest_transport = [_air1,["<t size='1.5' shadow='2' color='#00FF00'>Helicopter Destination</t>", "call SUPP_fnc_dest_transport", [_air1,_flyheight,_escortgrp], 5, false, true, "","alive _target"]] remoteExec ["addAction"]; 
	ghst_rtb_transport = _air1 addAction ["<t size='1.5' shadow='2' color='#00FFFF'>Helicopter RTB</t>", "call SUPP_fnc_rtb_transport", [_air1,_flyheight,_spawnmark,_escortgrp,[_air1,_air2,_air3]], 5, false, true, "","alive _target"];
	//ghst_rtb_transport = [_air1,["<t size='1.5' shadow='2' color='#00FFFF'>Helicopter RTB</t>", "call SUPP_fnc_rtb_transport", [_air1,_flyheight,_spawnmark,_escortgrp,[_air1,_air2,_air3]], 5, false, true, "","alive _target"]] remoteExec ["addAction"];
};

waituntil { !(unitReady _air1) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};
deletevehicle _lzpad;
deletemarker _lzpad_mark;