
disableSerialization;




_defaults =  profileNamespace getVariable["WeaponryParams",["Enter Weapon Name","","Amount of Mags"]];

_defaults params ["_defaultWeapon","_defaultMagazine","_defaultAmount"];

createDialog "PA_weaponry";

ctrlSetText [1400,"Loading Weapons"];

_load = [] spawn {
if(count (missionNamespace getVariable ["allWeapons",[]]) == 0) then {
	//get all available weapons from config
	disableSerialization;
	
	_allWeapons = ("isclass _x && {getnumber (_x >> 'scope') != 0}" configclasses (configfile >> "cfgweapons")) select {(configName _x) call BIS_fnc_itemType select 0 isEqualTo "Weapon" || (configName _x) call BIS_fnc_itemType select 0 isEqualTo "VehicleWeapon"} apply {configName _x};
	
	_allWeapons sort true;
	missionNamespace setVariable ["allWeapons", _allWeapons];
};
};

_display = findDisplay 1603;

ctrlSetText [1400,_defaultWeapon];


if(typename _defaultAmount == typename 0) then { _defaultAmount = str _defaultAmount; };

ctrlSetText [1401,_defaultAmount];

if(!(_defaultMagazine isEqualTo "")) then {
lbAdd[1501,_defaultMagazine];
lbSetCurSel [1501,0];
};


