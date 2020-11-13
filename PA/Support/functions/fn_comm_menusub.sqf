ghst_transportheli = "B_Heli_Transport_01_camo_F";
ghst_airliftheli = "B_Heli_Transport_03_F";
ghst_escortheli = ["B_Heli_Attack_01_F"];
ghst_air_cargo = "B_T_VTOL_01_vehicle_F";


CargodropsubMenu =

[
["Cargo Drop",true],

["Cargo Drop", [0],"",-2,[["expression", ""]], "1", "0"], // header text

["Cars and Trucks", [2], "", -5, [["expression", "ghst_drop = [player,(getmarkerpos ""ghst_player_support""),ghst_air_cargo,ghst_carlist,200] spawn SUPP_fnc_cargodrop;"]], "1", "1"],

["Armor", [3], "", -5, [["expression", "ghst_drop = [player,(getmarkerpos ""ghst_player_support""),ghst_air_cargo,ghst_armorlist,200] spawn SUPP_fnc_cargodrop;"]], "1", "1"],

["Static", [4], "", -5, [["expression", "ghst_drop = [player,(getmarkerpos ""ghst_player_support""),ghst_air_cargo,ghst_staticvehlist,200] spawn SUPP_fnc_cargodrop;"]], "1", "1"],

["Boats", [5], "", -5, [["expression", "ghst_drop = [player,(getmarkerpos ""ghst_player_support""),ghst_air_cargo,ghst_boatlist,200] spawn SUPP_fnc_cargodrop;"]], "1", "1"]

];

TransportsubMenu =

[
["Helicopter Airlift",true],

["Helicopter Airlift", [0],"",-2,[["expression", ""]], "1", "0"], // header text

["Helicopter Troop Transport", [2], "", -5, [["expression", "ghst_transport = [ghst_transportheli,ghst_escortheli,(getmarkerpos ""helortb""),50, false] spawn SUPP_fnc_init_transport;"]], "1", "1"],

["Helicopter Cargo Lift", [3], "", -5, [["expression", "ghst_airlift = [ghst_airliftheli,(getmarkerpos ""object_drop_point""),50] spawn SUPP_fnc_init_airlift;"]], "1", "1"]

];