
class PA_weaponry
{
	idd = 1603;
	movingenable=false;

	class controls
	{
		class PARscFrame_1800: PARscFrame
		{
			idc = 1800;
			x = 0.257274 * safezoneW + safezoneX;
			y = 0.191931 * safezoneH + safezoneY;
			w = 0.485452 * safezoneW;
			h = 0.602134 * safezoneH;
		};
		class PARscListbox_1500: PARscListBox
		{
			idc = 1500;
			onSetFocus = "[ctrlText 1400] spawn WPN_fnc_findWeapons;";
			onLBSelChanged = "hint format['%1', lbText [1500,lbCurSel 1500]];[lbText [1500,lbCurSel 1500]] spawn WPN_fnc_findMagazines;";

			x = 0.263834 * safezoneW + safezoneX;
			y = 0.261946 * safezoneH + safezoneY;
			w = 0.177125 * safezoneW;
			h = 0.518116 * safezoneH;
		};
		class PARscListbox_1501: PARscListBox
		{
			idc = 1501;
			onLBSelChanged = "hint format['%1', lbText [1501,lbCurSel 1501]]";

			x = 0.45408 * safezoneW + safezoneX;
			y = 0.261946 * safezoneH + safezoneY;
			w = 0.177125 * safezoneW;
			h = 0.518116 * safezoneH;
		};
		class PARscButtonMenuOK_2600: PARscButtonMenuOK
		{
			onButtonClick = "closeDialog 1603;[lbText [1500,lbCurSel 1500], lbText [1501,(lbCurSel 1501)],ctrlText 1401, ctrlText 1400] spawn WPN_fnc_execute;";

			x = 0.650884 * safezoneW + safezoneX;
			y = 0.471994 * safezoneH + safezoneY;
			w = 0.0721618 * safezoneW;
			h = 0.0280062 * safezoneH;
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0.8};
		};
		class PARscButtonMenuCancel_2700: PARscButtonMenuCancel
		{
			onButtonClick = "closeDialog 1603;";

			x = 0.650884 * safezoneW + safezoneX;
			y = 0.542009 * safezoneH + safezoneY;
			w = 0.0721618 * safezoneW;
			h = 0.0280062 * safezoneH;
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0.8};
		};
		class PARscEdit_1400: PARscEdit
		{
			idc = 1400;

			text = "Enter Weapon Name"; //--- ToDo: Localize;
			x = 0.263834 * safezoneW + safezoneX;
			y = 0.219938 * safezoneH + safezoneY;
			w = 0.177125 * safezoneW;
			h = 0.0280062 * safezoneH;
		};
		class PARscEdit_1401: PARscEdit
		{
			idc = 1401;

			text = "Amount of Mags"; //--- ToDo: Localize;
			x = 0.454079 * safezoneW + safezoneX;
			y = 0.219938 * safezoneH + safezoneY;
			w = 0.177125 * safezoneW;
			h = 0.0280062 * safezoneH;
		};

	}
}