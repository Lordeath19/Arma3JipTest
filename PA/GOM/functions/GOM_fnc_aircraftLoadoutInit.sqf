GOM_fnc_aircraftLoadoutSavePreset = {
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

GOM_fnc_aircraftLoadoutDeletePreset = {

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

GOM_fnc_aircraftLoadoutLoadPreset = {

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

GOM_fnc_setPylonOwner = {

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

GOM_fnc_setPylonsRearm = {

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

GOM_fnc_setPylonsRepair = {

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

GOM_fnc_setPylonsRefuel = {
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

GOM_fnc_getWeekday = {

	params [["_date",date]];

	_date params ["_year","_m","_q"];

	_yeararray = toarray str _year apply {_x-48};

	_yeararray params ["_y1","_y2","_y3","_y4"];
	_J = ((_y1) * 10) + (_y2);
	_K = ((_y3) * 10) + (_y4);

	if (_m < 3) then {_m = _m + 12};

	["","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"] select (_q + floor ( ((_m + 1) * 26) / 10 ) + _K + floor (_K / 4) + floor (_J / 4) - (2 * _J)) mod 7

};

GOM_fnc_titleText = {

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


	(finddisplay 66 displayctrl 1101) ctrlSetStructuredText parsetext _text;

};

GOM_fnc_roundByDecimals = {

	params ["_num",["_digits",2]];
	round (_num * (10 ^ _digits)) / (10 ^ _digits)

};

GOM_fnc_updateDialog = {

	params ["_obj",["_preset",false]];


	if (lbCursel 1500 < 0) exitWith {



		_obj = player;

	_availableTexts = ["<t color='#E51B1B'>Not available!</t>","<t color='#1BE521'>Available!</t>"];


	_fueltext = "";
	_repairtext = "";
	_rearmtext = "";

	_text = "";
	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext _text;

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

	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext _text;

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

	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext _text;

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

	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext _text;
true
};

GOM_fnc_updateVehiclesLB = {


	params ["_obj"];


	_vehicles = (_obj nearEntities [["Man","Air", "Car", "Motorcycle", "Tank", "StaticWeapon"],50]) select {alive _x};
	_lastVehs = _obj getVariable ["GOM_fnc_setPylonLoadoutVehicles",[]];
	if (_vehicles isEqualTo []) exitWith {true};
	if (_vehicles isEqualTo _lastVehs AND !(lbsize 1500 isequalto 0)) exitWith {true};//only update this when really needed, called on each frame
	_obj setVariable ["GOM_fnc_setPylonLoadoutVehicles",_vehicles,true];


	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>No aircraft in range (50m)!";
	lbclear 1500;


	{

		_dispName = gettext (configfile >> "CfgVehicles" >> typeof _x >> "displayName");
		_form = format ["%1",_dispName];
		lbAdd [1500,_form];
		lbSetData [1500,_foreachIndex,_x call BIS_fnc_objectVar];
	} forEach _vehicles;

};

GOM_fnc_CheckComponents = {

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

GOM_fnc_clearAllPylons = {


	if (!(finddisplay 66 isequalto displaynull) AND lbcursel 1500 < 0) exitWith {"No aircraft selected!"};
	params [["_veh",call compile lbData [1500,lbcursel 1500]]];
	_nosound = false;
	if (finddisplay 66 isequalto displaynull) then {_nosound = true} else {_veh = call compile lbdata [1500,lbcursel 1500]};
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

GOM_fnc_aircraftSetSerialNumber = {


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

GOM_fnc_pylonSound = {

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

GOM_fnc_properWeaponRemoval = {

params ["_veh","_pylonToCheck"];

_currentweapons = weapons _veh;
_pylons = GetPylonMagazines _veh;
_pylonWeapons = _pylons apply {getText ((configfile >> "CfgMagazines" >> _x >> "pylonWeapon"))};
_weaponToCheck = _pylonweapons select lbcursel 1501;
_check = (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1);
_check2 = _pylonweapons select {_x isEqualTo _weaponToCheck};
if (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1) then {_veh removeWeaponGlobal _weaponToCheck;Systemchat ("Removed " + _weaponToCheck)};//remove the current pylon weapon if no other pylon is using it

};

GOM_fnc_installPylons = {

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

GOM_fnc_pylonInstallWeapon = {

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

GOM_fnc_aircraftLoadoutPaintjob = {

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

GOM_fnc_aircraftGetSerialNumber = {

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

GOM_fnc_updateAmmoCountDisplay = {

	if (lbCursel 1500 >= 0 AND lbCursel 1501 < 0 AND lbCursel 1502 < 0) exitWith {

	ctrlSettext [1600,format ["Set Serial Number",""]];
	(finddisplay 66 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Serial Number:";
	ctrlSetText [1400,[] call GOM_fnc_aircraftGetSerialNumber];

	};

	if (lbCursel 1500 < 0) exitWith {false};
	if (lbCursel 1501 < 0) exitWith {false};
	if (lbCursel 1502 < 0) exitWith {false};


	ctrlSettext [1600,"Install Weapon"];

	(finddisplay 66 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Amount:";

	_mag = lbdata [1502,lbCursel 1502];
	_count = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");

	ctrlSetText [1400,str _count];

true
};

GOM_fnc_setPylonPriority = {

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

_keys = finddisplay 66 getVariable ["GOM_fnc_keyDown",["","",false,false,false]];
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

GOM_fnc_fillPylonsLB = {

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

GOM_fnc_updatePresetLB = {

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

GOM_fnc_setPylonLoadoutLBPylonsUpdate = {

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

	findDisplay 66 displayCtrl 2800 cbSetChecked (vehicleReportRemoteTargets _veh);
	findDisplay 66 displayCtrl 2801 cbSetChecked (vehicleReceiveRemoteTargets _veh);
	findDisplay 66 displayCtrl 2802 cbSetChecked (vehicleReportOwnPosition _veh);

	playSound "Click";
true
};

GOM_fnc_aircraftLoadout = {

	params ["_obj", "_allPylons"];
	GOM_fnc_allowAllPylons = _allPylons;
	createDialog "GOM_dialog_aircraftLoadout";
	playSound "Click";
	(finddisplay 66 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>Select an aircraft!";

	lbclear 1500;
	lbclear 1501;
	lbclear 1502;


	lbadd [2100,"Livery"];
	lbSetCurSel [2100,0];


	_getvar = _obj call BIS_fnc_objectVar;
	finddisplay 66 displayCtrl 1500 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;lbsetcursel [1502,-1];lbclear 1501;lbsetcursel [1501,-1];[%1] call GOM_fnc_setPylonLoadoutLBPylonsUpdate;
;[%1] call GOM_fnc_aircraftLoadoutPaintjob;",_getvar]];
	finddisplay 66 displayCtrl 1501 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;[%1] call GOM_fnc_fillPylonsLB;[%1,'NOCOUNT'] call GOM_fnc_setPylonPriority
",_getvar]];
	finddisplay 66 displayCtrl 1502 ctrlAddEventHandler ["LBSelChanged",format ["[%1] call GOM_fnc_updateAmmoCountDisplay;",_getvar]];

	finddisplay 66 displayCtrl 2100 ctrlAddEventHandler ["LBSelChanged",format ["[%1,true] call GOM_fnc_aircraftLoadoutPaintjob",_getvar]];
	finddisplay 66 displayCtrl 2101 ctrlAddEventHandler ["LBSelChanged",format ["",_getvar]];
	buttonSetAction [1600, format ["[%1] call GOM_fnc_pylonInstallWeapon;[] call GOM_fnc_aircraftSetSerialNumber",_getvar]];
	buttonSetAction [1601, format ["[%1] call GOM_fnc_clearAllPylons",_getvar]];
	buttonSetAction [1602, format ["[%1] call GOM_fnc_setPylonsRepair",_getvar]];
	buttonSetAction [1603, format ["[%1] call GOM_fnc_setPylonsRefuel",_getvar]];
	buttonSetAction [1604, format ["[%1] call GOM_fnc_setPylonsReArm",_getvar]];
	buttonSetAction [1605, format ["[%1] call GOM_fnc_setPylonOwner",_getvar]];
	buttonSetAction [1606, format ["[%1] call GOM_fnc_aircraftLoadoutSavePreset",_getvar]];
	buttonSetAction [1607, format ["[%1] call GOM_fnc_aircraftLoadoutDeletePreset",_getvar]];
	buttonSetAction [1608, format ["[%1] call GOM_fnc_aircraftLoadoutLoadPreset",_getvar]];


	buttonSetAction [1609, format ["lbclear 1502;lbSetCurSel [1502,-1];lbclear 1501;lbSetCurSel [1501,-1];lbclear 1500;lbSetCurSel [1500,-1]",""]];
	buttonSetAction [1610, format ["[%1] call GOM_fnc_setPylonPriority",_getvar]];

	findDisplay 66 displayAddEventHandler ["KeyDown",{finddisplay 66 setVariable ["GOM_fnc_keyDown",_this];if (_this select 3) then {ctrlEnable [1607,true];
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
	findDisplay 66 displayAddEventHandler ["KeyUp",{finddisplay 66 setVariable ["GOM_fnc_keyDown",[]];if (_this select 3) then {ctrlEnable [1607,false];ctrlSetText [1607,"CTRL"];

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

	findDisplay 66 displayCtrl 2800 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
	findDisplay 66 displayCtrl 2801 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
	findDisplay 66 displayCtrl 2802 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
	_color = [0,0,0,0.6];
	_dark = [1100,1103,1104,1105,1109,1101,1102,1103,1104,1105,1400,1401,1500,1501,1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,2100,2101];
	{

		findDisplay 66 displayCtrl _x ctrlSetBackgroundColor _color;


	} forEach _dark;
	GOM_fnc_aircraftLoadoutObject = _obj;
	_ID = addMissionEventHandler ["EachFrame",{



		_vehicles = [GOM_fnc_aircraftLoadoutObject] call GOM_fnc_updateVehiclesLB;

		if (displayNull isEqualTo findDisplay 66) exitWith {

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