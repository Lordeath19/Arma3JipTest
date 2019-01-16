//Replace the dummy launcher for the actual one when using the pylon from GOM

[] spawn {
	while {true} do {

	if ({"rhs_mag_kh55sm" in ([(configFile >> "CfgMagazines" >> _x),true] call BIS_fnc_returnParents)} count magazines vehicle player > 0
		&& !("rhs_weap_kh55sm_Launcher" in weapons (vehicle player))) then {
		
		
		vehicle player addWeapon "rhs_weap_kh55sm_Launcher";
	};
			
	sleep 2;
	};
};

if (isDedicated) exitWith {};
if !(hasinterface) exitwith {};

//Initialize GOM and start listening
private["_keyDown"];
[] spawn {
	waitUntil {!isNull player && player == player};
	waitUntil{!isNil "BIS_fnc_init"};
	waitUntil {!(IsNull (findDisplay 46))};
	GOM_list_allPylonMags = ("count( getArray (_x >> 'hardpoints')) > 0" configClasses (configfile >> "CfgMagazines")) apply {configname _x};
	GOM_list_allPylonMags = [GOM_list_allPylonMags, [], {getText (configfile >> "CfgMagazines" >> _x >> "displayName")}, "ASCEND"] call BIS_fnc_sortBy;
	GOM_list_validDispNames = GOM_list_allPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};
	DCON_Garage_Loadout_Controls = [];
	_load = [] spawn {
		if(count (missionNamespace getVariable ["allWeapons",[]]) == 0) then {
			disableSerialization;
			
			_allWeapons = ("isclass _x && {getnumber (_x >> 'scope') != 0}" configclasses (configfile >> "cfgweapons")) select {(configName _x) call BIS_fnc_itemType select 0 isEqualTo "Weapon" || (configName _x) call BIS_fnc_itemType select 0 isEqualTo "VehicleWeapon"} apply {toLower (configName _x)};
			
			_allWeapons sort true;
			missionNamespace setVariable ["allWeapons", _allWeapons];
		};
		systemChat "All weapons loaded";
	}; 
	systemChat "Personal arsenal loaded";
	private["_i", "_keyDown"];
   	_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
	
		_key = _this select 1;
		switch true do
		{
			case (_key in actionKeys "User1"): {if(!dialog) then {createDialog "PA_main";};};
			case (_key in actionKeys "User6"): {player moveInAny cursorTarget};
			//case (_key in actionKeys "User2"): {[0] spawn JEW_fnc_open};
		};
		false;
	}];
	
	//Disable stamina and add action to vehicle the player enters (kh-55sm and 9m79)
	player enablefatigue false;
	player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; (alive driver _veh) && {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0 && !(player in [driver _veh])}"];
	player addAction ["Enable driver assist", {[] spawn ASS_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
	player addAction ["Disable driver assist", {[] spawn ASS_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
	
	["onMapTP", "onMapSingleClick", {
		params ["_units","_pos","_alt","_shift"];
		if(count _units == 0 && _alt && !_shift) then {
			(vehicle player) setPos _pos;
		};		
	}] call BIS_fnc_addStackedEventHandler;

	player setVariable ["ControlPanelID",[
		player addAction  
		[
			"Open control panel",  
			{ 
			params ["_target", "_caller", "_actionId", "_arguments"]; 
			createDialog "tu95_main_dialog"; 
			}, 
			[], 
			7,  
			true,  
			true,  
			"", 
			"currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
		],
	   
		player addAction  
		[
			"Open control panel",  
			{ 
			params ["_target", "_caller", "_actionId", "_arguments"]; 
			createDialog "ss21_main_dialog"; 
			}, 
			[], 
			7,  
			true,  
			true,  
			"", 
			"currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
		]]
	];


	//Disable stamina and add action to vehicle the player enters (kh-55sm and 9m79) after respawn

	player addEventhandler ["Respawn", {
		
		player enableFatigue false;
		player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0}"];
		player addAction ["Enable driver assist", {[] spawn ASS_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
		player addAction ["Disable driver assist", {[] spawn ASS_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];

		["onMapTP", "onMapSingleClick", {
			params ["_units","_pos","_alt","_shift"];
			if(count _units == 0 && _alt && !_shift) then {
				(vehicle player) setPos _pos;
			};		
		}] call BIS_fnc_addStackedEventHandler;

		player setVariable ["ControlPanelID",[

			player addAction  
			[ 
				"Open control panel",  
				{ 
				params ["_target", "_caller", "_actionId", "_arguments"]; 
				createDialog "tu95_main_dialog"; 
				}, 
				[], 
				7,  
				true,  
				true,  
				"", 
				"currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
			],


			player addAction  
			[ 
				"Open control panel",  
				{ 
				params ["_target", "_caller", "_actionId", "_arguments"]; 
				createDialog "ss21_main_dialog"; 
				}, 
				[], 
				7,  
				true,  
				true,  
				"", 
				"currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
			]
		]];
	}];
	player addEventHandler ["GetInMan", {
		params ["_vehicle", "_role", "_unit", "_turret"];
		
		_vehicle = vehicle player;

		//Check if the vehicle already contains rhs missile launcher control panels
		if(_vehicle getVariable ["ControlPanelID",-1] isEqualTo -1) then {
		
			_vehicle setVariable ["ControlPanelID",
				[_vehicle addAction  
				[
				   "Open control panel",  
				   { 
					params ["_target", "_caller", "_actionId", "_arguments"]; 
					createDialog "tu95_main_dialog"; 
				   }, 
				   [], 
				   7,  
				   true,  
				   true,  
				   "", 
				   "currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
				],
				   
				   
				_vehicle addAction  
				[ 
				   "Open control panel",  
				   { 
					params ["_target", "_caller", "_actionId", "_arguments"]; 
					createDialog "ss21_main_dialog"; 
				   }, 
				   [], 
				   7,  
				   true,  
				   true,  
				   "", 
				   "currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
				]]	   
			];
		};	
	}];
};

