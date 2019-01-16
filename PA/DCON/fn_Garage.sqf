disableSerialization;
if !(isNull(uiNamespace getVariable [ "DCON_Garage_Display", objNull ])) exitwith {};


KK_fnc_setPosAGLS = {
	params ["_obj", "_pos", "_offset"];
	_offset = _pos select 2;
	if (isNil "_offset") then {_offset = 0};
	_pos set [2, worldSize]; 
	_obj setPosASL _pos;
	_pos set [2, vectorMagnitude (_pos vectorDiff getPosVisual _obj) + _offset];
	_obj setPosASL _pos;
};

if(isNil "DCON_Garage_SpawnType") then {
	DCON_Garage_SpawnType = 0;
};

_pos = _this select 0;
_dir = _this select 1;
_spawns = [];

_helipad = "C_Offroad_01_F" createVehicleLocal _pos;
_helipad enableSimulation false;
_helipad hideObject true;


waitUntil{!isNull _helipad};

_z = (getPos _helipad) select 2; 
if(_z < 0) then
{
	[_helipad, [(getPos _helipad) select 0,(getPos _helipad) select 1,0.5]] call KK_fnc_setPosAGLS;
};

_pos = getPosASL _helipad;

BIS_fnc_arsenal_fullGarage = true;
BIS_fnc_garage_center = _helipad;
missionnamespace setVariable ["BIS_fnc_arsenal_center",_helipad];
DCON_Garage_CanSpawn = 0;
DCON_Garage_Vehicle = objNull;
DCON_helipad = _helipad;

DCON_Garage_Color = [0,0,0,1];

comment "no idea what this does but it works";
disableSerialization;

_display = findDisplay 46 createDisplay "RscDisplayGarage";
uiNamespace setVariable ["DCON_Garage_Display", _display];
_xPos = safezoneX + safezoneW;
_yPos = safezoneY + safezoneH;

_yPos = _yPos - 0.11;

comment "select spawn type";
_combo = _display ctrlCreate ["RscCombo", -1];
_combo ctrlSetPosition [0.3455,_yPos,0.304,0.04];
_combo ctrlSetFont "PuristaMedium";
_combo ctrlSetTooltip "Spawn Type";
_combo ctrlSetEventHandler ["LBSelChanged", 
'
	DCON_Garage_SpawnType = _this select 1;
'];
_combo lbAdd "None";
_combo lbAdd "Getin Driver";
_combo lbAdd "Flying";

_combo lbSetCurSel DCON_Garage_SpawnType;

_combo ctrlCommit 0;

_yPos = _yPos - 0.07;

comment "r/woooosh";
_btn = _display ctrlCreate ["RscButton", -1];
_btn ctrlSetPosition [0.3455,_yPos,0.304,0.06];
_btn ctrlSetText "SPAWN";
_btn ctrlSetFont "PuristaMedium";
_btn ctrlSetTooltip "WooOOOOSH!!";
_btn ctrlSetEventHandler ["MouseButtonUp", 
'
	_display = (uiNamespace getVariable "DCON_Garage_Display");
	
	DCON_Garage_CanSpawn = 1;
	
	_display closeDisplay 1;
'];
_btn ctrlCommit 0;

comment "part of the function that doesn't work for some reason";
_slider = _display ctrlCreate ["RscXSliderH", -1];
_slider ctrlSetPosition [0,0.5,1,0];
_slider ctrlSetBackgroundColor [0,0,0,0.4];
_slider ctrlSetText "SPAWN";
_slider ctrlSetFont "PuristaMedium";
_slider ctrlSetTooltip "WooOOOOSH!!";
_slider ctrlSetEventHandler ["SliderPosChanged",'
	_value = (_this select 1)  / 10;
	
	DCON_Garage_Color set [0,_value];
	[] call DCON_fnc_Garage_UpdateColor;
'];
_slider ctrlCommit 0;

_controls = allControls _display;

comment "I sat here for about an hour manually going through each control trying to find the ones I hated. See my pain";
_spawn = _controls spawn {
	if true exitWith {};
	{
		hint str _x;
		_x ctrlSetBackgroundColor [1, 0, 0, 1];
		sleep 1;
	} forEach _this;
};
_spawns pushBack _spawn;

comment "they come back for some reason idk";
_spawn = _display spawn {
	while{true} do {
		(_this displayCtrl 28644) ctrlShow false;
		(_this displayCtrl 25815) ctrlShow false;
		(_this displayCtrl 44347) ctrlEnable false;
		comment "(_this displayCtrl 44046) ctrlShow false";
		sleep 0.01;
	};
};
_spawns pushBack _spawn;

comment "The intent is to provide players with a sense of pride and accomplishment by pressing the enter key";
_display displayAddEventHandler ["KeyUp",{
	_key = _this select 1;

	if(_key == 28) then {
		_display = (uiNamespace getVariable "DCON_Garage_Display");

		_display closeDisplay 1;

		DCON_Garage_CanSpawn = 1;
		[] call DCON_fnc_Garage_CreateVehicle;
	};
}];

_spawn = [_pos,_dir] spawn {
	_pos = _this select 0;
	_dir = _this select 1;
	_found = false;

	while {true} do {
		_objs = [_pos select 0,_pos select 1] nearEntities [["Air", "Car", "Tank", "Ship", "staticWeapon"], 30];
		reverse _objs;

		_model = uiNamespace getVariable "bis_fnc_garage_centertype";
		_model = _model splitString ":" select 0;
		if(_model find "\a3\" == -1) then {
			_model = "\"+_model;
		};
		if(_model find ".p3d" == -1) then {
			_model = _model+".p3d";
		};

		{
			_found = DCON_Garage_Vehicle getVariable "dcon_garage_veh";
			if(!isNil "_found") exitWith {};

			_id = _x call BIS_fnc_netId;
			_info = (getModelInfo _x) select 1;
			if(_info find "\a3\" == -1) then {
				_info = "\"+_info;
			};
			if(_info find ".p3d" == -1) then {
				_info = _info+".p3d";
			};
			_ignore = _x getVariable "dcon_garage_veh";

			if(_id find "0:" >= 0 && _info == _model && isNil "_ignore") exitWith {
				_veh = _x;

				_veh setVariable ["dcon_garage_veh",true];

				DCON_Garage_Vehicle = _veh;

				_display = (uiNamespace getVariable "DCON_Garage_Display");

				

				_pylons = (configProperties [configFile >> "CfgVehicles" >> typeOf _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons"]) apply {configName _x};
				if(count _pylons == 0) exitWith {};

				["DCON_Garage_FrameEvent", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
			};

		} forEach _objs;

		DCON_Garage_Vehicle setPosASL _pos;

		sleep 0.1;
	};
};
_spawns pushBack _spawn;

_spawn = [_pos,_dir] spawn {
	_pos = _this select 0;
	_dir = _this select 1;

	while {true} do {
		DCON_Garage_Vehicle setPosASL _pos;
	};
};
_spawns pushBack _spawn;

waitUntil {
	isNull _display;
};

{
	ctrlDelete (_x select 0);
} forEach DCON_Garage_Loadout_Controls;

["DCON_Garage_FrameEvent", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

deleteVehicle _helipad;

{
	terminate _x;
} forEach _spawns;

_veh = BIS_fnc_garage_center;
_roles = [];
{
	_roles pushBack [(agent _x),(assignedVehicleRole (agent _x))];
}foreach (agents select {(agent _x) isKindOf "B_Soldier_VR_F"});

if(DCON_Garage_CanSpawn == 1) then {
	[_roles] call DCON_fnc_Garage_CreateVehicle;
}
else
{
	deleteVehicle _veh;
};
