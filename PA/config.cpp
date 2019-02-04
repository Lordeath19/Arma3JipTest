#define CANNON(NAME) \
    class ##NAME##: CannonCore \
    { \
        type = 1 + 4 + 65536; \
    };

#define SUPPLY(NAME) \
	class ##NAME## : Supply5 { \
		maximumLoad = 9999000; \
	};
	
	
class CfgPatches {	
	class Lordeath_arsenal {
		units[] = {"VTOL_01_armed_base_F","Tank","Car","Air","B_Carryall_Base"};
		weapons[] = {"weapon_VLS_01","cannon_105mm_VTOL_01","gatling_20mm_VTOL_01","autocannon_40mm_VTOL_01"};
		requiredAddons[] = {
			"A3_Data_F",
			"A3_Functions_F",
			"A3Data",
			"a3_3den",
			"A3_Anims_F",
			"A3_Characters_F",
			"A3_Functions_F_Curator",
			"A3_Functions_F_Mark",
			"A3_Weapons_F",
			"A3_Weapons_F_Ammoboxes",
			"A3_Weapons_F_Exp",
			"A3_Weapons_F_Mark",
			"A3_Weapons_F_Destroyer",
			"A3_Air_F_Beta",
			"A3_Air_F_Exp",
			"A3_Air_F_Exp_VTOL_01"};
		author[] = {"Lordeath18"};
	};
};
class CfgFunctions {
	
	class GOM {
		class init
		{
			class aircraftLoadoutInit {file = "\Lordeath\GOM\functions\GOM_fnc_aircraftLoadoutInit.sqf";preInit = 1;};
		};
	};
	
	class Lordeath {
		class init {
			class personalArsenalInit {file = "\Lordeath\init.sqf";preInit = 1;};
		};
	};
	
	class Weaponry {
		tag = "WPN";
		class functions {			
			file = "\Lordeath\Weaponry\functions";	
			
			class execute {};
			class open {};
			class findWeapons {};
			class findMagazines {};
		

		};
	};
	
	class Loiter {
		tag = "LIT";
		class functions 
		{			
			file = "\Lordeath\Loiter\functions";	
			
			class execute {};
			class open {};
			class sliderChanged {};

		};
	};
	
	class Assist {
		tag = "ASS";
		class functions {			
			file = "\Lordeath";	
			
			class playerInit {};
			class disableDriverAssist {};
			class enableDriverAssist {};

		};
	};

	class R3F_LOG {
		class init {
			class R3F_LOGInitfile {file = "\Lordeath\R3F_LOG\init.sqf";postInit = 1;};
		};
	};

	class Debug {
		tag = "JEW";
		class functions {			
			file = "\Lordeath\Debug\functions";	
			
			class addStatement {};
			class prevStatement {};
			class nextStatement {};
			class open {};
			class execGlobal {};
			class execLocal {};
			class execPlayer {};
			class execServer {};

		};
	};

	class DCON {
		tag = "DCON";
		class functions {
			file = "\Lordeath\DCON";
			
			class Garage {};
			class Garage_Open {};
			class Garage_UpdateColor {};
			class Garage_CreateVehicle {};
			class Garage_CodeEditor_Open {};
		};
	};

	class Support {
		tag = "SUPP";
		class functions {
			file = "\Lordeath\Support\functions";
			
			class aircraftlist {};
			class boatlist {};
			class vehiclelist {};
			class cargodrop {};
			class comm_menusub {};
			class createwaypoint {};
			class dest_transport {};
			class init_airlift {};
			class init_transport {};
			class mark_local {};
			class mark_point {};
			class rtb_transport {};
			class tracker {};
			class map_click {};


		};
	};

};

class Mode_SemiAuto;
class manual;
class close;

class CfgWeapons {

	class weapon_VLSBase;
	class Cruise;
	class Rifle_Long_Base_F;
	class MGunCore;
	class CannonCore;
	//Modify all Classes that inherit from CannonCore because i can't overrite it directly (hardcoded in to the game)
	//CANNON(mortar_82mm);
	//CANNON(autocannon_Base_F);
	class autocannon_Base_F;
	//CANNON(gatling_20mm);
	class gatling_20mm;
	//CANNON(gatling_30mm_base);
	//CANNON(cannon_120mm);
	//CANNON(cannon_125mm);
	//CANNON(cannon_105mm);
	class cannon_105mm;
	//CANNON(gatling_25mm);
	//CANNON(autocannon_35mm);
	//CANNON(mortar_155mm_AMOS);
	//CANNON(Gatling_30mm_Plane_CAS_01_F);
	//CANNON(Cannon_30mm_Plane_CAS_02_F);
	//CANNON(weapon_Cannon_Phalanx);
	//CANNON(weapon_Fighter_Gun20mm_AA);
	//CANNON(weapon_Fighter_Gun_30mm);
	
	
	
	class weapon_VLS_01 : weapon_VLSBase {
		displayName = "$STR_A3_Missile_Cruise_weapon_name";
		magazines[] = {"magazine_Missiles_Cruise_01_x18", "magazine_Missiles_Cruise_01_Cluster_x18"};
		
		magazineReloadTime = 6;
		reloadTime = 2;
		class Cruise : Cruise {
			
			aiRateOfFire = 200;
			aiRateOfFireDispersion = -180;
			aiRateOfFireDistance = 32000;
			burst = 1;
			burstRangeMax = 2;
			displayName = "Terrain";
			maxRange = 32000;													
			maxRangeProbab = 1;
			midRange = 2000;
			midRangeProbab = 1;
			minRange = 500;
			minRangeProbab = 0.5;
			reloadTime = 1;
			sounds[] = {"StandardSound"};
			class StandardSound {};
			textureType = "terrain";
			
		};
		
		class EventHandlers {
			fired = "_this call (uinamespace getvariable 'BIS_fnc_effectFired');";
		};
	};

	class cannon_105mm_VTOL_01: cannon_105mm {
		ballisticsComputer = "1 + 8";
		magazines[] = {"40Rnd_105mm_APFSDS","40Rnd_105mm_APFSDS_T_Red","40Rnd_105mm_APFSDS_T_Green","40Rnd_105mm_APFSDS_T_Yellow","100Rnd_105mm_HEAT_MP","20Rnd_105mm_HEAT_MP","20Rnd_105mm_HEAT_MP_T_Red","20Rnd_105mm_HEAT_MP_T_Green","20Rnd_105mm_HEAT_MP_T_Yellow"};
		muzzleEnd = "Howitzer_barrel_beg";
		muzzlePos = "Howitzer_barrel_end";
		selectionFireAnim = "Howitzer_muzzleflash";
		reloadTime = 1;
		laserLock=1;
		magazineReloadTime = 1;
		class GunParticles
		{
			class FirstEffect
			{
				directionName = "Howitzer_barrel_beg";
				effectName = "CannonFired";
				positionName = "Howitzer_barrel_end";
			};
		};
		
		
		class player: Mode_SemiAuto
		{
			aiRateOfFire = 1;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\Sounds_F\arsenal\weapons_vehicles\cannon_105mm\slammer_105mm_distant",3.1622777,1,1500};
				soundBegin[] = {"begin1",1};
			};
			aiDispersionCoefX = 0;
			aiDispersionCoefY = 0;
			soundContinuous = 0;
			reloadTime = 1;
			magazineReloadTime = 1;
			autoReload = 1;
			autoFire = 0;
			dispersion = 0.0;
		};
	};
	
	class LMG_Mk200_F : Rifle_Long_Base_F {
		//Literally every single vehicle round can get into that weapon
		//Fuck yea 'murica
		magazines[] = {"200Rnd_65x39_cased_Box","200Rnd_65x39_cased_Box_Tracer","ACE_200Rnd_65x39_cased_Box_Tracer_Dim", "SmokeLauncherMag_Single","SmokeLauncherMag_boat","200Rnd_65x39_Belt","200Rnd_65x39_Belt_Tracer_Red","200Rnd_65x39_Belt_Tracer_Green","200Rnd_65x39_Belt_Tracer_Yellow","1000Rnd_65x39_Belt","1000Rnd_65x39_Belt_Tracer_Red","1000Rnd_65x39_Belt_Green","1000Rnd_65x39_Belt_Tracer_Green","1000Rnd_65x39_Belt_Yellow","1000Rnd_65x39_Belt_Tracer_Yellow","2000Rnd_65x39_Belt","2000Rnd_65x39_Belt_Tracer_Red","2000Rnd_65x39_Belt_Green","2000Rnd_65x39_Belt_Tracer_Green","2000Rnd_65x39_Belt_Tracer_Green_Splash","2000Rnd_65x39_Belt_Yellow","2000Rnd_65x39_Belt_Tracer_Yellow","2000Rnd_65x39_Belt_Tracer_Yellow_Splash","5000Rnd_762x51_Belt","5000Rnd_762x51_Yellow_Belt","500Rnd_127x99_mag","500Rnd_127x99_mag_Tracer_Red","500Rnd_127x99_mag_Tracer_Green","500Rnd_127x99_mag_Tracer_Yellow","200Rnd_127x99_mag","200Rnd_127x99_mag_Tracer_Red","200Rnd_127x99_mag_Tracer_Green","200Rnd_127x99_mag_Tracer_Yellow","100Rnd_127x99_mag","100Rnd_127x99_mag_Tracer_Red","100Rnd_127x99_mag_Tracer_Green","100Rnd_127x99_mag_Tracer_Yellow","450Rnd_127x108_Ball","150Rnd_127x108_Ball","50Rnd_127x108_Ball","200Rnd_40mm_G_belt","96Rnd_40mm_G_belt","64Rnd_40mm_G_belt","32Rnd_40mm_G_belt","200Rnd_20mm_G_belt","40Rnd_20mm_G_belt","32Rnd_155mm_Mo_shells","32Rnd_155mm_Mo_shells_O","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_guided","8Rnd_82mm_Mo_LG","6Rnd_155mm_Mo_smoke","6Rnd_155mm_Mo_smoke_O","2Rnd_155mm_Mo_guided","2Rnd_155mm_Mo_guided_O","4Rnd_155mm_Mo_guided","4Rnd_155mm_Mo_guided_O","2Rnd_155mm_Mo_LG","4Rnd_155mm_Mo_LG","4Rnd_155mm_Mo_LG_O","6Rnd_155mm_Mo_mine","6Rnd_155mm_Mo_mine_O","6Rnd_155mm_Mo_AT_mine","6Rnd_155mm_Mo_AT_mine_O","2Rnd_155mm_Mo_Cluster","2Rnd_155mm_Mo_Cluster_O","300Rnd_20mm_shells","1000Rnd_20mm_shells","2000Rnd_20mm_shells","300Rnd_25mm_shells","1000Rnd_25mm_shells","250Rnd_30mm_HE_shells","250Rnd_30mm_HE_shells_Tracer_Red","250Rnd_30mm_HE_shells_Tracer_Green","250Rnd_30mm_APDS_shells","250Rnd_30mm_APDS_shells_Tracer_Red","250Rnd_30mm_APDS_shells_Tracer_Green","250Rnd_30mm_APDS_shells_Tracer_Yellow","140Rnd_30mm_MP_shells","140Rnd_30mm_MP_shells_Tracer_Red","140Rnd_30mm_MP_shells_Tracer_Green","140Rnd_30mm_MP_shells_Tracer_Yellow","60Rnd_30mm_APFSDS_shells","60Rnd_30mm_APFSDS_shells_Tracer_Red","60Rnd_30mm_APFSDS_shells_Tracer_Green","60Rnd_30mm_APFSDS_shells_Tracer_Yellow","60Rnd_40mm_GPR_shells","60Rnd_40mm_GPR_Tracer_Red_shells","60Rnd_40mm_GPR_Tracer_Green_shells","60Rnd_40mm_GPR_Tracer_Yellow_shells","40Rnd_40mm_APFSDS_shells","40Rnd_40mm_APFSDS_Tracer_Red_shells","40Rnd_40mm_APFSDS_Tracer_Green_shells","40Rnd_40mm_APFSDS_Tracer_Yellow_shells","14Rnd_80mm_rockets","38Rnd_80mm_rockets","12Rnd_230mm_rockets","12Rnd_230mm_rockets_cluster","4Rnd_GAA_missiles","4Rnd_Titan_long_missiles","4Rnd_Titan_long_missiles_O","5Rnd_GAT_missiles","2Rnd_GAT_missiles","2Rnd_GAT_missiles_O","30Rnd_120mm_HE_shells","30Rnd_120mm_HE_shells_Tracer_Red","30Rnd_120mm_HE_shells_Tracer_Green","30Rnd_120mm_HE_shells_Tracer_Yellow","16Rnd_120mm_HE_shells","16Rnd_120mm_HE_shells_Tracer_Red","16Rnd_120mm_HE_shells_Tracer_Green","16Rnd_120mm_HE_shells_Tracer_Yellow","14Rnd_120mm_HE_shells","14Rnd_120mm_HE_shells_Tracer_Red","14Rnd_120mm_HE_shells_Tracer_Green","14Rnd_120mm_HE_shells_Tracer_Yellow","12Rnd_120mm_HE_shells","12Rnd_120mm_HE_shells_Tracer_Red","12Rnd_120mm_HE_shells_Tracer_Green","12Rnd_120mm_HE_shells_Tracer_Yellow","8Rnd_120mm_HE_shells","8Rnd_120mm_HE_shells_Tracer_Red","8Rnd_120mm_HE_shells_Tracer_Green","8Rnd_120mm_HE_shells_Tracer_Yellow","30Rnd_120mm_APFSDS_shells","30Rnd_120mm_APFSDS_shells_Tracer_Red","30Rnd_120mm_APFSDS_shells_Tracer_Green","30Rnd_120mm_APFSDS_shells_Tracer_Yellow","32Rnd_120mm_APFSDS_shells","32Rnd_120mm_APFSDS_shells_Tracer_Red","32Rnd_120mm_APFSDS_shells_Tracer_Green","32Rnd_120mm_APFSDS_shells_Tracer_Yellow","28Rnd_120mm_APFSDS_shells","28Rnd_120mm_APFSDS_shells_Tracer_Red","28Rnd_120mm_APFSDS_shells_Tracer_Green","28Rnd_120mm_APFSDS_shells_Tracer_Yellow","24Rnd_120mm_APFSDS_shells","24Rnd_120mm_APFSDS_shells_Tracer_Red","24Rnd_120mm_APFSDS_shells_Tracer_Green","24Rnd_120mm_APFSDS_shells_Tracer_Yellow","20Rnd_120mm_APFSDS_shells","20Rnd_120mm_APFSDS_shells_Tracer_Red","20Rnd_120mm_APFSDS_shells_Tracer_Green","20Rnd_120mm_APFSDS_shells_Tracer_Yellow","12Rnd_120mm_APFSDS_shells","12Rnd_120mm_APFSDS_shells_Tracer_Red","12Rnd_120mm_APFSDS_shells_Tracer_Green","12Rnd_120mm_APFSDS_shells_Tracer_Yellow","20Rnd_120mm_HEAT_MP","20Rnd_120mm_HEAT_MP_T_Red","20Rnd_120mm_HEAT_MP_T_Green","20Rnd_120mm_HEAT_MP_T_Yellow","12Rnd_120mm_HEAT_MP","12Rnd_120mm_HEAT_MP_T_Red","12Rnd_120mm_HEAT_MP_T_Green","12Rnd_120mm_HEAT_MP_T_Yellow","8Rnd_120mm_HEAT_MP","8Rnd_120mm_HEAT_MP_T_Red","8Rnd_120mm_HEAT_MP_T_Green","8Rnd_120mm_HEAT_MP_T_Yellow","12Rnd_125mm_HE","12Rnd_125mm_HE_T_Red","12Rnd_125mm_HE_T_Green","12Rnd_125mm_HE_T_Yellow","8Rnd_125mm_HE","8Rnd_125mm_HE_T_Red","8Rnd_125mm_HE_T_Green","8Rnd_125mm_HE_T_Yellow","20Rnd_125mm_APFSDS","20Rnd_125mm_APFSDS_T_Red","20Rnd_125mm_APFSDS_T_Green","20Rnd_125mm_APFSDS_T_Yellow","24Rnd_125mm_APFSDS","24Rnd_125mm_APFSDS_T_Red","24Rnd_125mm_APFSDS_T_Green","24Rnd_125mm_APFSDS_T_Yellow","16Rnd_125mm_APFSDS","16Rnd_125mm_APFSDS_T_Red","16Rnd_125mm_APFSDS_T_Green","16Rnd_125mm_APFSDS_T_Yellow","12Rnd_125mm_HEAT","12Rnd_125mm_HEAT_T_Red","12Rnd_125mm_HEAT_T_Green","12Rnd_125mm_HEAT_T_Yellow","40Rnd_105mm_APFSDS","40Rnd_105mm_APFSDS_T_Red","40Rnd_105mm_APFSDS_T_Green","40Rnd_105mm_APFSDS_T_Yellow","20Rnd_105mm_HEAT_MP","20Rnd_105mm_HEAT_MP_T_Red","20Rnd_105mm_HEAT_MP_T_Green","20Rnd_105mm_HEAT_MP_T_Yellow","680Rnd_35mm_AA_shells","680Rnd_35mm_AA_shells_Tracer_Red","680Rnd_35mm_AA_shells_Tracer_Green","680Rnd_35mm_AA_shells_Tracer_Yellow","1Rnd_GAA_missiles","1Rnd_GAT_missiles","200Rnd_762x51_Belt","200Rnd_762x51_Belt_Red","200Rnd_762x51_Belt_T_Red","200Rnd_762x51_Belt_Green","200Rnd_762x51_Belt_T_Green","200Rnd_762x51_Belt_Yellow","200Rnd_762x51_Belt_T_Yellow","1000Rnd_762x51_Belt","1000Rnd_762x51_Belt_Red","1000Rnd_762x51_Belt_T_Red","1000Rnd_762x51_Belt_Green","1000Rnd_762x51_Belt_T_Green","1000Rnd_762x51_Belt_Yellow","1000Rnd_762x51_Belt_T_Yellow","2000Rnd_762x51_Belt","2000Rnd_762x51_Belt_Red","2000Rnd_762x51_Belt_T_Red","2000Rnd_762x51_Belt_Green","2000Rnd_762x51_Belt_T_Green","2000Rnd_762x51_Belt_Yellow","2000Rnd_762x51_Belt_T_Yellow","1000Rnd_Gatling_30mm_Plane_CAS_01_F","7Rnd_Rocket_04_HE_F","7Rnd_Rocket_04_AP_F","500Rnd_Cannon_30mm_Plane_CAS_02_F","20Rnd_Rocket_03_HE_F","20Rnd_Rocket_03_AP_F","PylonRack_1Rnd_GAA_missiles","PylonMissile_1Rnd_GAA_missiles","PylonRack_7Rnd_Rocket_04_HE_F","PylonRack_7Rnd_Rocket_04_AP_F","PylonWeapon_300Rnd_20mm_shells","PylonWeapon_2000Rnd_65x39_belt","PylonRack_20Rnd_Rocket_03_HE_F","PylonRack_20Rnd_Rocket_03_AP_F","PylonRack_19Rnd_Rocket_Skyfire","500Rnd_65x39_Belt","500Rnd_65x39_Belt_Tracer_Red_Splash","500Rnd_65x39_Belt_Tracer_Green_Splash","500Rnd_65x39_Belt_Tracer_Yellow_Splash","4000Rnd_20mm_Tracer_Red_shells","160Rnd_40mm_APFSDS_Tracer_Red_shells","240Rnd_40mm_GPR_Tracer_Red_shells","100Rnd_105mm_HEAT_MP","magazine_Missile_rim116_x21","magazine_Missile_rim162_x8","magazine_Cannon_Phalanx_x1550","magazine_Fighter01_Gun20mm_AA_x450","magazine_Fighter04_Gun20mm_AA_x150","magazine_Fighter04_Gun20mm_AA_x250","magazine_Fighter02_Gun30mm_AA_x180","PylonRack_4Rnd_BombDemine_01_F","PylonRack_4Rnd_BombDemine_01_Dummy_F","4Rnd_120mm_cannon_missiles","4Rnd_120mm_LG_cannon_missiles","4Rnd_125mm_cannon_missiles","60Rnd_30mm_MP_shells_Tracer_Green","4Rnd_70mm_SAAMI_missiles","2Rnd_127mm_Firefist_missiles","60Rnd_20mm_HE_shells","60Rnd_20mm_AP_shells","magazine_Missiles_Cruise_01_x18","magazine_Missiles_Cruise_01_Cluster_x18","magazine_ShipCannon_120mm_HE_shells_x32","magazine_ShipCannon_120mm_smoke_shells_x6","magazine_ShipCannon_120mm_HE_guided_shells_x2","magazine_ShipCannon_120mm_HE_LG_shells_x2","magazine_ShipCannon_120mm_mine_shells_x6","magazine_ShipCannon_120mm_HE_cluster_shells_x2","magazine_ShipCannon_120mm_AT_mine_shells_x6","magazine_Missile_mim145_x4","magazine_Missile_s750_x4"};

	};
	
	class autocannon_40mm_CTWS: autocannon_Base_F {
		class HE;
		class AP;
	};

	class autocannon_40mm_VTOL_01: autocannon_40mm_CTWS {
		ballisticsComputer = "1 + 8";
		laserLock = 1;
		class HE: HE
		{
			ballisticsComputer = "1 + 8";
			laserLock = 1;
		};
		class AP: AP
		{
			ballisticsComputer = "1 + 8";
			laserLock = 1;
		};
	};

	class gatling_20mm_VTOL_01: gatling_20mm {
		ballisticsComputer = "1 + 8";
		laserLock = 1;
		FCSMaxLeadSpeed=200;
		maxZeroing = 4000;
		class manual : manual
		{
			dispersion=0.002;
		};
		
		class medium: close	{
			dispersion=0.002;
		};
		
		class short : manual
		{
			dispersion=0.002;
		};
	};
	
};

class CfgAmmo {
	
	class ammo_Missile_Cruise_01;
	class ammo_Missile_Cruise_01_Cluster : ammo_Missile_Cruise_01 {
		cameraViewAvailable = 1;
		model = "\A3\Weapons_F_Destroyer\Ammo\Missile_Cruise_01_Fly_F";
		proxyShape = "\A3\Weapons_F_Destroyer\Ammo\Missile_Cruise_01_Fly_F";
		triggerDistance = 250;
		triggerSpeedCoef[] = {0.5, 1};
		submunitionConeAngle = 19;
		submunitionConeType[] = {"randomcenter", 100};
		submunitionAmmo[] = {"Mo_cluster_AP", 0.96, "Mo_cluster_AP_UXO_deploy", 0.03};
	};
		
	class Sh_125mm_HEAT;
	class Sh_105mm_HEAT_MP: Sh_125mm_HEAT {
		hit = 1200;
		indirectHit = 100;
		indirectHitRange = 6;
		caliber = 6;
		deflecting = 0;
		airFriction = -0.000308;
	};

	class B_20mm;	
	class B_20mm_Tracer_Red: B_20mm {
		hit = 150;
		indirectHit = 80;
		indirectHitRange = 5;
		explosive = 0.7;
		caliber = 3.4;
		timeToLive = 60;
		
	};
	
	
	
};

class CfgMagazines {
	
	class 1000Rnd_20mm_shells;
	class 4000Rnd_20mm_Tracer_Red_shells : 1000Rnd_20mm_shells {
		initSpeed = 1630;
					
	};

};

class DefaultVehicleSystemsDisplayManagerLeft {
	class components;
};

class DefaultVehicleSystemsDisplayManagerRight {
	class components;
};

class CfgVehicles {
	
	class AllVehicles;
	class Land;
	class Bag_Base;
	class ContainerSupply;
	class Plane;
	class Plane_Base_F: Plane {
		class MarkerLights;
		class Turrets;
		class HitPoints;
		class Components;
	};
	
	class LandVehicle : Land {
		class Components
		{
			class TransportPylonsComponent
			{
				uiPicture = "\A3\Air_F_EPC\Plane_CAS_01\Data\UI\Plane_CAS_01_3DEN_CA.paa";

				class pylons // Pylons are indexed to aircraft model's proxies IDs in the order they are written in class Pylons
                {
                    class pylons1 // left wingtip
                    {
                        maxweight     = 90000;                            //kg ,magazine with higher mass will not be allowed on this pylon
                        hardpoints[]  = {"B_BOMB_PYLON"};               // magazine with at least one same hardpoints name will be attachable
                        //hardpoint[] = {"A164_PYLON_1_10","LAU_7","B_ASRAAM", "SUU_63_PYLON","BRU_32_EJECTOR","B_BOMB_PYLON",....}; // just example for community, I am sure you will go closer to realism
                        attachment    = "";
                        bay           = -1;                              // index of bay for animation
                        priority      = 5;                               // pylon with higher priority is used to fire missile first, this can by changed in run time by script command setPylonsPriority
                        UIposition[]  = {0.1, 0.25};                     // x,y coordinates in 3DEN UI
                        turret[]      = {};                              // default owner of pylon/weapon, empty for driver
                    };
                    class pylons2: pylons1 {priority = 4;};
                    class pylons3: pylons1 {priority = 3;};
                    class pylons4: pylons1 {priority = 2;};
                    class pylons5: pylons1 {priority = 1;};
                    class pylons6: pylons5 {mirroredMissilePos = 5;}; // Will copy loadout from pylon 5 in when "Mirror" is checked in Eden loadout interface. And proxies/missiles racks on this pylon will be re-indexed by magazine::mirrorMissilesIndexes[]
                    class pylons7: pylons4  {mirroredMissilePos = 4;};
                    class pylons8: pylons3  {mirroredMissilePos = 3;};
                    class pylons9: pylons2  {mirroredMissilePos = 2;};
                    class pylons10: pylons1 {mirroredMissilePos = 1;}; // right wingtip
                };

				class Bays
                {
                    class BayCenter // corresponding to pylons/##pylon##/bay=1;
                    {
                        bayOpenTime               = 1;
                        openBayWhenWeaponSelected = 1.0; // float value, can be used to half open bay

                        // -1 keep open, 0 close after last missile, > 0 keep open for given time after last shot                       
                        autoCloseWhenEmptyDelay   = 2; // when last shot keep 2s open after last shot
                    };
                    class BayRight   // corresponding to pylons/##pylon##/bay=2;
                    {
                        bayOpenTime               = 0.8;
                        openBayWhenWeaponSelected = 0.0;
                    };
                    class BayLeft: BayRight{}; // corresponding to pylons/##pylon##/bay=3;
                };
			};
			
		};
	};
	//Change vest carry capacity
	class Supply5 : ContainerSupply {
        maximumLoad = 9999000;               // Replace XX with the desired capacity value.
    };

	SUPPLY(Supply20);
	
	SUPPLY(Supply30);
	
	SUPPLY(Supply40);
	
	SUPPLY(Supply50);
	
	SUPPLY(Supply60);
	
	SUPPLY(Supply70);
	
	SUPPLY(Supply80);

	SUPPLY(Supply90);
	
	SUPPLY(Supply100);
	
	SUPPLY(Supply110);
	
	SUPPLY(Supply120);
	
	SUPPLY(Supply130);
	
	SUPPLY(Supply140);
	
	SUPPLY(Supply150);
	
	SUPPLY(Supply160);
	
	SUPPLY(Supply170);
	
	SUPPLY(Supply180);
	
	SUPPLY(Supply190);
	
	SUPPLY(Supply200);
	
	SUPPLY(Supply210);
	
	SUPPLY(Supply220);
	
	SUPPLY(Supply230);
	
	SUPPLY(Supply240);

	SUPPLY(Supply250);
	
	SUPPLY(Supply260);
	
	SUPPLY(Supply270);
	
	SUPPLY(Supply280);
	
	SUPPLY(Supply290);
	
	SUPPLY(Supply300);
	
	SUPPLY(Supply310);
	
	SUPPLY(Supply320);
	
	SUPPLY(Supply330);
	
	SUPPLY(Supply340);
	
	SUPPLY(Supply350);
	
	SUPPLY(Supply360);
	
	SUPPLY(Supply370);
	
	SUPPLY(Supply380);
	
	SUPPLY(Supply390);
	
	SUPPLY(Supply400);
	
	SUPPLY(Supply650);
	
	SUPPLY(Supply780);
	
	SUPPLY(Supply1000);

	SUPPLY(Supply1200);
		
	//Change carryall so he can carry it all
	class B_Carryall_Base : Bag_Base {
		maximumLoad = 9000000;
	};	

	class VTOL_Base_F: Plane_Base_F {
		class AnimationSources;
		class HitPoints: HitPoints
		{
			class HitHull;
		};
		class CargoTurret;
		class MarkerLights: MarkerLights
		{
			class PositionWhite;
		};
		class NewTurret;
		class Turrets: Turrets
		{
			class CopilotTurret;
		};
	};
	
	class VTOL_01_base_F: VTOL_Base_F {
		class Turrets: Turrets
		{
			class CopilotTurret;
		};
	};	

	class VTOL_01_armed_base_F: VTOL_01_base_F {
		class Turrets: Turrets
		{
			
			class CopilotTurret: CopilotTurret
			{
				magazines[] = {"Laserbatteries","magazine_Missile_rim162_x8","magazine_Missile_rim116_x21","magazine_Cannon_Phalanx_x1550"};
				weapons[] = {"weapon_Cannon_Phalanx","Laserdesignator_mounted","weapon_rim116Launcher","weapon_rim162Launcher"};
				minElev = -89;
				maxElev = 89;
				initElev = 0;
				minTurn = -360;
				maxTurn = 360;
				initTurn = 90;
				showAllTargets = 2;
				showCrewAim = "1 + 4";
				stabilizedInAxes = 3;
				maxVerticalRotSpeed = 1.2;
				maxHorizontalRotSpeed = 1.2;
			};
			class GunnerTurret_01: NewTurret
			{
				animationSourceBody = "Gunner01_rotH_source";
				animationSourceGun = "Gunner01_rotV_source";
				body = "Howitzer_turret_rot";
				castGunnerShadow = 1;
				commanding = -1;
				discreteDistance[] = {100,200,300,400,500,600,700,800,1000,1200,1500,1800,2100,2400};
				discreteDistanceInitIndex = 5;
				enableManualFire = 0;
				gun = "Howitzer_rot";
				gunBeg = "Howitzer_barrel_end";
				gunEnd = "Howitzer_barrel_beg";
				gunnerAction = "gunner_01_VTOL_01_armed";
				gunnerCompartments = "Compartment1";
				gunnerForceOptics = 0;
				gunnerGetInAction = "GetInHigh";
				gunnerGetOutAction = "GetOutHigh";
				gunnerInAction = "gunner_01_VTOL_01_armed";
				gunnerName = "$STR_A3_LEFT_GUNNER";
				gunnerOpticsModel = "\A3\Weapons_F\Reticle\Optics_Gunner_02_F.p3d";
				gunnerUsesPilotView = 1;
				memoryPointGunBone[] = {"Gatling_rot"};
				memoryPointGunnerOptics = "Howitzer_pip_pos";
				memoryPointGun[] = {"Gatling_barrel_beg"};
				memoryPointsGetInGunner = "GetIn_gunner_left_pos";
				memoryPointsGetInGunnerDir = "GetIn_gunner_left_dir";
				minElev = -80;
				maxElev = 80;
				initElev = 0;
				minTurn = 10;
				maxTurn = 160;
				initTurn = 90;
				missileBeg = "Howitzer_barrel_end";
				missileEnd = "Howitzer_barrel_beg";
				outGunnerMayFire = 1;
				particlesDir = "Howitzer_barrel_end";
				particlesPos = "Howitzer_barrel_beg";
				primaryGunner = 1;
				proxyIndex = 2;
				selectionFireAnim = "";
				showAllTargets = 4;
				showCrewAim = "1 + 4";
				stabilizedInAxes = 3;
				startEngine = 0;
				turretInfoType = "RscOptics_Heli_Attack_01_gunner";
				usePip = 1;
				gunnerHasFlares=true;
				magazines[] = {"100Rnd_105mm_HEAT_MP", "40Rnd_105mm_APFSDS","32Rnd_155mm_Mo_shells", "4Rnd_155mm_Mo_guided","4Rnd_155mm_Mo_LG","2Rnd_155mm_Mo_Cluster","240Rnd_40mm_GPR_Tracer_Red_shells","160Rnd_40mm_APFSDS_Tracer_Red_shells","4000Rnd_20mm_Tracer_Red_shells", "Laserbatteries", "300Rnd_CMFlare_Chaff_Magazine"};
				weapons[] = {"cannon_105mm_VTOL_01","gatling_20mm_VTOL_01","autocannon_40mm_VTOL_01","mortar_155mm_AMOS","Laserdesignator_mounted", "CMFlareLauncher_Triples"};
				class OpticsIn
				{
					class Wide
					{
						directionStabilized = 1;
						initAngleX = 0;
						minAngleX = -30;
						maxAngleX = 30;
						initAngleY = 0;
						minAngleY = -100;
						maxAngleY = 100;
						initFov = 0.466;
						minFov = 0.466;
						maxFov = 0.466;
						gunnerOpticsModel = "\A3\Weapons_F_Beta\Reticle\Heli_Attack_01_Optics_Gunner_wide_F.p3d";
						opticsDisplayName = "W";
						visionMode[] = {"Normal","NVG","Ti"};
						thermalMode[] = {0,1};
					};
					class Medium: Wide
					{
						initFov = 0.059;
						minFov = 0.059;
						maxFov = 0.059;
						gunnerOpticsModel = "\A3\Weapons_F_Beta\Reticle\Heli_Attack_01_Optics_Gunner_medium_F.p3d";
						opticsDisplayName = "M";
					};
					class Narrow: Wide
					{
						initFov = 0.030;
						minFov = 0.030;
						maxFov = 0.030;
						gunnerOpticsModel = "\A3\Weapons_F_Beta\Reticle\Heli_Attack_01_Optics_Gunner_narrow_F.p3d";
						opticsDisplayName = "N";
					};
					class Tiny : Narrow
					{
						initFov = 0.01;
						minFov = 0.01;
						maxFov = 0.01;
						opticsDisplayName = "T";
					};
					class Extreme : Tiny
					{
						initFov = 0.004;
						minFov = 0.004;
						maxFov = 0.004;
						opticsDisplayName = "E";
					};
				};
				class OpticsOut
				{
					class Monocular
					{
						initAngleX = 0;
						minAngleX = -30;
						maxAngleX = 30;
						initAngleY = 0;
						minAngleY = -100;
						maxAngleY = 100;
						minFov = 0.25;
						maxFov = 1.25;
						initFov = 0.75;
						gunnerOpticsEffect[] = {};
						gunnerOpticsModel = "";
						visionMode[] = {"Normal","NVG"};
					};
				};
				class Components
				{
					class VehicleSystemsDisplayManagerComponentLeft: DefaultVehicleSystemsDisplayManagerLeft
					{
						class Components
						{
							class EmptyDisplay
							{
								componentType = "EmptyDisplayComponent";
							};
							class MinimapDisplay
							{
								componentType = "MinimapDisplayComponent";
								resource = "RscCustomInfoMiniMap";
							};
							class CrewDisplay
							{
								componentType = "CrewDisplayComponent";
								resource = "RscCustomInfoCrew";
							};
							class UAVDisplay
							{
								componentType = "UAVFeedDisplayComponent";
							};
							class SensorDisplay
							{
								componentType = "SensorsDisplayComponent";
								range[] = {4000,2000,16000,8000};
								resource = "RscCustomInfoSensors";
							};
						};
					};
					class VehicleSystemsDisplayManagerComponentRight: DefaultVehicleSystemsDisplayManagerRight
					{
						defaultDisplay = "SensorDisplay";
						class Components
						{
							class EmptyDisplay
							{
								componentType = "EmptyDisplayComponent";
							};
							class MinimapDisplay
							{
								componentType = "MinimapDisplayComponent";
								resource = "RscCustomInfoMiniMap";
							};
							class CrewDisplay
							{
								componentType = "CrewDisplayComponent";
								resource = "RscCustomInfoCrew";
							};
							class UAVDisplay
							{
								componentType = "UAVFeedDisplayComponent";
							};
							class SensorDisplay
							{
								componentType = "SensorsDisplayComponent";
								range[] = {4000,2000,16000,8000};
								resource = "RscCustomInfoSensors";
							};
						};
					};
				};
			};
			class GunnerTurret_02: GunnerTurret_01
			{
				animationSourceBody = "Gunner02_rotH_source";
				animationSourceGun = "Gunner02_rotV_source";
				body = "Cannon_turret_rot";
				gun = "Cannon_rot";
				gunBeg = "Cannon_barrel_end";
				gunEnd = "Cannon_barrel_beg";
				gunnerName = "$STR_A3_RIGHT_GUNNER";
				gunnerAction = "gunner_02_VTOL_01_armed";
				gunnerInAction = "gunner_02_VTOL_01_armed";
				memoryPointGun[] = {};
				memoryPointGunBone[] = {};
				memoryPointGunnerOptics = "Cannon_pip_pos";
				memoryPointsGetInGunner = "GetIn_gunner_right_pos";
				memoryPointsGetInGunnerDir = "GetIn_gunner_right_dir";
				missileBeg = "Howitzer_barrel_end";
				missileEnd = "Howitzer_barrel_beg";
				particlesDir = "Cannon_barrel_end";
				particlesPos = "Cannon_barrel_beg";
				primaryGunner = 0;
				proxyIndex = 3;
				selectionFireAnim = "";
				showAllTargets = 4;
				turretCanSee = 31;
			};
		};
	};
};

class CfgInventoryGlobalVariable {
	maxSoldierLoad = 9999000;
};

#include "Support\functions\comm_menu.h"
#include "GOM\dialogs\GOM_dialog_parents.hpp"
#include "Support\dialogs\defines.hpp"
#include "GOM\dialogs\GOM_dialog_controls.hpp"
#include "Loiter\dialogs\dialog.hpp"
#include "Weaponry\dialogs\dialog.hpp"
#include "Main\dialogs\dialog.hpp"
#include "Debug\dialogs\dialog.hpp"
#include "Support\dialogs\Spawnveh.hpp"
#include "Support\dialogs\objlist.hpp"

#include "R3F_LOG\desc_include.h"
