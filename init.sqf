[] spawn {
	while {true} do {

	if ({"rhs_mag_kh55sm" in ([(configFile >> "CfgMagazines" >> _x),true] call BIS_fnc_returnParents)} count magazines vehicle player > 0
		&& !("rhs_weap_kh55sm_Launcher" in weapons (vehicle player))) then {
		
		
		vehicle player addWeapon "rhs_weap_kh55sm_Launcher";
	};
			
	sleep 2;
	};
};

private["_keyDown"];
[] spawn {
	waitUntil {!isNull player && player == player};
	waitUntil{!isNil "BIS_fnc_init"};
	waitUntil {!(IsNull (findDisplay 46))};
	GOM_list_allPylonMags = ("count( getArray (_x >> 'hardpoints')) > 0" configClasses (configfile >> "CfgMagazines")) apply {configname _x};
	GOM_list_allPylonMags = [GOM_list_allPylonMags, [], {getText (configfile >> "CfgMagazines" >> _x >> "displayName")}, "ASCEND"] call BIS_fnc_sortBy;
	GOM_list_validDispNames = GOM_list_allPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};

	systemChat "Personal arsenal loaded";
	private["_i", "_keyDown"];
   	_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", "
	
	_key = _this select 1;
	switch true do
	{
		case (_key in actionKeys 'User1'): {if(!dialog) then {createDialog 'PA_main';};};
		case (_key in actionKeys 'User6'): {player moveInAny cursorTarget};
	};
	false;
	"];

};
player enablefatigue false;


player setVariable ["ControlPanelID",
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
   ]];


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
   ];

	
	






player addEventhandler ["Respawn", {player enableFatigue false;



player setVariable ["ControlPanelID",
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
   ]];


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
   ];






}];

player addEventHandler ["GetInMan", {
	params ["_vehicle", "_role", "_unit", "_turret"];
	
	_vehicle = vehicle player;
	
	if(_vehicle getVariable ["DriverAssist", -1] isEqualTo -1) then {
	

		_vehicle setVariable ["DriverAssist",[
			
			
			_vehicle addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}],			
			_vehicle addAction ["Enable driver assist", {[] spawn ASS_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"],
			_vehicle addAction ["Disable driver assist", {[] spawn ASS_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"]]];
	
	
	};
	
	
	if(_vehicle getVariable ["ControlPanelID",-1] isEqualTo -1) then {
	
	_vehicle setVariable ["ControlPanelID",
	_vehicle addAction  
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
	   ]];
 
 
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
	   ];
 
 
	};	
}];