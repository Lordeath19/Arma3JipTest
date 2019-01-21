_pos = (getPos player vectorAdd (eyeDirection player vectorMultiply 15));
_dir = getDir player;
[_pos,_dir] spawn DCON_fnc_Garage;	
