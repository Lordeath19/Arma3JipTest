_weaponName = _this select 0;
_magName = _this select 1;
_amount = parseNumber (_this select 2);
_latestSearch = _this select 3;

if(_amount <= 0) exitWith {};
if(_amount > 300) then {_amount = 300;};


for "_i" from 0 to _amount-1 do
{
	vehicle player addMagazine _magName;
};
(vehicle player) addWeapon _weaponName;

hint ctrlText 1400;
profileNamespace setVariable["WeaponryParams",[_latestSearch, _magName, _amount]];
