[ missionNamespace, "garageClosed", {
	if(BIS_fnc_arsenal_center isEqualTo (player getVariable "garageMark")) then
	{
		deleteVehicle (player getVariable "garageMark");
	}
	else
	{
		_template = BIS_fnc_arsenal_center;
		_templateType = typeOf BIS_fnc_arsenal_center;
		_templatePos = position BIS_fnc_arsenal_center;
		_roles = [];
		{
			_roles pushBack [_x,(assignedVehicleRole _x)];
		}foreach crew _template;


		deleteVehicle _template;
		_actualVehicle = createVehicle [_templateType, _templatePos, [], 0, "NONE"];
		_actualVehicle allowDamage false;
		
		{
			_unit = (_x select 0);
			_unitPos = position _unit;
			_unitGroup = group _unit;
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
					_type = "C_crew_1";
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
					case "driver": {_spawnedUnit moveInDriver _actualVehicle};
					case "cargo": {_spawnedUnit moveInCargo [_actualVehicle, ((_seatInVeh select 1) select 0)]};
					case "turret": {_spawnedUnit moveInTurret [_actualVehicle, _seatInVeh select 1]};
				};
			};

			
		}foreach _roles;
		
		0 = [_actualVehicle] spawn {sleep 10; (_this select 0) allowDamage true;};
	};
}] call BIS_fnc_addScriptedEventHandler;