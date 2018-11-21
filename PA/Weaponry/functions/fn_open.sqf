
disableSerialization;




_defaults =  profileNamespace getVariable["WeaponryParams",["Enter Weapon Name","","Amount of Mags"]];

_defaults params ["_defaultWeapon","_defaultMagazine","_defaultAmount"];

createDialog "PA_weaponry";

ctrlSetText [1400,"Loading Weapons"];

_load = [] spawn {
if(count (missionNamespace getVariable ["allWeapons",[]]) == 0) then {
	disableSerialization;
	
	_allWeapons = ("isclass _x && {getnumber (_x >> 'scope') != 0}" configclasses (configfile >> "cfgweapons")) select {(configName _x) call BIS_fnc_itemType select 0 isEqualTo "Weapon" || (configName _x) call BIS_fnc_itemType select 0 isEqualTo "VehicleWeapon"} apply {configName _x};
	
	_allWeapons sort true;
	missionNamespace setVariable ["allWeapons", _allWeapons];
};
};

_display = findDisplay 1603;

ctrlSetText [1400,_defaultWeapon];

_listbox_weapons = _display ctrlCreate ["RscListBox", 1500];
_listbox_weapons ctrlSetPosition [0.263834 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
_listbox_weapons ctrladdEventHandler ["SetFocus",{
	[ctrlText 1400] spawn WPN_fnc_findWeapons;
}];
_listbox_weapons ctrladdEventHandler ["LBSelChanged",{
	hint format['%1', lbText [1500,lbCurSel 1500]];
	[lbText [1500,lbCurSel 1500]] spawn WPN_fnc_findMagazines;
}];
_listbox_weapons ctrlCommit 0;


_listbox_magazines = _display ctrlCreate ["RscListBox", 1501];
_listbox_magazines ctrlSetPosition [0.45408 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
_listbox_magazines ctrladdEventHandler ["LBSelChanged",{
	hint format['%1', lbText [1501,lbCurSel 1501]];
}];
_listbox_magazines ctrlCommit 0;



if(typename _defaultAmount == typename 0) then { _defaultAmount = str _defaultAmount; };

ctrlSetText [1401,_defaultAmount];

if(!(_defaultMagazine isEqualTo "")) then {
lbAdd[1501,_defaultMagazine];
lbSetCurSel [1501,0];
};
