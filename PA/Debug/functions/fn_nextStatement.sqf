disableSerialization;
_debugDisplay = findDisplay 1728;

_expression = _debugDisplay displayCtrl 5252;
_prevButton = _debugDisplay displayCtrl 90110;
_nextBUtton = _debugDisplay displayCtrl 90111;

private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

_statementIndex = (_statementIndex - 1) max 0;
profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

private _nextStatement = _prevStatements select _statementIndex;
_expression ctrlSetText _nextStatement;

_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
_nextButton ctrlEnable (_statementIndex > 0);
