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
		[] call _code;
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
		txt_mainMenuTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>RAZER MENU V1</t>";
		txt_mainMenuTitle ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.257813 * safezoneW,0.055 * safezoneH];
		txt_mainMenuTitle ctrlSetBackgroundColor [0,0,0,0.5];
		txt_mainMenuTitle ctrlCommit 0;
		
		btn_forceVoteAdmin = d_mainConsole ctrlCreate ["RscButtonMenu", 5250];
		
		btn_forceVoteAdmin ctrlSetStructuredText parseText "<t size='0.9' align='center'>FORCE-VOTE ADMIN</t>";
		btn_forceVoteAdmin ctrlSetPosition [0.37625 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0979687 * safezoneW,0.055 * safezoneH];
		btn_forceVoteAdmin ctrladdEventHandler ["ButtonClick",{
			newAdmin = lb_playerList lbText (lbCurSel lb_playerList);
			[[newAdmin],
			{
				newAdmin = _this select 0;
				disableSerialization;
				d_adminTransfer = (findDisplay 46) createDisplay "RscDisplayEmpty";
				showChat true;
				_mouseDetection2 = d_adminTransfer ctrlCreate ["RscButton", 8888];
				_mouseDetection2 ctrlSetPosition [-0.000156274 * safezoneW + safezoneX,-0.00599999 * safezoneH + safezoneY,1.00547 * safezoneW,1.023 * safezoneH];
				_mouseDetection2 ctrladdEventHandler ["MouseMoving",
				"
					serverCommand format ['#Vote Admin %1', newAdmin];
					d_adminTransfer closeDisplay 0;
				"];
				_mouseDetection2 ctrlSetBackgroundColor [0,0,0,0];
				_mouseDetection2 ctrlCommit 0;
			}] remoteExec ["spawn",-2];
		}];
		btn_forceVoteAdmin ctrlCommit 0;

		txt_debugConsoleTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5251];
		txt_debugConsoleTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>DEBUG CONSOLE</t>";
		txt_debugConsoleTitle ctrlSetPosition [0.371096 * safezoneW + safezoneX,0.429984 * safezoneH + safezoneY,0.257813 * safezoneW,0.03 * safezoneH];
		txt_debugConsoleTitle ctrlSetBackgroundColor [0,0,0,0.5];
		txt_debugConsoleTitle ctrlCommit 0;
		
		edit_debugConsoleInput = d_mainConsole ctrlCreate ["RscEditMulti", 5252];
		edit_debugConsoleInput ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.464712 * safezoneH + safezoneY,0.257813 * safezoneW,0.266059 * safezoneH];
		edit_debugConsoleInput ctrlSetBackgroundColor [-1,-1,-1,0.8];
		edit_debugConsoleInput ctrlSetTooltip "Script here";
		edit_debugConsoleInput ctrlCommit 0;
		if(!(profileNamespace getVariable["consoleLast", ""] isEqualTo "")) then
		{
			edit_debugConsoleInput ctrlSetText (profileNamespace getVariable "consoleLast");
		};

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
		
		btn_playerESP = d_mainConsole ctrlCreate ["RscButtonMenu", 5259];
		btn_playerESP ctrlSetStructuredText parseText "<t size='0.9' align='center'>Player<br />ESP</t>";
		btn_playerESP ctrlSetPosition [0.37625 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_playerESP ctrladdEventHandler ["ButtonClick",{
			if (isNil 'JEWESPTggle') then {JEWESPTggle = 1};
			if (JEWESPTggle == 1) then {
				JEWESPTggle = 0;
				titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
				[("
					MissionEH_3DESP = addMissionEventHandler ['Draw3D',
					{
						{
							if (((player distance _x) < 3000) && (_x != player)) then {
								if (side _x != side player) then {
									switch (side _x) do {
										case west: { drawIcon3D ['', [0.4, 0.4, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
										case east: { drawIcon3D ['', [1, 0.4, 0.4, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
										case independent: { drawIcon3D ['', [0.4, 1, 0.4, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
										default { drawIcon3D ['', [0, 0, 0, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
									};
								} else {
									drawIcon3D ['', [1, 1, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false];
								};
							};
						} forEach allPlayers;
					}];
				")] call {(with missionNamespace do compile (_this select 0));};
			} else {
				JEWESPTggle = 1;
				titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
				[("removeMissionEventHandler['Draw3D',MissionEH_3DESP];")] call {(with missionNamespace do compile (_this select 0));};
			};
		}];
		btn_playerESP ctrlCommit 0;
		
		btn_AIESP = d_mainConsole ctrlCreate ["RscButtonMenu", 5260];
		btn_AIESP ctrlSetStructuredText parseText "<t size='0.9' align='center'>AI<br />ESP</t>";
		btn_AIESP ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_AIESP ctrladdEventHandler ["ButtonClick",{
			if (isNil 'JEWhostileAIESPTggle') then {JEWhostileAIESPTggle = 1};
			if (JEWhostileAIESPTggle == 1) then {
				JEWhostileAIESPTggle = 0;
				titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
				JEWhostileAIEsp = addMissionEventHandler ['Draw3D',{
					{
						if ((side _x != side player) && ((player distance _x) < 3000)) then {
							drawIcon3D["", [1, 0, 0, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%1m", round(player distance _x)]), 1, 0.04, "EtelkaNarrowMediumPro"];
						} else {
							if (((player distance _x) < 3000) && (name _x != name player)) then {
								drawIcon3D["", [0, 0.5, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%1m", round(player distance _x)]), 1, 0.04, "EtelkaNarrowMediumPro"];
							};
						};
					} forEach call {
						_hostileai = [];
						{
							if ((_x isKindOf "Man") && (side _x != side player)) then {
								_hostileai pushBack _x;
							} else {
								if ((count crew _x) != 0) then {
									for "_i" from 0 to (count crew _x)-1 do {
										_l = (crew _x) select _i;
										if (side _l != side player) then {
											_hostileai pushBack _l;
										};
									};
								};
							};
						} forEach allUnits - allPlayers;
						_hostileai
					};
				}];
			} else {
				JEWhostileAIESPTggle = 1;
				titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
				removeMissionEventHandler['Draw3D',JEWhostileAIEsp];
			};
		}];
		btn_AIESP ctrlCommit 0;
		
		btn_mapAware = d_mainConsole ctrlCreate ["RscButtonMenu", 5261];
		btn_mapAware ctrlSetStructuredText parseText "<t size='0.9' align='center'>Map<br />Aware</t>";
		btn_mapAware ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_mapAware ctrladdEventHandler ["ButtonClick",{
			if (isNil "mapAwareTggle") then {mapAwareTggle = 1};
			if (mapAwareTggle == 1) then {
				mapAwareTggle = 0;
				["EH_RevealUnitsOnMap", "onEachFrame", 
				{
					{
						player reveal vehicle _x;
					} forEach allUnits;
				}] call BIS_fnc_addStackedEventHandler;
				titleText ["<t color='#42D6FC'>MAP-AWARE </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			} else {
				mapAwareTggle = 1;
				["EH_RevealUnitsOnMap", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
				titleText ["<t color='#42D6FC'>MAP-AWARE </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_mapAware ctrlCommit 0;
		
		btn_infStamina = d_mainConsole ctrlCreate ["RscButtonMenu", 5262];
		btn_infStamina ctrlSetStructuredText parseText "<t size='0.9' align='center'>Infinite<br />Stamina</t>";
		btn_infStamina ctrlSetPosition [0.530937 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_infStamina ctrladdEventHandler ["ButtonClick",{
			if (isNil "infStaminaTggle") then {infStaminaTggle = 1};
			if (infStaminaTggle == 1) then {
				infStaminaTggle = 0;
				player enableFatigue false;
				EH_cardio = player addEventHandler ["Respawn", {player enableFatigue false;}];
				titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			} else {
				infStaminaTggle = 1;
				player enableFatigue true;
				player removeEventHandler ["Respawn", EH_cardio];
				titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_infStamina ctrlCommit 0;
		
		btn_godMode = d_mainConsole ctrlCreate ["RscButtonMenu", 5263];
		btn_godMode ctrlSetStructuredText parseText "<t size='0.9' align='center'>God<br />Mode</t>";
		btn_godMode ctrlSetPosition [0.5825 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
		btn_godMode ctrladdEventHandler ["ButtonClick",{
			if (isNil "godModeTggle") then {godModeTggle = 1};
			if (godModeTggle == 1) then {
				godModeTggle = 0;
				player allowDamage false;
				EH_god = player addEventHandler ["Respawn", {player enableFatigue false;}];
				titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			} else {
				godModeTggle = 1;
				player allowDamage true;
				player removeEventHandler ["Respawn", EH_god];
				titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_godMode ctrlCommit 0;
		
		btn_noRecoil = d_mainConsole ctrlCreate ["RscButtonMenu", 5264];
		btn_noRecoil ctrlSetStructuredText parseText "<t size='0.9' align='center'>Disable<br />Recoil</t>";
		btn_noRecoil ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_noRecoil ctrladdEventHandler ["ButtonClick",{
			if (isNil "disableRecoilTggle") then {disableRecoilTggle = 1};
			if (disableRecoilTggle == 1) then {
				disableRecoilTggle = 0;
				player setUnitRecoilCoefficient 0;
				player setCustomAimCoef 0.1;
				EH_disableRecoil = player addEventHandler ["Respawn", {player enableFatigue false;}];
				titleText ["<t color='#42D6FC'>NO-RECOIL </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			} else {
				disableRecoilTggle = 1;
				player setUnitRecoilCoefficient 1;
				player setCustomAimCoef 1;
				player removeEventHandler ["Respawn", EH_disableRecoil];
				titleText ["<t color='#42D6FC'>NO-RECOIL </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_noRecoil ctrlCommit 0;
		
		btn_infAmmo = d_mainConsole ctrlCreate ["RscButtonMenu", 5265];
		btn_infAmmo ctrlSetStructuredText parseText "<t size='0.9' align='center'>Infinite<br />Ammo</t>";
		btn_infAmmo ctrlSetPosition [0.530937 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
		btn_infAmmo ctrladdEventHandler ["ButtonClick",{
			if (isNil "infAmmoTggle") then {infAmmoTggle = 1};
			if (infAmmoTggle == 1) then {
				infAmmoTggle = 0;
				titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
				[] spawn {
					while {infAmmoTggle == 0} do {
						player setVehicleAmmo 1;
						vehicle player setVehicleAmmo 1;
						sleep 0.5;
					};
				};
			} else {
				infAmmoTggle = 1;
				titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_infAmmo ctrlCommit 0;
		
		btn_aiIgnore = d_mainConsole ctrlCreate ["RscButtonMenu", 5266];
		btn_aiIgnore ctrlSetStructuredText parseText "<t size='0.9' align='center'>AI<br />Ignore</t>";
		btn_aiIgnore ctrlSetPosition [0.5825 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
		btn_aiIgnore ctrladdEventHandler ["ButtonClick",{
			if (isNil "aiIgnoreTggle") then {aiIgnoreTggle = 1};
			if (aiIgnoreTggle == 1) then {
				aiIgnoreTggle = 0;
				player setCaptive true;
				EH_aiIgnore = player addEventHandler ["Respawn", {player enableFatigue false;}];
				titleText ["<t color='#42D6FC'>AI Ignore </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			} else {
				aiIgnoreTggle = 1;
				player setCaptive false;
				player removeEventHandler ["Respawn", EH_aiIgnore];
				titleText ["<t color='#42D6FC'>AI Ignore </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
				playSound "Hint";
			};
		}];
		btn_aiIgnore ctrlCommit 0;
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

