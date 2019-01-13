_text = ctrlText 5252;
if(_text isEqualTo "") exitWith
{
	hint "No code to execute.";
};
[] call JEW_fnc_addStatement;
_code = compile _text;
ctrlSetText[5267, (str ([] call _code))];