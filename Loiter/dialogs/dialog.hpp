class PA_loiter
 {
	idd = 1602;
	movingenable=false;
	
	class controls
	{		
		class pa_loiter_ok: PARscButtonMenuOK
		{
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.528006 * safezoneH + safezoneY;
			w = 0.0590415 * safezoneW;
			h = 0.0280062 * safezoneH;
			onButtonClick = "closeDialog 1602;[sliderPosition 1900, sliderPosition 1901] spawn compile preprocessFileLineNumbers ""\PA\Loiter\functions\loiter_fnc_execute.sqf"";";
		};
		class pa_loiter_cancel: PARscButtonMenuCancel
		{
			x = 0.519681 * safezoneW + safezoneX;
			y = 0.528006 * safezoneH + safezoneY;
			w = 0.0590415 * safezoneW;
			h = 0.0280062 * safezoneH;
			onButtonClick = "closeDialog 1602;";
		};

		class pa_loiter_frame: PARscFrame
		{
			idc = 1800;
			x = 0.375357 * safezoneW + safezoneX;
			y = 0.27595 * safezoneH + safezoneY;
			w = 0.236166 * safezoneW;
			h = 0.294066 * safezoneH;
		};
		
		class pa_loiter_back: PAIGUIBack
		{
			idc = 2200;
			x = 0.375357 * safezoneW + safezoneX;
			y = 0.27595 * safezoneH + safezoneY;
			w = 0.236166 * safezoneW;
			h = 0.294066 * safezoneH;
		};

		class  pa_loiter_altitude: PARscSlider
		{
			idc = 1900;
			text="Altitude";
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.317959 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
			onSliderPosChanged = "[_this select 0, _this select 1] spawn compile preprocessFileLineNumbers ""\PA\Loiter\functions\loiter_fnc_sliderChanged.sqf"";";
		};
		class pa_loiter_radius: PARscSlider
		{
			idc = 1901;
			text="Radius";
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.415981 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
		    onSliderPosChanged = "[_this select 0, _this select 1] spawn compile preprocessFileLineNumbers ""\PA\Loiter\functions\loiter_fnc_sliderChanged.sqf"";";

		};
		
		class pa_loiter_altitude_text: PARscStructuredText
		{
			idc = 1000;
			tooltip = "Altitude";
			text = "<t align='center'>Altitude</t>"; //--- ToDo: Localize;
			x = 0.408158 * safezoneW + safezoneX;
			y = 0.359969 * safezoneH + safezoneY;
			w = 0.170564 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class pa_loiter_radius_text: PARscStructuredText
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