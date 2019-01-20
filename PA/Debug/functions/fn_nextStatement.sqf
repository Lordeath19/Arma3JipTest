private _prevButton = 90110;
private _nextButton = 90111;
private _expression = 5252;

private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

_statementIndex = (_statementIndex - 1) max 0;
profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

private _nextStatement = _prevStatements select _statementIndex;
ctrlSetText [_nextStatement, _expression];

ctrlEnable [_prevButton, (_statementIndex < count _prevStatements - 1)];
ctrlEnable [_nextButton, (_statementIndex > 0)];
