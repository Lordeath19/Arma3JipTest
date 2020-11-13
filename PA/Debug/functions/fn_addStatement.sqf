disableSerialization;
_debugDisplay = findDisplay 1728;

_expression = _debugDisplay displayCtrl 5252;
_prevButton = _debugDisplay displayCtrl 90110;
_nextBUtton = _debugDisplay displayCtrl 90111;

private _statement = ctrlText _expression;

private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

if !((_prevStatements param [0, ""]) isEqualTo _statement) then {

    reverse _prevStatements;
    _prevStatements pushBack _statement;
    reverse _prevStatements;

    if (count _prevStatements > 50) then {
        _prevStatements resize 50;
    };

    profileNamespace setVariable ["DebugStatementsIndex", 0];
    profileNamespace setVariable ["DebugStatements", _prevStatements];

    _prevButton ctrlEnable (count _prevStatements > 1);
    _nextButton ctrlEnable false;
};