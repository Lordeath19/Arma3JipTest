disableSerialization;

_weaponName = _this select 0;


_magNames = getArray(configFile >> "CfgWeapons" >> _weaponName >> "magazines");

lbClear 1501;
{lbAdd [1501,_x]} forEach _magNames;