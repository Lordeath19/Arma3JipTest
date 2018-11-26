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
