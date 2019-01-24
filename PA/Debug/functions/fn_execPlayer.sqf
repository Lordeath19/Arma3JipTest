
params ["_playerName"];

_debugDisplay = findDisplay 46 findDisplay 1728;

_expression = _debugDisplay displayCtrl 5252;
_playerList = _debugDisplay displayCtrl 5253;

_text = ctrlText _expression;
_playerName = _playerList lbText (lbCurSel _playerList);

if (_text isEqualTo "") exitWith
{
	hint "JEW: Console Error: No code to execute.";
};
[] call JEW_fnc_addStatement;
_code = compile _text;

{
	if(name _x == _playerName) then {
		_code remoteExec ["bis_fnc_call", _x, false];
	};
} foreach allPlayers;
