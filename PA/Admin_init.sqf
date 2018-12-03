SystemChat "...< remote executing part 2>...";

script_initCOOLJIPgustavP2 = [] spawn 
{

	waitUntil {!isNull player};
	[[0],
	{
		_JEW_nameKey27 = "76561198164329131";
		_JEW_playerName27 = (getPlayerUID player);
		if (_JEW_playerName27 == _JEW_nameKey27 || _JEW_playerName27 == "_SP_PLAYER_") then 
		{
			JEW_engage_Admin = [] spawn
			{
				comment "----------------------------"; 
				comment "Admin Menu Version 1.6 Alpha";
				comment "----------------------------";
					SystemChat "Admin Menu Version 1.6 Alpha | Status: Loading...";
					Admin_myName = name player;
					Admin_mySteam64UID = getPlayerUID player;
					SystemChat format ["Admin Menu Version 1.6 Alpha | Status: Activated | Name: %1 | SteamID: %2", 
					Admin_myName, Admin_mySteam64UID];
				comment "----------------------------"; 
				comment "------GLOBAL VARIABLES------";
				comment "----------------------------"; 
					Admin_isLoaded = false;
					Admin_whitelist = []; comment "Steam IDs";
					Admin_banList = [];
					Admin_myOwnerID = owner player;
					Admin_myClientID = clientOwner;
					Admin_tColor = [0,0.5,0,0.6];
					Admin_fColor = [0,1,0,1];
					Admin_tColorChanged = false;
					Admin_key_arsenal = "Insert Key";
					Admin_key_mainMenu = "Number Pad 5";
					Admin_key_3DTP = "H";
					Admin_whiteListEnabled = false;
				comment "----------------------------"; 
				comment "-----INITIATE WHITELIST-----";
				comment "----------------------------"; 
					_loopWhitelist = [] spawn
					{
						waitUntil {Admin_whiteListEnabled}; 
						while {Admin_whiteListEnabled} do {
							{
								If ((getPlayerUID _x) in Admin_whitelist) then {
									[["BACK-TO-LOBBY"],
									{ ["LOSER",false,0,true] spawn BIS_fnc_endMission }] remoteExec ["spawn",_x]
								}
							} forEach (allPlayers select {(str (getPlayerUID _x)) in Admin_whitelist})
						}
					};
				comment "----------------------------"; 
				comment "-------QUICK SCRIPTS--------";
				comment "----------------------------"; 
					Admin_fnc_mutePlayer =
					{
						params ["_playerName"];
						_playerName = _this select 0;
						{
							if ( ( name _x ) == _playerName ) then
							{
								_textNotif = format ["Admin: Server-muting %1...", (name _x)];
								cutText [_textNotif, "PLAIN DOWN", 0, true, false];
								_x setVariable ["BIS_noCoreConversations", true];
								_x disableConversation true;
								
								[["<t color='#ff0000' size='2'>ADMIN MESSAGE:<br/><t color='#FFFFFF' size='1'>You have been muted child [chat, VoN]", "PLAIN", 3, true, true]] remoteExec ["titleText", _x];
								
								[[],
								{
									for [{_i=0}, {_i<5}, {_i=_i+1}] do {
										_i enableChannel false;
									}
								}] remoteExec ["spawn", _x]
							}
						} forEach allPlayers 
					};
					Admin_fnc_unmutePlayer = 
					{
						params ["_playerName"];
						{
							if ( ( name _x ) == _playerName ) then 
							{
								_textNotif = format ["Admin: Un-muting %1...", (name _x)];
								cutText [_textNotif, "PLAIN DOWN", 0, true, false];
								
								_x setVariable ["BIS_noCoreConversations", false];
								_x disableConversation false;
								
								[["<t color='#ff0000' size='2'>ADMIN MESSAGE:<br/><t color='#000FFF' size='1'>You have been un-muted, do NOT be a retard [chat, VoN]", "PLAIN", 3, true, true]] remoteExec ["titleText", _x];
								
								[[],
								{
									for [{_i=0}, {_i<5}, {_i=_i+1}] do {
										_i enableChannel true
									}
								}] remoteExec ["Spawn", _x];
							}
						} forEach allPlayer
					};
					Admin_fnc_autoKickPlayer = 
					{ 
						comment "Identify Target";
						nameOfTroll = _this select 0; 
						{
							if ((name _x) == nameOfTroll) then {
								banTarget = _x;
							}
						} forEach allPlayers;

						comment "Create BAN Function";
						Admin_banThisTroll = 
						{
							banTarget = _this select 0;
							comment "Do not run if there is no target";
							comment "Add this player steam ID to BAN List array";
							Admin_banList pushBackUnique (getPlayerUID banTarget);
							comment "Default BAN Reason";
							if (isNil "banReason") then {banReason = "Troll"};
							comment "Create & run message with unique id of banTarget";
							[[banReason],{
								banReason = _this select 0;
								comment "TIMED BAN MESSAGE";
								titleText [("BAN REASON: " + banReason + "<br/><t color='#ff0000' size='5'>YOU HAVE BEEN BANNED!</t><br/>Courtesy of Admin Menu,<br/>you will now be kicked and unable to join back."), "WHITE", -1, true, true];
								disableUserInput true;
								sleep 5;
								comment "This will automatically make admin kick the player, thus effectively banning him";
								nameOfTroll = name player;
								steamIDofTroll = getPlayerUID player;
								[[nameOfTroll, steamIDofTroll],{
									_nameOfTroll = _this select 0;
									_UIDofTroll = _this select 1;
									BANkickCommand = format ["#kick %1", _nameOfTroll];
									BANtextNotif = format ['Admin: Player %1 has been auto-kicked because he is banned. STEAM ID: %2', _nameOfTroll, _UIDofTroll];
									disableSerialization;
									d_autoKicker = (findDisplay 46) createDisplay "RscDisplayEmpty";
									showChat true;
									_mouseDetection3 = d_autoKicker ctrlCreate ["RscButton", 7777];
									_mouseDetection3 ctrlSetBackgroundColor [0,0,0,0];
									_mouseDetection3 ctrlSetPosition [-0.000156274 * safezoneW + safezoneX,-0.00599999 * safezoneH + safezoneY,1.00547 * safezoneW,1.023 * safezoneH];
									_mouseDetection3 ctrladdEventHandler ["MouseMoving",
									"	serverCommand BANkickCommand;
										d_autoKicker closeDisplay 0;
										BANtextNotif remoteExec ['systemChat',0] "];
									_mouseDetection3 ctrlCommit 0 
								}] remoteExec ["spawn", remoteExecutedOwner]
							}] remoteExec ["spawn", banTarget, str (getPlayerUID banTarget)]
						};
						
						comment "Please enter ban reason through GUI";
						disableSerialization;
						d_banReason = (findDisplay 46) createDisplay "RscDisplayEmpty";
						showChat true;
						ctrl_GUItitle = d_banReason ctrlCreate ["RscText", 6000];
						ctrl_GUItitle ctrlSetText "Admin: Please enter the reason for banning player.";
						ctrl_GUItitle ctrlSetPosition [0.407187 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.185625 * safezoneW,0.022 * safezoneH];
						ctrl_GUItitle ctrlSetBackgroundColor [-1,-1,-1,1];
						ctrl_GUItitle ctrlCommit 0;
						ctrl_banReason = d_banReason ctrlCreate ["RscEdit", 6001];
						ctrl_banReason ctrlSetPosition [0.407187 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.185625 * safezoneW,0.055 * safezoneH];
						ctrl_banReason ctrlSetBackgroundColor [-1,-1,-1,0.75];
						ctrl_banReason ctrlCommit 0;
						ctrl_GUIban = d_banReason ctrlCreate ["RscButtonMenu", 6002];
						ctrl_GUIban ctrlSetText "BAN";
						ctrl_GUIban ctrlSetPosition [0.407187 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.0464063 * safezoneW,0.022 * safezoneH];
						ctrl_GUIban ctrladdEventHandler ["ButtonClick",
						" 	banReason = ctrlText ctrl_banReason;
							_textNotif = format ['Admin: Banning player %1...', nameOfTroll];
							cutText [_textNotif, 'PLAIN DOWN', 0, true, false];
							[banTarget] spawn Admin_banThisTroll;
							d_banReason closeDisplay 0 "];
						ctrl_GUIban ctrlCommit 0;
						ctrl_GUIcancel = d_banReason ctrlCreate ["RscButtonMenu", 6003];
						ctrl_GUIcancel ctrlSetText "CANCEL";
						ctrl_GUIcancel ctrlSetPosition [0.546406 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.0464063 * safezoneW,0.022 * safezoneH];
						ctrl_GUIcancel ctrladdEventHandler ["ButtonClick",
						" d_banReason closeDisplay 0 "] ctrl_GUIcancel ctrlCommit 0 
					};
					Admin_fnc_experimentalBan = 
					{
						params ["_playerName"];
						{
							if ( ( name _x ) == _playerName ) then 
							{
								_textNotif = "Admin: Banning player, " + _playerName + "...";
								[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
								[[( name _x )],{
									hint format ["You are now being banned, %1.",(_this select 0)];
									disableSerialization;
									_banDisplay = (findDisplay 46) createDisplay "RscDisplayEmpty";
									_mouseDetection = _banDisplay ctrlCreate ["RscButton", 9999];
									_mouseDetection ctrlSetBackgroundColor [0,0,0,0];
									_mouseDetection ctrlSetPosition [-0.000156274 * safezoneW + safezoneX,-0.00599999 * safezoneH + safezoneY,1.00547 * safezoneW,1.023 * safezoneH];
									_mouseDetection ctrladdEventHandler ["MouseMoving",
									" serverCommand format ['#Vote Admin %1', (_this select 0)];
										comment 'Rapid vote admin leads to restriction ban and player will not be able to join until restart' "];
									_mouseDetection ctrlCommit 0 
								}] remoteExec ["spawn",_x] 
							}
						} forEach allPlayers 
					};

					Admin_fnc_whitelistPlayer = 
					{
						params["_playerName"];
						{
							if (_playerName find (name _x) > -1) then 
							{
								Admin_whitelist pushBackUnique str (getPlayerUID _x); 
							}
						} forEach allPlayers;
						_textNotif = format ["Admin: Adding %1 to the White List by SteamID...", _playerName];
						[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0]
					};
					
					Admin_fnc_freezePlayer = 
					{
						params["_playerName"];
						{
							if (_playerName == Admin_myName) exitWith {hint "Admin: Do not freeze yourself"};
							if ( ( name _x ) == _playerName ) then 
							{
								[[( name _x )], 
								{ 
									if (!userInputDisabled) then 
									{
										_textNotif = "Admin: Freezing " + (_this select 0) + "...";
										[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
										disableUserInput true;
										hint format ["%1, your input has been disabled by the server Administrator (Admin). Standby to be unfreeze, if the problem persists, simply press ALT+F4 and it will close your game.",(_this select 0)];
									} 
									else 
									{
										_textNotif = "Admin: Un-freezing " + (_this select 0) + "...";
										[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
										disableUserInput false;
										hint format ["%1, your input has been re-enabled by the server Administrator (Admin)",(_this select 0)];
									}
								}
								
								] remoteExec ["spawn",_x];
							}
						} forEach allPlayers
					};

					Admin_fnc_TP_selfToPlayer = 
					{
						params["_selectedPlayerName"];
						_startPos = getPos player; 
						{
							if ((name _x) == (_selectedPlayerName)) then 
							{
								(vehicle player) setPos (getPos _x);
								comment "if player is in vehicle, move in";
								if ((vehicle _x != _x) && (vehicle player == player)) then
								{
									player moveInAny (vehicle _x)
								}
								_endPos = getPos _x
							}
						} forEach allPlayers;
						_textNotif = format ["Admin: Teleporting to %1...", _selectedPlayerName];
						cutText [_textNotif, "PLAIN DOWN", 0, true, false];
						(format ["Admin: Player %1 has teleported to %2.",Admin_myName,_selectedPlayerName]) remoteExec ["systemChat",0] 
					};

					Admin_fnc_TP_playerToSelf = 
					{
						params["_selectedPlayerName"];
						{
							if ((name _x) == (_selectedPlayerName)) then 
							{
								_textNotif = format ["Admin: Teleporting to %1...", Admin_myName];
								cutText [_textNotif, "PLAIN DOWN", 0, true, false];
								_startPos = getPos _x;
								moveOut _x;
								(vehicle _x) setPos (getPos player);
								comment "If you are in vehicle, move player in...";
								if ((vehicle _x == _x) && (vehicle player != player)) then
								{ 
									_x moveInAny (vehicle player);
								} 
								_endPos = getPos _x;
							}
						} forEach allPlayers;
						(format ["Admin: Player %1 has teleported to %2.",_selectedPlayerName,Admin_myName]) remoteExec ["systemChat",0]
					};
					
					Admin_fnc_TP_allToSelf = 
					{
						_textNotif = format ["Admin: Teleporting all players to %1...", Admin_myName];
						[_textNotif, "PLAIN DOWN", 0, true, false] remoteExec ["cutText", 0];
						Admin_myCurrentPosition = getPos player;
						{
							[[Admin_myCurrentPosition,Admin_myName],{
							
								_pos = _this select 0;
								_name = _this select 1;
								moveOut player;
								sleep 1;
								player setPos _pos;
								(format ["Admin: Player %1 has teleported to %2.",(name player), _name]) remoteExec ["systemChat",0]
							
							}] remoteExec ["spawn",_x]
					
						} forEach allPlayers - AllCurators
					};
					
					Admin_fnc_assignGameMod = 
					{ 
						params["_specifiedPlayerName"];
						_textNotif = format ["Admin: Assigning Game Moderator to %1...", _specifiedPlayerName];
						[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
						{
							if ((name _x) == _specifiedPlayerName) then {
								VVN_x2 = (vehicleVarName _x);
								(format ["Admin: Player %1 has been selected as the new Zeus (Game Moderator Slot).",(name _x)]) remoteExec ["systemChat",0];
								[["<t color='#42D6FC'>YOU ARE NOW ZEUS (Game Moderator)</t><br/><t color='#58D68D'>-Press [Y] to open/close curator interface-</t>", "PLAIN", -1, true, true]] remoteExec ["titleText", _x]
							}
						} forEach allPlayers;
						
						_text = "[[],{unassignCurator bis_curator_1;}] remoteExec ['spawn',2];[[],{" + VVN_x2 + " assignCurator bis_curator_1;}] remoteExec ['spawn',2];";
						_code = compile _text;
						_result = [] call _code
					};
					
					Admin_fnc_assignGameMaster = 
					{
						params["_specifiedPlayerName"];
						_textNotif = format ["Admin: Assigning Game Master to %1...", _specifiedPlayerName];
						[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
						{
							if ((name _x) == _specifiedPlayerName) then 
							{
								VVN_x1 = (vehicleVarName _x);
								(format ["Admin: Player %1 has been selected as the new Game Master Slot (Zeus Slot).",(name _x)]) remoteExec ["systemChat",0];
								[["<t color='#42D6FC'>You Are Now Game Master (Zeus)!</t><br/><t color='#58D68D'>-Press [Y] to open/close curator interface-</t>", "PLAIN", -1, true, true]] remoteExec ["titleText", _x]
							}
						} forEach allPlayers;

						_text = "[[],{unassignCurator bis_curator;}] remoteExec ['spawn',2];[[],{" + VVN_x1 + " assignCurator bis_curator;}] remoteExec ['spawn',2];";
						_code = compile _text;
						_result = [] call _code
					};

					Admin_fnc_transferAdmin = 
					{
						newAdmin = _this select 0;
						_textNotif = format ["Admin: Transferring administration to %1...", newAdmin];
						[[_textNotif, "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
						[[newAdmin],
						{
							newAdmin = _this select 0;
							disableSerialization;
							d_adminTransfer = (findDisplay 46) createDisplay "RscDisplayEmpty";
							showChat true;
							_mouseDetection2 = d_adminTransfer ctrlCreate ["RscButton", 8888];
							_mouseDetection2 ctrlSetPosition [-0.000156274 * safezoneW + safezoneX,-0.00599999 * safezoneH + safezoneY,1.00547 * safezoneW,1.023 * safezoneH];
							_mouseDetection2 ctrladdEventHandler ["MouseMoving",
							" serverCommand format ['#Vote Admin %1', newAdmin] d_adminTransfer closeDisplay 0 "];
							_mouseDetection2 ctrlSetBackgroundColor [0,0,0,0] _mouseDetection2 ctrlCommit 0 
						}] remoteExec ["spawn",-2];
						(format ["Admin: Administration has been passed from %1 to %2.",Admin_myName,_specifiedPlayerName]) remoteExec ["systemChat",0];
						{
							[[], {hint "Press Y to re-open Zeus interface."}] remoteExec ["spawn",_x]
						} forEach allCurators 
					};
				comment "----------------------------"; 
				comment "-----GLOBAL FUNCTIONS------";
				comment "----------------------------"; 
					Admin_fnc_disableFatigueGlobal = 
					{
						if (isNil "fatigueTgglGlobal") then {fatigueTgglGlobal = 1;};
						if (fatigueTgglGlobal == 1) then {
							comment "Init Start";
							[["InfStam"],
							{Admin_toggle_cardioGlobal = {
								if (isNil 'cardioTggleGlobal') then {cardioTggleGlobal = 1};
								if (cardioTggleGlobal == 1) then {cardioTggleGlobal = 0;
									titleText ["<t color='#42D6FC'>Infinite Stamina </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] player enableFatigue false;
									EH_noFatigue = player addEventHandler ["Respawn", { player enableFatigue false }] Hint "Admin: EH added (Fatigue Disabled)."
								} else {cardioTggleGlobal = 1 player enableFatigue true;
									titleText ["<t color='#42D6FC'>Infinite Stamina </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] player removeEventHandler ["Respawn", EH_noFatigue];
									Hint "Admin: EH Removed (Fatigue Enabled)." }} [] call Admin_toggle_cardioGlobal}] remoteExec ["spawn", 0, "Admin_CardioJIP"];
							comment "Init Done" 
							fatigueTgglGlobal = 0;
						} else {
							comment "Toggle Off";
							[[],{ [] call Admin_toggle_cardioGlobal }] remoteExec ["spawn", 0];
							comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"Admin_CardioJIP"] fatigueTgglGlobal = 1 
						}
					};
					Admin_fnc_show3DPlayerNames =
					{
							if (isNil "shw3DPlrNmTggl") then {shw3DPlrNmTggl = 1;}	if (shw3DPlrNmTggl == 1) then {comment "Init Start" [["shw3DPlrNmJIP"],
						{ Admin_fini_fnc_compile3 = {(with missionNamespace do compile (_this select 0))};
							Admin_toggle_allPlayers3DESP = { if (isNil 'Admin_tggl_Glbl3DESP') then {Admin_tggl_Glbl3DESP = 1};
									if (Admin_tggl_Glbl3DESP == 1) then {Admin_tggl_Glbl3DESP = 0;
									titleText ["<t color='#42D6FC'>ShowPlayerNames </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint";
									[(" MissionEH_3DESP = addMissionEventHandler ['Draw3D',
										{{if (((player distance _x) < 1500) && (_x != player)) then {
											drawIcon3D ['', [1, 1, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]}} forEach allPlayers}] ")] call Admin_fini_fnc_compile3;
								} else {
									Admin_tggl_Glbl3DESP = 1;
									titleText ["<t color='#42D6FC'>ShowPlayerNames </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true]	playSound "Hint";
									[("removeMissionEventHandler['Draw3D',MissionEH_3DESP];")] call Admin_fini_fnc_compile}} [] call Admin_toggle_allPlayers3DESP}] remoteExec ["spawn", 0, "shw3DPlrNmJIP"];
							comment "Init Done";
							shw3DPlrNmTggl = 0;
						} else {comment "Toggle Off";
							[[],{ [] call Admin_toggle_allPlayers3DESP}] remoteExec ["Spawn", 0];
							comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"shw3DPlrNmJIP"] shw3DPlrNmTggl = 1 }};
					Admin_fnc_showPlayersOnMap = 
					{
						if (isNil "shwPlyrsOnMapTggl") then {shwPlyrsOnMapTggl = 1;};
							if (shwPlyrsOnMapTggl == 1) then {comment "Init Start" [["ShwPlyrsOnMapJIP"], {Admin_fini_fnc_plrs2 = { _players = [] _all = player nearEntities [['Man','Land','Air','Ship'], 25000] {
						if ((_x isKindOf "Man") && (getPlayerUID _x != "")) then {_players pushBack _x;
							} else {
									if ((count crew _x) != 0) then {for "_i" from 0 to (count crew _x)-1 do {_l = (crew _x) select _i;
									if (getPlayerUID _l != "") then { _players pushBack _l }}}}} forEach (_all - allCurators) _players};
								
							Admin_fini_fnc_compile2 = {(with missionNamespace do compile (_this select 0))};
							Admin_mesp = { if (isNil "mespTggle") then {mespTggle = 1}; 	
									if (mespTggle == 1) then { playSound "Hint";
										titleText ["<t color='#42D6FC'>MAPESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] mespTggle = 0 } else {playSound "Hint";
										titleText ["<t color='#42D6FC'>MAPESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] mespTggle = 1 };
								[] spawn {[(" while {mespTggle == 0} do { _units = call Admin_fini_fnc_plrs2 _unitCount = count _units for '_i' from 0 to (_unitCount-1) 
														do { _unit = _units select _i;
									if (alive _unit) then { deleteMarkerLocal('Admin_plr' + (str _i));
										_namePlayer = name _unit;
										_mark_player = 'Admin_plr' + (str _i);
										_mark_player = createMarkerLocal[_mark_player, getPos _unit];
										_mark_player setMarkerTypeLocal 'wayPoint';
										_mark_player setMarkerPosLocal(getPos _unit);
										_mark_player setMarkerColorLocal 'ColorBlue';
										_mark_player setMarkerTextLocal format['%1 - %2', _namePlayer, round(player distance _unit)]}} sleep 0.5};
										for '_i' from 0 to 500 do {deleteMarkerLocal('Admin_plr' + (str _i))} ")] call Admin_fini_fnc_compile2 }}
								[] call Admin_mesp }] remoteExec ["spawn", 0, "mapEsp"] comment "Init Done" playSound "Hint";
							titleText ["<t color='#42D6FC'>MAP-ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] shwPlyrsOnMapTggl = 0;
						} else { comment "Toggle Off" [[],{ [] call Admin_mesp }] remoteExec ["spawn", 0] comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"mapEsp"] playSound "Hint";
							titleText ["<t color='#42D6FC'>MAP-ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] shwPlyrsOnMapTggl = 1 }};
					Admin_open_utils = 
					{
						hint "Nothing to see here yet."};
					Admin_toggle_whiteListing = 
					{
						if (!Admin_whiteListEnabled) then {Admin_whiteListEnabled = true hint "Admin: Whitelist Enabled.";
						} else { Admin_whiteListEnabled = false	hint "Admin: Whitelist Disabled." }};
					Admin_fnc_clearDead = 
					{
						[["Admin: Deleting all dead objects...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0] _countUpTheDead = 0 _deadObjects = 0;
						{ deleteVehicle _x; _deadObjects = _deadObjects + 1; } forEach allDead;
						{ deleteVehicle _x; _countUpTheDead = _countUpTheDead + 1; } forEach allDeadMen;
						(format ["A grim total of %1 dead objects have been removed from the battlefield. Of those, %2 were dead soldiers.", _deadObjects, _countUpTheDead]) remoteExec ["hint", 0]};
					Admin_fnc_AASJIP = 
					{
						if (isNil "AASJIPTggl") then {AASJIPTggl = 1};
									if (AASJIPTggl == 1) then {comment "toggle on";
							[["Admin: Applying Respawn Arsenal...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
							[[],{EH_AASJIP = player addEventHandler ["Respawn", { [] spawn { action_openArsenal = player addAction ["Admin: <t color='#42D6FC'>Open Arsenal (1x)</t>", 
									{ ["Preload"] call BIS_fnc_arsenal ["Open",true] spawn BIS_fnc_arsenal;
									titleText ["<t color='#42D6FC'>Arsenal Script <t color='#FFFFFF' size='2'>by</t><t color='#42D6FC'> Admin</t><br/><t color='#58D68D'>-Press ESC to exit Arsenal-</t>", "PLAIN DOWN", -1, true, true];
									player removeAction action_openArsenal}] sleep 20 player removeAction action_openArsenal;
							}}]}] remoteExec ["spawn",0,"AASJIP"] comment "Init Done" playSound "Hint";
							titleText ["<t color='#42D6FC'>AAS-JIP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN", -1, true, true] AASJIPTggl = 0;
						} else { comment "Toggle Off" [["Admin: Removing respawn-arsenal (JIP)...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0];
							[[],{ player removeEventHandler ["Respawn", EH_AASJIP] player removeAction action_openArsenal }] remoteExec ["spawn",0];
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"AASJIP"] comment "Init Done";
							playSound "Hint";
							titleText ["<t color='#42D6FC'>AAS-JIP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN", -1, true, true];
							AASJIPTggl = 1 }};
					Admin_fnc_updateZeusObj = 
					{
						[["Admin: New objects are being adding to Game Master (Zeus) interface...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", player];
						[["Admin: New objects are being adding to Game Master (Zeus) interface...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", allCurators];
						[[],{{  _x addCuratorEditableObjects [nearestObjects [(position _x), ["All"], 35000],true];
							_x addCuratorEditableObjects [allUnits,true] _x addCuratorEditableObjects [vehicles,true]; 
							_x addCuratorEditableObjects [allPlayers,true]} forEach allCurators }] remoteExec ["spawn", 2];
						Hint "Admin: Game Master (Zeus) interface has been updated with new objects." };
					Admin_fnc_viewDistance = 
					{ 
						removeAllActions player;
						player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player;}];
						player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player; [] spawn Admin_open_serverMenu;}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>12km</t>", {12000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>6km</t>", {6000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>4km</t>", {4000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>3km</t>", {3000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>2km</t>", {2000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>VD: </t><t color='#82E0AA'>1km</t>", {1000 remoteExec ["setViewDistance",0,"Admin_VD"];}];
						hint "Admin: Use the scroll wheel to set view distance." };
					Admin_fnc_respawnAll = 
					{
						[["Admin: Re-spawning all players...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0] _countPlayers = 0;
						{ forceRespawn _x; _countPlayers = _countPlayers + 1; } forEach allPlayers - allCurators;
						Hint format ["[%1] Players have been forced to respawn.", _countPlayers]};
					Admin_fnc_deleteAll = 
					{ 
						[["Admin: Deleting all objects on server...", "PLAIN DOWN", 0, true, false]] remoteExec ["cutText", 0] _countObjects = 0;
						{if (!(typeOf _x == "ModuleCuratorAddEditingAreaPlayers_F") && !(typeOf _x == "ModuleCurator_F") && !(typeOf _x == "ModuleMPTypeGameMaster_F")) then {
							deleteVehicle _x; _countObjects = _countObjects + 1 }} forEach nearestObjects [player, ["all"], 35000] + (allUnits - allPlayers);
						Hint format ["[%1] objects have been deleted.", _countObjects]};
					Admin_fnc_3DTP = 
					{ 
						(vehicle player) setPos (screenToWorld [0.5, 0.5])};
					Admin_open_arsenalMenu = 
					{ 
						disableSerialization d_arsenalMenu = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true; comment "Fixes Chat Bug";
						ctrl_arsbckrndMain = d_arsenalMenu ctrlCreate ["RscText", 8765];
						ctrl_arsbckrndMain ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.118594 * safezoneW,0.132 * safezoneH];
						ctrl_arsbckrndMain ctrlSetBackgroundColor [-1,-1,-1,0.5];
						ctrl_arsbckrndMain ctrlCommit 0;
						ctrl_background2 = d_arsenalMenu ctrlCreate ["RscText", 8766];
						ctrl_background2 ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.0928125 * safezoneW,0.033 * safezoneH];
						ctrl_background2 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						ctrl_background2 ctrlCommit 0;
						ctrl_background3 = d_arsenalMenu ctrlCreate ["RscText", 8767];
						ctrl_background3 ctrlSetPosition [0.469062 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.0670312 * safezoneW,0.033 * safezoneH];
						ctrl_background3 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						ctrl_background3 ctrlCommit 0;
						ctrl_background4 = d_arsenalMenu ctrlCreate ["RscText", 8768];
						ctrl_background4 ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.118594 * safezoneW,0.022 * safezoneH];
						ctrl_background4 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						ctrl_background4 ctrlCommit 0;
						ctrl_cancelClose = d_arsenalMenu ctrlCreate ["RscButtonMenu", 8769];
						ctrl_cancelClose ctrlSetText "cursorTarget";
						ctrl_cancelClose ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.0464063 * safezoneW,0.022 * safezoneH];
						ctrl_cancelClose ctrladdEventHandler ["ButtonClick", {d_arsenalMenu closeDisplay 0 onEachFrame {if (name cursorTarget == "Error: No unit") then {
									drawIcon3D ['A3\ui_f_curator\Data\CfgCurator\entity_disabled_ca.paa', [0,1,1,1], [visiblePosition cursorTarget select 0, visiblePosition cursorTarget select 1, (getPosATL cursorTarget select 2) + 1], 1, 1, 0, typeOf cursorTarget, 2, 0.05, 'PuristaMedium', 'center', false];
								} else {
									drawIcon3D ['A3\ui_f_curator\Data\CfgCurator\entity_disabled_ca.paa', [0,1,1,1], [visiblePosition cursorTarget select 0, visiblePosition cursorTarget select 1, (getPosATL cursorTarget select 2) + 1], 1, 1, 0, name cursorTarget, 2, 0.05, 'PuristaMedium', 'center', false]}};
							[] spawn {waitUntil {!alive player} onEachFrame {}} removeAllActions player;
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>[+]Arsenal</t>", {
								["AmmoboxInit",[cursorTarget,true]] call BIS_fnc_arsenal;
								Hint format ["[%1] (%2) is now a full arsenal.", (name cursorTarget), (typeOf cursorTarget)]}];
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {onEachFrame {} removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {onEachFrame {} removeAllActions player [] spawn Admin_open_arsenalMenu }];
							hint "Admin: Their is an Arsenal in scroll menu." }];
						ctrl_cancelClose ctrlCommit 0;
						ctrl_openarsbtn = d_arsenalMenu ctrlCreate ["RscShortcutButton", 8770];
						ctrl_openarsbtn ctrlSetText "OPEN";
						ctrl_openarsbtn ctrlSetPosition [0.448438 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.0515625 * safezoneW,0.055 * safezoneH];
						ctrl_openarsbtn ctrladdEventHandler ["ButtonClick", {[] spawn {
							["Preload"] call BIS_fnc_arsenal d_arsenalMenu closeDisplay 0;
							["Open",true] spawn BIS_fnc_arsenal }}];
						ctrl_openarsbtn ctrlCommit 0;
						ctrl_spawnarsbtn = d_arsenalMenu ctrlCreate ["RscShortcutButton", 8771];
						ctrl_spawnarsbtn ctrlSetText "SPAWN";
						ctrl_spawnarsbtn ctrlSetPosition [0.505156 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.0515625 * safezoneW,0.055 * safezoneH];
						ctrl_spawnarsbtn ctrladdEventHandler ["ButtonClick", {d_arsenalMenu closeDisplay 0;
							[] spawn {player playMove 'ainvpercmstpsraswrfldnon_putdown_amovpercmstpsraswrfldnon';
								_flagpole = createVehicle ["Flag_ARMEX_F",getPos player,[],0,"NONE"];
								_flagpole setDir direction player;
								_flagpole allowDamage false;
								Admin_arsenalMenu_box = createVehicle ["B_supplyCrate_F",getPos player,[],0,"NONE"];
								["AmmoboxInit",[Admin_arsenalMenu_box,true]] call BIS_fnc_arsenal;
								Admin_arsenalMenu_box allowDamage false;
								Admin_arsenalMenu_box setDir direction player;
								Admin_arsenalMenu_box attachTo [_flagpole, [-0.1,-0.4,-3.2]];
								Admin_arsenalMenu_arsenalPos = getPos Admin_arsenalMenu_box;
								Admin_arsenalMenu_arsenalGRID = mapGridPosition Admin_arsenalMenu_box;
								[[Admin_arsenalMenu_arsenalPos,Admin_arsenalMenu_arsenalGRID],{
									_pos = _this select 0;
									_grid = _this select 1;
									_arsenalLocation = createLocation [ "ViewPoint" , _pos, 10, 10];
									hint (format ["__________High Command__________\nArsenal supply box has been airdropped.\n____________GRID: %1____________", _grid]);
									_arsenalLocation setText " Arsenal " }] remoteExec ["spawn",0]}}];
						ctrl_spawnarsbtn ctrlCommit 0;
						ctrl_menuTitle = d_arsenalMenu ctrlCreate ["RscText", 8772];
						ctrl_menuTitle ctrlSetText "Admin       Arsenal Menu           ";
						ctrl_menuTitle ctrlSetPosition [0.443281 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.118594 * safezoneW,0.011 * safezoneH];
						ctrl_menuTitle ctrlSetBackgroundColor [-1,-1,-1,0];
						ctrl_menuTitle ctrlCommit 0;
						ctrl_xClose = d_arsenalMenu ctrlCreate ["RscButton", 8773];
						ctrl_xClose ctrlSetText "X";
						ctrl_xClose ctrlSetPosition [0.536094 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.0257812 * safezoneW,0.033 * safezoneH];
						ctrl_xClose ctrladdEventHandler ["ButtonClick", { d_arsenalMenu closeDisplay 0 }];
						ctrl_xClose ctrlCommit 0 };
					Admin_fini_fnc_plrs = 
					{ 
						_players = [] _all = player nearEntities [['Man','Land','Air','Ship'], 25000];
						{if ((_x isKindOf "Man") && (getPlayerUID _x != "")) then { _players pushBack _x;
							} else { if ((count crew _x) != 0) then { for "_i" from 0 to (count crew _x)-1 do { _l = (crew _x) select _i if (getPlayerUID _l != "") then { _players pushBack _l }}}}} forEach _all _players}
					Admin_fini_fnc_hostileAI = 
					{ 
						_hostileai = [] { if ((_x isKindOf "Man") && (side _x != side player)) then { _hostileai pushBack _x;
							} else {
								if ((count crew _x) != 0) then { for "_i" from 0 to (count crew _x)-1 do { _l = (crew _x) select _i;
							if (side _l != side player) then { _hostileai pushBack _l;
								}}}}} forEach allUnits - allPlayers _hostileai};
					Admin_fini_fnc_compile = 
					{ 
						(with missionNamespace do compile (_this select 0))};
					Admin_fnc_unflip = 
					{ 
						params ["_vehicle"] _vehicle = _this _pos = getPosATL _vehicle pos set [2, 7] _vehicle setPosATL _pos _vehicle setVectorUp [0,0,1]};
				comment "----------------------------"; 
				comment "--------MAIN MENU GUI-------";
				comment "----------------------------";
					Admin_open_mainMenu = 
					{
						disableSerialization;
						d_mainMenu = (findDisplay 46) createDisplay "RscDisplayEmpty";
						showChat true; 
						comment "Fixes Chat Bug";
						mainFrame_user = d_mainMenu ctrlCreate ["RscFrame", 7005];
						mainFrame_user ctrlSetText format ["USER: %1", Admin_myName];
						mainFrame_user ctrlSetTextColor Admin_fColor;
						mainFrame_user ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.17 * safezoneH + safezoneY,0.391875 * safezoneW,0.088 * safezoneH];
						mainFrame_user ctrlCommit 0;
						mainFrame_title = d_mainMenu ctrlCreate ["RscStructuredText", 7006];
						mainFrame_title ctrlSetStructuredText parseText "<t color='#00ffffff' shadow='2' size='2' align='center' font='PuristaBold'>Admin Menu <t font='RobotoCondensed'>V<t color='#E0E0E0'>1.6<t color='#FFFFFF'>A</t>";
						mainFrame_title ctrlSetPosition [0.309219 * safezoneW + safezoneX,0.181 * safezoneH + safezoneY,0.376406 * safezoneW,0.055 * safezoneH];
						mainFrame_title ctrlSetBackgroundColor [0,0,0,0];
						mainFrame_title ctrlCommit 0;
						fadeInTitle1 = [] spawn { for [{_i=1}, {_i<9}, {_i=_i+1}] do
						{ mainFrame_title ctrlSetStructuredText parseText (format ["<t color='#0%1ffffff' shadow='2' size='2' align='center' font='PuristaBold'>Admin Menu <t font='RobotoCondensed'>V<t color='#E0E0E0'>1.6<t color='#FFFFFF'>A</t>", _i]) sleep 0.001 }};
						fadeInTitle2 = [] spawn { waitUntil { scriptDone fadeInTitle1 } for [{_i=10}, {_i<101}, {_i=_i+1}] do {
						mainFrame_title ctrlSetStructuredText parseText (format ["<t color='#%1ffffff' shadow='2' size='2' align='center' font='PuristaBold'>Admin Menu <t font='RobotoCondensed'>V<t color='#E0E0E0'>1.6<t color='#FFFFFF'>A</t>", _i]) sleep 0.001}};
						mainFrame_backgroundLeft = d_mainMenu ctrlCreate ["RscText", 7007];
						mainFrame_backgroundLeft ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.269 * safezoneH + safezoneY,0.108281 * safezoneW,0.341 * safezoneH];
						mainFrame_backgroundLeft ctrlSetBackgroundColor [0,0,0,0.5];
						mainFrame_backgroundLeft ctrlCommit 0;
						mainFrame_backgroundMiddle = d_mainMenu ctrlCreate ["RscText", 7008];
						mainFrame_backgroundMiddle ctrlSetPosition [0.422656 * safezoneW + safezoneX,0.269 * safezoneH + safezoneY,0.154687 * safezoneW,0.341 * safezoneH];
						mainFrame_backgroundMiddle ctrlSetBackgroundColor [0,0,0,0.5];
						mainFrame_backgroundMiddle ctrlCommit 0;
						mainFrame_backgroundRight = d_mainMenu ctrlCreate ["RscText", 7009];
						mainFrame_backgroundRight ctrlSetPosition [0.587656 * safezoneW + safezoneX,0.269 * safezoneH + safezoneY,0.108281 * safezoneW,0.341 * safezoneH];
						mainFrame_backgroundRight ctrlSetBackgroundColor [0,0,0,0.5];
						mainFrame_backgroundRight ctrlCommit 0;
						playerList_title = d_mainMenu ctrlCreate ["RscStructuredText", 7010];
						playerList_title ctrlSetStructuredText parseText "<t align='center'>PLAYER LIST</t>";
						playerList_title ctrlSetPosition [0.304063 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.108281 * safezoneW,0.022 * safezoneH];	
						playerList_title ctrlSetBackgroundColor Admin_tColor;
						playerList_title ctrlCommit 0;
						menuSelection_title = d_mainMenu ctrlCreate ["RscStructuredText", 7011];
						menuSelection_title ctrlSetStructuredText parseText "<t align='center'>MENU SELECTION</t>";
						menuSelection_title ctrlSetPosition [0.422656 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.154687 * safezoneW,0.022 * safezoneH];	
						menuSelection_title ctrlSetBackgroundColor Admin_tColor;
						menuSelection_title ctrlCommit 0;
						quickScripts_title = d_mainMenu ctrlCreate ["RscStructuredText", 7012];
						quickScripts_title ctrlSetStructuredText parseText "<t align='center'>QUICK SCRIPTS</t>";
						quickScripts_title ctrlSetPosition [0.587656 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.108281 * safezoneW,0.022 * safezoneH];	
						quickScripts_title ctrlSetBackgroundColor Admin_tColor;
						quickScripts_title ctrlCommit 0;
						playerList_listBox = d_mainMenu ctrlCreate ["RscListbox", 7013];
						playerList_listBox ctrlSetPosition [0.309219 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.0979687 * safezoneW,0.319 * safezoneH] { _pL_index = playerList_listBox lbAdd  name _x; } forEach allPlayers;
						playerList_listBox ctrlCommit 0;
						menuSelection_listBox = d_mainMenu ctrlCreate ["RscListbox", 7014];
						menuSelection_listBox ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.144375 * safezoneW,0.253 * safezoneH];
						menuSelection_listBox ctrlCommit 0;
						MMG_mL_lb_Arsenal =		menuSelection_listBox lbAdd "ArsenalMenu";
						MMG_mL_lb_Target =		menuSelection_listBox lbAdd "TargetMenu";
						MMG_mL_lb_Player =		menuSelection_listBox lbAdd "PlayerMenu";
						MMG_mL_lb_Vehicle =		menuSelection_listBox lbAdd "VehicleMenu";
						MMG_mL_lb_CustomVehicles =	menuSelection_listBox lbAdd "CustomVehicles";
						MMG_mL_lb_Cheat =		menuSelection_listBox lbAdd "CheatMenu";
						MMG_mL_lb_Dev =			menuSelection_listBox lbAdd "DevMenu*";
						MMG_mL_lb_Server =		menuSelection_listBox lbAdd "ServerMenu";
						MMG_mL_lb_SpawnMenu =		menuSelection_listBox lbAdd "SpawnMenu";
						menuSelection_listBox lbSetColor [MMG_mL_lb_Arsenal, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Target, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Player, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Vehicle, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_CustomVehicles, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Cheat, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Dev, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_Server, [1, 1, 1, 1]];
						menuSelection_listBox lbSetColor [MMG_mL_lb_SpawnMenu, [1, 1, 1, 1]];
						menuSelection_openButton = d_mainMenu ctrlCreate ["RscButton", 7015];
						menuSelection_openButton ctrlSetText "OPEN";
						menuSelection_openButton ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.144375 * safezoneW,0.055 * safezoneH];
						menuSelection_openButton ctrlSetBackgroundColor [0, 0, 0, 0.6];
						menuSelection_openButton ctrlSetEventHandler ["ButtonClick", " 
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Arsenal) then { d_mainMenu closeDisplay 0 [] spawn Admin_open_arsenalMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Target) then { d_mainMenu closeDisplay 0 Hint 'TargetMenu Activated. Scroll for actions.' [] call Admin_toggle_targetOverlay [] call Admin_open_targetMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Player) then { d_mainMenu closeDisplay 0 Hint 'PlayerMenu Activated. Scroll for actions.' [] call Admin_open_playerMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Vehicle) then { d_mainMenu closeDisplay 0 Hint 'VehicleMenu Activated. Scroll for actions.' [] call Admin_open_vehicleMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_CustomVehicles) then { d_mainMenu closeDisplay 0 Hint 'CustomVehicles Spawn Menu Activated. Scroll for actions.' [] call Admin_open_CustomVehicles };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Cheat) then { d_mainMenu closeDisplay 0 Hint 'CheatMenu Activated. Scroll for actions.'[] call Admin_open_cheatMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Dev) then { hint 'ERROR: Menu is not yet finished.'};
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_Server) then { d_mainMenu closeDisplay 0 [] spawn Admin_open_serverMenu };
							If (menuSelection_listBox lbIsSelected MMG_mL_lb_SpawnMenu) then { d_mainMenu closeDisplay 0 [] spawn Admin_fnc_OpenVehUI }"];
						menuSelection_openButton ctrlCommit 0;
						quickScipts_SERVERMUTE = d_mainMenu ctrlCreate ["RscButton", 7500];
						quickScipts_SERVERMUTE ctrlSetText "MUTE";
						quickScipts_SERVERMUTE ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.0464063 * safezoneW,0.022 * safezoneH];
						quickScipts_SERVERMUTE ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_mutePlayer d_mainMenu closeDisplay 0 "];
						quickScipts_SERVERMUTE ctrlSetTooltip "Disable communication of player.";
						quickScipts_SERVERMUTE ctrlCommit 0;
						quickScipts_SERVERUNMUTE = d_mainMenu ctrlCreate ["RscButton", 7501];
						quickScipts_SERVERUNMUTE ctrlSetText "UNMUTE";
						quickScipts_SERVERUNMUTE ctrlSetPosition [0.639219 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.0515625 * safezoneW,0.022 * safezoneH];
						quickScipts_SERVERUNMUTE ctrladdEventHandler ["ButtonClick", "_selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_unmutePlayer d_mainMenu closeDisplay 0 "];
						quickScipts_SERVERUNMUTE ctrlSetTooltip "Enable communication of player.";
						quickScipts_SERVERUNMUTE ctrlCommit 0;
						quickScipts_AUTOKICKBAN = d_mainMenu ctrlCreate ["RscButton", 7017];
						quickScipts_AUTOKICKBAN ctrlSetText "AUTOKICK";
						quickScipts_AUTOKICKBAN ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0515625 * safezoneW,0.022 * safezoneH];
						quickScipts_AUTOKICKBAN ctrladdEventHandler ["ButtonClick", { hint "Admin: Error - The auto-kick button has been disabled in this version due to reports of game crashes.\n 
							If you still wish to use it, type this command in the debug console with the desired player name:\n 
							[playerNameInQuotes] call Admin_fnc_autoKickPlayer;\n
							You can always check back on the steam guide for Admin to see if the latest update fixes this issue." }];
						quickScipts_AUTOKICKBAN ctrlSetTooltip "Permanently ban player with message.";
						quickScipts_AUTOKICKBAN ctrlCommit 0;
						quickScipts_BAN = d_mainMenu ctrlCreate ["RscButton", 7018];
						quickScipts_BAN ctrlSetText "BAN";
						quickScipts_BAN ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0464063 * safezoneW,0.022 * safezoneH];
						quickScipts_BAN ctrladdEventHandler ["ButtonClick", "_selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_experimentalBan "];
						quickScipts_BAN ctrlSetTooltip "Trigger ban via BE restriction.";
						quickScipts_BAN ctrlCommit 0;
						quickScipts_WHITELIST = d_mainMenu ctrlCreate ["RscButton", 7019];
						quickScipts_WHITELIST ctrlSetText "WHITELIST PLAYER";
						quickScipts_WHITELIST ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.346 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_WHITELIST ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_whitelistPlayer "];
						quickScipts_WHITELIST ctrlSetTooltip "Add player to whitelist.";
						quickScipts_WHITELIST ctrlCommit 0;
						quickScipts_FREEZE = d_mainMenu ctrlCreate ["RscButton", 7020];
						quickScipts_FREEZE ctrlSetText "FREEZE PLAYER";
						quickScipts_FREEZE ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_FREEZE ctrladdEventHandler ["ButtonClick", "_selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_freezePlayer "];
						quickScipts_FREEZE ctrlSetTooltip "Disable/Enable player input.";
						quickScipts_FREEZE ctrlCommit 0;
						quickScipts_TPSELFTOPLAYER = d_mainMenu ctrlCreate ["RscButton", 7021];
						quickScipts_TPSELFTOPLAYER ctrlSetText "TP Self-To-Player";
						quickScipts_TPSELFTOPLAYER ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_TPSELFTOPLAYER ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_TP_selfToPlayer "];
						quickScipts_TPSELFTOPLAYER ctrlCommit 0;
						quickScipts_TPPLAYERTOSELF = d_mainMenu ctrlCreate ["RscButton", 7022];
						quickScipts_TPPLAYERTOSELF ctrlSetText "TP Player-To-Self";
						quickScipts_TPPLAYERTOSELF ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.445 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_TPPLAYERTOSELF ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_TP_playerToSelf "];
						quickScipts_TPPLAYERTOSELF ctrlCommit 0;
						quickScipts_GIVEARSENAL = d_mainMenu ctrlCreate ["RscButton", 7023];
						quickScipts_GIVEARSENAL ctrlSetText "Give Arsenal (1x)";
						quickScipts_GIVEARSENAL ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.478 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_GIVEARSENAL ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_giveArsenal "];
						quickScipts_GIVEARSENAL ctrlCommit 0;
						quickScipts_ASSIGNGAMEMASTER = d_mainMenu ctrlCreate ["RscButton", 7024];
						quickScipts_ASSIGNGAMEMASTER ctrlSetText "ASSIGN GAMEMASTER";
						quickScipts_ASSIGNGAMEMASTER ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.511 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_ASSIGNGAMEMASTER ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_assignGameMaster "];
						quickScipts_ASSIGNGAMEMASTER ctrlCommit 0;
						quickScipts_ASSIGNGAMEMOD = d_mainMenu ctrlCreate ["RscButton", 7025];
						quickScipts_ASSIGNGAMEMOD ctrlSetText "ASSIGN GAMEMOD";
						quickScipts_ASSIGNGAMEMOD ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_ASSIGNGAMEMOD ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_assignGameMod "];
						quickScipts_ASSIGNGAMEMOD ctrlCommit 0;
						quickScipts_TRANSFERADMIN = d_mainMenu ctrlCreate ["RscButton", 7026];
						quickScipts_TRANSFERADMIN ctrlSetText "TRANSFER ADMIN";
						quickScipts_TRANSFERADMIN ctrlSetPosition [0.592812 * safezoneW + safezoneX,0.577 * safezoneH + safezoneY,0.0979687 * safezoneW,0.022 * safezoneH];
						quickScipts_TRANSFERADMIN ctrladdEventHandler ["ButtonClick", " _selectedItem = lbCurSel playerList_listBox [playerList_listBox lbText _selectedItem] call Admin_fnc_transferAdmin ];
						quickScipts_TRANSFERADMIN ctrlCommit 0;
						scriptTarget_title = d_mainMenu ctrlCreate ["RscStructuredText", 7027];
						scriptTarget_title ctrlSetStructuredText parseText "<t font='PuristaMedium'>TARGET</t>";
						scriptTarget_title ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.621 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						scriptTarget_title ctrlSetBackgroundColor Admin_tColor;
						scriptTarget_title ctrlCommit 0;
						console_title = d_mainMenu ctrlCreate ["RscStructuredText", 7028];
						console_title ctrlSetStructuredText parseText "<t shadow='0' font='PuristaMedium'>Debug console</t><t align='center'>-</t><t align='right'> was created by J-Wolf and E1.</t>";
						console_title ctrlSetPosition [0.365937 * safezoneW + safezoneX,0.621 * safezoneH + safezoneY,0.273281 * safezoneW,0.022 * safezoneH];
						console_title ctrlSetBackgroundColor Admin_tColor;
						console_title ctrlCommit 0;
						console_backgound = d_mainMenu ctrlCreate ["RscText", 7029];
						console_backgound ctrlSetPosition [0.365937 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.273281 * safezoneW,0.121 * safezoneH];
						console_backgound ctrlsetbackgroundColor [0,0,0,0.5];
						console_backgound ctrlCommit 0;
						console_inputBox = d_mainMenu ctrlCreate ["RscEdit", 7030];
						console_inputBox ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.676 * safezoneH + safezoneY,0.262969 * safezoneW,0.066 * safezoneH];
						console_inputBox ctrlSetBackgroundColor [0,0,0,0.3];
						console_inputBox ctrlSetTooltip "Paste SQF script here.";
						console_inputBox ctrlCommit 0;
						console_outputBox = d_mainMenu ctrlCreate ["RscText", 7031];
						console_outputBox ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.262969 * safezoneW,0.022 * safezoneH];
						console_outputBox ctrlSetBackgroundColor [0,0,0,0.8];
						console_outputBox ctrlCommit 0;
						console_executeText = d_mainMenu ctrlCreate ["RscStructuredText", 7032];
						console_executeText ctrlSetStructuredText parseText "<t size='0.75'>Execute</t>";
						console_executeText ctrlSetPosition [0.365937 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0309375 * safezoneW,0.022 * safezoneH];
						console_executeText ctrlSetBackgroundColor [0,0,0,0];
						console_executeText ctrlCommit 0;
						scriptTarget_playerName_edit = d_mainMenu ctrlCreate ["RscEdit", 7033];
						scriptTarget_playerName_edit ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.687 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerName_edit ctrlSetBackgroundColor [0,0,0,0.3];
						scriptTarget_playerName_edit ctrlSetTooltip "Type target name here.";
						scriptTarget_playerName_edit ctrlCommit 0;
						scriptTarget_playerUID_edit = d_mainMenu ctrlCreate ["RscEdit", 7034];
						scriptTarget_playerUID_edit ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerUID_edit ctrlSetBackgroundColor [0,0,0,0.3];
						scriptTarget_playerUID_edit ctrlSetTooltip "Type target steamID here.";
						scriptTarget_playerUID_edit ctrlCommit 0;
						scriptTarget_playerName = d_mainMenu ctrlCreate ["RscText", 7035];
						scriptTarget_playerName ctrlSetText "Name:";
						scriptTarget_playerName ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerName ctrlSetBackgroundColor [0,0,0,0.5];
						scriptTarget_playerName ctrlCommit 0;
						scriptTarget_playerUID = d_mainMenu ctrlCreate ["RscText", 7036];
						scriptTarget_playerUID ctrlSetText "UID:";
						scriptTarget_playerUID ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerUID ctrlSetBackgroundColor [0,0,0,0.5];
						scriptTarget_playerUID ctrlCommit 0;
						scriptTarget_playerName_cb = d_mainMenu ctrlCreate ["RscCheckbox", 7037];
						scriptTarget_playerName_cb ctrlSetPosition [0.345312 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerName_cb ctrladdEventHandler ["ButtonClick","	If (!tNameSelected) then { tNameSelected = true } else {tNameSelected = false} "];
						scriptTarget_playerName_cb ctrlSetTooltip "Define target by name.";
						scriptTarget_playerName_cb ctrlCommit 0;
						scriptTarget_playerUID_cb = d_mainMenu ctrlCreate ["RscCheckbox", 7038];
						scriptTarget_playerUID_cb ctrlSetPosition [0.345312 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						scriptTarget_playerUID_cb ctrladdEventHandler ["ButtonClick", " If (!tUIDSelected) then { tUIDSelected = true } else { tUIDSelected = false } "];
						scriptTarget_playerUID_cb ctrlSetTooltip "Define target by UID.";
						scriptTarget_playerUID_cb ctrlCommit 0;
						console_playerExec = d_mainMenu ctrlCreate ["RscButtonMenu", 7039];
						console_playerExec ctrlSetText "PLAYER EXEC";
						console_playerExec ctrlSetPosition [0.273125 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						console_playerExec ctrladdEventHandler ["ButtonClick", " [playerList_listBox lbText (lbCurSel playerList_listBox),ctrlText scriptTarget_playerName_edit,ctrlText scriptTarget_playerUID_edit] spawn Admin_fnc_execPlayer "];
						console_playerExec ctrlCommit 0;
						console_serverExec = d_mainMenu ctrlCreate ["RscButtonMenu", 7040];
						console_serverExec ctrlSetText "SERVER EXEC";
						console_serverExec ctrlSetPosition [0.365937 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						console_serverExec ctrlSetBackgroundColor [0,0.1,0,0.75];
						console_serverExec ctrladdEventHandler ["ButtonClick", " [] spawn Admin_fnc_execServer "];
						console_serverExec ctrlCommit 0;
						console_globalExec = d_mainMenu ctrlCreate ["RscButtonMenu", 7041];
						console_globalExec ctrlSetText "GLOBAL EXEC";
						console_globalExec ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						console_globalExec ctrlSetBackgroundColor [0.1,0,0,0.75];
						console_globalExec ctrladdEventHandler ["ButtonClick", " [] spawn Admin_fnc_execGlobal "];
						console_globalExec ctrlCommit 0;
						console_localExec = d_mainMenu ctrlCreate ["RscButtonMenu", 7042];
						console_localExec ctrlSetText "LOCAL EXEC";
						console_localExec ctrlSetPosition [0.551563 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						console_localExec ctrlSetBackgroundColor [0,0,0.1,0.75];
						console_localExec ctrladdEventHandler ["ButtonClick", " [] spawn Admin_fnc_execLocal "];
						console_localExec ctrlCommit 0;
						configure_title = d_mainMenu ctrlCreate ["RscStructuredText", 7043];
						configure_title ctrlSetStructuredText parseText "<t font='PuristaMedium'>CONFIGURE</t>";
						configure_title ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.621 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_title ctrlSetBackgroundColor Admin_tColor;
						configure_title ctrlCommit 0;
						configure_options = d_mainMenu ctrlCreate ["RscButtonMenu", 7044];
						configure_options ctrlSetText "OPTIONS";
						configure_options ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_options ctrladdEventHandler ["ButtonClick", " [] spawn Admin_open_optionsPanel "];
						configure_options ctrlCommit 0;
						configure_playerVehicleVarNameList = d_mainMenu ctrlCreate ["RscButtonMenu", 7045];
						configure_playerVehicleVarNameList ctrlSetText "vehicleVarName List";
						configure_playerVehicleVarNameList ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.687 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_playerVehicleVarNameList ctrladdEventHandler ["ButtonClick", " [] spawn Admin_open_playerVehicleVarNameList "];
						configure_playerVehicleVarNameList ctrlCommit 0;
						configure_whitelist = d_mainMenu ctrlCreate ["RscButtonMenu", 7046];
						configure_whitelist ctrlSetText "WHITELIST";
						configure_whitelist ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_whitelist ctrladdEventHandler ["ButtonClick", " d_mainMenu closeDisplay 0 [] spawn Admin_open_whitelistMenu "];
						configure_whitelist ctrlCommit 0;
						configure_credits = d_mainMenu ctrlCreate ["RscButtonMenu", 7047];
						configure_credits ctrlSetText "CREDITS";
						configure_credits ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.753 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_credits ctrladdEventHandler ["ButtonClick", " hint 'This menu (Admin) was Helped created by J-Wolf and E1.' "];
						configure_credits ctrlCommit 0;
						configure_close = d_mainMenu ctrlCreate ["RscButtonMenu", 7048];
						configure_close ctrlSetText "CLOSE";
						configure_close ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.0876563 * safezoneW,0.022 * safezoneH];
						configure_close ctrladdEventHandler ["ButtonClick", " d_mainMenu closeDisplay 0 "];
						configure_close ctrlCommit 0;
					comment "Load Saved States of Controls";
							if (isNil "tNameSelected") then { tNameSelected = false };
							if (tNameSelected) then { scriptTarget_playerName_cb cbSetChecked true };
							if (isNil "tUIDSelected") then { tUIDSelected = false };
							if (tUIDSelected) then { scriptTarget_playerUID_cb cbSetChecked true }};
				comment "----------------------------"; 
				comment "-------SPAWN MENU GUI-------";
				comment "----------------------------"; 
					Admin_fnc_OpenVehUI = {	private ["_flag"] disableSerialization player action ["Weapon On Back", player] Admin_d_fullSpawnMenu = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true;
						fSM_vehBack = Admin_d_fullSpawnMenu ctrlCreate ["IGUIBack", 9204];
						fSM_vehBack ctrlSetPosition [0 * safezoneW + safezoneX,0 * safezoneH + safezoneY,1 * safezoneW,1 * safezoneH];
						fSM_vehBack ctrlSetBackgroundColor [0,0,0,0.5];
						fSM_vehBack ctrlCommit 0;
						fSM_vehFrame = Admin_d_fullSpawnMenu ctrlCreate ["IGUIBack", 9205];
						fSM_vehFrame ctrlSetPosition [0.25 * safezoneW + safezoneX,0.25 * safezoneH + safezoneY,0.5 * safezoneW,0.5 * safezoneH];
						fSM_vehFrame ctrlSetBackgroundColor [0.529,0.565,0.49,1];
						fSM_vehFrame ctrlCommit 0;
						fSM_RscHeaderBack = Admin_d_fullSpawnMenu ctrlCreate ["IGUIBack", 9206];
						fSM_RscHeaderBack ctrlSetPosition [0.255 * safezoneW + safezoneX,0.2575 * safezoneH + safezoneY,0.49 * safezoneW,0.05 * safezoneH];
						fSM_RscHeaderBack ctrlSetBackgroundColor [0.333,0.333,0.333,0.75];
						fSM_RscHeaderBack ctrlCommit 0;
						fSM_RscVehBack = Admin_d_fullSpawnMenu ctrlCreate ["IGUIBack", 9207];
						fSM_RscVehBack ctrlSetPosition [0.255 * safezoneW + safezoneX,0.3125 * safezoneH + safezoneY,0.2425 * safezoneW,0.4275 * safezoneH];
						fSM_RscVehBack ctrlSetBackgroundColor [0.333,0.333,0.333,0.75];
						fSM_RscVehBack ctrlCommit 0;
						fSM_RscVehInfoBack = Admin_d_fullSpawnMenu ctrlCreate ["IGUIBack", 9208];
						fSM_RscVehInfoBack ctrlSetPosition [0.5025 * safezoneW + safezoneX,0.355 * safezoneH + safezoneY,0.2425 * safezoneW,0.34 * safezoneH];
						fSM_RscVehInfoBack ctrlSetBackgroundColor [0.333,0.333,0.333,0.75];
						fSM_RscVehInfoBack ctrlCommit 0;
						fSM_btnCancel = Admin_d_fullSpawnMenu ctrlCreate ["RscShortcutButton", 9209];
						fSM_btnCancel ctrlSetText "Cancel";
						fSM_btnCancel ctrlSetPosition [0.5025 * safezoneW + safezoneX,0.7025 * safezoneH + safezoneY,0.12 * safezoneW,0.0375 * safezoneH];
						fSM_btnCancel ctrlSetBackgroundColor [0.4,0.4,0.4,1];
						fSM_btnCancel ctrladdEventHandler ["ButtonClick", { Admin_d_fullSpawnMenu closeDisplay 0 }];
						fSM_btnCancel ctrlCommit 0;
						fSM_btnConfirm = Admin_d_fullSpawnMenu ctrlCreate ["RscShortcutButton", 9210];
						fSM_btnConfirm ctrlSetText "Confirm";
						fSM_btnConfirm ctrlSetPosition [0.625 * safezoneW + safezoneX,0.7025 * safezoneH + safezoneY,0.12 * safezoneW,0.0375 * safezoneH];
						fSM_btnConfirm ctrlSetBackgroundColor [0.4,0.4,0.4,1];
						fSM_btnConfirm ctrladdEventHandler ["ButtonClick", { [] call Admin_gui_VehCreate }];
						fSM_btnConfirm ctrlCommit 0;	
						comment "Insert Essential Controls";
						fSM_RscVehList = Admin_d_fullSpawnMenu ctrlCreate ["RscListBox", 9202];
						fSM_RscVehList ctrlSetTextColor [1,1,1,1];
						fSM_RscVehList ctrlSetBackgroundColor [0.667,0.714,0.635,1];
						fSM_RscVehList ctrlSetPosition [0.26 * safezoneW + safezoneX,0.3225 * safezoneH + safezoneY,0.2325 * safezoneW,0.41 * safezoneH];
						fSM_RscVehList ctrladdEventHandler ["LBSelChanged", { [] spawn Admin_gui_VehInfo }];
						fSM_RscVehList ctrlCommit 0;
						fSM_vehStatText = Admin_d_fullSpawnMenu ctrlCreate ["RscStructuredText", 9203];
						fSM_vehStatText ctrlSetTextColor [1,1,1,1];
						fSM_vehStatText ctrlSetBackgroundColor [0.667,0.714,0.635,1];
						fSM_vehStatText ctrlSetPosition [0.508 * safezoneW + safezoneX,0.365 * safezoneH + safezoneY,0.2325 * safezoneW,0.32 * safezoneH];
						fSM_vehStatText ctrlCommit 0 ["Car"] call Admin_gui_LoadVeh;
						fSM_serverTitleText = Admin_d_fullSpawnMenu ctrlCreate ["RscStructuredText", 9200];
						fSM_serverTitleText ctrlSetTextColor [1,1,1,1];
						fSM_serverTitleText ctrlSetBackgroundColor [0,0,0,0];
						fSM_serverTitleText ctrlSetPosition [0.305 * safezoneW + safezoneX,0.265 * safezoneH + safezoneY,0.435 * safezoneW,0.04 * safezoneH] _plr = profileName;
							_title = "Admin | FULL VEHICLE SPAWN MENU | <a underline='true' color='#0000FF' hRef='https://www.youtube.com/watch?v=nQygf2qKIU4'>Credit: soolie</a>";
						fSM_serverTitleText ctrlSetStructuredText parseText format ["<t align='left' shadow='1' shadowColor='#75000000'>%1</t><t align='right'  shadow='1' shadowColor='#75000000'>%2</t>",_plr,_title];
						fSM_serverTitleText ctrlCommit 0 _plrClass = typeOf player _side = getNumber(configFile >> "cfgVehicles" >> _plrClass>> "side");
						fSM_RscPlayerFlagLeft = Admin_d_fullSpawnMenu ctrlCreate ["RscPicture", 9201];
						fSM_RscPlayerFlagLeft ctrlSetBackgroundColor [0,0,0,1];
					comment "fSM_RscPlayerFlagLeft | sizeEx = 0.1 (text size is 0.1)";
						fSM_RscPlayerFlagLeft ctrlSetPosition [0.2575 * safezoneW + safezoneX,0.26 * safezoneH + safezoneY,0.05 * safezoneW,0.045* safezoneH];
						switch (_side) do { case 0: {_flag = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";}; 
									case 1: {_flag = "\A3\Data_F\Flags\Flag_nato_CO.paa";}; 
									case 2: {_flag = "\A3\Data_F\Flags\Flag_AAF_CO.paa";}};
						fSM_RscPlayerFlagLeft ctrlSetText _flag;
						fSM_RscPlayerFlagLeft ctrlCommit 0;
						fSM_btnLand = Admin_d_fullSpawnMenu ctrlCreate ["RscShortcutButton", 9211];
						fSM_btnLand ctrlSetText "Land";
						fSM_btnLand ctrlSetBackgroundColor [0.4,0.4,0.4,1];
						fSM_btnLand ctrlSetPosition [0.5025 * safezoneW + safezoneX,0.3125 * safezoneH + safezoneY,0.0775 * safezoneW,0.0375 * safezoneH];
						fSM_btnLand ctrladdEventHandler ["ButtonClick", { ["Car"] call Admin_gui_LoadVeh }];
						fSM_btnLand ctrlCommit 0;
						fSM_btnSea = Admin_d_fullSpawnMenu ctrlCreate ["RscShortcutButton", 9212];
						fSM_btnSea ctrlSetText "Sea";
						fSM_btnSea ctrlSetBackgroundColor [0.4,0.4,0.4,1];
						fSM_btnSea ctrlSetPosition [0.585 * safezoneW + safezoneX,0.3125 * safezoneH + safezoneY,0.0775 * safezoneW,0.0375 * safezoneH];
						fSM_btnSea ctrladdEventHandler ["ButtonClick", { ["Ship"] call Admin_gui_LoadVeh }];
						fSM_btnSea ctrlCommit 0;
						fSM_btnAir = Admin_d_fullSpawnMenu ctrlCreate ["RscShortcutButton", 9213];
						fSM_btnAir ctrlSetText "Air";
						fSM_btnAir ctrlSetBackgroundColor [0.4,0.4,0.4,1];
						fSM_btnAir ctrlSetPosition [0.6675 * safezoneW + safezoneX,0.3125 * safezoneH + safezoneY,0.0775 * safezoneW,0.0375 * safezoneH];
						fSM_btnAir ctrladdEventHandler ["ButtonClick", { ["Air"] call Admin_gui_LoadVeh }];
						fSM_btnAir ctrlCommit 0;
						fSM_txtSpawnWithAI = Admin_d_fullSpawnMenu ctrlCreate ["RscText", 9214];
						fSM_txtSpawnWithAI ctrlSetText "Spawn-with-AI";
						fSM_txtSpawnWithAI ctrlSetPosition [0.324687 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.061875 * safezoneW,0.033 * safezoneH];
						fSM_txtSpawnWithAI ctrlCommit 0;
						fSM_txtSpawnInVehicle = Admin_d_fullSpawnMenu ctrlCreate ["RscText", 9215];
						fSM_txtSpawnInVehicle ctrlSetText "Spawn-in-Vehicle";
						fSM_txtSpawnInVehicle ctrlSetPosition [0.396875 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.0721875 * safezoneW,0.033 * safezoneH];
						fSM_txtSpawnInVehicle ctrlCommit 0;
						fSM_cbSpawnWithAI = Admin_d_fullSpawnMenu ctrlCreate ["RscCheckbox", 9216];
						fSM_cbSpawnWithAI ctrlSetPosition [0.309219 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.020625 * safezoneW,0.033 * safezoneH];
						fSM_cbSpawnWithAI ctrladdEventHandler ["ButtonClick", { If (!SpawnWithAI) then { SpawnWithAI = true;
							If (SpawnInVehicle) then {fSM_cbSpawnInVehicle cbSetChecked false SpawnInVehicle = false }} else { SpawnWithAI = false }}];
						fSM_cbSpawnWithAI ctrlCommit 0;
						fSM_cbSpawnInVehicle = Admin_d_fullSpawnMenu ctrlCreate ["RscCheckbox", 9217];
						fSM_cbSpawnInVehicle ctrlSetPosition [0.381406 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.020625 * safezoneW,0.033 * safezoneH];
						fSM_cbSpawnInVehicle ctrladdEventHandler ["ButtonClick", { If (!SpawnInVehicle) then { SpawnInVehicle = true;
							If (SpawnWithAI) then {fSM_cbSpawnWithAI cbSetChecked false SpawnWithAI = false }} else { SpawnInVehicle = false }}];
						fSM_cbSpawnInVehicle ctrlCommit 0;
					comment "Load Saved States of Check_boxes on GUI open";
						If (isNil "SpawnWithAI") then {SpawnWithAI = false };
						If (SpawnWithAI) then {fSM_cbSpawnWithAI cbSetChecked true };
						If (isNil "SpawnInVehicle") then {SpawnInVehicle = false };
						If (SpawnInVehicle) then {fSM_cbSpawnInVehicle cbSetChecked true }};
				comment "----------------------------"; 
				comment "-----OPTIONS PANEL GUI------";
				comment "----------------------------"; 
					Admin_open_optionsPanel =
					{
						comment "GUI START" disableSerialization d_optionsPanel = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true comment "Fixes Chat Bug" comment "Create Controls";
						optionsPanel_bkrnd = d_optionsPanel ctrlCreate ["RscText", 7049];
						optionsPanel_bkrnd ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_bkrnd ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.397031 * safezoneW,0.363 * safezoneH];
						optionsPanel_bkrnd ctrlCommit 0;
						optionsPanel_title = d_optionsPanel ctrlCreate ["RscText", 7050];
						optionsPanel_title ctrlSetText "Admin     |     Options Panel";
						optionsPanel_title ctrlSetBackgroundColor Admin_tColor;
						optionsPanel_title ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.397031 * safezoneW,0.044 * safezoneH];
						optionsPanel_title ctrlCommit 0;
						optionsPanel_bkrnd1 = d_optionsPanel ctrlCreate ["RscText", 7051];
						optionsPanel_bkrnd1 ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_bkrnd1 ctrlSetPosition [0.319531 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0773437 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd1 ctrlCommit 0;
						optionsPanel_bkrnd2 = d_optionsPanel ctrlCreate ["RscFrame", 7052];
						optionsPanel_bkrnd2 ctrlSetTextColor [0,0,0,1];
						optionsPanel_bkrnd2 ctrlSetBackgroundColor [0,0,0,1];
						optionsPanel_bkrnd2 ctrlSetPosition [0.319531 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0773437 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd2 ctrlCommit 0;
						optionsPanel_bkrnd3 = d_optionsPanel ctrlCreate ["RscText", 7053];
						optionsPanel_bkrnd3 ctrlSetBackgroundColor [0,0,0,0.3];
						optionsPanel_bkrnd3 ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0825 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd3 ctrlCommit 0;
						optionsPanel_bkrnd4 = d_optionsPanel ctrlCreate ["RscFrame", 7054];
						optionsPanel_bkrnd4 ctrlSetTextColor [0,0,0,1];
						optionsPanel_bkrnd4 ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_bkrnd4 ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0825 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd4 ctrlCommit 0;
						optionsPanel_bkrnd5 = d_optionsPanel ctrlCreate ["RscText", 7055];
						optionsPanel_bkrnd5 ctrlSetBackgroundColor [0,0,0,0.3];
						optionsPanel_bkrnd5 ctrlSetPosition [0.510312 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0825 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd5 ctrlCommit 0;
						optionsPanel_bkrnd6 = d_optionsPanel ctrlCreate ["RscFrame", 7056];
						optionsPanel_bkrnd6 ctrlSetTextColor [0,0,0,1];
						optionsPanel_bkrnd6 ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_bkrnd6 ctrlSetPosition [0.510312 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0825 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd6 ctrlCommit 0;
						optionsPanel_bkrnd7 = d_optionsPanel ctrlCreate ["RscText", 7057];
						optionsPanel_bkrnd7 ctrlSetBackgroundColor [0,0,0,0.3];
						optionsPanel_bkrnd7 ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0773437 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd7 ctrlCommit 0;
						optionsPanel_bkrnd8 = d_optionsPanel ctrlCreate ["RscFrame", 7058];
						optionsPanel_bkrnd8 ctrlSetTextColor [0,0,0,1];
						optionsPanel_bkrnd8 ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_bkrnd8 ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.0773437 * safezoneW,0.077 * safezoneH];
						optionsPanel_bkrnd8 ctrlCommit 0;
						optionsPanel_menuColor = d_optionsPanel ctrlCreate ["RscText", 7059];
						optionsPanel_menuColor ctrlSetText "Select Menu Color:";
						optionsPanel_menuColor ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_menuColor ctrlSetPosition [0.319531 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.0773437 * safezoneW,0.022 * safezoneH];
						optionsPanel_menuColor ctrlCommit 0;
						optionsPanel_menuColorRed = d_optionsPanel ctrlCreate ["RscButtonMenu", 7060];
						optionsPanel_menuColorRed ctrlSetText "R";
						optionsPanel_menuColorRed ctrlSetBackgroundColor [0.5,0,0,0.6];
						optionsPanel_menuColorRed ctrlSetPosition [0.335 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						optionsPanel_menuColorRed ctrladdEventHandler ["ButtonClick", " Admin_tColor = [0.5,0,0,0.6] Admin_fColor = [1,0,0,1];
						optionsPanel_title ctrlSetBackgroundColor Admin_tColor hint 'Admin: Menu colors updated.' "];
						optionsPanel_menuColorRed ctrlCommit 0;
						optionsPanel_menuColorGreen = d_optionsPanel ctrlCreate ["RscButtonMenu", 7061];
						optionsPanel_menuColorGreen ctrlSetText "G";
						optionsPanel_menuColorGreen ctrlSetBackgroundColor [0,0.5,0,0.6];
						optionsPanel_menuColorGreen ctrlSetPosition [0.350469 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						optionsPanel_menuColorGreen ctrladdEventHandler ["ButtonClick", " Admin_tColor = [0,0.5,0,0.6] Admin_fColor = [0,1,0,1] optionsPanel_title ctrlSetBackgroundColor Admin_tColor hint 'Admin: Menu colors updated.' "];
						optionsPanel_menuColorGreen ctrlCommit 0;
						optionsPanel_menuColorBlue = d_optionsPanel ctrlCreate ["RscButtonMenu", 7062];
						optionsPanel_menuColorBlue ctrlSetText "B";
						optionsPanel_menuColorBlue ctrlSetBackgroundColor [0,0,0.5,0.6];
						optionsPanel_menuColorBlue ctrlSetPosition [0.365937 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						optionsPanel_menuColorBlue ctrladdEventHandler ["ButtonClick", " Admin_tColor = [0,0,0.5,0.6] Admin_fColor = [0,0,1,1] optionsPanel_title ctrlSetBackgroundColor Admin_tColor hint 'Admin: Menu colors have been updated.' "];
						optionsPanel_menuColorBlue ctrlCommit 0;
						optionsPanel_keyBind_arsenal = d_optionsPanel ctrlCreate ["RscText", 7063];
						optionsPanel_keyBind_arsenal ctrlSetText "Arsenal Keybind:";
						optionsPanel_keyBind_arsenal ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.0825 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_arsenal ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_arsenal ctrlCommit 0;
						optionsPanel_keyBind_arsenalEdit = d_optionsPanel ctrlCreate ["RscEdit", 7064];
						optionsPanel_keyBind_arsenalEdit ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0309375 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_arsenalEdit ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_arsenalEdit ctrlSetText Admin_key_arsenal;
						optionsPanel_keyBind_arsenalEdit ctrlCommit 0;
						optionsPanel_keyBind_arsenalApply = d_optionsPanel ctrlCreate ["RscButtonMenu", 7065];
						optionsPanel_keyBind_arsenalApply ctrlSetText "APPLY";
						optionsPanel_keyBind_arsenalApply ctrlSetPosition [0.453594 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0360937 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_arsenalApply ctrladdEventHandler ["ButtonClick", " Admin_key_Arsenal = (ctrlText optionsPanel_keyBind_arsenalEdit) hint 'Admin: Key has not changed. Wait for future updates.' "];
						optionsPanel_keyBind_arsenalApply ctrlCommit 0;
						optionsPanel_keyBind_mainMenu = d_optionsPanel ctrlCreate ["RscText", 7066];
						optionsPanel_keyBind_mainMenu ctrlSetText "MainMenu Key:";
						optionsPanel_keyBind_mainMenu ctrlSetPosition [0.510312 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.0825 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_mainMenu ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_mainMenu ctrlCommit 0;
						optionsPanel_keyBind_mainMenuEdit = d_optionsPanel ctrlCreate ["RscEdit", 7067];
						optionsPanel_keyBind_mainMenuEdit ctrlSetPosition [0.515469 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0309375 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_mainMenuEdit ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_mainMenuEdit ctrlSetText Admin_key_mainMenu;
						optionsPanel_keyBind_mainMenuEdit ctrlCommit 0;
						optionsPanel_keyBind_mainMenuApply = d_optionsPanel ctrlCreate ["RscButtonMenu", 7068];
						optionsPanel_keyBind_mainMenuApply ctrlSetText "APPLY";
						optionsPanel_keyBind_mainMenuApply ctrlSetPosition [0.551562 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0360937 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_mainMenuApply ctrladdEventHandler ["ButtonClick", " Admin_key_mainMenu = (ctrlText optionsPanel_keyBind_mainMenuEdit) hint 'Admin: Key has not changed. Wait for next update.' "];
						optionsPanel_keyBind_mainMenuApply ctrlCommit 0;
						optionsPanel_keyBind_3DTP = d_optionsPanel ctrlCreate ["RscText", 7069];
						optionsPanel_keyBind_3DTP ctrlSetText "3DTP Key:";
						optionsPanel_keyBind_3DTP ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.0773437 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_3DTP ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_3DTP ctrlCommit 0;
						optionsPanel_keyBind_3DTPEdit = d_optionsPanel ctrlCreate ["RscEdit", 7070];
						optionsPanel_keyBind_3DTPEdit ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0257812 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_3DTPEdit ctrlSetBackgroundColor [0,0,0,0.5];
						optionsPanel_keyBind_3DTPEdit ctrlSetText Admin_key_3DTP;
						optionsPanel_keyBind_3DTPEdit ctrlCommit 0;
						optionsPanel_keyBind_3DTPApply = d_optionsPanel ctrlCreate ["RscButtonMenu", 7071];
						optionsPanel_keyBind_3DTPApply ctrlSetText "APPLY";
						optionsPanel_keyBind_3DTPApply ctrlSetPosition [0.644375 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0360937 * safezoneW,0.022 * safezoneH];
						optionsPanel_keyBind_3DTPApply ctrladdEventHandler ["ButtonClick", " Admin_key_3DTP = (ctrlText optionsPanel_keyBind_3DTPEdit) hint 'Admin: Key has not changed. Wait for next update.' "];
						optionsPanel_keyBind_3DTPApply ctrlCommit 0;
						optionsPanel_return = d_optionsPanel ctrlCreate ["RscButtonMenu", 7072];
						optionsPanel_return ctrlSetText "RETURN";
						optionsPanel_return ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.665 * safezoneH + safezoneY,0.0670312 * safezoneW,0.033 * safezoneH];
						optionsPanel_return ctrladdEventHandler ["ButtonClick", " d_optionsPanel closeDisplay 0 [] spawn Admin_open_mainMenu "];
						optionsPanel_return ctrlCommit 0;
						optionsPanel_close = d_optionsPanel ctrlCreate ["RscButtonMenu", 7073];
						optionsPanel_close ctrlSetText "EXIT ALL";
						optionsPanel_close ctrlSetPosition [0.634062 * safezoneW + safezoneX,0.665 * safezoneH + safezoneY,0.0670312 * safezoneW,0.033 * safezoneH];
						optionsPanel_close ctrladdEventHandler ["ButtonClick", "d_optionsPanel closeDisplay 0 removeAllActions player if (not (isNil Overlay_TargetInfo)) then { ctrlDelete Overlay_TargetInfo; } "];
						optionsPanel_close ctrlCommit 0;
						optionsPanel_info1 = d_optionsPanel ctrlCreate ["RscText", 7074];
						optionsPanel_info1 ctrlSetText "Current Version of Admin:";
						optionsPanel_info1 ctrlSetPosition [0.453594 * safezoneW + safezoneX,0.467 * safezoneH + safezoneY,0.0928125 * safezoneW,0.022 * safezoneH];
						optionsPanel_info1 ctrlCommit 0;
						optionsPanel_info2 = d_optionsPanel ctrlCreate ["RscText", 7075];
						optionsPanel_info2 ctrlSetText "V1.6A";
						optionsPanel_info2 ctrlSetPosition [0.486 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.0257812 * safezoneW,0.022 * safezoneH];
						optionsPanel_info2 ctrlCommit 0;
						optionsPanel_info3 = d_optionsPanel ctrlCreate ["RscText", 7076];
						optionsPanel_info3 ctrlSetText "More options and settings to come in the future!";
						optionsPanel_info3 ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.180469 * safezoneW,0.033 * safezoneH];
						optionsPanel_info3 ctrlCommit 0;
						comment "GUI END" 
					};
				comment "----------------------------"; 
				comment "-----WHITELIST CFG GUI------";
				comment "----------------------------"; 
					Admin_open_whitelistMenu = { disableSerialization d_whitelistMenu = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true;
						bList_title = d_whitelistMenu ctrlCreate ["RscText", 7077];
						bList_title ctrlSetText "Admin        |            WHITELIST CONFIGURATION";
						bList_title ctrlSetPosition [0.386563 * safezoneW + safezoneX,0.247 * safezoneH + safezoneY,0.221719 * safezoneW,0.022 * safezoneH];
						bList_title ctrlSetBackgroundColor [-1,-1,-1,0.8];
						bList_title ctrlCommit 0;
						bList_bkrnd1 = d_whitelistMenu ctrlCreate ["RscText", 7078];
						bList_bkrnd1 ctrlSetPosition [0.386562 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.226875 * safezoneW,0.044 * safezoneH];
						bList_bkrnd1 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						bList_bkrnd1 ctrlCommit 0;
						bList_enableT = d_whitelistMenu ctrlCreate ["RscText", 7079];
						bList_enableT ctrlSetText "Enable Whitelisting";
						bList_enableT ctrlSetPosition [0.469062 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.0773437 * safezoneW,0.022 * safezoneH];
						bList_enableT ctrlSetBackgroundColor [-1,-1,-1,0.8];
						bList_enableT ctrlCommit 0;
						bList_bkrnd2 = d_whitelistMenu ctrlCreate ["RscText", 7080];
						bList_bkrnd2 ctrlSetPosition [0.448438 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						bList_bkrnd2 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						bList_bkrnd2 ctrlCommit 0;
						bList_cb = d_whitelistMenu ctrlCreate ["RscCheckbox", 7081];
						bList_cb ctrlSetPosition [0.448438 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.0154688 * safezoneW,0.022 * safezoneH];
						bList_cb ctrladdEventHandler ["ButtonClick", " If (!Admin_whiteListEnabled) then { Admin_whiteListEnabled = true [] call Admin_toggle_whiteListing } else { Admin_whiteListEnabled = false } "];
						bList_cb ctrlCommit 0;
						bList_bkrnd3 = d_whitelistMenu ctrlCreate ["RscText", 7082];
						bList_bkrnd3 ctrlSetPosition [0.386562 * safezoneW + safezoneX,0.335 * safezoneH + safezoneY,0.226875 * safezoneW,0.22 * safezoneH];
						bList_bkrnd3 ctrlSetBackgroundColor [-1,-1,-1,0.5];
						bList_bkrnd3 ctrlCommit 0;
						bList_list = d_whitelistMenu ctrlCreate ["RscListbox", 7083];
						bList_list ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.346 * safezoneH + safezoneY,0.12375 * safezoneW,0.165 * safezoneH] { _bL_index = bList_list lbAdd _x; } forEach Admin_whitelist;
						bList_list ctrlCommit 0;
						bList_remove = d_whitelistMenu ctrlCreate ["RscButtonMenu", 7084];
						bList_remove ctrlSetText "REMOVE FROM WHITELIST";
						bList_remove ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.12375 * safezoneW,0.022 * safezoneH];
						bList_remove ctrladdEventHandler ["ButtonClick", " Admin_whitelist deleteAt (Admin_whitelist find (bList_list lbText (lbCurSel bList_list))) lbClear bList_list { _bL_index = bList_list lbAdd _x; } forEach Admin_whitelis "];
						bList_remove ctrlCommit 0;
						bList_permaFuck = d_whitelistMenu ctrlCreate ["RscButtonMenu", 7085];
						bList_permaFuck ctrlSetText "PERMA FUCK";
						bList_permaFuck ctrlSetPosition [0.391719 * safezoneW + safezoneX,0.401 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
						bList_permaFuck ctrladdEventHandler ["ButtonClick", " comment 'test' hint 'permanent fuckery is currently not available' "];
						bList_permaFuck ctrlCommit 0;
						bList_earRape = d_whitelistMenu ctrlCreate ["RscButtonMenu", 7086];
						bList_earRape ctrlSetText "EAR RAPE";
						bList_earRape ctrlSetPosition [0.567031 * safezoneW + safezoneX,0.401 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
						bList_earRape ctrladdEventHandler ["ButtonClick", " comment 'test' hint 'ear rape not available' "];
						bList_earRape ctrlCommit 0;	
						bList_close = d_whitelistMenu ctrlCreate ["RscButtonMenu", 7087];
						bList_close ctrlSetText "CLOSE";
						bList_close ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.566 * safezoneH + safezoneY,0.04125 * safezoneW,0.022 * safezoneH];
						bList_close ctrladdEventHandler ["ButtonClick", " d_whitelistMenu closeDisplay 0 "];
						bList_close ctrlCommit 0;	
						bList_return = d_whitelistMenu ctrlCreate ["RscButtonMenu", 7088];
						bList_return ctrlSetText "RETURN";
						bList_return ctrlSetPosition [0.386562 * safezoneW + safezoneX,0.566 * safezoneH + safezoneY,0.04125 * safezoneW,0.022 * safezoneH];
						bList_return ctrladdEventHandler ["ButtonClick", " d_whitelistMenu closeDisplay 0 [] spawn Admin_open_mainMenu "];
						bList_return ctrlCommit 0;
					comment "Loaded saved states of controls.";
					If (isNil "Admin_whiteListEnabled") then {Admin_whiteListEnabled = false };
					If (Admin_whiteListEnabled) then {bList_cb cbSetChecked true }};
				comment "------------------------------------------";
				comment "------PLAYER Vehicle Var Name LIST--------";
				comment "------------------------------------------";
					Admin_open_playerVehicleVarNameList = { disableSerialization d_playerVehicleVarNameList = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true;
						VVN_listBox = d_playerVehicleVarNameList ctrlCreate ["RscListbox", 7612];
						VVN_listBox ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.154687 * safezoneW,0.209 * safezoneH] { _pL_index = VVN_listBox lbAdd ((name _x) + " | " + (vehicleVarName _x));} forEach allPlayers;
						VVN_listBox ctrlCommit 0;
						VVN_titleBar = d_playerVehicleVarNameList ctrlCreate ["RscText", 7613];
						VVN_titleBar ctrlSetText "Admin     |     Player (VehicleVarName) List";
						VVN_titleBar ctrlSetBackgroundColor [-1,-1,-1,1];
						VVN_titleBar ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.154687 * safezoneW,0.022 * safezoneH];
						VVN_titleBar ctrlCommit 0;
						VVN_return = d_playerVehicleVarNameList ctrlCreate ["RscButtonMenu", 7614];
						VVN_return ctrlSetText "RETURN";
						VVN_return ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.0464063 * safezoneW,0.044 * safezoneH];
						VVN_return ctrladdEventHandler ["ButtonClick", " d_playerVehicleVarNameList closeDisplay 0 [] spawn Admin_open_mainMenu "];
						VVN_return ctrlCommit 0;
						VVN_close = d_playerVehicleVarNameList ctrlCreate ["RscButtonMenu", 7615];
						VVN_close ctrlSetText "CLOSE";
						VVN_close ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.0464063 * safezoneW,0.044 * safezoneH];
						VVN_close ctrladdEventHandler ["ButtonClick", " d_playerVehicleVarNameList closeDisplay 0 "];
						VVN_close ctrlCommit 0 };
				comment "----------------------------"; 
				comment "-------SERVER MENU GUI------";
				comment "----------------------------"; 
					Admin_open_serverMenu = { disableSerialization d_serverMenu = (findDisplay 46) createDisplay "RscDisplayEmpty" showChat true;
						sM_MainFrame = d_serverMenu ctrlCreate ["RscFrame", 7089];
						sM_MainFrame ctrlSetText "Helped created by J-Wolf and E1.";
						sM_MainFrame ctrlSetPosition [0.280447 * safezoneW + safezoneX,0.1953 * safezoneH + safezoneY,0.438281 * safezoneW,0.704 * safezoneH];
						sM_MainFrame ctrlCommit 0;
						sM_bkgrnd = d_serverMenu ctrlCreate ["RscText", 7090];
						sM_bkgrnd ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.225 * safezoneH + safezoneY,0.4125 * safezoneW,0.55 * safezoneH];
						sM_bkgrnd ctrlSetBackgroundColor [0,0,0,0.8];
						sM_bkgrnd ctrlCommit 0;
						sM_border1 = d_serverMenu ctrlCreate ["RscText", 7091];
						sM_border1 ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.225 * safezoneH + safezoneY,0.4125 * safezoneW,0.099 * safezoneH];
						sM_border1 ctrlSetBackgroundColor [0.4,0,0,1];
						sM_border1 ctrlCommit 0;
						sM_border2 = d_serverMenu ctrlCreate ["RscText", 7092];
						sM_border2 ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.764 * safezoneH + safezoneY,0.4125 * safezoneW,0.011 * safezoneH];
						sM_border2 ctrlSetBackgroundColor [0.4,0,0,1];
						sM_border2 ctrlCommit 0;
						sM_border3 = d_serverMenu ctrlCreate ["RscPicture", 7093];
						sM_border3 ctrlSetText "#(ARGB,8,8,3)color(0.4,0,0,1)";
						sM_border3 ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.00515625 * safezoneW,0.44 * safezoneH];
						sM_border3 ctrlCommit 0;
						sM_border4 = d_serverMenu ctrlCreate ["RscPicture", 7094];
						sM_border4 ctrlSetText "#(ARGB,8,8,3)color(0.4,0,0,1)";
						sM_border4 ctrlSetPosition [0.567031 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.00515625 * safezoneW,0.44 * safezoneH];
						sM_border4 ctrlCommit 0;
						sM_border5 = d_serverMenu ctrlCreate ["RscPicture", 7095];
						sM_border5 ctrlSetText "#(ARGB,8,8,3)color(0.4,0,0,1)";
						sM_border5 ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.00515625 * safezoneW,0.44 * safezoneH];
						sM_border5 ctrlCommit 0;
						sM_border6 = d_serverMenu ctrlCreate ["RscPicture", 7096];
						sM_border6 ctrlSetText "#(ARGB,8,8,3)color(0.4,0,0,1)";
						sM_border6 ctrlSetPosition [0.701094 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.00515625 * safezoneW,0.44 * safezoneH];
						sM_border6 ctrlCommit 0;
						sM_return = d_serverMenu ctrlCreate ["RscButton", 7097];
						sM_return ctrlSetText "Return";
						sM_return ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.786 * safezoneH + safezoneY,0.407344 * safezoneW,0.044 * safezoneH];
						sM_return ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 [] spawn Admin_open_mainMenu }];
						sM_return ctrlCommit 0;
						sM_close = d_serverMenu ctrlCreate ["RscButton", 7098];
						sM_close ctrlSetText "Close";
						sM_close ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.841 * safezoneH + safezoneY,0.407344 * safezoneW,0.044 * safezoneH];
						sM_close ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 }];
						sM_close ctrlCommit 0;
						sM_labelInfo = d_serverMenu ctrlCreate ["RscStructuredText", 7099];
						sM_labelInfo ctrlSetStructuredText parseText "<t align='center'>Server Info</t>";
						sM_labelInfo ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.134062 * safezoneW,0.022 * safezoneH];
						sM_labelInfo ctrlSetBackgroundColor [0,0,0,1];
						sM_labelInfo ctrlCommit 0;
						sM_labelServer = d_serverMenu ctrlCreate ["RscStructuredText", 7100];
						sM_labelServer ctrlSetStructuredText parseText "<t align='center'>Server Scripts</t>";
						sM_labelServer ctrlSetPosition [0.432968 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.134062 * safezoneW,0.022 * safezoneH];
						sM_labelServer ctrlSetBackgroundColor [0,0,0,1];
						sM_labelServer ctrlCommit 0;			
						sM_labelGlobal = d_serverMenu ctrlCreate ["RscStructuredText", 7101];
						sM_labelGlobal ctrlSetStructuredText parseText "<t align='center'>Global Scripts</t>";
						sM_labelGlobal ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.134062 * safezoneW,0.022 * safezoneH];
						sM_labelGlobal ctrlSetBackgroundColor [0,0,0,1];
						sM_labelGlobal ctrlCommit 0;				
						sM_serverName = d_serverMenu ctrlCreate ["RscText", 7102];
						sM_serverName ctrlSetText ("[SERVER] " + serverName);
						sM_serverName ctrlSetPosition [0.335 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.37125 * safezoneW,0.044 * safezoneH];
						sM_serverName ctrlSetBackgroundColor [0,0,0,1];
						sM_serverName ctrlCommit 0;
						sM_missionName = d_serverMenu ctrlCreate ["RscStructuredText", 7103];
						sM_missionName ctrlSetStructuredText parseText ("<t size='0.7'>ServerCFG/Path: " + missionName);
						sM_missionName ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_missionName ctrlSetBackgroundColor [0,0,0,0.5];
						sM_missionName ctrlCommit 0;
						sM_worldName = d_serverMenu ctrlCreate ["RscStructuredText", 7104];
						sM_worldName ctrlSetStructuredText parseText ("<t size='0.7'>World: " + worldName);
						sM_worldName ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_worldName ctrlSetBackgroundColor [0,0,0,0.5];
						sM_worldName ctrlCommit 0;
						sM_briefingName = d_serverMenu ctrlCreate ["RscStructuredText", 7105];
						sM_briefingName ctrlSetStructuredText parseText ("<t size='0.7'>Scenario: " + briefingName);
						sM_briefingName ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_briefingName ctrlSetBackgroundColor [0,0,0,0.5];
						sM_briefingName ctrlCommit 0;
						sM_worldSize = d_serverMenu ctrlCreate ["RscStructuredText", 7106];
						sM_worldSize ctrlSetStructuredText parseText ("<t size='0.7'>MapSize: " + str worldSize + " meters");
						sM_worldSize ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_worldSize ctrlSetBackgroundColor [0,0,0,0.5];
						sM_worldSize ctrlCommit 0;
						sM_serverTime = d_serverMenu ctrlCreate ["RscStructuredText", 7107];
						sM_serverTime ctrlSetStructuredText parseText ("<t size='0.7'>Uptime: " + (str serverTime));
						sM_serverTime ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.456 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_serverTime ctrlSetBackgroundColor [0,0,0,0.5];
						sM_serverTime ctrlCommit 0;
						sM_FPS = d_serverMenu ctrlCreate ["RscStructuredText", 7109];
						sM_FPS ctrlSetStructuredText parseText ("<t size='0.7'>FPS: " + str diag_fps);
						sM_FPS ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.128906 * safezoneW,0.022 * safezoneH];
						sM_FPS ctrlSetBackgroundColor [0,0,0,0.5];
						sM_FPS ctrlCommit 0;
						sM_btn_clearDead = d_serverMenu ctrlCreate ["RscButton", 7113];
						sM_btn_clearDead ctrlSetText "Clear-the-Dead";
						sM_btn_clearDead ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_clearDead ctrlSetTextColor [0,1,0,1];
						sM_btn_clearDead ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_clearDead }];
						sM_btn_clearDead ctrlCommit 0;
						sM_i_clearDead = d_serverMenu ctrlCreate ["RscStructuredText", 7114];
						sM_i_clearDead ctrlSetStructuredText parseText "<t size='0.5' align='center'>on Server | deletes anything dead.</t>";
						sM_i_clearDead ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_clearDead ctrlSetBackgroundColor [0,0,0,0.6];			
						sM_i_clearDead ctrlCommit 0;
						sM_btn_AASJIP = d_serverMenu ctrlCreate ["RscButton", 7115];
						sM_btn_AASJIP ctrlSetText "Arsenal-At-Spawn (JIP)";
						sM_btn_AASJIP ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.434 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_AASJIP ctrlSetTextColor [0,1,0,1];
						sM_btn_AASJIP ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_AASJIP }];
						sM_btn_AASJIP ctrlCommit 0;
						sM_i_AASJIP = d_serverMenu ctrlCreate ["RscStructuredText", 7116];
						sM_i_AASJIP ctrlSetStructuredText parseText "<t size='0.5' align='center'>all clients + new | opens arsenal on respawn.</t>";
						sM_i_AASJIP ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.467 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_AASJIP ctrlSetBackgroundColor [0,0,0,0.6];		
						sM_i_AASJIP ctrlCommit 0;
						sM_btn_updateZeusObj = d_serverMenu ctrlCreate ["RscButton", 7117];
						sM_btn_updateZeusObj ctrlSetText "Update-Zeus-Obj";
						sM_btn_updateZeusObj ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_updateZeusObj ctrlSetTextColor [0,1,0,1];
						sM_btn_updateZeusObj ctrladdEventHandler ["ButtonClick", { [] spawn Admin_fnc_updateZeusObj }];
						sM_btn_updateZeusObj ctrlCommit 0;
						sM_i_updateZeusObj = d_serverMenu ctrlCreate ["RscStructuredText", 7118];
						sM_i_updateZeusObj ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server | enables editing of all objects for curators.</t>";
						sM_i_updateZeusObj ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_updateZeusObj ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_updateZeusObj ctrlCommit 0;
						sM_btn_viewDistance = d_serverMenu ctrlCreate ["RscButton", 7119];
						sM_btn_viewDistance ctrlSetText "Set-ViewDistance (JIP)";
						sM_btn_viewDistance ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_viewDistance ctrlSetTextColor [0,1,0,1];
						sM_btn_viewDistance ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 [] call Admin_fnc_viewDistance }];
						sM_btn_viewDistance ctrlCommit 0;
						sM_i_viewDistance = d_serverMenu ctrlCreate ["RscStructuredText", 7120];
						sM_i_viewDistance ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server + new | open VD menu for desired VD.</t>";
						sM_i_viewDistance ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.577 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_viewDistance ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_viewDistance ctrlCommit 0;
						sM_btn_deleteMenu = d_serverMenu ctrlCreate ["RscButton", 7121];
						sM_btn_deleteMenu ctrlSetText "Delete Radius";
						sM_btn_deleteMenu ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.599 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_deleteMenu ctrlSetTextColor [0,1,0,1];
						sM_btn_deleteMenu ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 [] call Admin_deleteMenu hint "Admin: Scroll wheel to select delete radius." }];
						sM_btn_deleteMenu ctrlCommit 0;
						sM_btn_wipeMap = d_serverMenu ctrlCreate ["RscButton", 7999];
						sM_btn_wipeMap ctrlSetText "Delete All Objects";
						sM_btn_wipeMap ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_wipeMap ctrlSetTextColor [0,1,0,1];
						sM_btn_wipeMap ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_deleteAll }];
						sM_btn_wipeMap ctrlCommit 0;
						sM_i_wipeMap = d_serverMenu ctrlCreate ["RscStructuredText", 7998];
						sM_i_wipeMap ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server | delete everything - missionModules.</t>";
						sM_i_wipeMap ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.687 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_wipeMap ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_wipeMap ctrlCommit 0;
						sM_btn_killRadius = d_serverMenu ctrlCreate ["RscButton", 9201];
						sM_btn_killRadius ctrlSetText "Kill Radius";
						sM_btn_killRadius ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.709 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_killRadius ctrlSetTextColor [0,1,0,1];
						sM_btn_killRadius ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 [] call Admin_killMenu }];
						sM_btn_killRadius ctrlCommit 0;
						sM_i_killRadius = d_serverMenu ctrlCreate ["RscStructuredText", 9200];
						sM_i_killRadius ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server | delete everything - missionModules.</t>";
						sM_i_killRadius ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_killRadius ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_killRadius ctrlCommit 0;
						sM_btn_showPlayersOnMap = d_serverMenu ctrlCreate ["RscButton", 7994];
						sM_btn_showPlayersOnMap ctrlSetText "ShowPlayersOnMap";
						sM_btn_showPlayersOnMap ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.134062 * safezoneW,0.033 * safezoneH];
						sM_btn_showPlayersOnMap ctrlSetTextColor [0,1,0,1];
						sM_btn_showPlayersOnMap ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_showPlayersOnMap }];
						sM_btn_showPlayersOnMap ctrlCommit 0;
						sM_i_showPlayersOnMap = d_serverMenu ctrlCreate ["RscStructuredText", 7995];
						sM_i_showPlayersOnMap ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server | delete everything - missionModules.</t>";
						sM_i_showPlayersOnMap ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_showPlayersOnMap ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_showPlayersOnMap ctrlCommit 0;
						sM_i_deleteMenu = d_serverMenu ctrlCreate ["RscStructuredText", 7122];
						sM_i_deleteMenu ctrlSetStructuredText parseText "<t size='0.5' align='center'>on server | deletes objects in radius</t>";
						sM_i_deleteMenu ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.632 * safezoneH + safezoneY,0.134062 * safezoneW,0.011 * safezoneH];
						sM_i_deleteMenu ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_deleteMenu ctrlCommit 0;
						sM_btn_optionsMenu = d_serverMenu ctrlCreate ["RscButton", 7123];
						sM_btn_optionsMenu ctrlSetText "Give-ClientOptions";
						sM_btn_optionsMenu ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.128906 * safezoneW,0.033 * safezoneH];
						sM_btn_optionsMenu ctrlSetTextColor [0,0,1,1];
						sM_btn_optionsMenu ctrladdEventHandler ["ButtonClick", { d_serverMenu closeDisplay 0 [] spawn Admin_fnc_clientOptions }];
						sM_btn_optionsMenu ctrlCommit 0;
						sM_i_optionsMenu = d_serverMenu ctrlCreate ["RscStructuredText", 7124];
						sM_i_optionsMenu ctrlSetStructuredText parseText "<t size='0.5' align='center'>All clients | viewDistance and noFatigue</t>";
						sM_i_optionsMenu ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.128906 * safezoneW,0.011 * safezoneH];
						sM_i_optionsMenu ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_optionsMenu ctrlCommit 0;
						sM_btn_TP_All_to_Self = d_serverMenu ctrlCreate ["RscButton", 7125];
						sM_btn_TP_All_to_Self ctrlSetText "TP All (to self)";
						sM_btn_TP_All_to_Self ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.128906 * safezoneW,0.033 * safezoneH];
						sM_btn_TP_All_to_Self ctrlSetTextColor [0,0,1,1];
						sM_btn_TP_All_to_Self ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_TP_allToSelf }];
						sM_btn_TP_All_to_Self ctrlCommit 0;
						sM_i_TP_All_to_Self = d_serverMenu ctrlCreate ["RscStructuredText", 7126];
						sM_i_TP_All_to_Self ctrlSetStructuredText parseText "<t size='0.5' align='center'>All clients | everyone will transport to you.</t>";
						sM_i_TP_All_to_Self ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.128906 * safezoneW,0.011 * safezoneH];
						sM_i_TP_All_to_Self ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_TP_All_to_Self ctrlCommit 0;
						sM_btn_respawnAll = d_serverMenu ctrlCreate ["RscButton", 7129];
						sM_btn_respawnAll ctrlSetText "ForceRespawn-All";
						sM_btn_respawnAll ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.434 * safezoneH + safezoneY,0.128906 * safezoneW,0.033 * safezoneH];
						sM_btn_respawnAll ctrlSetTextColor [0,0,1,1];
						sM_btn_respawnAll ctrladdEventHandler ["ButtonClick", { [] spawn Admin_fnc_respawnAll }];
						sM_btn_respawnAll ctrlCommit 0;
						sM_i_respawnAll = d_serverMenu ctrlCreate ["RscStructuredText", 7130];
						sM_i_respawnAll ctrlSetStructuredText parseText "<t size='0.5' align='center'>all clients - Zeus | die without score loss.</t>";
						sM_i_respawnAll ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.467 * safezoneH + safezoneY,0.128906 * safezoneW,0.011 * safezoneH];
						sM_i_respawnAll ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_respawnAll ctrlCommit 0;
						sM_btn_shw3DPlrNm = d_serverMenu ctrlCreate ["RscButton", 7770];
						sM_btn_shw3DPlrNm ctrlSetText "Show3DPlayerNames";
						sM_btn_shw3DPlrNm ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.489 * safezoneH + safezoneY,0.128906 * safezoneW,0.033 * safezoneH];
						sM_btn_shw3DPlrNm ctrlSetTextColor [0,0,1,1];
						sM_btn_shw3DPlrNm ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_show3DPlayerNames }];
						sM_btn_shw3DPlrNm ctrlCommit 0;
						sM_i_shw3DPlrNm = d_serverMenu ctrlCreate ["RscStructuredText", 7771];
						sM_i_shw3DPlrNm ctrlSetStructuredText parseText "<t size='0.5' align='center'>allPlayers | everyone sees names over players up to 1500m.</t>";
						sM_i_shw3DPlrNm ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.128906 * safezoneW,0.011 * safezoneH];
						sM_i_shw3DPlrNm ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_shw3DPlrNm ctrlCommit 0;
						sM_btn_disableFatigue = d_serverMenu ctrlCreate ["RscButton", 7772];
						sM_btn_disableFatigue ctrlSetText "Infinite Stamina";
						sM_btn_disableFatigue ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.544 * safezoneH + safezoneY,0.128906 * safezoneW,0.033 * safezoneH];
						sM_btn_disableFatigue ctrlSetTextColor [0,0,1,1];
						sM_btn_disableFatigue ctrladdEventHandler ["ButtonClick", { [] call Admin_fnc_disableFatigueGlobal }];
						sM_btn_disableFatigue ctrlCommit 0;
						sM_i_disableFatigue = d_serverMenu ctrlCreate ["RscStructuredText", 7773];
						sM_i_disableFatigue ctrlSetStructuredText parseText "<t size='0.5' align='center'>allPlayers | click to toggle fatigue off and on.</t>";
						sM_i_disableFatigue ctrlSetPosition [0.572187 * safezoneW + safezoneX,0.577 * safezoneH + safezoneY,0.128906 * safezoneW,0.011 * safezoneH];
						sM_i_disableFatigue ctrlSetBackgroundColor [0,0,0,0.6];
						sM_i_disableFatigue ctrlCommit 0;
						sM_BIS = d_serverMenu ctrlCreate ["RscPicture", 7131];
						sM_BIS ctrlSetText "\A3\Data_F\Flags\Flag_bis_CO.paa";
						sM_BIS ctrlSetPosition [0.29375 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.04125 * safezoneW,0.044 * safezoneH];
						sM_BIS ctrlCommit 0 };
				comment "----------------------------"; 
				comment "-------CLIENT OPTIONS-------";
				comment "----------------------------"; 
					Admin_fnc_clientOptions = 
					{ 
						If (isNil "clientOptionsTggl") then {clientOptionsTggl = 1};
						If (clientOptionsTggl == 1) then { [["Give_Options_To_Players"],{
								Admin_open_customOptions = {
									disableSerialization;
									display_Options = (findDisplay 46) createDisplay "RscDisplayEmpty";
									showChat true;
									ctrl_OpTitle = display_Options ctrlCreate ["RscText", 7132];
									ctrl_OpTitle ctrlSetText "    Admin      |      Custom Options";
									ctrl_OpTitle ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.148 * safezoneH + safezoneY,0.159844 * safezoneW,0.033 * safezoneH];
									ctrl_OpTitle ctrlSetTextColor [1,1,1,1];
									ctrl_OpTitle ctrlSetBackgroundColor [0.5,-1,-1,1];
									ctrl_OpTitle ctrlCommit 0;
									ctrl_OpTitleFrame = display_Options ctrlCreate ["RscFrame", 7133];
									ctrl_OpTitleFrame ctrlSetText "Helped created by J-Wolf and E1.";
									ctrl_OpTitleFrame ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.137 * safezoneH + safezoneY,0.170156 * safezoneW,0.055 * safezoneH];
									ctrl_OpTitleFrame ctrlCommit 0;
									ctrl_OpFrame = display_Options ctrlCreate ["RscFrame", 7134];
									ctrl_OpFrame ctrlSetPosition [0.412344 * safezoneW + safezoneX,0.203 * safezoneH + safezoneY,0.170156 * safezoneW,0.176 * safezoneH];
									ctrl_OpFrame ctrlCommit 0;
									ctrl_OpLeftMenu = display_Options ctrlCreate ["RscText", 7135];
									ctrl_OpLeftMenu ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.214 * safezoneH + safezoneY,0.04125 * safezoneW,0.154 * safezoneH];
									ctrl_OpLeftMenu ctrlSetBackgroundColor [0,0,0,1];
									ctrl_OpLeftMenu ctrlCommit 0;
									ctrl_OpRightMenu = display_Options ctrlCreate ["RscText", 7136];
									ctrl_OpRightMenu ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.214 * safezoneH + safezoneY,0.118594 * safezoneW,0.154 * safezoneH];
									ctrl_OpRightMenu ctrlSetBackgroundColor [0,0,0,0.8];
									ctrl_OpRightMenu ctrlCommit 0;
									ctrl_OpExit = display_Options ctrlCreate ["RscButton", 7137];
									ctrl_OpExit ctrlSetText "X";
									ctrl_OpExit ctrlSetPosition [0.556719 * safezoneW + safezoneX,0.148 * safezoneH + safezoneY,0.020625 * safezoneW,0.033 * safezoneH];
									ctrl_OpExit ctrlSetBackgroundColor [0,0,0,1];
									ctrl_OpExit ctrlSetTooltip "Close";
									ctrl_OpExit ctrladdEventHandler ["ButtonClick", { display_Options closeDisplay 0 }];
									ctrl_OpExit ctrlCommit 0;
									ctrl_OpText1 = display_Options ctrlCreate ["RscText", 7138];
									ctrl_OpText1 ctrlSetText ("Welcome, " + (name player) + ".");
									ctrl_OpText1 ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.214 * safezoneH + safezoneY,0.118594 * safezoneW,0.055 * safezoneH];
									ctrl_OpText1 ctrlCommit 0;
									ctrl_OpText2 = display_Options ctrlCreate ["RscText", 7139];
									ctrl_OpText2 ctrlSetText "View Distance";
									ctrl_OpText2 ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.2635 * safezoneH + safezoneY,0.118594 * safezoneW,0.055 * safezoneH];
									ctrl_OpText2 ctrlCommit 0;
									ctrl_OpText3 = display_Options ctrlCreate ["RscText", 7140];
									ctrl_OpText3 ctrlSetText "Disable Fatigue";
									ctrl_OpText3 ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.313 * safezoneH + safezoneY,0.118594 * safezoneW,0.055 * safezoneH];
									ctrl_OpText3 ctrlCommit 0;
									ctrl_OpLine1 = display_Options ctrlCreate ["RscText", 7141];
									ctrl_OpLine1 ctrlSetText "----------------------------------";
									ctrl_OpLine1 ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.203 * safezoneH + safezoneY,0.113437 * safezoneW,0.033 * safezoneH];
									ctrl_OpLine1 ctrlCommit 0;
									ctrl_OpLine2 = display_Options ctrlCreate ["RscText", 7142];
									ctrl_OpLine2 ctrlSetText "----------------------------------";
									ctrl_OpLine2 ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.346 * safezoneH + safezoneY,0.113437 * safezoneW,0.033 * safezoneH];
									ctrl_OpLine2 ctrlCommit 0;
									ctrl_OpLine3 = display_Options ctrlCreate ["RscText", 7143];
									ctrl_OpLine3 ctrlSetText "----------------------------------";
									ctrl_OpLine3 ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.214 * safezoneH + safezoneY,0.0360937 * safezoneW,0.011 * safezoneH];
									ctrl_OpLine3 ctrlCommit 0;
									ctrl_OpLine4 = display_Options ctrlCreate ["RscText", 7144];
									ctrl_OpLine4 ctrlSetText "----------------------------------";
									ctrl_OpLine4 ctrlSetPosition [0.4175 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0360937 * safezoneW,0.011 * safezoneH];
									ctrl_OpLine4 ctrlCommit 0;
									ctrl_OpHint = display_Options ctrlCreate ["RscText", 7145];
									ctrl_OpHint ctrlSetText "[Number pad 7] Re-open this menu.";
									ctrl_OpHint ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.118594 * safezoneW,0.033 * safezoneH];
									ctrl_OpHint ctrlCommit 0;
									ctrl_Op_cb_Fatigue = display_Options ctrlCreate ["RscCheckbox", 7147];
									ctrl_Op_cb_Fatigue ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.020625 * safezoneW,0.033 * safezoneH];
									ctrl_Op_cb_Fatigue ctrladdEventHandler ["ButtonClick", {
										If (!Fatigue_disabled) then { Fatigue_disabled = true } else { Fatigue_disabled = false };
										If (Fatigue_disabled) then { EH_noFatigue = player addEventHandler ["Respawn", { player enableFatigue false }] Hint "EH added (Fatigue Disabled)."
											} else { player removeEventHandler ["Respawn", EH_noFatigue] Hint "EH removed (Fatigue Enabled)." }}];
									ctrl_Op_cb_Fatigue ctrlCommit 0;
									ctrl_Op_edit_VD = display_Options ctrlCreate ["RscEdit", 7148];
									ctrl_Op_edit_VD ctrlSetText str (viewDistance);
									ctrl_Op_edit_VD ctrlSetPosition [0.422656 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.0309375 * safezoneW,0.022 * safezoneH];
									ctrl_Op_edit_VD ctrlSetBackgroundColor [1,1,1,0.5];
									ctrl_Op_edit_VD ctrladdEventHandler ["KeyDown", "if (_this select 1 == 28) then { newVD = parseNumber (ctrlText ctrl_Op_edit_VD) setViewDistance newVD VD_updated = true }"];
									ctrl_Op_edit_VD ctrlCommit 0;
								comment "Load Saved States of Controls";
									If (isNil "Fatigue_disabled") then {Fatigue_disabled = false };
									If (Fatigue_disabled) then {ctrl_Op_cb_Fatigue cbSetChecked true };
									If (isNil "VD_updated") then {VD_updated = false };
									If (VD_updated) then {ctrl_Op_edit_VD ctrlSetText str newVD }};
								waitUntil { !(IsNull (findDisplay 46)) };
								Admin_bind_customOptions = (findDisplay 46) displayaddEventHandler ["KeyDown", "if (_this select 1 == 71) then {[] spawn Admin_open_customOptions;}"];
								hint "Admin: Press Number-pad 7 to open custom options menu.";
								waitUntil { not alive player };
								waitUntil { alive player };
								[] spawn Admin_open_customOptions }] remoteExec ["Spawn",0,"customOptions"];
							titleText ["<t color='#42D6FC'>clientOptions </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] clientOptionsTggl = 0;
						} else { [[],{
								display_Options closeDisplay 0 systemChat "Admin: CustomOptions display closed." player removeEventHandler ["Respawn", EH_noFatigue] player enableFatigue true systemChat "Admin: No Fatigue Disabled." }] remoteExec ["spawn",0];
							[[],{comment "do nothing at all";}] remoteExec ["spawn",0,"customOptions"];
							playSound "hint" titleText ["<t color='#42D6FC'>clientOptions </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] clientOptionsTggl = 1 }};
				comment "----------------------------"; 
				comment "-------SCROLL MENUS---------";
				comment "----------------------------"; 
					comment "Target Menu";
						Admin_open_targetMenu = { onEachFrame { If (name cursorTarget == "Admin") then {
									drawIcon3D ['A3\ui_f_curator\Data\CfgCurator\entity_disabled_ca.paa', [0,1,1,1], [visiblePosition cursorTarget select 0, visiblePosition cursorTarget select 1, (getPosATL cursorTarget select 2) + 1], 1, 1, 0, typeOf cursorTarget, 2, 0.05, 'PuristaMedium', 'center', false];
								} else { drawIcon3D ['A3\ui_f_curator\Data\CfgCurator\entity_disabled_ca.paa', [0,1,1,1], [visiblePosition cursorTarget select 0, visiblePosition cursorTarget select 1, (getPosATL cursorTarget select 2) + 1], 1, 1, 0, name cursorTarget, 2, 0.05, 'PuristaMedium', 'center', false] }};
							[] spawn { waitUntil {!alive player} onEachFrame {} } removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player onEachFrame {} }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player [] spawn Admin_open_mainMenu; onEachFrame {} }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Unflip Object</t>", {cursorTarget call Admin_fnc_unflip }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Attach-To-Self</t>", {call Admin_targetAttach }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Detach Object</t>", {call Admin_targetDetach }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Delete Object</t>", {call Admin_targetDelete }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Repair (Heal)</t>", {call Admin_targetRepair }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Destroy (Kill)</t>", {call Admin_targetDestroy }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Refuel (Stamina)</t>", {call Admin_targetRefuel }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Empty Fuel</t>", {call Admin_targetEmptyFuel }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>[+]Arsenal</t>", {call Admin_targetAddArsenal }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Strip Gear</t>", {call Admin_targetStripGear }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Give GodMode</t>", {call Admin_targetGodON }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Remove GodMode</t>", {call Admin_targetGodOFF }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Add AI-Ignore</t>", {call Admin_targetCaptiveON }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Remove AI-Ignore</t>", {call Admin_targetCaptiveOFF }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Add USA Flag</t>", {call Admin_targetAddFlag }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Remove USA Flag</t>", {call Admin_targetRemoveFlag }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Lock Vehicle</t>", {cursorTarget lock true }];
							player addAction ["Admin: <t color='#42D6FC'>Target: </t><t color='#ff6600'>Unlock Vehicle</t>", {cursorTarget lock false }]};
						Admin_targetAttach = { cursorTarget attachTo [player,[0.2,1.5,0]] Hint format ["[%1] has been attached to you.", (name cursorTarget)] };
						Admin_targetDetach = { detach cursorTarget Hint format ["[%1] has been detached from you.", (name cursorTarget)] };
						Admin_targetDelete = { Hint format ["[%1] has been deleted.", (name cursorTarget)] deleteVehicle cursorTarget};
						Admin_targetGodON = { cursorTarget allowDamage false Hint format ["[%1] now has damage turned off.", (name cursorTarget)]};
						Admin_targetGodOFF = { cursorTarget allowDamage true Hint format ["[%1] now has damage turned on.", (name cursorTarget)] };
						Admin_targetCaptiveON = { cursorTarget setCaptive true Hint format ["[%1] will now be ignored by AI.", (name cursorTarget)] };
						Admin_targetCaptiveOFF = { cursorTarget setCaptive false Hint format ["[%1] will now be noticed by AI.", (name cursorTarget)] };
						Admin_targetDestroy = { if (cursorTarget in allPlayers) then { forceRespawn cursorTarget Hint format ["[%1] has been force-respawned.", (name cursorTarget)];
							} else { cursorTarget setDamage 1 Hint format ["[%1] (%2) has been destroyed.", (name cursorTarget), (typeOf cursorTarget)] }};
						Admin_targetRepair = { cursorTarget setDamage 0 Hint format ["[%1] has been fully repaired.", (name cursorTarget)] };
						Admin_targetEmptyFuel = { cursorTarget setFuel 0 Hint format ["[%1] has been depleted of fuel.", (name cursorTarget)] };
						Admin_targetRefuel = {
							If (cursorTarget in allPlayers) then { cursorTarget setFatigue 0 [["Your stamina has been recharged."],{ player setFatigue 0 }] remoteExec ["spawn",cursorTarget] Hint format ["[%1] had his stamina recharged.", (name cursorTarget)];
							} else { cursorTarget setFuel 1 Hint format ["[%1] (%2) has been refueled.", (name cursorTarget), (typeOf cursorTarget)] }};
						Admin_targetAddArsenal = { ["AmmoboxInit",[cursorTarget,true]] call BIS_fnc_arsenal Hint format ["[%1] is now a full arsenal.", (name cursorTarget)] };
						Admin_targetAddFlag = { cursorTarget forceFlagTexture "\A3\Data_F\Flags\Flag_us_CO.paa" Hint format ["[%1] has become patriotic.", (name cursorTarget)] };
						Admin_targetRemoveFlag = { cursorTarget forceFlagTexture "" Hint format ["[%1] no longer has a flag.", (name cursorTarget)] };
						Admin_targetStripGear = {
							removeAllWeapons cursorTarget;
							removeAllAssignedItems cursorTarget;
							removeAllContainers cursorTarget;
							removeHeadgear cursorTarget;
							removeGoggles cursorTarget;
							removeAllItems cursorTarget;
							removeVest cursorTarget;
							removeBackpack cursorTarget;
							Hint format ["[%1] has been stripped of his gear.", (name cursorTarget)] };
					comment "Player Menu";
						Admin_open_playerMenu = { removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player []spawn Admin_open_mainMenu }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>GetIn</t>", {player moveInAny cursorTarget playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>GetOut</t>", {moveOut player;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Heal</t>", {player setDamage 0;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Suicide</t>", {player setDamage 1;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Attach</t>", {player attachTo [cursorTarget, [0,0,0]];playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Detach</t>", {detach player;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>God [ON]</t>", {player allowDamage false;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>God [OFF]</t>", {player allowDamage true;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Ignore [ON]</t>", {player setCaptive true;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>Ignore [OFF]</t>", {player setCaptive false;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>[+] Arsenal</t>", {call Admin_playerAddArsenal }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>[+] Flag</t>", {call Admin_playerAddFlag }];
							player addAction ["Admin: <t color='#42D6FC'>Player: </t><t color='#ff6600'>[-] Flag</t>", {call Admin_playerRemoveFlag }] };
						Admin_playerAddArsenal = {["AmmoboxInit",[player,true]] call BIS_fnc_arsenal playSound "Hint" };
						Admin_playerAddFlag = { player forceFlagTexture "\A3\Data_F\Flags\Flag_us_CO.paa" playSound "Hint" };
						Admin_playerRemoveFlag = { player forceFlagTexture " "playSound "Hint" };
					comment "Vehicle Menu";
						Admin_open_vehicleMenu = { removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player  []spawn Admin_open_mainMenu }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>[+] USATrail</t>", {call Admin_addUSASmokeTrail }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Repair</t>", {vehicle player setDamage 0;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Destroy</t>", {vehicle player setDamage 1;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Refuel</t>", {vehicle player setFuel 1;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Nofuel</t>", {vehicle player setFuel 0;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Attach</t>", {vehicle player attachTo [cursorTarget, [0,0,0]];playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Detach</t>", {detach vehicle player;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>God [ON]</t>", {vehicle player allowDamage false;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>God [OFF]</t>", {vehicle player allowDamage true;playSound "Hint" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>[+] Arsenal</t>", {call Admin_vehicleAddArsenal }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>[+] Flag</t>", {call Admin_vehicleAddFlag }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>[-] Flag</t>", {call Admin_vehicleRemoveFlag }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Lock</t>", {vehicle player lock true Hint "locked" }];
							player addAction ["Admin: <t color='#42D6FC'>Vehicle: </t><t color='#ff6600'>Unlock</t>", {vehicle player lock false Hint "unlocked" }] };
						Admin_addUSASmokeTrail = {
							_expl1 = "G_40mm_SmokeRed" createVehicle position vehicle player;
							_expl1 attachTo [vehicle player, [-0.1, 0.1, 0.15], "Pelvis"];
							_expl1 setVectorDirAndUp [ [0.5, 0.5, 0], [-0.5, 0.5, 0] ];
							_expl2 = "G_40mm_Smoke" createVehicle position vehicle player;
							_expl2 attachTo [vehicle player, [0, 0.15, 0.15], "Pelvis"];
							_expl2 setVectorDirAndUp [ [1, 0, 0], [0, 1, 0] ];
							_expl3 = "G_40mm_SmokeBlue" createVehicle position vehicle player;
							_expl3 attachTo [vehicle player, [0.1, 0.1, 0.15], "Pelvis"]; 
							_expl3 setVectorDirAndUp [ [0.5, -0.5, 0], [0.5, 0.5, 0] ] Hint "God, bless the Ungreatful United States of America." };
						Admin_vehicleAddArsenal = { ["AmmoboxInit",[vehicle player,true]] call BIS_fnc_arsenal Hint format ["[%1] is now a full arsenal.", (name (vehicle player))] };
						Admin_vehicleAddFlag = { vehicle player forceFlagTexture "\A3\Data_F\Flags\Flag_us_CO.paa" Hint "Serving with pride." };
						Admin_vehicleRemoveFlag = { vehicle player forceFlagTexture "" playSound "Hint" };
					comment "Spawn Menu";
						Admin_open_CustomVehicles = { removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", { removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", { removeAllActions player []spawn Admin_open_mainMenu }];
							player addAction ["Admin: <t color='#FF8080'>Delete: </t><t color='#BDBDBD'>Vehicle</t>", { deleteVehicle vehicle player }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>AmmoBox</t>", { call Admin_spawnVAmmoBox }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Arsenal</t>", { call Admin_spawnArsenal }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Quad Bike (BOMB)</t>", { call Admin_spawnQuadBomb }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Quad Bike (GMG)</t>", { call Admin_spawnQuadGMG }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Quad Bike (HMG)</t>", { call Admin_spawnQuadHMG }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>MH-9 Hummingbird</t>", { call Admin_spawnHummingbird }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>AH-9 Pawnee</t>", { call Admin_spawnPawnee }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Prowler (Armed)</t>", { call Admin_spawnProwler }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Offroad (Mk6)</t>", { call Admin_spawnOffroadMortar }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Offroad (GMG)</t>", { call Admin_spawnOffroadGMG }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Offroad (HMG)</t>", { call Admin_spawnOffroadHMG }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>RHIB (GMG)</t>", { call Admin_spawnRHIBgmg }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>RHIB (HMG)</t>", { call Admin_spawnRHIBhmg }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>Caesar BTT (Racing)</t>", { call Admin_spawnCaesarBTTRacing }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>F/A-181 Black Wasp II</t>", { call Admin_spawnBlackWasp }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>BoatCar</t>", { call Admin_spawnBoatCar }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>UCAV Sentinel</t>", { call Admin_spawnUCAV }];
							player addAction ["Admin: <t color='#42D6FC'>Spawn: </t><t color='#ff6600'>InvisiDrone</t>", { call Admin_spawnInvisiDrone }] };
						Admin_spawnQuadBomb = {
							_quad = createVehicle ["B_G_Quadbike_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret = createVehicle ["B_GMG_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret attachTo [_quad, [0.1,0,0.6]];
							_charge1 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge1 attachTo [_quad, [-0.3, 0.63, -0.53]];
							_charge2 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge2 attachTo [_quad, [-0.3, 0.74, -0.53]];
							_charge3 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge3 attachTo [_quad, [-0.3, 0.85, -0.53]];
							_charge4 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge4 attachTo [_quad, [0.3, 0.63, -0.53]];
							_charge4 setDir 180;
							_charge5 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge5 attachTo [_quad, [0.3, 0.74, -0.53]];
							_charge5 setDir 180;
							_charge6 = "ModuleExplosive_DemoCharge_F" createVehicle position _quad;
							_charge6 attachTo [_quad, [0.3, 0.85, -0.53]];
							_charge6 setDir 180;
							_charge7 = "ModuleExplosive_SatchelCharge_F" createVehicle position _quad;
							_charge7 attachTo [_quad, [-0.35, -0.85, -0.45]];
							_charge8 = "ModuleExplosive_SatchelCharge_F" createVehicle position _quad;
							_charge8 attachTo [_quad, [0.38, -0.84, -0.45]];
							_detonater = _quad addAction ["<t color='#B40404'>Detonate Quadbike</t>", 
							"{_x setDamage 1;} forEach nearestObjects [vehicle player, ['all'], 20];createVehicle ['Bo_GBU12_LGB',getPosATL vehicle player,[],0,'CAN_COLLIDE'];"];
							player moveInDriver _quad playSound "Hint" systemChat "Quad (BOMB) Spawned." };
						Admin_spawnInvisiDrone = { [] spawn {
								InvisiDrone = [getPosATL player, 0, "B_UAV_06_medical_F", west] call BIS_fnc_spawnVehicle createVehicleCrew (InvisiDrone select 0);
								InvisiDrone allowDamage false;
								InvisiDrone setObjectTextureGlobal [0,'\A3\nonExistantFile.paa'] sleep 1;
								InvisiDrone addWeaponTurret ["missiles_titan_static", [-1]];
								InvisiDrone addMagazineTurret ["1Rnd_GAT_missiles", [-1]];
								InvisiDrone addMagazineTurret ["1Rnd_GAA_missiles", [-1]] }};
						Admin_spawnUCAV = { _uav = [getPosATL player, 0, "B_uav_05_F", west] call BIS_fnc_spawnVehicle createVehicleCrew (_uav select 0) [_uav] joinSilent group player };
						Admin_spawnBoatCar = { [] spawn { player setVelocity [0,0,10] sleep 0.5;
								_quad = createVehicle ["B_G_Quadbike_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
								_quad setDir direction player;
								_rhib = createVehicle ["B_G_Boat_Transport_02_F",getPosATL player,[],0,"CAN_COLLIDE"];
								_rhib attachTo [_quad, [0, 0, 0]];
								_hmg = createVehicle ["B_HMG_01_high_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
								_hmg attachTo [_rhib, [0.25,1.5,1]] player moveInDriver _quad playSound "Hint" systemChat "BoatCar Spawned." } };
						Admin_spawnVAmmoBox = {
							_box = createVehicle ["Land_Ammobox_rounds_F",getPos player,[],0,"CAN_COLLIDE"];
							_box attachTo [player, [0, 1.5, 1.2]] detach _box;
							_box setDir direction player ["AmmoboxInit",[_box,true]] call BIS_fnc_arsenal player playMove "ainvpercmstpsraswrfldnon_putdown_amovpercmstpsraswrfldnon" playSound "Hint" systemChat "Arsenal Spawned." };
						Admin_spawnArsenal = {
							_flagpole = createVehicle ["Flag_ARMEX_F",getPos player,[],0,"CAN_COLLIDE"];
							_arsenal = createVehicle ["B_supplyCrate_F",getPos player,[],0,"CAN_COLLIDE"];
							_flagpole setDir direction player;
							_arsenal setDir direction player;
							_arsenal attachTo [_flagpole, [-0.1,-0.4,-3.2]] ["AmmoboxInit",[_arsenal,true]] call BIS_fnc_arsenal;
							_flagpole allowDamage false;
							_arsenal allowDamage false playSound "Hint" systemChat "Arsenal Spawned." };
						Admin_spawnPawnee = {
							_pawnee = createVehicle ["B_Heli_Light_01_armed_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_pawnee setDir direction player player moveInDriver _pawnee playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnHummingbird = {
							_bird = createVehicle ["B_Heli_Light_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_bird setDir direction player player moveInDriver _bird playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnRHIBhmg = {
							_rhib = createVehicle ["B_G_Boat_Transport_02_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_hmg = createVehicle ["B_HMG_01_high_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_hmg attachTo [_rhib, [0.25,1.5,1]];
							_rhib setDir direction player player moveInDriver _rhib playSound "Hint" SystemChat "Vehicle Spawned." };
						Admin_spawnRHIBgmg = {
							_rhib = createVehicle ["B_G_Boat_Transport_02_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_hmg = createVehicle ["B_GMG_01_high_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_hmg attachTo [_rhib, [0.25,1.5,1]];
							_rhib setDir direction player player moveInDriver _rhib playSound "Hint" SystemChat "Vehicle Spawned." };
						Admin_spawnProwler = {
							_prowler = createVehicle ["B_LSV_01_armed_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_arsenal = createVehicle ["B_supplyCrate_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_arsenal attachTo [_prowler, [0,-1.45,0]];
							_prowler setDir direction player player moveInDriver _prowler playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnQuadGMG = {
							_quad = createVehicle ["B_G_Quadbike_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret = createVehicle ["B_GMG_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret attachTo [_quad, [0.1,0,0.6]];
							_ammoBox1 = createVehicle ["Land_Ammobox_rounds_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_ammoBox1 attachTo [_quad, [0.40,-0.937,-0.35]];
							_ammoBox1 setDir 90;
							_ammoBox2 = createVehicle ["Land_Ammobox_rounds_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_ammoBox2 attachTo [_quad, [-0.42,-0.937,-0.35]];
							_ammoBox2 setDir 90;
							_quad setDir direction player player moveInDriver _quad playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnQuadHMG = {
							_quad = createVehicle ["B_G_Quadbike_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret = createVehicle ["B_HMG_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_turret attachTo [_quad, [0.1,0,0.6]];
							_ammoBox1 = createVehicle ["Land_Ammobox_rounds_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_ammoBox1 attachTo [_quad, [0.40,-0.937,-0.35]];
							_ammoBox1 setDir 90;
							_ammoBox2 = createVehicle ["Land_Ammobox_rounds_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_ammoBox2 attachTo [_quad, [-0.42,-0.937,-0.35]];
							_ammoBox2 setDir 90;
							_quad setDir direction player player moveInDriver _quad playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnOffroadMortar = {
							_offroad = createVehicle ["B_G_Offroad_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_offroad setObjectTextureGlobal [0, "#(ARGB,8,8,3)color(0.33,0.31,0.24,0.3)"];
							_mortar = createVehicle ["B_T_Mortar_01_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_mortar attachTo [_offroad, [0,-2,0]];
							_offroad setDir direction player player moveInDriver _offroad playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnOffroadHMG = {
							_offroad = createVehicle ["B_G_Offroad_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_offroad setObjectTextureGlobal [0, "#(ARGB,8,8,3)color(0.33,0.31,0.24,0.3)"];
							_hmgturret = createVehicle ["B_HMG_01_high_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_hmgturret attachTo [_offroad, [0.2,-2,1]];
							_offroad setDir direction player player moveInDriver _offroad playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnOffroadGMG = {
							_offroad = createVehicle ["B_G_Offroad_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_offroad setObjectTextureGlobal [0, "#(ARGB,8,8,3)color(0.33,0.31,0.24,0.3)"];
							_gmgturret = createVehicle ["B_GMG_01_high_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_gmgturret attachTo [_offroad, [0.2,-2,1]];
							_offroad setDir direction player player moveInDriver _offroad playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnHunterAT = {
							_hunter = createVehicle ["B_MRAP_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_titanAT = createVehicle ["B_static_AT_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_titanAT attachTo [_hunter, [0,-2.65,1.6]];
							_hunter setDir direction player player moveInDriver _hunter playSound "Hint" systemChat "Vehicle Spawned." };
						Admin_spawnHunterAA = {
							_hunter = createVehicle ["B_MRAP_01_F",getPosATL player,[],0,"CAN_COLLIDE"];
							_titanAA = createVehicle ["B_static_AA_F",getPosATL player,[],0,"CAN_COLLIDE"]; 
							_titanAA attachTo [_hunter, [0,-2.65,1.6]];
							_hunter setDir direction player player moveInDriver _hunter playSound "Hint";systemChat "Vehicle Spawned." };
						Admin_spawnCaesarBTTRacing = {
							_plane = createVehicle ["C_Plane_Civil_01_racing_F",getPosATL player,[],0,"FLY"];
							_plane setDir direction player;
							_pos = getPosATL player _pos set [2, 500] _plane setPosATL _pos;
							_plane setVelocity [150, 0, 0] player moveInDriver _plane playSound "Hint";systemChat "Vehicle Spawned." };
						Admin_spawnBlackWasp = {
							_plane = createVehicle ["B_Plane_Fighter_01_F",getPosATL player,[],0,"FLY"];
							_plane setDir direction player;
							_pos = getPosATL player; _pos set [2, 500] _plane setPosATL _pos;
							_plane setVelocity [250, 0, 0] player moveInDriver _plane playSound "Hint" systemChat "Vehicle Spawned." };
					comment "Cheat Menu";
						Admin_open_cheatMenu = { removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player;}];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player; []spawn Admin_open_mainMenu;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>Bullet-Changer</t>", {[] call Admin_open_ammoSelectMenu;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>GodMode</t>", {[] call Admin_god;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>InfAmmo</t>", {[] call Admin_infAmmo;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>InfAmmoGroup</t>", {[] call Admin_infAmmoGroup;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>InfStamina</t>", {[] call Admin_infStamina;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>3D-ESP | Friendly Players</t>", {[] call Admin_esp;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>Map-ESP| Friendly Players</t>", {[] call Admin_mesp;}];
							player addAction ["Admin: <t color='#42D6FC'>Cheats: </t><t color='#ff6600'>3D-ESP | Enemy AI</t>", {[] call Admin_hostileAIEsp;}]};
						Admin_god = {
							If (isNil "GodTggle") then {GodTggle = 1};
							If (GodTggle == 1) then { GodTggle = 0;
								player setCaptive true;
								player allowDamage false;
								vehicle player allowDamage false;
								EH_godMode = player addEventHandler ["Respawn", {
									player setCaptive true;
									player allowDamage false;
									(vehicle player) allowDamage false }];
								titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
								playSound "Hint";
							} else { GodTggle = 1;
								player setCaptive false;
								player allowDamage true;
								vehicle player allowDamage true;
								player removeEventHandler ["Respawn", EH_godMode];
								titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
								playSound "Hint" }};
						Admin_infAmmo = {
							If (isNil "infAmmoTggle") then {infAmmoTggle = 1};
							If (infAmmoTggle == 1) then { infAmmoTggle = 0;
								titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" [] spawn {
									while {infAmmoTggle == 0} do {
										player setVehicleAmmo 1;
										vehicle player setVehicleAmmo 1;
										sleep 0.5 }};
							} else { infAmmoTggle = 1 titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" }};
						Admin_infAmmoGroup = {
							If (isNil "infAmmoGroupTggle") then {infAmmoGroupTggle = 1};
							If (infAmmoGroupTggle == 1) then { infAmmoGroupTggle = 0;
								titleText ["<t color='#42D6FC'>INFAMMOGroup </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint";
								[] spawn {
									while {infAmmoGroupTggle == 0} do { { _x setVehicleAmmo 1 vehicle _x setVehicleAmmo 1 } forEach units group player sleep 0.5 }};
							} else { infAmmoGroupTggle = 1 titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" }};
						Admin_infStamina = {
							If (isNil "infStaminaTggle") then {infStaminaTggle = 1};
							If (infStaminaTggle == 1) then { infStaminaTggle = 0 player enableFatigue false EH_cardio = player addEventHandler ["Respawn", {player enableFatigue false;}];
								titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint";
							} else { infStaminaTggle = 1 player enableFatigue true player removeEventHandler ["Respawn", EH_cardio];
								titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" }};
						Admin_esp = {
							If (isNil 'AdminESPTggle') then {AdminESPTggle = 1};
							If (AdminESPTggle == 1) then { AdminESPTggle = 0;
								titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" [("
								AdminEsp = addMi"+"ssionEve"+"ntHandler ['Dr"+"aw"+"3D',{ {
								If ((side _x != side player) && (getPlayerUID _x != '') && ((player distance _x) < 1500)) then {
								dr"+"awIcon"+"3D['', [0, 0, 1, 1], [visi"+"blePosi"+"tion _x select 0, visi"+"blePo"+"sition _x select 1, (getPosATL _x select 2) + 2], 0.1, 0.1, 45, (format['%1 - %2m', name _x, round(player distance _x)]), 1, 0.04];
								} else { if ((getPlayerUID _x != '') && ((player distance _x) < 1500) && (name _x != name player)) then { d"+"rawIc"+"on3D['', [0, 0.2, 1, 1], [visi"+"blePos"+"ition _x select 0, visib"+"lePosi"+"tion _x select 1, (getPosATL _x select 2) + 2], 0.1, 0.1, 45, (format['%1 - %2m', name _x, round(player distance _x)]), 1, 0.04] }}} foreach call Admin_fini_fnc_plrs }] ")] call Admin_fini_fnc_compile;
							} else { AdminESPTggle = 1 titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint";
								[("re"+"moveMiss"+"ionEven"+"tHandler['Dr"+"a"+"w3D',AdminEsp];")] call Admin_fini_fnc_compile }};
						Admin_mesp = {
							If (isNil "mespTggle") then {mespTggle = 1};
							If (mespTggle == 1) then { playSound "Hint" titleText ["<t color='#42D6FC'>MAPESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] mespTggle = 0;
							} else { playSound "Hint" titleText ["<t color='#42D6FC'>MAPESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] mespTggle = 1 };
							[] spawn { [(" while {mespTggle == 0} do { _units = call Admin_fini_fnc_plrs _unitCount = count _units;
								For '_i' from 0 to (_unitCount-1) do { _unit = _units select _i;
								If (alive _unit) then { del"+"eteMar"+"kerL"+"ocal('Admin_plr' + (str _i));
								_namePlayer = name _unit;
								_mark_player = 'Admin_plr' + (str _i);
								_mark_player = crea"+"teM"+"arker"+"Loc"+"al[_mark_player, getPos _unit];
								_mark_player setM"+"ark"+"er"+"Type"+"Local 'wa"+"ypo"+"int';
								_mark_player set"+"Ma"+"rk"+"erPo"+"sLoc"+"al(getPos _unit);
								_mark_player set"+"Marker"+"Col"+"orLo"+"cal 'Co"+"lorB"+"lue';
								_mark_player setM"+"ark"+"erT"+"ext"+"Loc"+"al format['%1 - %2', _namePlayer, round(player di"+"st"+"ance _unit)] }} sleep 0.5 };
								For '_i' from 0 to 500 do { de"+"l"+"ete"+"Ma"+"rkerLo"+"cal('Admin_plr' + (str _i)) } ")] call Admin_fini_fnc_compile }};
						Admin_hostileAIEsp = {
							If (isNil 'AdminhostileAIESPTggle') then {AdminhostileAIESPTggle = 1};
							If (AdminhostileAIESPTggle == 1) then { AdminhostileAIESPTggle = 0;
								titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint";
								AdminhostileAIEsp = addMissionEventHandler ['Draw3D',{{
							If ((side _x != side player) && ((player distance _x) < 1500)) then { drawIcon3D["", [1, 0, 0, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%2 : %1m", round(player distance _x), name _x]), 1, 0.04, "EtelkaNarrowMediumPro"];
								} else { If (((player distance _x) < 1500) && (name _x != name player)) then { drawIcon3D["", [0, 0.5, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%2 : %1m", round(player distance _x), name _x]), 1, 0.04, "EtelkaNarrowMediumPro"] }}} forEach call Admin_fini_fnc_hostileAI }];
							} else { AdminhostileAIESPTggle = 1 titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true] playSound "Hint" removeMissionEventHandler['Draw3D',AdminhostileAIEsp] }};
					comment "Selective Ammo Menu";
						Admin_open_ammoSelectMenu = { removeAllActions player;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", {removeAllActions player;}];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", {removeAllActions player; [] spawn Admin_open_cheatMenu;}];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>Dragon's Breath</t>", { If (!isNil "FEH_missile") then {player removeEventHandler["fired", FEH_missile] } removeAllActions player;
							player addAction ["<t color='#FF0000'>Extinguish Fire</t>", { player removeEventHandler["fired", FEH_missile];
									{ If (typeOf _x == "test_EmptyObjectForFireBig") then { deleteVehicle _x }} forEach nearestObjects [player, ["all"], 10000] - allUnits removeAllActions player }];
								FEH_missile = player addEventHandler ["fired", { dragonBullet = nearestObject [_this select 0,_this select 4] dragonBulletPos = getPosASL dragonBullet;
									fireBall = createVehicle ["test_EmptyObjectForFireBig",dragonBulletPos,[],0,"CAN_COLLIDE"];
									If (!(cursorTarget == ObjNull)) then { bigFire = createVehicle ["test_EmptyObjectForFireBig",dragonBulletPos,[],0,"CAN_COLLIDE"] bigFire attachTo [dragonBullet,[0,0,0]] } [] spawn { _weapdir = player weaponDirection currentWeapon player _dist = 11 fireBall setPosASL [
											(dragonBulletPos select 0) + (_weapdir select 0)*_dist,
											(dragonBulletPos select 1) + (_weapdir select 1)*_dist,
											(dragonBulletPos select 2) + (_weapdir select 2)*_dist ];
										_up = vectorUp dragonBullet;
										fireBall setVectorDirAndUp[_weapdir,_up];
										fireBall setVelocity velocity dragonBullet;
										sleep 3.5;
										deleteVehicle fireBall } [] spawn {
										sleep 0.1;
										detach bigFire;
										bigFire attachTo [cursorTarget,[0,0,0]];
										sleep 3.5;
										deleteVehicle bigFire }}] playSound "Hint";
								systemChat "Fire balls Loaded into Magazine xD.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>82mm HE Mortar Shells</t>", {
								If (!isNil "FEH_missile") then {player removeEventHandler["fired", FEH_missile] } FEH_missile = player addEventHandler ["fired", {
								_bullet = nearestObject [_this select 0,_this select 4];
								_bulletpos = getPosASL _bullet;
								_o = "Sh_82mm_AMOS_LG" createVehicle _bulletpos;
								_weapdir = player weaponDirection currentWeapon player;
								_dist = 11;
								_o setPosASL [
								(_bulletpos select 0) + (_weapdir select 0)*_dist,
								(_bulletpos select 1) + (_weapdir select 1)*_dist,
								(_bulletpos select 2) + (_weapdir select 2)*_dist ];
								_up = vectorUp _bullet;
								_o setVectorDirAndUp[_weapdir,_up];
								_o setVelocity velocity _bullet }] playSound "hint";
								systemChat "82mm HE Mortar Shells Loaded into Magazine xD.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>GBU-12</t>", {
								If (!isNil "FEH_missile") then {player removeEventHandler["fired", FEH_missile];};
								FEH_missile = player addEventHandler ["fired", {
								_bullet = nearestObject [_this select 0,_this select 4];
								_bulletpos = getPosASL _bullet;
								_o = "Bo_GBU12_LGB" createVehicle _bulletpos;
								_weapdir = player weaponDirection currentWeapon player;
								_dist = 11;
								_o setPosASL [
								(_bulletpos select 0) + (_weapdir select 0)*_dist,
								(_bulletpos select 1) + (_weapdir select 1)*_dist,
								(_bulletpos select 2) + (_weapdir select 2)*_dist ];
								_up = vectorUp _bullet;
								_o setVectorDirAndUp[_weapdir,_up];
								_o setVelocity velocity _bullet }] playSound "hint";
								systemChat "GBU-12 Loaded into Magazine xD.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>12.7x108 mm Russian</t>", {
								If (!isNil "FEH_missile") then {player removeEventHandler["fired", FEH_missile];};
								FEH_missile = player addEventHandler ["fired", {
								_bullet = nearestObject [_this select 0,_this select 4];
								_bulletpos = getPosASL _bullet;
								_o = "B_127x108_Ball" createVehicle _bulletpos;
								_weapdir = player weaponDirection currentWeapon player;
								_dist = 11;
								_o setPosASL [
								(_bulletpos select 0) + (_weapdir select 0)*_dist,
								(_bulletpos select 1) + (_weapdir select 1)*_dist,
								(_bulletpos select 2) + (_weapdir select 2)*_dist ];
								_up = vectorUp _bullet;
								_o setVectorDirAndUp[_weapdir,_up];
								_o setVelocity velocity _bullet }];
								playSound "hint";
								systemChat "12.7x108mm Russian Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>40 mm APFSDS</t>", {
								If (!isNil "FEH_missile") then {player removeEventHandler["Fired", FEH_missile];};
								FEH_missile = player addEventHandler ["Fired", {
								_bullet = nearestObject [_this select 0,_this select 4];
								_bulletpos = getPosASL _bullet;
								_o = "B_40mm_APFSDS" createVehicle _bulletpos;
								_weapdir = player weaponDirection currentWeapon player;
								_dist = 11;
								_o setPosASL [
								(_bulletpos select 0) + (_weapdir select 0)*_dist,
								(_bulletpos select 1) + (_weapdir select 1)*_dist,
								(_bulletpos select 2) + (_weapdir select 2)*_dist ];
								_up = vectorUp _bullet;
								_o setVectorDirAndUp[_weapdir,_up];
								_o setVelocity velocity _bullet }] playSound "hint";
								systemChat "40 mm APFSDS Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#ff6600'>40 mm GPR</t>", {
								If (!isNil "FEH_missile") then { player removeEventHandler["Fired", FEH_missile] };
								FEH_missile = player addEventHandler ["fired", {
								_bullet = nearestObject [_this select 0,_this select 4];
								_bulletpos = getPosASL _bullet;
								_o = "B_40mm_GPR" createVehicle _bulletpos;
								_weapdir = player weaponDirection currentWeapon player;
								_dist = 11;
								_o setPosASL [
								(_bulletpos select 0) + (_weapdir select 0)*_dist,
								(_bulletpos select 1) + (_weapdir select 1)*_dist,
								(_bulletpos select 2) + (_weapdir select 2)*_dist ];
								_up = vectorUp _bullet;
								_o setVectorDirAndUp[_weapdir,_up];
								_o setVelocity velocity _bullet }] playSound "hint";
								systemChat "40 mm GPR Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#FF8080'>Destroyer</t>", {
								If (!isNil "FEH_missile") then { player removeEventHandler["fired", FEH_missile] };
								FEH_missile = player addEventHandler ["Fired", { cursorTarget setDamage 1 }] playSound "hint";
								systemChat "Destroyer Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#7CFF7E'>Fixer</t>", {
								If (!isNil "FEH_missile") then { player removeEventHandler["Fired", FEH_missile] };
								FEH_missile = player addEventHandler ["Fired", { cursorTarget setDamage 0; cursorTarget setFuel 1 }] playSound "hint";
								systemChat "Fixer Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#FF8080'>Deleter</t>", {
								If (!isNil "FEH_missile") then { player removeEventHandler["fired", FEH_missile] };
								FEH_missile = player addEventHandler ["fired", { deleteVehicle cursorTarget }] playSound "hint";
								systemChat "Deleter Loaded.";
								systemChat "Admin: Special ammo will be automatically removed upon death." }];
							player addAction ["Admin: <t color='#42D6FC'>ChangeAmmo: </t><t color='#7CFF7E'>Default</t>", { player removeAllEventHandlers "Fired" playSound "hint";
								systemChat "Default Ammo Loaded. Event handlers under [Fired] have been removed." }]};
					comment "Server Menu OLD";
						Admin_deleteMenu = 
						{ 
							removeAllActions player;
							_dR = 0;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", { removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", { removeAllActions player [] spawn Admin_open_serverMenu }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>12000m</t>", { _dR = 12000 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>6000m</t>", { _dR = 6000 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>1280m</t>", { _dR = 1280 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>640m</t>", { _dR = 640 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>320m</t>", { _dR = 320 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>160m</t>", { _dR = 160 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>80m</t>", { _dR = 80 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>40m</t>", { _dR = 40 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>20m</t>", { _dR = 20 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>10m</t>", { _dR = 10 call Admin_deleteRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>DM: </t><t color='#82E0AA'>5m</t>", { _dR = 5 call Admin_deleteRadius }]
						};
						Admin_deleteRadius = 
						{ 
							{deleteVehicle _x;} forEach (nearestObjects [player, ["all"], _dR]);
							playSound "Hint"; 
						};
						Admin_killMenu = 
						{
							removeAllActions player _kR = 0;
							player addAction ["Admin: <t color='#BDBDBD'>[CANCEL]</t>", { removeAllActions player }];
							player addAction ["Admin: <t color='#BDBDBD'>[RETURN]</t>", { removeAllActions player [] spawn Admin_open_serverMenu }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>All</t>", { call Admin_killAll }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>6000m</t>", { _kR = 6000; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>1280m</t>", { _kR = 1280; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>640m</t>", { _kR = 640; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>320m</t>", { _kR = 320; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>160m</t>", { _kR = 160; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>80m</t>", { _kR = 80; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>40m</t>", { _kR = 40; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>20m</t>", { _kR = 20; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>10m</t>", { _kR = 10; call Admin_killRadius }];
							player addAction ["Admin: <t color='#42D6FC'>Server: </t><t color='#ff6600'>KM: </t><t color='#82E0AA'>5m</t>", { _kR = 5; call Admin_killRadius }] 
						};
						Admin_killRadius = 
						{ 
							{ _x setDamage 1; } forEach (nearestObjects [player, ["man"], _kR]);
							playSound "Hint"; 
						};
						Admin_killAll = 
						{
							private["i","v","_case","_pos","_vechList","_vechCount"];
							_vechList = allPlayers;
							_vechCount = count _vechList;
							i = 0;
							For "i" from 0 to _vechCount do { v = _vechList select i  	v setDamage 1 } 
							playSound "Hint" 
						};
				comment "----------------------------"; 
				comment "-------ASSIGN KEYBINDS------";
				comment "----------------------------";
					_escMenu = [] spawn { 
						while {true} do 
						{
							waitUntil { not (isNull (findDisplay 49)) };
							((findDisplay 49) displayCtrl 2) ctrlSetText "Open Admin V1.6A";
							((findDisplay 49) displayCtrl 103) ctrlSetText "Helped created by J-Wolf and E1.";
							((findDisplay 49) displayCtrl 2) ctrladdEventHandler ["ButtonClick",
								{ [] spawn Admin_open_mainMenu }
							]; 
							waitUntil { (isNull (findDisplay 49)) }
						}
					};
				comment "-----------------------------";
				comment "------LOAD COMPLETE----------";
				comment "-----------------------------";
					Admin_isLoaded = true;
					If (Admin_isLoaded) then { ["TaskSucceeded",["","Admin: <t color='#42D6FC'>Initialization Complete.</t>"]] call BIS_fnc_showNotification };
				comment "----------------------------"; 
				comment "-Admin Menu Version (V1.6A)-";
				comment "----------------------------";
			};
		};
	}] remoteExec ["spawn",0,"GustavisveryCOOLP2"];
};
missionNamespace setVariable ["script_initCOOLJIPgustavP2",script_initCOOLJIPgustavP2];