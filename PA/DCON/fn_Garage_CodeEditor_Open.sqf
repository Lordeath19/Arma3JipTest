
disableSerialization;

_garageDisplay = (uiNamespace getVariable "DCON_Garage_Display");

_display = _garageDisplay createDisplay "RscDisplayGarage";
uiNamespace setVariable ["DCON_Garage_CodeEditor_Display", _display];

_bg = _display ctrlCreate ["RscBackground", -1];
_bg ctrlSetPosition [0.086,0,0.78,0.18];
_bg ctrlSetBackgroundColor [0,0,0,0.8];
_bg ctrlCommit 0;

comment "technically this is exploting, please don't ban me";
_exec = _display ctrlCreate ["RscAttributeExec", 200];
_exec ctrlSetPosition [0.086,0,0.78,0.18];
_exec ctrlCommit 0;

((_display) displayCtrl 14466) ctrlEnable false;

ctrlSetFocus ((_display) displayCtrl 13766);

sleep 3;

_display closeDisplay 1;
