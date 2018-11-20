
createDialog "PA_loiter";


disableSerialization;

//Default height and radius
_defaults =  vehicle player getVariable ["LoiterParams",[1500,1500]];



_display = findDisplay 1602;

{
_control = _display displayCtrl _x;

_control_text = _display displayCtrl (ctrlIDC _control - 900);

_type = "";

switch (ctrlIDC _control) do
{
	case 1900: {_type = "Altitude"};
	case 1901: {_type = "Radius"};
};

_control sliderSetRange [500,4000];
_control slidersetSpeed [100,100,100];
_control sliderSetPosition (_defaults select _forEachIndex);
_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_defaults select _forEachIndex];

} forEach [1900,1901];