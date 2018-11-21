class PA_main
{
	idd = 1609;
	movingenable=false;

	class controls
	{
		class pa_main_frame: GOMRscFrame
		{
			idc = 1800;

			x = 0.427838 * safezoneW + safezoneX;
			y = 0.233941 * safezoneH + safezoneY;
			w = 0.144324 * safezoneW;
			h = 0.434097 * safezoneH;
		};
		class pa_main_va: GOMRscButton
		{
			idc = 1600;
			onButtonClick = "closeDialog 1609;['Open', true] call BIS_fnc_arsenal";

			text = "Virtual Arsenal"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.261947 * safezoneH + safezoneY;
			w = 0.0918423 * safezoneW;
			h = 0.0420094 * safezoneH;
		};
		class pa_main_vs: GOMRscButton
		{
			idc = 1601;
			onButtonClick = "closeDialog 1609;_pos = player getPos [30,getDir player];if((AGLToASL _pos) select 2 < 0) then {_pos set [2, 0]; };_vehicle = createVehicle [ 'Land_HelipadEmpty_F', _pos, [], 0, 'CAN_COLLIDE' ];['Open',[ true, _vehicle ]] execVM '\PA\replacement\fn_garage.sqf';";
			text = "Virtual Garage"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.345966 * safezoneH + safezoneY;
			w = 0.0918423 * safezoneW;
			h = 0.0420094 * safezoneH;
		};
		class pa_main_goml: GOMRscButton
		{
			idc = 1602;
			onButtonClick = "closeDialog 1609;[[player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo '')), false] call GOM_fnc_aircraftLoadout;";
			text = "Pylons - Limited"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.429984 * safezoneH + safezoneY;
			w = 0.0918423 * safezoneW;
			h = 0.0420094 * safezoneH;
		};
		class pa_main_gomul: GOMRscButton
		{
			idc = 1603;
			onButtonClick = "closeDialog 1609;[[player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo '')), true] call GOM_fnc_aircraftLoadout;";
			text = "Pylons - Unlimited"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.514003 * safezoneH + safezoneY;
			w = 0.0918423 * safezoneW;
			h = 0.0420094 * safezoneH;
		};
		class pa_main_wpn: GOMRscButton
		{
			idc = 1604;
			onButtonClick = "closeDialog 1609;[] spawn WPN_fnc_open;";
			text = "Add Weapons"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.598022 * safezoneH + safezoneY;
			w = 0.0918423 * safezoneW;
			h = 0.0420094 * safezoneH;
		};
	};
};
