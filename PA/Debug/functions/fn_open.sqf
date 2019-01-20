
createDialog "PA_debug";

disableSerialization;

if(!(profileNamespace getVariable["DebugStatements", []] isEqualTo [])) then
{
	_prevStatements = profileNamespace getVariable ["DebugStatements", []];

	ctrlSetText [5252, (_prevStatements select 0)];
};


_statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
_prevStatements = profileNamespace getVariable ["DebugStatements", []];

ctrlEnable [90110, (_statementIndex < count _prevStatements - 1)];
ctrlEnable [90111, (_statementIndex > 0)];




//Debug input init
if(!(profileNamespace getVariable["DebugStatements", []] isEqualTo [])) then {
	_prevStatements = profileNamespace getVariable ["DebugStatements", []];
	ctrlSetText [5252,(_prevStatements select 0)];
};

//Player list
{lbAdd[5253,name _x];} forEach allPlayers;