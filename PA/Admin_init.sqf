SystemChat "...< remote executing part 2>...";

script_initCOOLJIPgustavP2 = [] spawn 
{

	waitUntil {!isNull player};
	[[0],
	{
		_JEW_nameKey27 = "76561198164329131";
		_JEW_playerName27 = (getPlayerUID player);
		if (_JEW_playerName27 == _JEW_nameKey27 || _JEW_playerName27 == "_SP_PLAYER_") then 
		{
			SystemChat "Well fuck my life then";
		};
	}] remoteExec ["spawn",0,"GustavisveryCOOLP2"];
};
missionNamespace setVariable ["script_initCOOLJIPgustavP2",script_initCOOLJIPgustavP2];