SystemChat "...< Loading >...";

script_initCOOLJIPgustav = [] spawn 
{
	waitUntil {!isNull player};
	SystemChat "...< remote executing >...";
	[[0],
	{
		JEW_nameKey27 = "76561198164329131";
		JEW_playerName27 = (getPlayerUID player);
		if (JEW_playerName27 == JEW_nameKey27 || JEW_playerName27 == "_SP_PLAYER_") then 
		{
			JEW_engage_Client = [] spawn 
			{	comment "Load Functions";
				

				GOM_fnc_aircraftLoadoutSavePreset = 
				{
					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_index = 0;
						_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];
					_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];

					_preset = [typeof _veh,ctrlText 1401,GetPylonMagazines _veh,((GetPylonMagazines _veh) apply {_index = _index + 1;_veh AmmoOnPylon _index}),[lbText [2100,lbCursel 2100],getObjectTextures _veh],_pylonOwners,_priorities,true];

					if (!(_presets isEqualTo []) AND {count (_presets select {ctrlText 1401 isequalTo (_x select 1)}) > 0}) exitWith {systemchat "Preset exists! Chose another name!";playsound "Simulation_Fatal"};


					if (ctrlText 1401 isEqualTo "") exitWith {systemchat "Invalid name! Choose another one!";playSound "Simulation_Fatal"};
					_presets pushback _preset;
					profileNamespace setVariable ["GOM_fnc_aircraftLoadoutPresets",_presets];
							_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

					systemchat format ["Saved %1 preset: %2!",_vehDispName,str ctrlText 1401];
					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					lbsetcursel [2101,((lbsize 2101) -1)];
					true
				};

				GOM_fnc_aircraftLoadoutDeletePreset = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];

					_toDelete = _presets select {(_x select 1) isEqualTo lbText [2101,lbcursel 2101]};
					if (count _toDelete isequalto 0)  exitWith {systemchat "Preset not found!";playsound "Simulation_Fatal"};
					_presets = _presets - [_toDelete select 0];
					profileNamespace setVariable ["GOM_fnc_aircraftLoadoutPresets",_presets];
						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					true
				};

				GOM_fnc_aircraftLoadoutLoadPreset = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					if (lbCursel 2101 < 0) exitWith {systemchat "No preset selected."};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_preset = [];
					{if((_x select 0) isEqualTo typeOf _veh AND (_x select 1) isEqualTo lbText [2101,lbcursel 2101]) then{_preset = _x;}}forEach _presets;
					_preset params ["_vehType","_presetName","_pylons","_pylonAmmoCounts","_textureParams","_pylonOwners","_pylonPriorities",["_restrictedLoadout",true]];

					[_obj,true,_pylons,_pylonAmmoCounts] call	GOM_fnc_setPylonsRearm;
					[_veh,_pylonPriorities] remoteExec ["setPylonsPriority",0,true];
					_textureParams params ["_textureName","_textures"];
					{

						_veh setObjectTextureGlobal [_foreachIndex,_x];

					} forEach _textures;


					true
				};

				GOM_fnc_setPylonOwner = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];
					_ownerName = "Pilot";
					if (_pylonOwner isEqualTo []) then {_pylonOwner = [0];_ownerName = "Gunner"} else {_pylonOwner = []};

					ctrlSetText [1605,format ["%1 control",_ownerName]];

					_veh setVariable ["GOM_fnc_aircraftLoadoutPylonOwner",_pylonOwner,true];
					//_update = [_obj] call GOM_fnc_updateDialog;
					true
				};

				GOM_fnc_setPylonsRearm = 
				{

					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};
					params ["_obj",["_rearm",false],["_pylons",[]],["_pylonAmmoCounts",[]]];
					_nul = [_obj,_rearm,_pylons,_pylonAmmoCounts] spawn {

						params ["_obj",["_rearm",false],["_pylons",[]],["_pylonAmmoCounts",[]]];

							_veh = call compile lbData [1500,lbcursel 1500];



						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if (_veh getVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false]) exitWith {systemchat "Aircraft is currently being rearmed!"};
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",true,true];
						_activePylonMags = GetPylonMagazines _veh;
						if (_rearm) exitWith {

							[_obj] call GOM_fnc_clearAllPylons;
								_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];

							{
								_pylonOwner = if (_pylonOwners isequalto []) then {[]} else {_pylonOwners select (_foreachindex + 1)};

							[_veh,[_foreachindex+1,_x,true,_pylonOwner]] remoteexec ["setPylonLoadOut",0] ;
							[_veh,[_foreachIndex + 1,0]] remoteexec ["SetAmmoOnPylon",0] ;
							} foreach _pylons;
					{
							_mag = _activePylonMags select _forEachIndex;


								_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];
								_pylonOwner = if (_pylonOwners isequalto []) then {[]} else {_pylonOwners select (_foreachindex + 1)};
								_maxAmount = (_pylonAmmoCounts select _forEachIndex);





							if (_maxamount < 24) then {

							for "_i" from 0 to _maxamount do {
							[_veh,[_foreachIndex + 1,_i]] remoteexec ["SetAmmoOnPylon",0];
							if (_i > 0) then {

							_sound = [_veh,_foreachIndex] call GOM_fnc_pylonSound;
							};
							};
							} else {

							[_veh,[_foreachIndex + 1,_maxamount]] remoteexec ["SetAmmoOnPylon",0] ;
							_sound = [_veh,_foreachIndex] call GOM_fnc_pylonSound;
							};



						} forEach _pylons;
						playSound "Click";
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false,true];
						_veh setVehicleAmmo 1;
						systemchat "All pylons, counter measures and board guns rearmed!";
					true
					};



					_mounts = [];
						{



								_mount = [_veh,_forEachIndex+1,_x] spawn {
									params ["_veh","_ind","_mag"];

						_maxAmount = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");





							if (_maxamount < 24) then {

							for "_i" from (_veh AmmoOnPylon _ind) to _maxamount do {
									[_veh,[_ind,_i]] remoteexec ["SetAmmoOnPylon",0];

							if (_i > 0) then {

							_sound = [_veh,_ind - 1] call GOM_fnc_pylonSound;
							}
							};
							} else {
									[_veh,[_ind,_maxamount]] remoteexec ["SetAmmoOnPylon",0];

							_sound = [_veh, _ind - 1] call GOM_fnc_pylonSound;
							};
						};
						_mounts pushback _mount;

						} forEach _activePylonMags;
						waituntil {!alive _veh OR {scriptdone _x} count _mounts isequalto count _mounts};
						playSound "Click";
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false,true];
						_veh setVehicleAmmo 1;

						systemchat "All pylons, counter measures and board guns rearmed!";

					};
					true
				};

				GOM_fnc_setPylonsRepair = 
				{

					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};
					params ["_obj"];

					_veh = call compile  lbData [1500,lbcursel 1500];




					_repair = [_veh,_obj] spawn {
						params ["_veh","_obj"];
						_curDamage = damage _veh;
						_abort = false;
						_timer = 0;
						_highestDamaged = 0;
						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if(count getAllHitPointsDamage _veh == 0) then {_highestDamaged = damage _veh} else{
						{if(_x > 0.0) exitWith {_highestDamaged = _x;};} forEach (getAllHitPointsDamage _veh select 2);};
						if (_highestDamaged isEqualTo 0 && damage _veh == 0) exitWith {systemchat "Aircraft is already at 100% integrity!"};


						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

							_repairTick = (1 / 10);
							_timeNeeded = ceil (_curDamage / _repairtick);

							_damDisp = [((_curDamage * 100) - 100) * -1] call GOM_fnc_roundByDecimals;
						_empty = false;
						

						
						while {
							(!isNil {{if(_x > 0.0) exitWith {_x};} forEach (getAllHitPointsDamage _veh select 2)}
							OR damage _veh > 0) AND alive _veh AND !_abort AND !_empty} do {
						

						_curDamage = damage _veh;

							_timeNeeded = ceil (_curDamage / _repairtick);

						_veh setdamage (_curDamage - _repairTick + 0.1);
						_veh setdamage _curDamage - _repairTick;
					_sound = [_veh] call GOM_fnc_pylonSound;

							_damDisp = [((_curDamage * 100) - 100) * -1] call GOM_fnc_roundByDecimals;
						
							_timeout = time + 1;
							_timer = _timer + 1;
										//_update = [_obj] call GOM_fnc_updateDialog;

						};
					};




					playSound "Click";

					true
				};

				GOM_fnc_setPylonsRefuel = 
				{
					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];


					_refuel = [_veh,_obj] spawn {
						params ["_veh","_obj"];
						_curFuel = fuel _veh;
						_abort = false;
						_timer = 0;
						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if (_curFuel isEqualTo 1) exitWith {systemchat "Aircraft is already at 100% fuel capacity!"};
						_maxFuel = getNumber (configfile >> "CfgVehicles" >> typeof _veh >> "fuelCapacity");
						_sourceDispname = selectRandom ["love and light","the love of friendship","a wondrous device","gimlis magic barrel"];

						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
						_fuel = round(_curFuel * _maxfuel);

						_missingFuel = _maxfuel - _fuel;
						_fillrate = 1800;
						_timeNeeded = ((_missingFuel / _fillrate) * 60);
						if(_timeNeeded isEqualTo 0) exitWith {systemChat "Aircraft is already at 100% fuel capacity!"};
						_fuelTick = ((1 - _curFuel) / _timeNeeded);
						_fuelPerTick = 1800 / 60;



						_empty = false;
						_leaking = false;
						while {fuel _veh < 0.99 AND alive _veh AND !_abort AND !_empty} do {


						_curFuel = fuel _veh;

						[_veh,(_curFuel + _fuelTick)] remoteExec ["setFuel",_veh];

						_fuel = [(_curFuel * _maxfuel),1] call GOM_fnc_roundByDecimals;

						_missingFuel = _maxfuel - _fuel;

								_timeNeeded = round ((_missingFuel / _fillrate) * 60);

							_timeout = time + 1;
							_timer = _timer + 1;
						};
							if (!_abort AND !_empty AND !_leaking) then {	systemchat format ["%1 filled up!",_vehDispName];

					} else {

					if (_abort) then {systemchat "Refuelling aborted!"};

					};

							playSound "Click";
						};
					true

				};

				GOM_fnc_getWeekday = 
				{

					params [["_date",date]];

					_date params ["_year","_m","_q"];

					_yeararray = toarray str _year apply {_x-48};

					_yeararray params ["_y1","_y2","_y3","_y4"];
					_J = ((_y1) * 10) + (_y2);
					_K = ((_y3) * 10) + (_y4);

					if (_m < 3) then {_m = _m + 12};

					["","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"] select (_q + floor ( ((_m + 1) * 26) / 10 ) + _K + floor (_K / 4) + floor (_J / 4) - (2 * _J)) mod 7

				};

				GOM_fnc_titleText = 
				{

					date params ["_year","_month","_day"];
					_checkdate = [_year,_month,_day];

					_lastCheck = player getVariable ["GOM_fnc_titleTextCheckDate",[[0,0,0],""]];
					_lastCheck params ["_lastDate","_weekDay"];

					if !(_checkDate isequalto _lastDate) then {

					_weekday = [] call GOM_fnc_getWeekday;
					player setvariable ["GOM_fnc_titleTextCheckDate",[_checkdate,_weekday]];

					};
					_date = format ["%1, %2.%3.%4",_weekday,_day,_month,_year];//suck it americans

					_posCheck = player getvariable ["GOM_fnc_titleTextPosChange",[[0,0,0],"",""]];
					_posCheck params ["_checkPos","_nearestloc","_coords"];


					if (player distance2d _checkPos > 50) then {
					_playerpos = getposasl player;
					_coords = mapGridPosition _playerpos;
					_nearLocs = nearestlocations [_playerpos,["NameMarine","NameVillage","NameCity","NameCityCapital"],5000,_playerpos];
					_nearlocs apply {text _x != ""};
					_nearestloc = "";
					if (_nearlocs isequalto []) then {_nearestloc = ""} else {
					_nearestloc = text (_nearlocs select 0) + " - ";
					};
					player setvariable ["GOM_fnc_titleTextPosChange",[_playerpos,_nearestLoc,_coords]];
					};


					_t = toString [71,114,117,109,112,121,32,79,108,100,32,77,97,110,115,32,65,105,114,99,114,97,102,116,32,76,111,97,100,111,117,116];

					_time = [daytime,"HH:MM:SS"] call BIS_fnc_timeToString;
					_text = format ["<t align='left' size='0.75'>%1Grid ""%2""<t align='center'>--- %3 ---<t align='right'>%4<br />%5",_nearestloc,_coords,_t,_date,_time];


					(findDisplay 57 displayctrl 1101) ctrlSetStructuredText parsetext _text;

				};

				GOM_fnc_roundByDecimals = 
				{

					params ["_num",["_digits",2]];
					round (_num * (10 ^ _digits)) / (10 ^ _digits)

				};

				GOM_fnc_updateDialog = 
				{

					params ["_obj",["_preset",false]];


					if (lbCursel 1500 < 0) exitWith {



						_obj = player;

					_availableTexts = ["<t color='#E51B1B'>Not available!</t>","<t color='#1BE521'>Available!</t>"];


					_fueltext = "";
					_repairtext = "";
					_rearmtext = "";

					_text = "";
					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

					};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_dispName = lbText [1500,lbCurSel 1500];

					if (lbcursel 2101 >= 0) exitWith {

					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_preset = (_presets select {(_x select 0) isEqualTo typeOf _veh AND {(_x select 1) isEqualTo lbText [2101,lbcursel 2101]}}) select 0;
					_preset params ["_vehType","_presetName","_pylons","_pylonAmmoCounts","_textureParams","_pylonOwners","_priorities","_serialNumber"];
					_textureParams params ["_textureName","_textures"];

					_pylonInfoText = "";
					_sel = 0;
					_align = ["<t align='left'>","<t align='center'>","<t align='right'>"];
					_count = 0;
					_priorities = 	_veh getVariable ["GOM_fnc_pylonPriorities",[]];

					{
						_count = _count + 1;
						_owner = "Pilot";
						if !(_pylonOwners isEqualTo []) then {

						_owner = if ((_pylonowners select _forEachIndex+1) isEqualTo []) then {"Pilot"} else {"Gunner"};
					};

					_pylonDispname = getText (configfile >> "CfgMagazines" >> _x >> "displayName");
					_setAlign = _align select _sel;
						_sel = _sel + 1;
					_break = "";
					if (_sel > 2) then {_sel = 0;_break = "<br />"};
					if (count _pylons <= 6) then {_setAlign = "<t align='left'>";_break = "<br />"};

						_priority = "N/A";
						if (count _priorities > 0) then {

					_priority = _priorities select _foreachindex;
					};
							_pylonInfoText = _pylonInfoText + format ["%1Pyl%2: %3 Prio. %4 %5 (%6).%7",_setAlign,_count,_owner,_priority,_pylonDispname,_pylonAmmoCounts select _forEachIndex,_break];

						} forEach _pylons;
								_text = format ["<t align='center' size='0.75'>Selected %1 preset: %2 Tail No. %5<br /><br /><t align='left'>Livery: %3<br />%4",_dispName,_presetName,_textureName,_pylonInfoText,_serialNumber];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

						};

							if (lbCursel 1502 < 0 AND lbCursel 1501 >= 0) exitWith {


						_pylonInfoText = "";
						_sel = 0;
						_align = ["<t align='left'>","<t align='center'>","<t align='right'>"];
						_count = 0;
							_priorities = 	_veh getVariable ["GOM_fnc_pylonPriorities",[]];
						{
							_priority = "N/A";
							if (count _priorities > 0) then {

						_priority = _priorities select _foreachindex;
					};
							_count = _count + 1;
							_owner = "N/A";

						_ammo = _veh AmmoOnPylon (_foreachindex+1);

						_pylonDispname = getText (configfile >> "CfgMagazines" >> _x >> "displayName");
						_setAlign = _align select _sel;
							_sel = _sel + 1;
						_break = "";
						if (_sel > 2) then {_sel = 0;_break = "<br />"};
						if (count _pylons <= 6) then {_setAlign = "<t align='left'>";_break = "<br />"};
							_pylonInfoText = _pylonInfoText + format ["%1Pyl%2: %3 Prio. %4 %5 (%6).%7",_setAlign,_count,_owner,_priority,_pylonDispname,_ammo,_break];

						} forEach GetPylonMagazines _veh;
								_text = format ["<t align='center' size='0.75'>%1 current loadout:<br /><br /><t align='left' size='0.75'><br />%2",_dispName,_pylonInfoText];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

						};

						_driverName = name assigneddriver _veh;

						_rank = [assignedDriver _veh,"displayName"] call BIS_fnc_rankParams;
						_rank = _rank + " ";
						if (assigneddriver _veh isEqualTo objnull) then {_driverName = "No Pilot";_rank = ""};

						_mag = "N/A";
						_get = "";
						if (lbcursel 1502 > -1) then {_get = (lbdata [1502,(lbCursel 1502)]);};
						_ind2 = "N/A";
						_pylonMagDispName = getText (configfile >> "CfgMagazines" >> _get >> "displayName");
						_pylonMagType = getText (configfile >> "CfgMagazines" >> _get >> "displayNameShort");
						_pylonMagDetails = getText (configfile >> "CfgMagazines" >> _get >> "descriptionShort");
						if (_pylonMagDispName isequalto "") then {_pylonMagDispName = "N/A"};
						if (_pylonMagType isequalto "") then {_pylonMagType = "N/A"};
						if (_pylonMagDetails isequalto "") then {_pylonMagDetails = "N/A"};
						_pyl = "N/A";
						if (lbcursel 1501 > -1) then {_pyl = (lbdata [1501,(lbCursel 1501)]);};

						_curFuel = fuel _veh;

						_maxFuel = getNumber (configfile >> "CfgVehicles" >> typeof _veh >> "fuelCapacity");
						_fuel = [(_curFuel * _maxfuel),1] call GOM_fnc_roundByDecimals;

							_missingFuel = _maxfuel - _fuel;

						_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];

						_pylonOwnerName = "Pilot";
						_nextOwnerName = "Gunner";
						if !(_pylonOwner isEqualTo []) then {_pylonOwnerName = "Gunner"};
						_ownerText = format ["Operated by: %1",_pylonOwnerName];

						_integrity = [((damage _veh * 100) - 100) * -1] call GOM_fnc_roundByDecimals;

						_pylontext = format ["Mount %1 on %2 - %3<br /><br /><t align='left'>Weapon Type: %4<br />Details: %5",_pylonMagDispName,_pyl,_ownertext,_pylonMagType,_pylonMagDetails];

							if (lbcursel 1502 < 0) then {_pylontext = ""};

							_kills = _veh getVariable ["GOM_fnc_aircraftLoadoutTrackStats",[]];

							_killtext = if (_kills isequalto []) then {"Confirmed kills:<br />None"} else {
							_kills params ["_infantry","_staticWeapon","_cars","_armored","_chopper","_plane","_ship","_building","_parachute"];

							_typeNamesS = ["infantry","static weapon","vehicle","armored vehicle","helicopter","plane","ship","building","parachuting kitten"];
							_typeNamesPL = ["infantry","static weapons","vehicles","armored vehicles","helicopters","planes","ships","buildings","parachuting kittens"];

							_out = "Confirmed kills:<br />";
							_index = -1;
							_killText = _kills apply {_index = _index + 1;_kind = ([_typeNamesS select _index,_typeNamesPL select _index] select (_x > 1));
								if (_x > 0) then {

									_out = _out + (format ["%1 %2, ",_x,_kind])};

							};
					_out = _out select [0,count _out - 2];
					_out = _out + ".";
					_out
							};

					_landings = _veh getvariable ["GOM_fnc_aircraftStatsLandings",0];

					_landingtext = format ["Successful landings: %1<br />",_landings];
					if (typeof _veh iskindof "Helicopter") then {_landingtext = "<br />"};
					if (lbcursel 1502 >= 0) then {_landingtext = "";_killtext = ""};


						_tailNumber = [] call GOM_fnc_aircraftGetSerialNumber;


						_text = format ["<t align='center' size='0.75'>%1 - %11, Integrity: %2%3<br />Pilot: %4%5<br />Fuel: %6l / %7l<br />%8<br />%9<br />%10",_dispName,_integrity,"%",_rank,_driverName,_fuel,_maxFuel,_pylontext,_landingtext,_killtext,_tailnumber];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;
					true
				};

				GOM_fnc_updateVehiclesLB = 
				{


					params ["_obj"];


					_vehicles = (_obj nearEntities [["Air", "Car", "Motorcycle", "Tank", "StaticWeapon"],50]) select {alive _x};
					_lastVehs = _obj getVariable ["GOM_fnc_setPylonLoadoutVehicles",[]];
					if (_vehicles isEqualTo []) exitWith {true};
					if (_vehicles isEqualTo _lastVehs AND !(lbsize 1500 isequalto 0)) exitWith {true};//only update this when really needed, called on each frame
					_obj setVariable ["GOM_fnc_setPylonLoadoutVehicles",_vehicles,true];


					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>No aircraft in range (50m)!";
					lbclear 1500;


					{

						_dispName = gettext (configfile >> "CfgVehicles" >> typeof _x >> "displayName");
						_form = format ["%1",_dispName];
						lbAdd [1500,_form];
						lbSetData [1500,_foreachIndex,_x call BIS_fnc_objectVar];
					} forEach _vehicles;

				};

				GOM_fnc_CheckComponents = 
				{

					params ["_ctrlParams","_obj"];
					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_vehDispName = getText (configfile >> "CfgVehicles" >> typeOf _veh >> "displayName");
					_ctrlParams params ["_ctrl","_state"];
					_set = [false,true] select _state;

					if (_set) then {

						if (str _ctrl find "2800" > -1) then {systemchat format ["%1 will now report remote targets!",_vehDispName];_veh setVehicleReportRemoteTargets _set};

						if (str _ctrl find "2801" > -1) then {systemchat format ["%1 will now receive remote targets!",_vehDispName];_veh setVehicleReceiveRemoteTargets _set};

						if (str _ctrl find "2802" > -1) then {systemchat format ["%1 will now report its own position!",_vehDispName];_veh setVehicleReportOwnPosition _set};

						} else {

						if (str _ctrl find "2800" > -1) then {systemchat format ["%1 will no longer report remote targets!",_vehDispName];_veh setVehicleReportRemoteTargets _set};

						if (str _ctrl find "2801" > -1) then {systemchat format ["%1 will no longer receive remote targets!",_vehDispName];_veh setVehicleReceiveRemoteTargets _set};

						if (str _ctrl find "2802" > -1) then {systemchat format ["%1 will no longer report its own position!",_vehDispName];_veh setVehicleReportOwnPosition _set};



					};
					playSound "Click";
					true
				};

				GOM_fnc_clearAllPylons = 
				{


					if (!(findDisplay 57 isequalto displaynull) AND lbcursel 1500 < 0) exitWith {"No aircraft selected!"};
					params [["_veh",call compile lbData [1500,lbcursel 1500]]];
					_nosound = false;
					if (findDisplay 57 isequalto displaynull) then {_nosound = true} else {_veh = call compile lbdata [1500,lbcursel 1500]};
					_activePylonMags = GetPylonMagazines _veh;

					{

						[_veh,[_foreachIndex + 1,"",true]] remoteexec ["setPylonLoadOut",0];
						[_veh,[_foreachIndex + 1,0]] remoteexec ["SetAmmoOnPylon",0];
						if (!_nosound) then {

					_sound = [_veh,_foreachindex] call GOM_fnc_pylonSound;
					};

						} forEach _activePylonMags;

							if (!_nosound) then {
						playSound "Click";
					};
						_pylonWeapons = [];
						{ _pylonWeapons append getArray (_x >> "weapons") } forEach ([_veh, configNull] call BIS_fnc_getTurrets);
						{ [_veh,_x] remoteexec ["removeWeaponGlobal",0] } forEach ((weapons _veh) - _pylonWeapons);

						systemchat "All pylons cleared!";
					true
				};

				GOM_fnc_aircraftSetSerialNumber = 
				{


					params [["_veh",call compile (lbData [1500,lbcursel 1500])],["_number",ctrltext 1400]];


					_selections = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "hiddenSelections");
					_textures = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "hiddenSelectionsTextures");
					_numberTextures = _textures select {toUpper _x find "NUMBER" > 0};



					if (lbcursel 1501 >= 0 OR lbcursel 1502 >= 0) exitWith {false};
					if (_numberTextures isequalto []) exitWith {
						ctrlSetText [1400,"N/A"];
						systemchat "Aircraft does not support tail numbers.";playsound "Simulation_Fatal"; false};
					_index = _textures find (_numberTextures select 0);

					if (count _number > 3) then {_number = _number select [0,3];systemchat "Invalid Number, using first 3 digits instead!";ctrlSetText [1400,_number select [0,3]];
					};
					_numberArray = toarray _number;

					_zeroesneeded = 3 - count _numberarray;
					_fill = [];
					_fill resize (3 - count _numberarray);
					_fill = _fill apply {48};

					_numberarray = _fill + _numberarray;
					_numberarray = _numberarray apply {parsenumber tostring [_x]};
					_count = 0;
					_numberarray apply {

						_oldSuffix = (_textures select _index) select [count (_textures select _index) - 7,7];
						_oldPrefix = (_textures select _index) select [0,count (_textures select _index) - 9];
						_newTexture = _oldPrefix + "0" + str _x + _oldsuffix;
						_veh setObjectTextureGlobal [(_index + _count),_newTexture];
						_count = _count + 1;

					};
					_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
					systemchat format ["Changed %1 tail number to: %2",_vehDispName,str _number];

				};

				GOM_fnc_pylonSound = 
				{

					params ["_veh",["_pylon",-1]];

					_soundpos = getPosASL _veh;
					if (_pylon >= 0) then {

					_selections = selectionnames _veh;
					_presort = _selections select {(toupper _x find "PYLON") >= 0 AND parsenumber (_x select [count _x - 3,3]) > 0};
					_presort apply {[parsenumber (_x select [count _x - 3,3]),_x]};
					_presort sort true;

					};

						_rndSound = selectRandom ['FD_Target_PopDown_Large_F','FD_Target_PopDown_Small_F','FD_Target_PopUp_Small_F'];
						_getPath = getArray (configfile >> "CfgSounds" >> _rndSound >> "sound");
						_path = _getPath select 0;

					true
				};

				GOM_fnc_properWeaponRemoval = 
				{

					params ["_veh","_pylonToCheck"];

					_currentweapons = weapons _veh;
					_pylons = GetPylonMagazines _veh;
					_pylonWeapons = _pylons apply {getText ((configfile >> "CfgMagazines" >> _x >> "pylonWeapon"))};
					_weaponToCheck = _pylonweapons select lbcursel 1501;
					_check = (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1);
					_check2 = _pylonweapons select {_x isEqualTo _weaponToCheck};
					if (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1) then {_veh removeWeaponGlobal _weaponToCheck;Systemchat ("Removed " + _weaponToCheck)};//remove the current pylon weapon if no other pylon is using it

				};

				GOM_fnc_installPylons = 
				{

					params ["_veh","_pylonNum","_mag","_finalAmount","_magDispName","_pylonName"];
					_weaponCheck = [_veh,_mag] call GOM_fnc_properWeaponRemoval;
					_check = _veh getVariable ["GOM_fnc_airCraftLoadoutPylonInstall",[]];

					if (_pylonNum in _check) exitWith {systemchat "Installation in progress!"};
					_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];

					_pylonOwnerName = "Pilot";
					_nextOwnerName = "Gunner";
					if !(_pylonOwner isEqualTo []) then {_pylonOwnerName = "Gunner"};
					_initArray = GetPylonMagazines _veh;
					_init = [];
					_initArray apply {_init pushback []};//should solve r3vos bug, might be because undefined pylon owner
					_storePylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",_init];//maybe r3vos bug
					_storePylonOwners set [_pylonNum,_pylonOwner];
					_veh setVariable ["GOM_fnc_aircraftLoadoutPylonOwners",_storePylonOwners,true];

					_check pushback _pylonNum;
					_veh setVariable ["GOM_fnc_airCraftLoadoutPylonInstall",_check,true];



						[_veh,[_pylonNum,"",true,_pylonOwner]] remoteexec ["setPylonLoadOut",0];
						[_veh,[_pylonNum,_mag,true,_pylonOwner]] remoteexec ["setPylonLoadOut",0];



						[_veh,[_pylonNum,0]] remoteexec ["SetAmmoOnPylon",0];

						//[_ammosource,_mag,_veh] call GOM_fnc_handleAmmoCost;
					if (_finalamount <= 24) then {

					for "_i" from 1 to _finalamount do {


						[_veh,[_pylonNum,_i]] remoteexec ["SetAmmoOnPylon",0];
						_sound = [_veh,_pylonNum-1] call GOM_fnc_pylonSound;

					};

					} else {

						[_veh,[_pylonNum,_finalamount]] remoteexec ["SetAmmoOnPylon",0];
						_sound = [_veh,_pylonNum-1] call GOM_fnc_pylonSound;
					};
						//_ammosource setvariable ["GOM_fnc_aircraftLoadoutBusyAmmoSource",false,true];
					_checkOut = _veh getVariable ["GOM_fnc_airCraftLoadoutPylonInstall",[]];
					_checkOut = _checkOut - [_pylonNum];
					_veh setVariable ["GOM_fnc_airCraftLoadoutPylonInstall",_checkOut,true];

					systemchat format ["Successfully installed %1 %2 on %3!",_finalAmount,_magDispName,_pylonName];
					true
				};

				GOM_fnc_pylonInstallWeapon = 
				{

					params ["_obj"];



					if (lbCursel 1502 < 0 OR lbCursel 1501 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_mag = lbdata [1502,lbCurSel 1502];
					_magDispName = getText (configfile >> "CfgMagazines" >> _mag >> "displayName");

					_maxAmount = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");

					_setAmount = parsenumber (ctrlText 1400);//only allows numbers

					_finalAmount = _setAmount min _maxAmount max 0;//limit range

					if (_setAmount > _maxAmount) then {systemchat "Invalid number, defaulting to allowed amount.";playsound "Simulation_Fatal";ctrlsetText [1400,str _maxAmount]};

					_pylonNum = lbCurSel 1501 + 1;
					_pylonName = lbdata [1501,lbCurSel 1501];


					_add = [_veh,_pylonNum,_mag,_finalAmount,_magDispName,_pylonName] spawn GOM_fnc_installPylons;


					playSound "Click";
					true
				};

				GOM_fnc_aircraftLoadoutPaintjob = 
				{

					params ["_obj",["_apply",false]];

					if (lbCursel 1500 < 0) exitWith {false};
					lbClear 2100;
					lbAdd [2100,"Livery"];
					_veh = call compile  lbData [1500,lbcursel 1500];
						_colorConfigs = "true" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources");
						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
						_colorTextures = [""];
						if (count _colorConfigs > 0) then {

							_colorNames = [""];
							{
							_colorNames pushback (getText (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "displayName"));
							lbAdd [2100,(getText (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "displayName"))];
							_colorTextures pushback (getArray (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "textures"));
						} foreach _colorConfigs;

						if (_apply AND lbCurSel 2100 > 0) then {

						{
						_index = (_colorTextures select (lbCurSel 2100)) find _x;
						_veh setObjectTextureGlobal [_index, (_colorTextures select (lbCurSel 2100)) select _index];
					} foreach (_colorTextures select (lbCurSel 2100));
					};
						playSound "Click";
					};

					true
				};

				GOM_fnc_aircraftGetSerialNumber = 
				{

					if (lbcursel 1500 < 0) exitwith {false};

					params [["_veh",call compile (lbdata [1500,lbcursel 1500])]];

					_textures = getObjectTextures _veh;
					_numberTextures = _textures select {toUpper _x find "NUMBER" > 0};

					if (_numberTextures isequalto [] AND lbcursel 1501 < 0 AND lbcursel 1502 < 0) exitWith {ctrlSetText [1400,"N/A"];
					"N/A"};

					_texture = _numbertextures select 0;
					_index = _textures find _texture;
					_output = "";

					_numbertextures apply {

						_number = _x select [count _x - 8,1];
						_index = _index + 1;
						_output = _output + _number;

					};
					_output

				};

				GOM_fnc_updateAmmoCountDisplay = 
				{

					if (lbCursel 1500 >= 0 AND lbCursel 1501 < 0 AND lbCursel 1502 < 0) exitWith {

					ctrlSettext [1600,format ["Set Serial Number",""]];
					(findDisplay 57 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Serial Number:";
					ctrlSetText [1400,[] call GOM_fnc_aircraftGetSerialNumber];

					};

					if (lbCursel 1500 < 0) exitWith {false};
					if (lbCursel 1501 < 0) exitWith {false};
					if (lbCursel 1502 < 0) exitWith {false};


					ctrlSettext [1600,"Install Weapon"];

					(findDisplay 57 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Amount:";

					_mag = lbdata [1502,lbCursel 1502];
					_count = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");

					ctrlSetText [1400,str _count];

					true
				};

				GOM_fnc_setPylonPriority = 
				{

					params ["_obj"];

					if (lbCursel 1501 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_count = 0;
					_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",(GetPylonMagazines _veh) apply {_count = _count + 1;_count}];//I fucking love apply

					_selectedPriority = _priorities select lbcursel 1501;
					if ("NOCOUNT" in _this) exitWith {

						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
					};

					_keys = findDisplay 57 getVariable ["GOM_fnc_keyDown",["","",false,false,false]];
					_keys params ["","",["_keyshift",false],["_keyctrl",false],["_keyALT",false]];

						if (_keyshift) exitWith {
							_selectedPriority = _selectedPriority - 1;
						if (_selectedPriority < 1) then {_selectedPriority = count _priorities};


							_priorities set [lbcursel 1501,_selectedPriority];

						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];

							};
						if (_keyALT) exitWith {
							_priorities = _priorities apply {_selectedPriority};
							systemchat format ["All pylons priority set to %1",_selectedPriority];
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1",_selectedPriority]];

						};

						if (_keyctrl) exitWith {
					systemchat format ["All pylons priority set to 1",""];
							_priorities = _priorities apply {1};
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", 1]];

						};

					_selectedPriority = _selectedPriority + 1;

						if (_selectedPriority > count _priorities) then {_selectedPriority = 1};

							_priorities set [lbcursel 1501,_selectedPriority];

						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];


				};

				GOM_fnc_fillPylonsLB = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];


					_pylon = lbData [1501,lbcursel 1501];
					_getCompatibles = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons" >> _pylon >> "hardpoints");

					if (_getCompatibles isEqualTo []) then {

						//darn BI for using "Pylons" and "pylons" all over the place as if it doesnt fucking matter ffs honeybadger

						_getCompatibles = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "pylons" >> _pylon >> "hardpoints");

					};



					lbClear 1502;

					_validPylonMags = GOM_list_allPylonMags;
					_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};

					
					if (GOM_fnc_allowAllPylons) then {

						_validPylonMags = GOM_list_allPylonMags;
						_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};

					} else {

						_validPylonMags = GOM_list_allPylonMags select {!((getarray (configfile >> "CfgMagazines" >> _x >> "hardpoints") arrayIntersect _getCompatibles) isEqualTo [])};
						_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};
					};

					{

						lbAdd [1502,_validDispNames select _foreachIndex];
						lbsetData [1502,_foreachIndex,_x];

					} forEach _validPylonMags;
					true
				};

				GOM_fnc_updatePresetLB = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					

					_validPresets = _presets select {(_x select 0) isEqualTo typeOf _veh};
					lbClear 2101;
					{

						lbAdd [2101,_x select 1];

					} forEach _validPresets;
					true
				};

				GOM_fnc_setPylonLoadoutLBPylonsUpdate = 
				{

					params ["_obj"];


					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					_validPylons = (("isClass _x" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons")) apply {configname _x});

					lbClear 1501;
					{

						lbAdd [1501,_x];
						lbsetData [1501,_foreachIndex,_x];

					} forEach _validPylons;

						_colorConfigs = "true" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources");
						if (_colorConfigs isequalto []) then {lbclear 2100;lbAdd [2100,"No paintjobs available."];lbSetCurSel [2100,0]};

					findDisplay 57 displayCtrl 2800 cbSetChecked (vehicleReportRemoteTargets _veh);
					findDisplay 57 displayCtrl 2801 cbSetChecked (vehicleReceiveRemoteTargets _veh);
					findDisplay 57 displayCtrl 2802 cbSetChecked (vehicleReportOwnPosition _veh);

					playSound "Click";
					true
				};

				GOM_fnc_aircraftLoadout = 
				{

					params ["_obj", "_allPylons"];
					GOM_fnc_allowAllPylons = _allPylons;
					_display = [] call JEW_fnc_dynamicLoadout;
					playSound "Click";
					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>Select an aircraft!";

					lbclear 1500;
					lbclear 1501;
					lbclear 1502;


					lbadd [2100,"Livery"];
					lbSetCurSel [2100,0];


					_getvar = _obj call BIS_fnc_objectVar;
					findDisplay 57 displayCtrl 1500 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;lbsetcursel [1502,-1];lbclear 1501;lbsetcursel [1501,-1];[%1] call GOM_fnc_setPylonLoadoutLBPylonsUpdate;
					;[%1] call GOM_fnc_aircraftLoadoutPaintjob;",_getvar]];
						findDisplay 57 displayCtrl 1501 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;[%1] call GOM_fnc_fillPylonsLB;[%1,'NOCOUNT'] call GOM_fnc_setPylonPriority
					",_getvar]];
						findDisplay 57 displayCtrl 1502 ctrlAddEventHandler ["LBSelChanged",format ["[%1] call GOM_fnc_updateAmmoCountDisplay;",_getvar]];

						findDisplay 57 displayCtrl 2100 ctrlAddEventHandler ["LBSelChanged",format ["[%1,true] call GOM_fnc_aircraftLoadoutPaintjob",_getvar]];
						findDisplay 57 displayCtrl 2101 ctrlAddEventHandler ["LBSelChanged",format ["",_getvar]];
						buttonSetAction [1600, format ["[%1] call GOM_fnc_pylonInstallWeapon;[] call GOM_fnc_aircraftSetSerialNumber",_getvar]];
						buttonSetAction [1601, format ["[%1] call GOM_fnc_clearAllPylons",_getvar]];
						buttonSetAction [1602, format ["[%1] call GOM_fnc_setPylonsRepair",_getvar]];
						buttonSetAction [1603, format ["[%1] call GOM_fnc_setPylonsRefuel",_getvar]];
						buttonSetAction [1604, format ["[%1] call GOM_fnc_setPylonsReArm",_getvar]];
						buttonSetAction [1605, format ["[%1] call GOM_fnc_setPylonOwner",_getvar]];
						buttonSetAction [1606, format ["[%1] call GOM_fnc_aircraftLoadoutSavePreset",_getvar]];
						buttonSetAction [1607, format ["[%1] call GOM_fnc_aircraftLoadoutDeletePreset",_getvar]];
						buttonSetAction [1608, format ["[%1] call GOM_fnc_aircraftLoadoutLoadPreset",_getvar]];


						buttonSetAction [1610, format ["[%1] call GOM_fnc_setPylonPriority",_getvar]];

						findDisplay 57 displayAddEventHandler ["KeyDown",{findDisplay 57 setVariable ["GOM_fnc_keyDown",_this];if (_this select 3) then {ctrlEnable [1607,true];
							ctrlSetText [1607,"Delete"];
							ctrlSetText [1610,format ["Set all to 1",""]];
						};
						if (_this select 4) then {
						_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
						if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Set all to %1",_selectedPriority]];
						}
						};


					
						}];
						findDisplay 57 displayAddEventHandler ["KeyUp",{findDisplay 57 setVariable ["GOM_fnc_keyDown",[]];if (_this select 3) then {ctrlEnable [1607,false];ctrlSetText [1607,"CTRL"];

						_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
							if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Priority: %1",_selectedPriority]];
					};
						;};


					if (_this select 4) then {	_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
							if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Priority: %1",_selectedPriority]];
					};
					;}



					}];
					ctrlEnable [1607,false];
					ctrlSetText [1607,"CTRL"];

					findDisplay 57 displayCtrl 2800 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					findDisplay 57 displayCtrl 2801 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					findDisplay 57 displayCtrl 2802 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					_color = [0,0,0,0.6];
					_dark = [1100,1101,1102,1103,1104,1105,1400,1401,1500,1501,1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,2100,2101];
					{

						findDisplay 57 displayCtrl _x ctrlSetBackgroundColor _color;


					} forEach _dark;
					GOM_fnc_aircraftLoadoutObject = _obj;
					_ID = addMissionEventHandler ["EachFrame",{



						_vehicles = [GOM_fnc_aircraftLoadoutObject] call GOM_fnc_updateVehiclesLB;

						if (displayNull isEqualTo findDisplay 57) exitWith {

							removeMissionEventHandler ["EachFrame",_thisEventHandler];
							_display = [] spawn GOM_fnc_showResourceDisplay;
							playSound "Click";

						};

						_check = [_obj] call GOM_fnc_updateDialog;
						[] call GOM_fnc_titleText;

						true

					}];
					GOM_fnc_aircraftLoadoutObject setvariable ["GOM_fnc_aircraftloadoutEH",_ID];

					true
				};

				JEW_fnc_dynamicLoadout =
				{
					disableSerialization;
					showChat true; comment "Fixes Chat Bug";
					createDialog "RscDisplayHintC";

					_GOM_dialog_aircraftLoadout = findDisplay 57;
					{_x ctrlshow false;_x ctrlEnable false} foreach (allcontrols _GOM_dialog_aircraftLoadout);


					profileNamespace setVariable ["JEW_LoadoutDisplay",_GOM_dialog_aircraftLoadout];

					_GOMRscStructuredText_1100 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1100];
					_GOMRscStructuredText_1100 ctrlSetStructuredText parseText "<t align='center'>";
					_GOMRscStructuredText_1100 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.26909723 * safezoneH + safezoneY, 0.39160157 * safezoneW, 0.15277778 * safezoneH];
					_GOMRscStructuredText_1100 ctrlCommit 0;



					_GOMRscStructuredText_1101 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1101];
					_GOMRscStructuredText_1101 ctrlSetStructuredText parseText "<t align='center'>--- Grumpy Old Mans Aircraft Loadout ---";
					_GOMRscStructuredText_1101 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.39160157 * safezoneW, 0.04340278 * safezoneH];
					_GOMRscStructuredText_1101 ctrlCommit 0;



					_GOMRscListbox_1500 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1500];
					_GOMRscListbox_1500 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1500 ctrlCommit 0;



					_GOMRscListbox_1501 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1501];
					_GOMRscListbox_1501 ctrlSetPosition [0.37597657 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1501 ctrlCommit 0;



					_GOMRscListbox_1502 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1502];
					_GOMRscListbox_1502 ctrlSetPosition [0.44824219 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1502 ctrlCommit 0;



					_GOMRscStructuredText_1102 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1102];
					_GOMRscStructuredText_1102 ctrlSetStructuredText parseText "<t align='center'>Select Vehicle";
					_GOMRscStructuredText_1102 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1102 ctrlCommit 0;



					_GOMRscStructuredText_1103 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1103];
					_GOMRscStructuredText_1103 ctrlSetStructuredText parseText "<t align='center'>Select Pylon";
					_GOMRscStructuredText_1103 ctrlSetPosition [0.37597657 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1103 ctrlCommit 0;



					_GOMRscStructuredText_1104 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1104];
					_GOMRscStructuredText_1104 ctrlSetStructuredText parseText "<t align='center'>Select Weapon";
					_GOMRscStructuredText_1104 ctrlSetPosition [0.44824219 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1104 ctrlCommit 0;



					_GOMRscButton_1600 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1600];
					_GOMRscButton_1600 ctrlSetStructuredText parseText "Install Weapon";
					_GOMRscButton_1600 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.5 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1600 ctrlCommit 0;



					_GOMRscButton_1601 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1601];
					_GOMRscButton_1601 ctrlSetStructuredText parseText "Clear all pylons";
					_GOMRscButton_1601 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.73090278 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1601 ctrlCommit 0;



					_GOMRscStructuredText_1105 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1105];
					_GOMRscStructuredText_1105 ctrlSetStructuredText parseText "<t align='center'>Amount:";
					_GOMRscStructuredText_1105 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1105 ctrlCommit 0;



					_GOMRscEdit_1400 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscEdit", 1400];
					_GOMRscEdit_1400 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscEdit_1400 ctrlCommit 0;



					_GOMRscButton_1602 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1602];
					_GOMRscButton_1602 ctrlSetText "Repair";
					_GOMRscButton_1602 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.44444445 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1602 ctrlCommit 0;



					_GOMRscButton_1603 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1603];
					_GOMRscButton_1603 ctrlSetText "Refuel";
					_GOMRscButton_1603 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.47743056 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1603 ctrlCommit 0;



					_GOMRscButton_1604 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1604];
					_GOMRscButton_1604 ctrlSetText "Rearm";
					_GOMRscButton_1604 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.51041667 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1604 ctrlCommit 0;



					_GOMRscCheckbox_2800 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2800];
					_GOMRscCheckbox_2800 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2800 ctrlCommit 0;



					_GOMRscCheckbox_2801 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2801];
					_GOMRscCheckbox_2801 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.63194445 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2801 ctrlCommit 0;



					_GOMRscCheckbox_2802 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2802];
					_GOMRscCheckbox_2802 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.66493056 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2802 ctrlCommit 0;



					_GOMRscStructuredText_1003 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1003];
					_GOMRscStructuredText_1003 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Report Remote Targets";
					_GOMRscStructuredText_1003 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.08789063 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1003 ctrlCommit 0;



					_GOMRscStructuredText_1004 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1004];
					_GOMRscStructuredText_1004 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Receive Remote Targets";
					_GOMRscStructuredText_1004 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.63194445 * safezoneH + safezoneY, 0.08789063 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1004 ctrlCommit 0;



					_GOMRscStructuredText_1005 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1005];
					_GOMRscStructuredText_1005 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Report Own Position";
					_GOMRscStructuredText_1005 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.66493056 * safezoneH + safezoneY, 0.09277344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1005 ctrlCommit 0;



					_GOMRscFrame_1800 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1800];
					_GOMRscFrame_1800 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.40136719 * safezoneW, 0.52604167 * safezoneH];
					_GOMRscFrame_1800 ctrlCommit 0;



					_GOMRscButton_1610 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1610];
					_GOMRscButton_1610 ctrlSetText "Priority: 1";
					_GOMRscButton_1610 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.53298612 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1610 ctrlCommit 0;



					_GOMRscButton_1605 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1605];
					_GOMRscButton_1605 ctrlSetText "Pilot control";
					_GOMRscButton_1605 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.56597223 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1605 ctrlCommit 0;



					_GOMRscCombo_2100 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCombo", 2100];
					_GOMRscCombo_2100 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.54340278 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCombo_2100 ctrlCommit 0;



					_GOMRscFrame_1801 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1801];
					_GOMRscFrame_1801 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1801 ctrlCommit 0;



					_GOMRscFrame_1802 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1802];
					_GOMRscFrame_1802 ctrlSetPosition [0.37109375 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1802 ctrlCommit 0;



					_GOMRscFrame_1803 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1803];
					_GOMRscFrame_1803 ctrlSetPosition [0.44335938 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1803 ctrlCommit 0;



					_GOMRscFrame_1804 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1804];
					_GOMRscFrame_1804 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.09895834 * safezoneH];
					_GOMRscFrame_1804 ctrlCommit 0;



					_GOMRscFrame_1805 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1805];
					_GOMRscFrame_1805 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.53298612 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.06597223 * safezoneH];
					_GOMRscFrame_1805 ctrlCommit 0;



					_GOMRscFrame_1806 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1806];
					_GOMRscFrame_1806 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.10839844 * safezoneW, 0.08854167 * safezoneH];
					_GOMRscFrame_1806 ctrlCommit 0;



					_GOMRscFrame_1807 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1807];
					_GOMRscFrame_1807 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.40136719 * safezoneW, 0.20833334 * safezoneH];
					_GOMRscFrame_1807 ctrlCommit 0;



					_GOMRscCombo_2101 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCombo", 2101];
					_GOMRscCombo_2101 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.57638889 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCombo_2101 ctrlCommit 0;



					_GOMRscFrame_1808 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1808];
					_GOMRscFrame_1808 ctrlSetPosition [0.62402344 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.14236112 * safezoneH];
					_GOMRscFrame_1808 ctrlCommit 0;



					_GOMRscEdit_1401 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscEdit", 1401];
					_GOMRscEdit_1401 ctrlSetText "Your Preset";
					_GOMRscEdit_1401 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.65277778 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscEdit_1401 ctrlCommit 0;



					_GOMRscButton_1606 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1606];
					_GOMRscButton_1606 ctrlSetText "Save";
					_GOMRscButton_1606 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.68576389 * safezoneH + safezoneY, 0.03125 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1606 ctrlCommit 0;



					_GOMRscButton_1607 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1607];
					_GOMRscButton_1607 ctrlSetText "Delete";
					_GOMRscButton_1607 ctrlSetPosition [0.66503907 * safezoneW + safezoneX, 0.68576389 * safezoneH + safezoneY, 0.03125 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1607 ctrlCommit 0;



					_GOMRscFrame_1809 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1809];
					_GOMRscFrame_1809 ctrlSetPosition [0.62402344 * safezoneW + safezoneX, 0.57638889 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.14236112 * safezoneH];
					_GOMRscFrame_1809 ctrlCommit 0;



					_GOMRscButton_1608 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1608];
					_GOMRscButton_1608 ctrlSetText "Load Preset";
					_GOMRscButton_1608 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.609375 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1608 ctrlCommit 0;


					_GOM_dialog_aircraftLoadout;
				};

				DCON_fnc_Garage = 
				{
					if !(isNull(uiNamespace getVariable [ "DCON_Garage_Display", objNull ])) exitwith {};

					if(isNil "DCON_Garage_SpawnType") then {
						DCON_Garage_SpawnType = 0;
					};

					_pos = _this select 0;
					_dir = _this select 1;
					_spawns = [];

					_helipad = "Land_HelipadEmpty_F" createVehicleLocal _pos;
					waitUntil{!isNull _helipad};

					_helipad setPos _pos;
					
					BIS_fnc_arsenal_fullGarage = true;
					BIS_fnc_garage_center = _helipad;
					DCON_Garage_CanSpawn = 0;
					DCON_Garage_Vehicle = objNull;

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

							DCON_Garage_Vehicle setPos _pos;

							sleep 0.1;
						};
					};
					_spawns pushBack _spawn;

					_spawn = [_pos,_dir] spawn {
						_pos = _this select 0;
						_dir = _this select 1;

						while {true} do {
							DCON_Garage_Vehicle setPos _pos;
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

				};

				DCON_fnc_Garage_CodeEditor_Open = 
				{
					disableSerialization;

					_garageDisplay = (uiNamespace getVariable "DCON_Garage_Display");

					_display = _garageDisplay createDisplay "RscDisplayGarage";
					uiNamespace setVariable ["DCON_Garage_CodeEditor_Display", _display];

					_bg = _display ctrlCreate ["RscBackground", -1];
					_bg ctrlSetPosition [0.086,0,0.78,0.18];
					_bg ctrlSetBackgroundColor [0,0,0,0.8];
					_bg ctrlCommit 0;

					comment "technically this is exploting, please don't ban me";
					_exec = _display ctrlCreate ["RscAttributeExec", 200];
					_exec ctrlSetPosition [0.086,0,0.78,0.18];
					_exec ctrlCommit 0;

					((_display) displayCtrl 14466) ctrlEnable false;

					ctrlSetFocus ((_display) displayCtrl 13766);

					sleep 3;

					_display closeDisplay 1;
				};

				DCON_fnc_Garage_CreateVehicle = 
				{
					params ["_roles"];
					_veh  = BIS_fnc_garage_center;

					_type = typeOf _veh;
					_textures = getObjectTextures _veh;
					_animationNames = animationNames _veh;
					_animationValues = [];
					_current_mags = (getPylonMagazines (_veh));
					_special = "CAN_COLLIDE";
					_movein = false;

					{
						_animationValues pushBack (_veh animationPhase _x);
					} forEach _animationNames;

					deleteVehicle _veh;
					waitUntil {!alive _veh};
					sleep 0.1;

					switch (DCON_Garage_SpawnType) do {
						case 1 : {
							_movein = true;
						};
						case 2 : {
							_movein = true;
							_special = "FLY";
						};
					};

					_veh = createvehicle [_type,_pos,[],0,_special];
					_veh setVariable ["dcon_garage_veh",true,true];

					comment "i died about 200 times before implementing this..";
					if!(_veh isKindOf "plane") then {
						_veh setDir _dir;
					};

					{
						_veh animate [_x,_animationValues select _forEachIndex,true];
					} forEach _animationNames;

					{
						_veh setObjectTextureGlobal [_forEachIndex,_x];
					} forEach _textures;

					{
						_veh setPylonLoadOut [_forEachIndex+1, _x,true];
					} forEach _current_mags;


					{
						_unit = (_x select 0);
						_unitPos = position _unit;
						_unitGroup = group player;

						deleteVehicle _unit;

						_type = "";
						switch(playerSide) do
						{
							case west: {
								_type = "B_crew_F";
							};
							case east: {
								_type = "O_crew_F";
							};
							case resistance: {
								_type = "I_crew_F";
							};
							case civilian: {
								_type = "C_man_1";
							};
							default {
								_type = "B_crew_F";
							}
						};
						
						_seatInVeh =  _x select 1;
						if(!(_seatInVeh isEqualTo [])) then
						{
							_spawnedUnit = _unitGroup createUnit [_type, _unitPos, [], 0, "NONE"];

							_positionInVehicle = toLower (_seatInVeh select 0);
							switch (_positionInVehicle) do
							{
								case "driver": {_spawnedUnit moveInDriver _veh};
								case "cargo": {
									if(count _seatInVeh == 2) then {
										_spawnedUnit moveInCargo [_veh, ((_seatInVeh select 1) select 0)];
									}
									else {
										_spawnedUnit moveInCargo _veh;
									};
								};
								case "turret": {_spawnedUnit moveInTurret [_veh, _seatInVeh select 1]};
							};
						};
					}foreach _roles;
				
					if(_movein) then {
						moveout player;
						waitUntil {vehicle player == player};
						if(isNull (driver _veh)) then
						{
							player moveInDriver _veh;
						}
						else
						{
							player moveInAny _veh;
						};
						
					};

					comment "clean up your mess..";
					_veh spawn {
						waitUntil {sleep 1;!alive _this;};
						sleep 40;
						deleteVehicle _this;
					};
				};

				DCON_fnc_Garage_UpdateColor = 
				{
					comment "no idea why this doesn't work ¯\_(ツ)_/¯";

					_veh = DCON_Garage_Vehicle;
					_color = DCON_Garage_Color;

					hint str _color;

					_color2 = format ["#(rgb,8,8,3)color(%1,%2,%3,%4)",_color select 0,_color select 1,_color select 2,_color select 3];

					_veh setObjectTexture [0, _color2];
					_veh setObjectTexture [1, _color2];
					_veh setObjectTexture [2, _color2];
					_veh setObjectTexture [3, _color2];
					_veh setObjectTexture [4, _color2];
					_veh setObjectTexture [5, _color2];
				};

				DCON_fnc_Garage_Open = 
				{
					_pos = (getPos player vectorAdd (eyeDirection player vectorMultiply 15));
					_dir = getDir player;
					[_pos,_dir] spawn DCON_fnc_Garage;	
				};


				WPN_fnc_execute = 
				{
					_weaponName = _this select 0;
					_magName = _this select 1;
					_amount = parseNumber (_this select 2);
					_latestSearch = _this select 3;
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");

					
					if(_amount <= 0) exitWith {};
					if(_amount > 300) then {_amount = 300;};


					for "_i" from 0 to _amount-1 do
					{
						vehicle player addMagazine _magName;
					};
					(vehicle player) addWeapon _weaponName;

					_textbox = (_display displayCtrl 1400);
					hint (ctrlText _textbox);
					profileNamespace setVariable["WeaponryParams",[_latestSearch, _weaponName, _magName, _amount]];				
				};
				
				WPN_fnc_findMagazines = 
				{
					disableSerialization;
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
					_weaponName = _this select 0;


					_magNames = getArray(configFile >> "CfgWeapons" >> _weaponName >> "magazines");
					_listbox = _display displayCtrl 1501;
					lbClear _listbox;
					{_listbox lbAdd _x} forEach _magNames;
					
				};
				
				WPN_fnc_findWeapons = 
				{
					disableSerialization;

					_weaponName = _this select 0;

					waitUntil {count (missionNamespace getVariable ["allWeapons",[]]) > 0};

					_allWeapons = missionNamespace getVariable "allWeapons";
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");

					_correctWeapons = _allWeapons select {_x find toLower(_weaponName) != -1};
					_listbox = _display displayCtrl 1500;

					lbClear _listbox;
					{_listbox lbAdd _x} forEach _correctWeapons;
				};
					
				WPN_fnc_open = 
				{
					disableSerialization;
					
					_defaults =  profileNamespace getVariable["WeaponryParams",["Enter Weapon Name","","Amount of Mags"]];

					_defaults params ["_latestSearch","_defaultWeapon","_defaultMagazine","_defaultAmount"];

					_display = [] call JEW_fnc_weaponry;
					
					(_display displayCtrl 1400) ctrlSetText "Loading Weapons";


					(_display displayCtrl 1400) ctrlSetText _latestSearch;

					_show_func = [_latestSearch] spawn WPN_fnc_findWeapons;
					waitUntil{scriptDone _show_func};

					if(typename _defaultAmount == typename 0) then { _defaultAmount = str _defaultAmount; };

					(_display displayCtrl 1401) ctrlSetText _defaultAmount;

					if(!(_defaultMagazine isEqualTo "")) then {
						(_display displayCtrl 1501) lbAdd _defaultMagazine;
						(_display displayCtrl 1501) lbSetCurSel 0;
					};
				};
				
				JEW_fnc_weaponry = 
				{
					disableSerialization;
					_d_weaponry = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_WeaponryDisplay",_d_weaponry];
					
					_btn_weaponryExecute = _d_weaponry ctrlCreate ["RscButtonMenu", 2600];
					_btn_weaponryExecute ctrlSetText "OK";
					_btn_weaponryExecute ctrlSetPosition [0.650884 * safezoneW + safezoneX,0.471994 * safezoneH + safezoneY,0.0721618 * safezoneW,0.0280062 * safezoneH];
					_btn_weaponryExecute ctrladdEventHandler ["ButtonClick",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500)), (_display displayCtrl 1501) lbText (lbCurSel (_display displayCtrl 1501)),ctrlText (_display displayCtrl 1401),ctrlText (_display displayCtrl 1400)] spawn WPN_fnc_execute;
						_display closeDisplay 1;
					}];
					_btn_weaponryExecute ctrlCommit 0;
					
					
					_btn_weaponryCancel = _d_weaponry ctrlCreate ["RscButtonMenu", 2700];
					_btn_weaponryCancel ctrlSetText "CANCEL";
					_btn_weaponryCancel ctrlSetPosition [0.650884 * safezoneW + safezoneX,0.542009 * safezoneH + safezoneY,0.0721618 * safezoneW,0.0280062 * safezoneH];
					_btn_weaponryCancel ctrladdEventHandler ["ButtonClick",{
						(profileNamespace getVariable "JEW_WeaponryDisplay") closeDisplay 1;
					}];
					_btn_weaponryCancel ctrlCommit 0;
					
					
					_frm_weaponryBack = _d_weaponry ctrlCreate ["RscFrame", 1800];
					_frm_weaponryBack ctrlSetPosition [0.257274 * safezoneW + safezoneX,0.191931 * safezoneH + safezoneY,0.485452 * safezoneW,0.602134 * safezoneH];
					_frm_weaponryBack ctrlCommit 0;
					
					
					_list_weaponryWeapons = _d_weaponry ctrlCreate ["RscListBox", 1500];
					_list_weaponryWeapons ctrlSetPosition [0.263834 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
					_list_weaponryWeapons ctrladdEventHandler ["LBSelChanged",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						
						hint format['%1',(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500))];
						[(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500))] spawn WPN_fnc_findMagazines;
					}];
					_list_weaponryWeapons ctrlCommit 0;
					
					
					_list_weaponryMagazines = _d_weaponry ctrlCreate ["RscListBox", 1501];	
					_list_weaponryMagazines ctrlSetPosition [0.45408 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
					_list_weaponryMagazines ctrladdEventHandler ["LBSelChanged",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						hint format['%1',(_display displayCtrl 1501) lbText (lbCurSel (_display displayCtrl 1501))];
					}];
					_list_weaponryMagazines ctrlCommit 0;
					
					
					_edit_weaponryWeapons = _d_weaponry ctrlCreate ["RscEdit", 1400];
					_edit_weaponryWeapons ctrlSetPosition [0.263834 * safezoneW + safezoneX,0.219938 * safezoneH + safezoneY,0.177125 * safezoneW,0.0280062 * safezoneH];
					_edit_weaponryWeapons ctrlSetTooltip "Enter Weapon Name";
					_edit_weaponryWeapons ctrladdEventHandler ["KeyUp",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[ctrlText (_display displayCtrl 1400)] spawn WPN_fnc_findWeapons;
					}];
					_edit_weaponryWeapons ctrlCommit 0;
					
					
					_edit_weaponryAmount = _d_weaponry ctrlCreate ["RscEdit", 1401];
					_edit_weaponryAmount ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.219938 * safezoneH + safezoneY,0.177125 * safezoneW,0.0280062 * safezoneH];
					_edit_weaponryAmount ctrlSetTooltip "Amount of Mags";
					_edit_weaponryAmount ctrlCommit 0;
					
					_d_weaponry;
				};
								
				
				
				LIT_fnc_execute = 
				{
					
					params ["_H","_L"];

					openMap true;
					[_H,_L] onMapSingleClick { 
						params ["_H","_L"];
						
						_tar = (driver (vehicle player));
						
						(vehicle _tar) flyInHeight _H;

						(group _tar) move _pos;

						_tar = (group _tar);
						if(waypointType [_tar,(currentWaypoint _tar)] isEqualTo "LOITER") then {

							_tar = [_tar,currentWaypoint _tar];
							_tar setWaypointPosition [_pos,0];
							_tar setWaypointLoiterType "CIRCLE_L";
							_tar setWaypointLoiterRadius _L ;

						}
						else {

							_tar = _tar addwaypoint [_pos, 0];
							_tar setWaypointType "LOITER";
							_tar setWaypointLoiterType "CIRCLE_L";
							_tar setWaypointLoiterRadius _L ; 

						};
						_tar setWaypointBehaviour "CARELESS";
						_tar setWaypointCombatMode "BLUE";
						_tar setWaypointForceBehaviour true;
						
						onMapSingleClick "";
						
					};

					vehicle player setVariable ["LoiterParams",[_H,_L]];
				};
				
				LIT_fnc_open = 
				{
					
					_display = [] call JEW_fnc_loiter;


					disableSerialization;

					_defaults =  vehicle player getVariable ["LoiterParams",[1500,1500]];



					{
					_control = _display displayCtrl _x;

					_control_text = _display displayCtrl (ctrlIDC _control - 900);

					_type = "";

					switch (ctrlIDC _control) do
					{
						case 1900: {_type = "Altitude"};
						case 1901: {_type = "Radius"};
					};

					_control sliderSetRange [500,4000];
					_control slidersetSpeed [100,100,100];
					_control sliderSetPosition (_defaults select _forEachIndex);
					_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_defaults select _forEachIndex];

					} forEach [1900,1901];
				};
				
				LIT_fnc_sliderChanged = 
				{
					disableSerialization;

					_control = _this select 0;
					_newValue = _this select 1;
					_display = ctrlParent _control;
					_control_text = _display displayCtrl (ctrlIDC _control - 900);

					_type = "";

					switch (ctrlIDC _control) do
					{
						case 1900: {_type = "Altitude"};
						case 1901: {_type = "Radius"};
					};

					_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_newValue];


				};
				
				JEW_fnc_loiter = 
				{
					disableSerialization;
					_d_loiter = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_WeaponryDisplay",_d_loiter];

					
					_btn_loiterExecute = _d_loiter ctrlCreate ["RscButtonMenu", 2600];
					_btn_loiterExecute ctrlSetText "OK";
					_btn_loiterExecute ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.528006 * safezoneH + safezoneY,0.0590415 * safezoneW,0.0280062 * safezoneH];
					_btn_loiterExecute ctrladdEventHandler ["ButtonClick",{
						
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[sliderPosition (_display displayCtrl 1900), sliderPosition (_display displayCtrl 1901)] spawn LIT_fnc_execute;
						_display closeDisplay 1;

					}];
					_btn_loiterExecute ctrlCommit 0;
					
					
					_btn_loiterCancel = _d_loiter ctrlCreate ["RscButtonMenu", 2700];
					_btn_loiterCancel ctrlSetText "CANCEL";
					_btn_loiterCancel ctrlSetPosition [0.519681 * safezoneW + safezoneX,0.528006 * safezoneH + safezoneY,0.0590415 * safezoneW,0.0280062 * safezoneH];
					_btn_loiterCancel ctrladdEventHandler ["ButtonClick",{
						(profileNamespace getVariable "JEW_WeaponryDisplay") closeDisplay 1;
					}];
					_btn_loiterCancel ctrlCommit 0;
					
					
					_frm_loiterBack = _d_loiter ctrlCreate ["RscFrame", 1800];
					_frm_loiterBack ctrlSetPosition [0.375357 * safezoneW + safezoneX,0.27595 * safezoneH + safezoneY,0.236166 * safezoneW,0.294066 * safezoneH];
					_frm_loiterBack ctrlCommit 0;
					
					
					_gui_loiterBack = _d_loiter ctrlCreate ["IGUIBack", 2200];
					_gui_loiterBack ctrlSetPosition [0.375357 * safezoneW + safezoneX,0.27595 * safezoneH + safezoneY,0.236166 * safezoneW,0.294066 * safezoneH];
					_gui_loiterBack ctrlCommit 0;
					
					
					_slider_loiterAltitude = _d_loiter ctrlCreate ["RscSlider", 1900];
					_slider_loiterAltitude ctrlSetText "Altitude";
					_slider_loiterAltitude ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.317959 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_slider_loiterAltitude ctrladdEventHandler ["SliderPosChanged",{
						[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;
					}];
					_slider_loiterAltitude ctrlCommit 0;
					
					
					_slider_loiterRadius = _d_loiter ctrlCreate ["RscSlider", 1901];	
					_slider_loiterAltitude ctrlSetText "Radius";
					_slider_loiterRadius ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.415981 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_slider_loiterRadius ctrladdEventHandler ["SliderPosChanged",{
						[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;
					}];
					_slider_loiterRadius ctrlCommit 0;
					
					
					_text_loiterAltitude = _d_loiter ctrlCreate ["RscStructuredText", 1000];
					_text_loiterAltitude ctrlSetTooltip "Altitude";
					_text_loiterAltitude ctrlSetText "<t align='center'>Altitude</t>";
					_text_loiterAltitude ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.359969 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_text_loiterAltitude ctrlCommit 0;
					
					
					_text_loiterRadius = _d_loiter ctrlCreate ["RscStructuredText", 1001];
					_text_loiterRadius ctrlSetTooltip "Radius";
					_text_loiterRadius ctrlSetText "<t align='center'>Radius</t>";
					_text_loiterRadius ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.471994 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_text_loiterRadius ctrlCommit 0;
					
					_d_loiter;
				};
				
				
				
				JEW_fnc_main = 
				{
					
					disableSerialization;
					_d_main = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_MainDisplay",_d_main];
					
					_frm_loiterBack = _d_main ctrlCreate ["RscFrame", 1800];
					_frm_loiterBack ctrlSetPosition [0.427838 * safezoneW + safezoneX,0.233941 * safezoneH + safezoneY,0.144324 * safezoneW,0.434097 * safezoneH];
					_frm_loiterBack ctrlCommit 0;
					
					
					_btn_virtualArsenal = _d_main ctrlCreate ["RscButton", 1600];
					_btn_virtualArsenal ctrlSetText "Virtual Arsenal";
					_btn_virtualArsenal ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_virtualArsenal ctrladdEventHandler ["ButtonClick",{
						
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						['Open', true] spawn BIS_fnc_arsenal;
						_display closeDisplay 1;

					}];
					_btn_virtualArsenal ctrlCommit 0;
					
					
					_btn_virtualGarage = _d_main ctrlCreate ["RscButton", 1601];
					_btn_virtualGarage ctrlSetText "Virtual Garage";
					_btn_virtualGarage ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.345965 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_virtualGarage ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						[] call DCON_fnc_Garage_Open;


					}];
					_btn_virtualGarage ctrlCommit 0;
					
					
					_btn_limitedPylon = _d_main ctrlCreate ["RscButton", 1602];
					_btn_limitedPylon ctrlSetText "Pylons - Limited";
					_btn_limitedPylon ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.429984 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_limitedPylon ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						_loadoutObject = [player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo ''));
						[_loadoutObject, false] call GOM_fnc_aircraftLoadout;

					}];
					_btn_limitedPylon ctrlCommit 0;
					
					
					_btn_unlimitedPylon = _d_main ctrlCreate ["RscButton", 1603];
					_btn_unlimitedPylon ctrlSetText "Pylons - Unlimited";
					_btn_unlimitedPylon ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.514003 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_unlimitedPylon ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;

						_loadoutObject = [player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo ''));
						[_loadoutObject, true] call GOM_fnc_aircraftLoadout;

					}];
					_btn_unlimitedPylon ctrlCommit 0;
					
					
					_btn_weaponry = _d_main ctrlCreate ["RscButton", 1604];
					_btn_weaponry ctrlSetText "Add Weapons";
					_btn_weaponry ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.598022 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_weaponry ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						[] spawn WPN_fnc_open;

					}];
					_btn_weaponry ctrlCommit 0;

				};
				
				
				
				JEW_fnc_enableDriverAssist =
				{
					private _veh = objectParent player;

					if (!alive _veh || alive driver _veh || effectiveCommander _veh != player) exitWith {};

					private _class = format ["%1_UAV_AI", ["B","O","I"] select (([BLUFOR,OPFOR,INDEPENDENT] find playerSide) max 0)];
					private _ai = createAgent [_class, _veh, [], 0, "NONE"];

					_ai allowDamage false;
					_ai setVariable ["A3W_driverAssistOwner", player, true];
					[_ai, ["Autodrive","",""]] remoteExec ["A3W_fnc_setName", 0, _ai];
					_ai moveInDriver _veh;

					[_veh, _ai] spawn
					{
						params ["_veh", "_ai"];

						_time = time;
						waitUntil {local _veh || time - _time > 3};

						waitUntil {driver _veh != _ai};
						
						deleteVehicle _ai;

					};

				};
				
				JEW_fnc_disableDriverAssist = 
				{
					private _veh = if (isNil "_veh") then { objectParent player } else { _veh };
					private _driver = driver _veh;

					if (!isAgent teamMember _driver || !((_driver getVariable ["A3W_driverAssistOwner", objNull]) in [player,objNull])) exitWith {};

					deleteVehicle _driver;

				};
				
				JEW_fnc_prevStatement = 
				{
					private _display = d_mainConsole;
					private _nextButton = _display displayCtrl 90111;
					private _prevButton = _display displayCtrl 90110;
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
					private _display = d_mainConsole;
					private _prevButton = _display displayCtrl 90110;
					private _nextButton = _display displayCtrl 90111;
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
								case (_key in actionKeys 'User1'): {[] call JEW_fnc_main};
								case (_key in actionKeys 'User6'): {player moveInAny cursorTarget};
								case (_key in actionKeys 'User2'): {[0] spawn JEW_open_mainConsole};
							};
							false;
						}];

						player enablefatigue false;
						
						player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0}"];		
						player addAction ["Enable driver assist", {[] spawn JEW_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
						player addAction ["Disable driver assist", {[] spawn JEW_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
							
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
						
						player addEventhandler ["Respawn", {
		
							player enableFatigue false;
							
							player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0}"];		
							player addAction ["Enable driver assist", {[] spawn JEW_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
							player addAction ["Disable driver assist", {[] spawn JEW_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
							
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
						}];
						player addEventHandler ["GetInMan", {
							params ["_vehicle", "_role", "_unit", "_turret"];
							
							_vehicle = vehicle player;
							
							
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

					EH_mapTP = player addEventHandler ["Respawn", {
						JEW_fnc_mapTP = {if (!_shift and _alt) then {(vehicle player) setPos _pos;};};
						JEW_keybind_mapTP = ["JEWfncMapTP", "onMapSingleClick", JEW_fnc_MapTP] call BIS_fnc_addStackedEventHandler;
					}];
					SystemChat "...< Keybinds Initialized >...";
				};
				SystemChat "...< Client Initialized >...";
				SystemChat "-----------------------------";
				SystemChat "...< HOME - Main Console >...";
			};
		};
				
				
		}] remoteExec ["spawn",0,"GustavisveryCOOL"];
};

script_notifyWhenDone_Gustav = [] spawn {
	waitUntil { scriptDone script_initCOOLJIPgustav };
	for "_i" from 0 to 10 do {
		SystemChat "...< Init Complete >...";
		sleep 5;
	};
};
