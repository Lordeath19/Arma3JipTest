disableSerialization;

_debugDisplay = findDisplay 46 createDisplay "PA_debug";

_inputControl = _debugDisplay displayCtrl 5252;
_prevButton = _debugDisplay displayCtrl 90110;
_nextButton = _debugDisplay displayCtrl 90111;
_playerList = _debugDisplay displayCtrl 5253;

if(!(profileNamespace getVariable["DebugStatements", []] isEqualTo [])) then
{
    _prevStatements = profileNamespace getVariable ["DebugStatements", []];

    _inputControl ctrlSetText (_prevStatements select 0);
};


_statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
_prevStatements = profileNamespace getVariable ["DebugStatements", []];

_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
_nextButton ctrlEnable (_statementIndex > 0);

if(!(profileNamespace getVariable["DebugStatements", []] isEqualTo [])) then {
    _prevStatements = profileNamespace getVariable ["DebugStatements", []];
    _inputControl ctrlSetText (_prevStatements select 0);
};

{
    _playerList lbAdd name _x;
} forEach allPlayers;
