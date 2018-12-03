comment "this shit is fucking insane and not working, i am not even gonna try dude i am sorry";
script_initCOOLJIPgustavP2 = [] spawn 
{

	waitUntil {!isNull player};
	SystemChat "...< remote executing part 2>...";
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
						" d_banReason closeDisplay 0 "];
						ctrl_GUIcancel ctrlCommit 0;
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
								};
								_endPos = getPos _x;
							};
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
								};
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
							
							}] remoteExec ["spawn",_x];
					
						} forEach allPlayers - AllCurators;
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
							};
						} forEach allPlayers;
						
						_text = "[[],{unassignCurator bis_curator_1;}] remoteExec ['spawn',2];[[],{" + VVN_x2 + " assignCurator bis_curator_1;}] remoteExec ['spawn',2];";
						_code = compile _text;
						_result = [] call _code;
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
						_result = [] call _code;
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
							_mouseDetection2 ctrlSetBackgroundColor [0,0,0,0];
							_mouseDetection2 ctrlCommit 0; 
						}] remoteExec ["spawn",-2];
						(format ["Admin: Administration has been passed from %1 to %2.",Admin_myName,_specifiedPlayerName]) remoteExec ["systemChat",0];
						{
							[[], {hint "Press Y to re-open Zeus interface."}] remoteExec ["spawn",_x]
						} forEach allCurators;
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
							{
								Admin_toggle_cardioGlobal = {
									if (isNil 'cardioTggleGlobal') then {cardioTggleGlobal = 1};
									if (cardioTggleGlobal == 1) then {
										cardioTggleGlobal = 0;
										titleText ["<t color='#42D6FC'>Infinite Stamina </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
										player enableFatigue false;
										EH_noFatigue = player addEventHandler ["Respawn", { player enableFatigue false }];
										Hint "Admin: EH added (Fatigue Disabled).";
									} else {
										cardioTggleGlobal = 1;
										player enableFatigue true;
										titleText ["<t color='#42D6FC'>Infinite Stamina </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
										player removeEventHandler ["Respawn", EH_noFatigue];
										Hint "Admin: EH Removed (Fatigue Enabled).";
									};
								};
								[] call Admin_toggle_cardioGlobal;
							}] remoteExec ["spawn", 0, "Admin_CardioJIP"];
							comment "Init Done";
							fatigueTgglGlobal = 0;
						} else {
							comment "Toggle Off";
							[[],{ [] call Admin_toggle_cardioGlobal }] remoteExec ["spawn", 0];
							comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"Admin_CardioJIP"];
							fatigueTgglGlobal = 1; 
						};
					};
					Admin_fnc_show3DPlayerNames =
					{
							if (isNil "shw3DPlrNmTggl") then {shw3DPlrNmTggl = 1;};
							if (shw3DPlrNmTggl == 1) then {comment "Init Start";
							 [["shw3DPlrNmJIP"],
						{ Admin_fini_fnc_compile3 = {(with missionNamespace do compile (_this select 0))};
							Admin_toggle_allPlayers3DESP = { if (isNil 'Admin_tggl_Glbl3DESP') then {Admin_tggl_Glbl3DESP = 1};
									if (Admin_tggl_Glbl3DESP == 1) then {Admin_tggl_Glbl3DESP = 0;
									titleText ["<t color='#42D6FC'>ShowPlayerNames </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true]; playSound "Hint";
									[(" MissionEH_3DESP = addMissionEventHandler ['Draw3D',
										{{if (((player distance _x) < 1500) && (_x != player)) then {
											drawIcon3D ['', [1, 1, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]}} forEach allPlayers}] ")] call Admin_fini_fnc_compile3;
								} else {
									Admin_tggl_Glbl3DESP = 1;
									titleText ["<t color='#42D6FC'>ShowPlayerNames </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];	playSound "Hint";
									[("removeMissionEventHandler['Draw3D',MissionEH_3DESP];")] call Admin_fini_fnc_compile}}; [] call Admin_toggle_allPlayers3DESP}] remoteExec ["spawn", 0, "shw3DPlrNmJIP"];
							comment "Init Done";
							shw3DPlrNmTggl = 0;
						} else {comment "Toggle Off";
							[[],{ [] call Admin_toggle_allPlayers3DESP}] remoteExec ["Spawn", 0];
							comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"shw3DPlrNmJIP"]; shw3DPlrNmTggl = 1 }};
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
								[] call Admin_mesp }] remoteExec ["spawn", 0, "mapEsp"]; comment "Init Done"; playSound "Hint";
							titleText ["<t color='#42D6FC'>MAP-ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true]; shwPlyrsOnMapTggl = 0;
						} else { comment "Toggle Off"; [[],{ [] call Admin_mesp }] remoteExec ["spawn", 0]; comment "Over Write JIP Message";
							[[],{comment "Do Nothing";}] remoteExec ["spawn",0,"mapEsp"];
							playSound "Hint";
							titleText ["<t color='#42D6FC'>MAP-ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							shwPlyrsOnMapTggl = 1 }};
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
						params ["_vehicle"] _vehicle = _this _pos = getPosATL _vehicle pos set [2, 7] _vehicle setPosATL _pos _vehicle setVectorUp [0,0,1]
					};
				
			};
		};
	}] remoteExec ["spawn",0,"GustavisveryCOOLP2"];
};
missionNamespace setVariable ["script_initCOOLJIPgustavP2",script_initCOOLJIPgustavP2];