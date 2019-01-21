disableSerialization;

_weaponName = _this select 0;

waitUntil {count (missionNamespace getVariable ["allWeapons",[]]) > 0};

_allWeapons = missionNamespace getVariable "allWeapons";

_correctWeapons = _allWeapons select {_x find toLower(_weaponName) != -1};

lbClear 1500;
{lbAdd [1500,_x]} forEach _correctWeapons;