if !(local player) exitwith {};
_veh = _this select 0;
_mcolor = _this select 1;
_veh_name = _this select 2;
_always_show = [_this, 3, false,[true]] call BIS_fnc_param;//always show marker even with crew

_vehpos = getpos _veh;

_mtext = format ["%1", _veh_name];
_markname = "ghst_mark" + (name player) + str (random 999);
_markertext = "";

_mark1 = [_vehpos,_mcolor,_markname,_mtext] call SUPP_fnc_mark_local;

sleep 1;
while {alive _veh} do {
    if ((count crew _veh < 1) or _always_show) then {
        _mark1 setMarkerAlphaLocal 1;
        _mark1 setMarkerTextLocal _veh_name;
    } else {
        _markertext = format ["%1 [+%2]", (configFile >> "cfgVehicles" >> (typeOf _veh) >> "displayName") call BIS_fnc_getCfgData, (count crew _veh) -1];
        _mark1 setMarkerTextLocal _markertext;
        _mark1 setMarkerAlphaLocal 0;
    };
    _mark1 setmarkerposlocal (getpos _veh);
    if (isnil "_veh") exitwith {};
    sleep 1;
};
deletemarkerlocal _mark1;