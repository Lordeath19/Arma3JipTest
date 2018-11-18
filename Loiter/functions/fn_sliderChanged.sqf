disableSerialization;

_control = _this select 0;
_newValue = _this select 1;
_display = ctrlParent _control;
_control_text = _display displayCtrl (ctrlIDC _control - 900);

_type = "";

switch (ctrlIDC _control) do
{
	case 1900: {_type = "Altitude"};
	case 1901: {_type = "Radius"};
};

_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_newValue];

