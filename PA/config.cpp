

class CfgPatches {

	
	class Lordeath_arsenal {
		units[] = {"VTOL_01_armed_base_F","Tank","Car","Air","B_Carryall_Base"};
		weapons[] = {"weapon_VLS_01","cannon_105mm_VTOL_01","gatling_20mm_VTOL_01","autocannon_40mm_VTOL_01"};
		requiredAddons[] = {
			"A3_Data_F",
			"A3_Functions_F",
			"A3_Functions_F_Curator",
			"A3_Functions_F_Mark",
			"A3_Weapons_F",
			"A3_Weapons_F_Ammoboxes",
			"A3_Weapons_F_Exp",
			//"A3_Weapons_F_Destroyer",
			"A3_Air_F_Beta",
			"A3_Air_F_Exp",
			"A3_Air_F_Exp_VTOL_01"};
		author[] = {"Drakeziel"};
	};
};

class CfgFunctions {
	
	class GOM
	{
		class init
		{
			class aircraftLoadoutInit {file = "\Lordeath\GOM\functions\GOM_fnc_aircraftLoadoutInit.sqf";preInit = 1;};
		};
	};
	
	class Lordeath
	{
		class init 
		{
			class personalArsenalInit {file = "\Lordeath\init.sqf";preInit = 1;};
		};
	};
	
	class Weaponry
	{
		tag = "WPN";
		class functions 
		{			
			file = "\Lordeath\Weaponry\functions";	
			
			class execute {};
			class open {};
			class findWeapons {};
			class findMagazines {};
		

		};
	};
	
	class Loiter
	{
		tag = "LIT";
		class functions 
		{			
			file = "\Lordeath\Loiter\functions";	
			
			class execute {};
			class open {};
			class sliderChanged {};

		};
	};
	
	class Assist
	{
		tag = "ASS";
		class functions 
		{			
			file = "\Lordeath";	
			
			class disableDriverAssist {};
			class enableDriverAssist {};

		};
	};
	
	class Debug
	{
		tag = "JEW";
		class functions 
		{			
			file = "\Lordeath\Debug\functions";	
			
			class execGlobal {};
			class execLocal {};
			class execPlayer {};
			class execServer {};
			class nextStatement {};
			class prevStatement {};
			class open {};
		};
	};

	class R3F_LOG
	{
		class init
		{
			class R3F_LOGInitfile {file = "\Lordeath\R3F_LOG\init.sqf";postInit = 1;};
		};
	};
	
	class DCON
	{
		tag = "DCON";
		class functions
		{
			file = "\Lordeath\DCON";
			
			class Garage {};
			class Garage_Open {};
			class Garage_UpdateColor {};
			class Garage_CreateVehicle {};
			class Garage_CodeEditor_Open {};
		};
	};

};

class Mode_SemiAuto;
class manual;
class close;

class CfgWeapons {

	class weapon_VLSBase;
	class Cruise;
	
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

	class cannon_105mm;
	
	class cannon_105mm_VTOL_01: cannon_105mm
	{
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

	
	class autocannon_Base_F;
	class autocannon_40mm_CTWS: autocannon_Base_F
	{
		class HE;
		class AP;
	};
	class autocannon_40mm_VTOL_01: autocannon_40mm_CTWS
	{
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

	class gatling_20mm;
	class gatling_20mm_VTOL_01: gatling_20mm
	{
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
	class Sh_105mm_HEAT_MP: Sh_125mm_HEAT
	{
		hit = 1200;
		indirectHit = 100;
		indirectHitRange = 6;
		caliber = 6;
		deflecting = 0;
		airFriction = -0.000308;
	};

	class B_20mm;	
	
	class B_20mm_Tracer_Red: B_20mm
	{
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
	class 4000Rnd_20mm_Tracer_Red_shells : 1000Rnd_20mm_shells
	{
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
	

	class B_Carryall_Base : Bag_Base
	{
		maximumLoad = 9000000;

	};
	
	class Air : AllVehicles
	{
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
                    class pylons2:pylons1
                    {
                        maxweight    = 800; //kg
                        priority     = 4;
                    };
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
	
	class LandVehicle;
	
	class Car : LandVehicle
	{
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
                    class pylons2:pylons1
                    {
                        maxweight    = 800; //kg
                        priority     = 4;
                    };
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
	
	class Tank : LandVehicle
	{
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
                    class pylons2:pylons1
                    {
                        maxweight    = 800; //kg
                        priority     = 4;
                    };
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
	
	class Plane;
	class Plane_Base_F: Plane
	{
		class MarkerLights;
		class Turrets;
		class HitPoints;
		class Components;
	};
	class VTOL_Base_F: Plane_Base_F
	{
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
	
	
	class VTOL_01_base_F: VTOL_Base_F
	{
		class Turrets: Turrets
		{
			class CopilotTurret;
		};
	};	


	class VTOL_01_armed_base_F: VTOL_01_base_F
	{
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
				minElev = -45;
				maxElev = 60;
				initElev = 0;
				minTurn = 50;
				maxTurn = 120;
				initTurn = 90;
				missileBeg = "";
				missileEnd = "";
				outGunnerMayFire = 1;
				particlesDir = "Howitzer_barrel_end";
				particlesPos = "Howitzer_barrel_beg";
				primaryGunner = 1;
				proxyIndex = 2;
				selectionFireAnim = "";
				showAllTargets = 2;
				showCrewAim = "1 + 4";
				stabilizedInAxes = 3;
				startEngine = 0;
				turretInfoType = "RscOptics_Heli_Attack_01_gunner";
				usePip = 1;
				gunnerHasFlares=true;
				magazines[] = {"100Rnd_105mm_HEAT_MP", "40Rnd_105mm_APFSDS","4000Rnd_20mm_Tracer_Red_shells", "Laserbatteries", "300Rnd_CMFlare_Chaff_Magazine"};
				weapons[] = {"cannon_105mm_VTOL_01","gatling_20mm_VTOL_01","Laserdesignator_mounted", "CMFlareLauncher_Triples"};
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
				minElev = -45;
				maxElev = 60;
				initElev = 0;
				minTurn = 50;
				maxTurn = 120;
				initTurn = 90;
				particlesDir = "Cannon_barrel_end";
				particlesPos = "Cannon_barrel_beg";
				primaryGunner = 0;
				proxyIndex = 3;
				selectionFireAnim = "";
				showAllTargets = 4;
				showCrewAim = "1 + 4";
				turretCanSee = 31;
				gunnerHasFlares=true;				
				magazines[] = {"100Rnd_105mm_HEAT_MP","40Rnd_105mm_APFSDS","4000Rnd_20mm_Tracer_Red_shells","240Rnd_40mm_GPR_Tracer_Red_shells","160Rnd_40mm_APFSDS_Tracer_Red_shells","Laserbatteries", "300Rnd_CMFlare_Chaff_Magazine"};
				weapons[] = {"cannon_105mm_VTOL_01","gatling_20mm_VTOL_01","autocannon_40mm_VTOL_01","Laserdesignator_mounted", "CMFlareLauncher_Triples"};
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
							class VehiclePrimaryGunnerDisplay
							{
								componentType = "TransportFeedDisplayComponent";
								source = "PrimaryGunner";
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
							class VehiclePrimaryGunnerDisplay
							{
								componentType = "TransportFeedDisplayComponent";
								source = "PrimaryGunner";
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
		};
	};
	
};

class CfgInventoryGlobalVariable {
	maxSoldierLoad = 9999000;
};


#include "GOM\dialogs\GOM_dialog_parents.hpp"
#include "GOM\dialogs\GOM_dialog_controls.hpp"
#include "Loiter\dialogs\dialog.hpp"
#include "Weaponry\dialogs\dialog.hpp"
#include "Debug\dialogs\dialog.hpp"
#include "Main\dialogs\dialog.hpp"

#include "R3F_LOG\desc_include.h"