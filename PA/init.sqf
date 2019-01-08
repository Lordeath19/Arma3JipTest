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
			case (_key in actionKeys "User2"): {[0] spawn JEW_open_mainConsole};
		};
		false;
	}];
	
	
	
	//Disable stamina and add action to vehicle the player enters (kh-55sm and 9m79)
	player enablefatigue false;
	player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; (alive driver _veh) && {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0 && !(player in [driver _veh])}"];
	player addAction ["Enable driver assist", {[] spawn ASS_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
	player addAction ["Disable driver assist", {[] spawn ASS_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
	

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
	
	JEW_fnc_prevStatement = 
	{
		params ["_prevButton"];
		private _display = ctrlParent _prevButton;
		private _nextButton = _display displayCtrl 90111;
		private _expression = _display displayCtrl 5252;

		private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
		private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

		_statementIndex = (_statementIndex + 1) min ((count _prevStatements - 1) max 0);
		profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

		private _prevStatement = _prevStatements select _statementIndex;
		_expression ctrlSetText _prevStatement;

		_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
		_nextButton ctrlEnable (_statementIndex > 0);
	};

	JEW_fnc_nextStatement = 
	{
		params ["_nextButton"];
		private _display = ctrlParent _nextButton;
		private _prevButton = _display displayCtrl 90110;
		private _expression = _display displayCtrl 5252;

		private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
		private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

		_statementIndex = (_statementIndex - 1) max 0;
		profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

		private _nextStatement = _prevStatements select _statementIndex;
		_expression ctrlSetText _nextStatement;

		_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
		_nextButton ctrlEnable (_statementIndex > 0);
	};

	JEW_fnc_addStatement = 
	{
		params ["_control"];
		private _display = d_mainConsole;
		private _prevButton = _display displayCtrl 90110;
		private _nextButton = _display displayCtrl 90111;
		private _expression = _display displayCtrl 5252;

		private _statement = ctrlText _expression;

		private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
		private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

		if !((_prevStatements param [0, ""]) isEqualTo _statement) then {

			reverse _prevStatements;
			_prevStatements pushBack _statement;
			reverse _prevStatements;

			if (count _prevStatements > 50) then {
				_prevStatements resize 50;
			};

			profileNamespace setVariable ["DebugStatementsIndex", 0];
			profileNamespace setVariable ["DebugStatements", _prevStatements];

			_prevButton ctrlEnable (count _prevStatements > 1);
			_nextButton ctrlEnable false;
		};

	};
	
	JEW_fnc_execLocal = 
	{
		_text = ctrlText edit_debugConsoleInput;
		if(_text isEqualTo "") exitWith
		{
			hint "No code to execute.";
		};
		[] call JEW_fnc_addStatement;
		_code = compile _text;
		edit_debugConsoleOutput ctrlSetText (str ([] call _code));
	};

	JEW_fnc_execGlobal = 
	{
		_text = ctrlText edit_debugConsoleInput;
		if (_text isEqualTo "") exitWith
		{
			hint "No code to execute.";
		};
		[] call JEW_fnc_addStatement;
		_code = compile _text;
		_code remoteExec ["bis_fnc_call", 0, false];
	};

	JEW_fnc_execServer = 
	{																																																																																																																																							
		_text = ctrlText edit_debugConsoleInput;
		if (_text isEqualTo "") exitWith
		{
			hint "JEW: Console Error: No code to execute.";
		};
		[] call JEW_fnc_addStatement;
		_code = compile _text;
		_code remoteExec ["bis_fnc_call", 2, false];
	};
	
	JEW_fnc_execPlayer = 
	{
		params ["_playerName"];
		_text = ctrlText edit_debugConsoleInput;
		if (_text isEqualTo "") exitWith
		{
			hint "JEW: Console Error: No code to execute.";
		};
		[] call JEW_fnc_addStatement;
		_code = compile _text;
		_code remoteExec ["bis_fnc_call", _playerName, false];
	};

	
	JEW_open_mainConsole = 
	{
		disableSerialization;
		d_mainConsole = (findDisplay 46) createDisplay "RscDisplayEmpty";
		showChat true; comment "Fixes Chat Bug";

		txt_background1 = d_mainConsole ctrlCreate ["RscText", 5248];
		txt_background1 ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY, 0.257813 * safezoneW,0.196044 * safezoneH];
		txt_background1 ctrlSetBackgroundColor [-1,-1,-1,0.7];
		txt_background1 ctrlCommit 0;
		
		txt_mainMenuTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5249];
		txt_mainMenuTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>DEBUG CONSOLE</t>";
		txt_mainMenuTitle ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.257813 * safezoneW,0.055 * safezoneH];
		txt_mainMenuTitle ctrlSetBackgroundColor [0,0,0,0.5];
		txt_mainMenuTitle ctrlCommit 0;
				
		edit_debugConsoleInput = d_mainConsole ctrlCreate ["RscEditMulti", 5252];
		edit_debugConsoleInput ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.464712 * safezoneH + safezoneY,0.257813 * safezoneW,0.216059 * safezoneH];
		edit_debugConsoleInput ctrlSetBackgroundColor [-1,-1,-1,0.8];
		edit_debugConsoleInput ctrlSetTooltip "Script here";
		edit_debugConsoleInput ctrlCommit 0;
		if(!(profileNamespace getVariable["DebugStatements", []] isEqualTo [])) then
		{
			_prevStatements = profileNamespace getVariable ["DebugStatements", []];

			edit_debugConsoleInput ctrlSetText (_prevStatements select 0);
		};

		
		edit_debugConsoleOutput = d_mainConsole ctrlCreate ["RscEdit", 5267];
		edit_debugConsoleOutput ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.688771 * safezoneH + safezoneY,0.257813 * safezoneW,0.04 * safezoneH];
		edit_debugConsoleOutput ctrlSetBackgroundColor [0,0,0,1];
		edit_debugConsoleOutput ctrlCommit 0;


		lb_playerList = d_mainConsole ctrlCreate ["RscListbox", 5253];
		lb_playerList ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0670312 * safezoneW,0.341 * safezoneH];
		{ _pL_index = lb_playerList lbAdd name _x; } forEach allPlayers;
		lb_playerList ctrlCommit 0;
		
		btn_serverExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5254];
		btn_serverExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Server</t>";
		btn_serverExecute ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0825 * safezoneW,0.03 * safezoneH];
		btn_serverExecute ctrladdEventHandler ["ButtonClick",{
			[] spawn JEW_fnc_execServer;
		}];
		btn_serverExecute ctrlCommit 0;
		
		btn_globalExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5255];
		btn_globalExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Global</t>";
		btn_globalExecute ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0876563 * safezoneW,0.03 * safezoneH];
		btn_globalExecute ctrladdEventHandler ["ButtonClick",{
			[] spawn JEW_fnc_execGlobal;
		}];
		btn_globalExecute ctrlCommit 0;
		
		btn_localExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5256];
		btn_localExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Local</t>";
		btn_localExecute ctrlSetPosition [0.551563 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0773437 * safezoneW,0.03 * safezoneH];
		btn_localExecute ctrladdEventHandler ["ButtonClick",{
			[] spawn JEW_fnc_execLocal;
		}];
		btn_localExecute ctrlCommit 0;

		comment "Enter key shortcut (just for you baby boy <3)";
		d_mainConsole displayAddEventHandler ["KeyUp",{
			_key = _this select 1;
			if(_key == 28) then {
				[] spawn JEW_fnc_execLocal;
			};
		}];

		btn_playerExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5257];
		btn_playerExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Player</t>";
		btn_playerExecute ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0670312 * safezoneW,0.03 * safezoneH];
		btn_playerExecute ctrladdEventHandler ["ButtonClick",{
			[lb_playerList lbText (lbCurSel lb_playerList)] spawn JEW_fnc_execPlayer;
		}];
		btn_playerExecute ctrlCommit 0;
		
																												




		btn_prevButton = d_mainConsole ctrlCreate ["RscButtonMenu", 90110];
		btn_prevButton ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.783229 * safezoneH + safezoneY,0.103125 * safezoneW,0.03 * safezoneH];
		btn_prevButton ctrlCommit 0;
		btn_prevButton ctrlSetStructuredText parseText "<t size='1' align='center'>Prev Statement</t>";
		btn_prevButton ctrlAddEventHandler ["MouseButtonUp", {_this call JEW_fnc_prevStatement; true}];

		btn_nextButton = d_mainConsole ctrlCreate ["RscButtonMenu", 90111];
		btn_nextButton ctrlSetPosition [0.5257817 * safezoneW + safezoneX,0.783229 * safezoneH + safezoneY,0.103125 * safezoneW,0.03 * safezoneH]; 
		btn_nextButton ctrlCommit 0;
		btn_nextButton ctrlSetStructuredText parseText "<t size='1' align='center'>Next Statement</t>";
		btn_nextButton ctrlAddEventHandler ["MouseButtonUp", {_this call JEW_fnc_nextStatement; true}];


		_statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
		_prevStatements = profileNamespace getVariable ["DebugStatements", []];

		btn_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
		btn_nextButton ctrlEnable (_statementIndex > 0);

		txt_playerListTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5258];
		txt_playerListTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center'>Player List</t>";
		txt_playerListTitle ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.269 * safezoneH + safezoneY,0.0670312 * safezoneW,0.03 * safezoneH];
		txt_playerListTitle ctrlSetBackgroundColor [0,0,0,0.5];
		txt_playerListTitle ctrlCommit 0;
		
	};
	
	_keybinds = [] spawn { 
		waitUntil { !(IsNull (findDisplay 46)) };				
		
		EH_mapTP = player addEventHandler ["Respawn", {
			JEW_fnc_mapTP = {if (!_shift and _alt) then {(vehicle player) setPos _pos;};};
			JEW_keybind_mapTP = ["JEWfncMapTP", "onMapSingleClick", JEW_fnc_MapTP] call BIS_fnc_addStackedEventHandler;
		}];
		comment "numpad 5";
		SystemChat "...< Keybinds Initialized >...";
		hint "-----------------------------\nKEYBINDS\n-----------------------------\nHOME - Main Console\n-----------------------------";
		};

};

