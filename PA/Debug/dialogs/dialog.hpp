class PA_debug
{
    idd = 1728;
    movingenable=false;

    class controls
    {
        class pa_prev_button: GOMRscButtonMenu
        {
            idc = 90110;

            onMouseButtonUp = "[] call JEW_fnc_prevStatement";
            text = "Prev Statement";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.783229 * safezoneH + safezoneY;
            w = 0.103125 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_next_button: GOMRscButtonMenu
        {
            idc = 90111;

            onMouseButtonUp = "[] call JEW_fnc_nextStatement";
            text = "Next Statement";
            x = 0.5257817 * safezoneW + safezoneX;
            y = 0.783229 * safezoneH + safezoneY;
            w = 0.103125 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_main_title: GOMRscStructuredText
        {
            idc = 5249;

            colorBackground[] = {0,0,0,0.5};
            text = "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>DEBUG CONSOLE</t>";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.257813 * safezoneW;
            h = 0.055 * safezoneH;
        };

        class pa_txt_background: GOMRscText
        {
            idc = 5248;

            colorBackground[] = {-1,-1,-1,0.7};

            x = 0.371094 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.257813 * safezoneW;
            h = 0.196044 * safezoneH;
        };

        class pa_debug_console_input: GOMRscEdit
        {
            idc = 5252;

            style = 16;
            lineSpacing = 1;

            colorBackground[] = {-1,-1,-1,0.8};
            tooltip = "Script here";

            x = 0.371094 * safezoneW + safezoneX;
            y = 0.464712 * safezoneH + safezoneY;
            w = 0.257813 * safezoneW;
            h = 0.216059 * safezoneH;
        };

        class pa_debug_console_output: GOMRscEdit
        {
            idc = 5267;
            canModify = false;

            colorBackground[] = {0,0,0,1};

            x = 0.371094 * safezoneW + safezoneX;
            y = 0.688771 * safezoneH + safezoneY;
            w = 0.257813 * safezoneW;
            h = 0.04 * safezoneH;
        };

        class pa_player_list_title: GOMRscStructuredText
        {
            idc = 5258;

            text = "<t color='#FFFFFF' shadow='2' size='1' align='center'>Player List</t>";
            colorBackground[] = {0,0,0,0.5};
            x = 0.298906 * safezoneW + safezoneX;
            y = 0.269 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_player_list: GOMRscListbox
        {
            idc = 5253;

            x = 0.298906 * safezoneW + safezoneX;
            y = 0.302 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.341 * safezoneH;
        };

        class pa_server_execute: GOMRscButtonMenu
        {
            idc = 5254;

            text = "Server";

            action = "[] spawn JEW_fnc_execServer";

            x = 0.371094 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.0825 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_global_execute: GOMRscButtonMenu
        {
            idc = 5255;

            text = "Global";

            action = "[] spawn JEW_fnc_execGlobal;";

            x = 0.45875 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.0876563 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_local_execute: GOMRscButtonMenu
        {
            idc = 5256;

            text = "Local";

            action = "[] spawn JEW_fnc_execLocal;";

            x = 0.551563 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.0773437 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class pa_player_execute: GOMRscButtonMenu
        {
            idc = 5257;

            text = "Player";

            action = "[] spawn JEW_fnc_execPlayer";

            x = 0.298906 * safezoneW + safezoneX;
            y = 0.654 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.03 * safezoneH;
        };
    };
};
