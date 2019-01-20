
params ["_playerName"];
_text = ctrlText 5252;
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
