/*
V1 By: Ghost - creates helicopter to pickup cargo
ghst_airlift = ["typeofhelicopter","spawn pos drop point",50 alt, 30 min delay] spawn SUPP_fnc_init_airlift;
*/

#include "..\dialogs\def_VEHsel.hpp"
private ["_pos"];
_airtype = _this select 0;
_spawnmark = _this select 1;
_flyheight = _this select 2;

private ["_liftpad_mark","_liftRope","_liftObject","_liftobj_name"];


if(_spawnmark isEqualTo [0,0,0]) then
{
    _spawnmark = ["Mark the base's location"] call SUPP_fnc_map_click;

    if(_spawnmark isEqualTo [0,0,0]) exitwith {
        hint "Helicopter airlift Ready";
    };
};

openMap true;

hint "Left click on the map where you want sling load";

mapclick = false;

onMapSingleClick "clickpos = _pos; mapclick = true; onMapSingleClick """";true;";

waituntil {mapclick or !(visiblemap)};
if (!visibleMap) exitwith {
    hint "Helicopter airlift Ready";
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

_liftObjectList = nearestObjects [_pos, ["Cargo_base_F","ThingX","Air","Tank","Car","Ship","StaticWeapon"], 200];

#ifndef VBS
    disableSerialization;
#endif

// fill dialog with vehicle names
createDialog "UseSelectedVehicle";
sleep 0.1;
_ctrlList = findDisplay DLG_USE_IDD displayCtrl DLG_USE_LIST;

private ["_index","_lstidx","_lstpos""_i"];

for "_i" from 0 to (count _liftObjectList)-1 do {
    _liftObj = _liftObjectlist select _i;
    _liftobj_name = (configFile >> "cfgVehicles" >> (typeof _liftObj) >> "displayName") call bis_fnc_getcfgdata;
    lbAdd [DLG_USE_LIST,format["%1",_liftobj_name]];
    lbSetValue [DLG_USE_LIST, _i, _i];
};
lbSort (findDisplay DLG_USE_IDD displayCtrl DLG_USE_LIST);

// put the selection somewhat in the middle of the displayed listing
_index = -1;
_i=(_index -9) max 0;
lbSetCurSel [DLG_USE_LIST, _i];
lbSetCurSel [DLG_USE_LIST, _index];

_VEHidx = lbValue [DLG_USE_LIST, _index];
_lstidx = _index;
_lstpos = -1;
DLG_USE_SELECTED = false;

        while {ctrlVisible DLG_USE_LIST} do {
            _index = lbCurSel DLG_USE_LIST;
            _posidx = _index;
        #ifdef VBS
            if !(isNil "DLG_VEH_USE_SEL") then {
                if (DLG_VEH_USE_SEL select 3) then {
                    _posidx = _ctrlList lbPosIndex [DLG_VEH_USE_SEL select 1,DLG_VEH_USE_SEL select 2];
                };
            };
        #endif
            if (DLG_USE_SELECTED) then {
                _VEHidx=lbValue [DLG_USE_LIST, _index];
                closeDialog DLG_USE_IDD;
            };
            if (_posidx == -1) then {
                _posidx = _index;
            };
            if (_lstpos != _posidx) then {
                _lbidx = lbValue [DLG_USE_LIST, _posidx];
                _lstpos=_posidx;
            };
            sleep 0.1;
        };
    if (_lstidx == _index) exitWith {};
    _liftObject = (_liftObjectlist select _VEHidx);

if ((isnil "ghst_vehsel") or ! DLG_USE_SELECTED) exitwith {hint "Nothing Selected";};

_liftobj_name = (configFile >> "cfgVehicles" >> (typeof _liftObject) >> "displayName") call bis_fnc_getcfgdata;

_airliftgrp = createGroup (side player);

_pos = getpos _liftObject;
_dir = [_spawnmark, _pos] call BIS_fnc_dirTo;

//airlift helicopter
_air1_array = [_spawnmark, _dir, _airtype, _airliftgrp] call BIS_fnc_spawnVehicle;
_air1 = _air1_array select 0;
_air1 setpos [getpos _air1 select 0, getpos _air1 select 1, _flyheight];
_air1 setVelocity [55 * (sin _dir), 55 * (cos _dir), 0];
_air1 flyInHeight _flyheight;
_air1 lockDriver true;
_air1 lockCargo true;
{_air1 lockTurret [_x, true];} foreach allTurrets _air1;
//_crewcount = count crew _air1;

_airliftgrp setBehaviour "CARELESS";


//_airliftgrp move _pos;
_wp = [_airliftgrp,_pos, 5, "HOOK", "CARELESS", "NORMAL", "WEDGE"] call SUPP_fnc_createwaypoint;
_wp waypointAttachObject _liftObject;

_air1 sidechat format ["I am inbound to your location to sling load %1", _liftobj_name];

_liftpad_mark = [_pos,"ColorGreen","Airlift Sling Load","hd_pickup"] call SUPP_fnc_mark_point;

//tracking Marker
_trackname = format ["%1 Airlift", name player];
[_air1, "ColorGreen", _trackname, true] spawn SUPP_fnc_tracker;

while { (alive _air1) and (canmove _air1) and (alive (driver _air1)) and (_pos distance2D _air1 > 400) } do {
    sleep 1;
};
_smoke = "SmokeShellGreen" createVehicle _pos;

if ((alive _air1) and (canmove _air1) and (alive (driver _air1))) then {

    //_air1 flyInHeight 10;

    waituntil { (vectorMagnitude velocity _air1 <= 5) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};
    //_liftRope = ropeCreate [_air1, [0,0,-2], _liftObject, [0,0,0], 45];
    _liftObjectmass = getMass _liftObject;
    if (_liftObjectmass > 3000) then {_liftObject setMass 3000;};
};

//waituntil { ((ropeAttachedTo _liftObject) == _air1) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1)) };
waituntil {((getpos _air1) select 2 < 25) or (getSlingLoad _air1 == _liftObject) or (vectorMagnitude velocity _air1 <= 3) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1)) };
_slinged = false;
if(getSlingLoad _air1 == _liftObject) then {
    _slinged = true;
};
//Attach in addition to sling loading because arma physics
[_air1,_liftObject] spawn SUPP_fnc_hook;
[_liftObject, "ColorGrey", _liftobj_name, true] spawn SUPP_fnc_tracker;
_air1 sidechat format ["Sling loading %1", _liftobj_name];

//ropeUnwind [ _liftRope, 5, -35, true];
//waituntil { ropeLength _liftRope < 20 };
//_airliftgrp move _spawnmark;
deleteWaypoint _wp;
_wp = [_airliftgrp,_spawnmark, 5, "UNHOOK", "CARELESS", "NORMAL", "WEDGE"] call SUPP_fnc_createwaypoint;
_air1 flyInHeight _flyheight;
_air1 sidechat format ["Returning to Base to Drop off %1", _liftobj_name];
deletemarker _liftpad_mark;

while { (alive _air1) and (canmove _air1) and (alive (driver _air1)) and (_spawnmark distance2D _air1 > 100) } do {
    sleep 1;
};
//_air1 flyInHeight 30;

waituntil { (vectorMagnitude velocity _air1 <= 5)  or (_slinged and !(getSlingLoad _air1 == _liftObject)) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};//((getpos _air1) select 2 < 45)
[_air1] spawn SUPP_fnc_unhook;

if (!(alive _air1) or !(canmove _air1) or !(alive (driver _air1))) then {
    player groupChat "We lost our airlift helicopter.";
} else {
    //ropeUnwind [ _liftRope, 5, 45, true];
    //waituntil { ropeLength _liftRope > 40 };
    _air1 sidechat format ["Dropped off %1", _liftobj_name];
    deleteWaypoint _wp;
    sleep 5;

    deletevehicle _air1;
    {if !(isnil "_x") then {deletevehicle _x;};} foreach units _airliftgrp;
    deletegroup _airliftgrp;
    //_air1 ropeDetach _liftRope;
    //ropeCut [ _liftRope, 5];
};

//waituntil { !(unitReady _air1) or !(alive _air1) or !(canmove _air1) or !(alive (driver _air1))};