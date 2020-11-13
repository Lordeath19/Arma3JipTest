player enableFatigue false;
player enableStamina false;

player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player;alive _veh && alive driver _veh && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['Plane'] > 0"];
player addAction ["Enable driver assist", {[] spawn ASS_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
player addAction ["Disable driver assist", {[] spawn ASS_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];

["onMapTP", "onMapSingleClick", {
    params ["_units","_pos","_alt","_shift"];
    if(count _units == 0 && _alt && !_shift) then {
        (vehicle player) setPos _pos;
    };
}] call BIS_fnc_addStackedEventHandler;

player setVariable ["ControlPanelID",[

    player addAction
    [
        "Open control panel",
        {
        params ["_target", "_caller", "_actionId", "_arguments"];
        createDialog "tu95_main_dialog";
        },
        [],
        7,
        true,
        true,
        "",
        "currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'"
    ],


    player addAction
    [
        "Open control panel",
        {
        params ["_target", "_caller", "_actionId", "_arguments"];
        createDialog "ss21_main_dialog";
        },
        [],
        7,
        true,
        true,
        "",
        "currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'"
    ]
]];


