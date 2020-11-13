#include "def_vehsel.hpp"

class SelectVehicle
{
  idd = DLG_VEH_IDD;
  movingEnable = 1;
  controlsBackground[] = {BACKGROUND1,BACKGROUND2,HEADER};
  class BACKGROUND1 : Ghst_RscText_WS{
    colorBackground[] = {0,0,0,0.5};
    //colorbackground[] = {0.1961, 0.1451, 0.0941, 0.85};//colorBackground[] = {.6, .6, .6, .8};
    text = ;
      x = 0.2;
      y = 0.1;
      w = 0.4;
      h = 0.8;
      moving = 1;
  };
  class BACKGROUND2 : Ghst_RscText_WS {
    colorBackground[] = {0,0,0,0.5};
    //colorbackground[] = {0.1961, 0.1451, 0.0941, 0.85};//colorBackground[] = {.4, .4, .4, .8};
    text = ;
      x = 0.6;
      y = 0.1;
      w = 0.4;
      h = 0.8;
      moving = 1;
  };
  class HEADER : Ghst_RscText_WS {
    x = 0.2;
    y = 0.1;
    w = 0.4;
    h = 0.06;
        moving = 0;
    colorBackground[] = {0,0,0,0.5};
    //colorbackground[] = {0.1961, 0.1451, 0.0941, 0.85};//colorBackground[] = {.2, .2, .2, .8};
        //colorText[] = {0.95, 0.95, 0.95, 1};//colorText[] = {1, .5, 0, .9};
    sizeEx = 0.04;
    text = "Available Vehicles";
  };

  objects[] = {};

  controls[] = {VEHLIST,VEHIMG,VEHNAME,VEHDESC_CTRL,VEHSEL,VEHclose};
  class VEHLIST : Ghst_RscListBox_WS {
      idc = DLG_VEH_LIST;
      x = 0.21;
      y = 0.165;
      w = 0.38;
      h = 0.62;//0.72;
        //colorText[] = {0.95, 0.95, 0.95, 1};//colorText[] = {0, 0, 0, 1};
        //soundSelect[] = {"",0.1,1};
#ifdef VBS
      onMouseMoving = "DLG_VEH_SEL=_this";
#endif
      moving = 1;
  };
  class VEHNAME : Ghst_RscTextMulti_WS {
      idc = DLG_VEH_NAME;
      style = ST_CENTER;
      x = 0.61;
      y = 0.1;
      w = 0.38;
      h = 0.08;
    sizeEx = 0.04;
        //colorText[] = {0.95, 0.95, 0.95, 1};//colorText[] = {1, .5, 0, .9};
      moving = 1;
  };
  class VEHIMG : Ghst_RscPictureKeepAspect_WS {
      idc = DLG_VEH_PIC;
      x = 0.61;
      y = 0.15;
      w = 0.37;
      h = 0.28;
      moving = 1;
  };
  class VEHDESC_CTRL: Ghst_RscControlsGroup_WS {
        x = .6;
        y = .44;
        w = .395;
        h = .4;
      class Controls {
          class VEHDESC: Ghst_RscStructuredText_WS {
              idc = DLG_VEH_DESC;
              x = 0;
              y = 0;
              w = 0.38;
              h = 0.8;
                //colorText[] = {0.95, 0.95, 0.95, 1};//colorText[] = {1, 1, 1, 1};
              moving = 1;
          };
        };
  };

  class VEHSEL : Ghst_RscButton_WS
  {
      idc = DLG_VEH_BTN;
      x = 0.30;//0.61
      y = 0.83;
      w = 0.20;//0.38
      h = 0.04;
        sizeEx = 0.04;
         text = "Use Selected";
      action = "DLG_VEH_SELECTED = true;ghst_vehsel = ""go"";";
  };

  class VEHclose : VEHSEL
  {
      idc = -1;
      x = 0.80;
      w = 0.10;
        sizeEx = 0.04;
         text = "Close";
      action = "ghst_vehsel = ""none"";closeDialog 0;";
  };
  /*
  class VEHQTY : VEHLIST {
      idc = DLG_VEH_QTY;
      x = 0.55;//0.41;
      y = 0.80;
      w = 0.18;
      h = 0.07;
        //colorText[] = {0.95, 0.95, 0.95, 1};//colorText[] = {0, 0, 0, 1};
        //soundSelect[] = {"",0.1,1};
#ifdef VBS
      onMouseMoving = "DLG_VEH_QTY_SEL=_this";
#endif
      moving = 1;
  };*/
};
