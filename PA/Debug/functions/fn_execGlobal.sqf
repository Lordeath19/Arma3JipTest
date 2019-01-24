_debugDisplay = (findDisplay 46) findDisplay 1728;

_expression = _debugDisplay displayCtrl 5252;

_text = ctrlText _expression;
if (_text isEqualTo "") exitWith
{
	hint "No code to execute.";
};
[] call JEW_fnc_addStatement;
_code = compile _text;
_code remoteExec ["bis_fnc_call", 0, false];
