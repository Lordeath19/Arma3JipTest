private _prevButton = 90110;
private _nextButton = 90111;
private _expression = 5252;

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

	ctrlEnable [_prevButton, (count _prevStatements > 1)];
	ctrlEnable [_nextButton, false];
};