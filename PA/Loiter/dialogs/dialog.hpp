class PA_loiter
{
	idd = 1602;
	movingenable=false;

	class controls
	{		
		class pa_loiter_ok: GOMRscButtonMenu
		{
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.528006 * safezoneH + safezoneY;
			w = 0.0590415 * safezoneW;
			h = 0.0280062 * safezoneH;
			text = "OK";
			onButtonClick = "closeDialog 1602;[sliderPosition 1900, sliderPosition 1901] spawn LIT_fnc_execute;";
		};
		class pa_loiter_cancel: GOMRscButtonMenu
		{
			x = 0.519681 * safezoneW + safezoneX;
			y = 0.528006 * safezoneH + safezoneY;
			w = 0.0590415 * safezoneW;
			h = 0.0280062 * safezoneH;
			text = "Cancel";
			onButtonClick = "closeDialog 1602;";
		};

		class pa_loiter_frame: GOMRscFrame
		{
			idc = 1800;
			x = 0.375357 * safezoneW + safezoneX;
			y = 0.27595 * safezoneH + safezoneY;
			w = 0.236166 * safezoneW;
			h = 0.294066 * safezoneH;
		};
		
		class pa_loiter_back: GOMIGUIBack
		{
			idc = 2200;
			x = 0.375357 * safezoneW + safezoneX;
			y = 0.27595 * safezoneH + safezoneY;
			w = 0.236166 * safezoneW;
			h = 0.294066 * safezoneH;
		};

		class pa_loiter_altitude: GOMRscSlider
		{
			idc = 1900;
			text="Altitude";
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.317959 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
			onSliderPosChanged = "[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;";
		};
		class pa_loiter_radius: GOMRscSlider
		{
			idc = 1901;
			text="Radius";
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.415981 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
			onSliderPosChanged = "[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;";

		};
		
		class pa_loiter_altitude_text: GOMRscStructuredText
		{
			idc = 1000;
			tooltip = "Altitude";
			text = "<t align='center'>Altitude</t>"; //--- ToDo: Localize;
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.359969 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		
		class pa_loiter_radius_text: GOMRscStructuredText
		{
			idc = 1001;
			tooltip = "Radius";
			text = "<t align='center'>Radius</t>"; //--- ToDo: Localize;
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.471994 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		
	};
};