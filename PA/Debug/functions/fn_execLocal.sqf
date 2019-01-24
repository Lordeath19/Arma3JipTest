_debugDisplay = findDisplay 46 findDisplay 1728;


_output = _debugDisplay displayCtrl 5267;
_expression = _debugDisplay displayCtrl 5252;

_text = ctrlText _expression;

if(_text isEqualTo "") exitWith
{
	hint "No code to execute.";
};
[] call JEW_fnc_addStatement;
_code = compile _text;
_output ctrlSetText (str ([] call _code));