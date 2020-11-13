params ["_showMessage"];
openMap true;

player groupChat _showMessage;

mapclick = false;
onMapSingleClick "clickpos = _pos; mapclick = true; onMapSingleClick """";true;";

waituntil {mapclick or !(visiblemap)};
if (!visibleMap) exitwith {
    hint "Cancelled";
    [0,0,0];
};

[clickpos select 0, clickpos select 1, 0];
