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

//Store the _H and _L for future use
vehicle player setVariable ["LoiterParams",[_H,_L]];