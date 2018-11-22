
disableSerialization;




_defaults =  profileNamespace getVariable["WeaponryParams",["Enter Weapon Name","","Amount of Mags"]];

_defaults params ["_latestSearch","_defaultWeapon","_defaultMagazine","_defaultAmount"];

createDialog "PA_weaponry";

_display = findDisplay 1603;

ctrlSetText [1400,_latestSearch];

_show_func = [_latestSearch] spawn WPN_fnc_findWeapons;
waitUntil{scriptDone _show_func};


if(typename _defaultAmount == typename 0) then { _defaultAmount = str _defaultAmount; };

ctrlSetText [1401,_defaultAmount];

if(!(_defaultMagazine isEqualTo "")) then {
	lbAdd[1501,_defaultMagazine];
	lbSetCurSel [1501,0];
};
