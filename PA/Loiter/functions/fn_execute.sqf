params ["_H","_L"];

openMap true;
[_H,_L] onMapSingleClick {
    params ["_H","_L"];

    _veh = vehicle player;
    _group = group player;
    _pilot = driver _veh;

    //Initialize the script, Set flight altitude, position, and hold fire (so the pilot won't try combat manouvers)
    _veh flyInHeight _H;
    _group move _pos;
    _pilot disableAI "AUTOCOMBAT";
    _pilot enableAttack false;
    _pilot setCombatMode "BLUE";
    _waypoint = [_group, currentWaypoint _group];

    //If the waypoint already equals to LOITER, just change the loiter position for the waypoint
    if(waypointType _waypoint isEqualTo "LOITER") then {
        _waypoint setWaypointPosition [_pos,0];
    }

    //Waypoint is something the group got from player commands
    else {
        //Add a new loiter waypoint
        _waypoint = _group addwaypoint [_pos, 0];
        _waypoint setWaypointType "LOITER";

    };

    _waypoint setWaypointLoiterType "CIRCLE_L";
    _waypoint setWaypointLoiterRadius _L;
    _waypoint setWaypointBehaviour "CARELESS";
    _waypoint setWaypointCombatMode "BLUE";
    _waypoint setWaypointForceBehaviour true;

    _group setCurrentWaypoint _waypoint;

    onMapSingleClick "";

};

//Store the _H and _L for future use
vehicle player setVariable ["LoiterParams",[_H,_L]];