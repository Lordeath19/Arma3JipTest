class PA_debug
 {
	idd = 1604;
	movingenable=false;
	
	class controls
	{	

		class RscEdit_1400: RscEdit
		{
			idc = 1400;
			x = 0.375357 * safezoneW + safezoneX;
			y = 0.331963 * safezoneH + safezoneY;
			w = 0.236166 * safezoneW;
			h = 0.280062 * safezoneH;
		};
		class RscButton_1600: RscButton
		{
			idc = 1600;
			text = "GLOBAL"; //--- ToDo: Localize;
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.640031 * safezoneH + safezoneY;
			w = 0.0656017 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class RscButton_1601: RscButton
		{
			idc = 1601;
			text = "SERVER"; //--- ToDo: Localize;
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.682041 * safezoneH + safezoneY;
			w = 0.0656017 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class RscButton_1602: RscButton
		{
			idc = 1602;
			text = "LOCAL"; //--- ToDo: Localize;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.640031 * safezoneH + safezoneY;
			w = 0.0656017 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class RscButton_1603: RscButton
		{
			idc = 1603;
			text = "PLAYER"; //--- ToDo: Localize;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.682041 * safezoneH + safezoneY;
			w = 0.0656017 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class RscFrame_1800: RscFrame
		{
			idc = 1800;
			x = 0.368797 * safezoneW + safezoneX;
			y = 0.317959 * safezoneH + safezoneY;
			w = 0.249286 * safezoneW;
			h = 0.406091 * safezoneH;
		};
		class RscListbox_1500: RscListbox
		{
			idc = 1500;
			x = 0.296635 * safezoneW + safezoneX;
			y = 0.317959 * safezoneH + safezoneY;
			w = 0.0656017 * safezoneW;
			h = 0.406091 * safezoneH;
		};
		
	};
 };