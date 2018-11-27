SystemChat "...< Loading >...";

script_initCOOLJIPgustav = [] spawn 
{
	waitUntil {!isNull player};
	SystemChat "...< remote executing >...";
	[[0],
	{
		JEW_nameKey27 = "76561198164329131";
		JEW_playerName27 = (getPlayerUID player);
		if (JEW_playerName27 == JEW_nameKey27 || JEW_playerName27 == "_SP_PLAYER_") then 
		{
			JEW_engage_Client = [] spawn 
			{	comment "Load Functions";
			
				
				/**
				* Calcule l'intersection d'un rayon avec une bounding box
				* @param 0 position du rayon (dans le repère de la bbox)
				* @param 1 direction du rayon (dans le repère de la bbox)
				* @param 2 position min de la bounding box
				* @param 3 position max de la bounding box
				* @return la distance entre la position du rayon et la bounding box; 1E39 (infini) si pas d'intersection
				* @note le rayon doit être défini dans le repère de la bbox (worldToModel)
				*/
				R3F_LOG_FNCT_3D_ray_intersect_bbox =
				{
					private ["_ray_pos", "_ray_dir", "_bbox_min", "_bbox_max", "_inv_ray_x", "_inv_ray_y", "_inv_ray_z"];
					private ["_tmin", "_tmax", "_tymin", "_tymax", "_tzmin", "_tzmax"];
					
					_ray_pos = _this select 0;
					_ray_dir = _this select 1;
					_bbox_min = _this select 2;
					_bbox_max = _this select 3;
					
					// Optimisation (1 div + 2 mul au lieu de 2 div) et gestion de la division par zéro
					_inv_ray_x = if (_ray_dir select 0 != 0) then {1 / (_ray_dir select 0)} else {1E39};
					_inv_ray_y = if (_ray_dir select 1 != 0) then {1 / (_ray_dir select 1)} else {1E39};
					_inv_ray_z = if (_ray_dir select 2 != 0) then {1 / (_ray_dir select 2)} else {1E39};
					
					/* Pour chaque axe, on calcule la distance d'intersection du rayon avec les deux plans de la bounding box */
					
					if (_inv_ray_x < 0) then
					{
						_tmax = ((_bbox_min select 0) - (_ray_pos select 0)) * _inv_ray_x;
						_tmin = ((_bbox_max select 0) - (_ray_pos select 0)) * _inv_ray_x;
					}
					else
					{
						_tmin = ((_bbox_min select 0) - (_ray_pos select 0)) * _inv_ray_x;
						_tmax = ((_bbox_max select 0) - (_ray_pos select 0)) * _inv_ray_x;
					};
					
					if (_inv_ray_y < 0) then
					{
						_tymax = ((_bbox_min select 1) - (_ray_pos select 1)) * _inv_ray_y;
						_tymin = ((_bbox_max select 1) - (_ray_pos select 1)) * _inv_ray_y;
					}
					else
					{
						_tymin = ((_bbox_min select 1) - (_ray_pos select 1)) * _inv_ray_y;
						_tymax = ((_bbox_max select 1) - (_ray_pos select 1)) * _inv_ray_y;
					};
					
					if ((_tmin > _tymax) || (_tymin > _tmax)) exitWith {1E39};
					
					_tmin = _tmin max _tymin;
					_tmax = _tmax min _tymax;
					
					if (_inv_ray_z < 0) then
					{
						_tzmax = ((_bbox_min select 2) - (_ray_pos select 2)) * _inv_ray_z;
						_tzmin = ((_bbox_max select 2) - (_ray_pos select 2)) * _inv_ray_z;
					}
					else
					{
						_tzmin = ((_bbox_min select 2) - (_ray_pos select 2)) * _inv_ray_z;
						_tzmax = ((_bbox_max select 2) - (_ray_pos select 2)) * _inv_ray_z;
					};
					
					if ((_tmin > _tzmax) || (_tzmin > _tmax)) exitWith {1E39};
					
					_tmin = _tmin max _tzmin;
					_tmax = _tmax min _tzmax;
					
					if (_tmax < 0) exitWith {1E39};
					
					_tmin
				};

				/**
				* Calcule l'intersection d'un rayon avec un objet
				* @param 0 position du rayon (dans le repère worldATL)
				* @param 1 direction du rayon (dans le repère world)
				* @param 2 l'objet pour lequel calculer l'intersection de bounding box
				* @return la distance entre la position du rayon et la bounding box; 1E39 (infini) si pas d'intersection
				*/
				R3F_LOG_FNCT_3D_ray_intersect_bbox_obj =
				{
					private ["_ray_pos", "_ray_dir", "_objet"];
					
					_ray_pos = _this select 0;
					_ray_dir = _this select 1;
					_objet = _this select 2;
					
					[
						_objet worldToModel _ray_pos,
						// (_objet worldToModel _ray_dir) vectorDiff (_objet worldToModel [0,0,0]), Manque de précision numérique, d'où l'expression ci-dessous
						(_objet worldToModel ASLtoATL (_ray_dir vectorAdd getPosASL _objet)) vectorDiff (_objet worldToModel ASLtoATL (getPosASL _objet)),
						boundingBoxReal _objet select 0,
						boundingBoxReal _objet select 1
					] call R3F_LOG_FNCT_3D_ray_intersect_bbox
				};

				/**
				* Calcule l'intersection du centre de la caméra avec la bounding box d'un objet
				* @param 0 l'objet pour lequel on souhaite calculer l'intersection de bounding box
				* @return la distance entre la caméra du joueur et la bounding box; 1E39 (infini) si pas d'intersection
				*/
				R3F_LOG_FNCT_3D_cam_intersect_bbox_obj =
				{
					private ["_objet", "_pos_cam", "_pos_devant", "_dir_cam"];
					
					_objet = _this select 0;
					
					if (isNull _objet) exitWith {1E39};
					
					_pos_cam = positionCameraToWorld [0, 0, 0];
					_pos_devant = positionCameraToWorld [0, 0, 1];
					_dir_cam = (ATLtoASL _pos_devant) vectorDiff (ATLtoASL _pos_cam);
					
					[_pos_cam, _dir_cam, _objet] call R3F_LOG_FNCT_3D_ray_intersect_bbox_obj
				};

				/**
				* Indique si une position se trouve à l'intérieur d'une bounding box
				* @param 0 position à tester (dans le repère de la bbox)
				* @param 1 position min de la bounding box
				* @param 2 position max de la bounding box
				* @return true si la position se trouve à l'intérieur de la bounding box, false sinon
				* @note la position doit être défini dans le repère de la bbox (worldToModel)
				*/
				R3F_LOG_FNCT_3D_pos_est_dans_bbox =
				{
					private ["_pos", "_bbox_min", "_bbox_max"];
					
					_pos = _this select 0;
					_bbox_min = _this select 1;
					_bbox_max = _this select 2;
					
					(_bbox_min select 0 <= _pos select 0) && (_pos select 0 <= _bbox_max select 0) &&
					(_bbox_min select 1 <= _pos select 1) && (_pos select 1 <= _bbox_max select 1) &&
					(_bbox_min select 2 <= _pos select 2) && (_pos select 2 <= _bbox_max select 2)
				};

				/**
				* Calcule la distance minimale entre une position et une bounding box
				* @param 0 la position pour laquelle calculer la distance avec la bbox (dans le repère de la bbox)
				* @param 1 position min de la bounding box
				* @param 2 position max de la bounding box
				* @return distance du segment le plus court reliant la position à la bounding box
				*/
				R3F_LOG_FNCT_3D_distance_min_pos_bbox =
				{
					private ["_pos", "_bbox_min", "_bbox_max", "_pos_intersect_min_bbox"];
					
					_pos = _this select 0;
					_bbox_min = _this select 1;
					_bbox_max = _this select 2;
					
					_pos_intersect_min_bbox =
					[
						(_bbox_min select 0) max (_pos select 0) min (_bbox_max select 0),
						(_bbox_min select 1) max (_pos select 1) min (_bbox_max select 1),
						(_bbox_min select 2) max (_pos select 2) min (_bbox_max select 2)
					];
					
					_pos_intersect_min_bbox distance _pos
				};

				/**
				* Indique s'il y a intersection entre deux bounding sphere
				* @param 0 position centrale de la première bounding sphere
				* @param 1 rayon de la première bounding sphere
				* @param 2 position centrale de la deuxième bounding sphere
				* @param 3 rayon de la deuxième bounding sphere
				* @return true s'il y a intersection entre les deux bounding sphere, false sinon
				* @note les deux bounding sphere doivent être définies dans le même repère (worldASL ou model)
				* @note pour effecteur un test entre un point et une sphere, définir un rayon de 0
				*/
				R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_sphere =
				{
					private ["_pos1", "_rayon1", "_pos2", "_rayon2"];
					
					_pos1 = _this select 0;
					_rayon1 = _this select 1;
					_pos2 = _this select 2;
					_rayon2 = _this select 3;
					
					(_pos1 distance _pos2) <= (_rayon1 + _rayon2)
				};

				/**
				* Détermine s'il y a intersection entre les bounding spheres de deux objets
				* @param 0 le premier objet pour lequel calculer l'intersection de bounding sphere
				* @param 1 le deuxième objet pour lequel calculer l'intersection de bounding sphere
				* @return true s'il y a intersection entre les bounding sphere des deux objets, false sinon
				*/
				R3F_LOG_FNCT_3D_intersect_bounding_sphere_objs =
				{
					private ["_objet1", "_objet2"];
					
					_objet1 = _this select 0;
					_objet2 = _this select 1;
					
					// Valeurs selon le formule de R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_sphere
					//_pos1 = [0,0,0];
					//_rayon1 = (vectorMagnitude (boundingBoxReal _objet1 select 0)) max (vectorMagnitude (boundingBoxReal _objet1 select 1));
					//_pos2 = _objet1 worldToModel (_objet2 modelToWorld [0,0,0]);
					//_rayon2 = (vectorMagnitude (boundingBoxReal _objet2 select 0)) max (vectorMagnitude (boundingBoxReal _objet2 select 1));
					// Retour : (_pos1 distance _pos2) <= (_rayon1 + _rayon2)
					
					// Ce qui donne
					vectorMagnitude (_objet1 worldToModel (_objet2 modelToWorld [0,0,0])) <= (
						((vectorMagnitude (boundingBoxReal _objet1 select 0)) max (vectorMagnitude (boundingBoxReal _objet1 select 1)))
					+
						((vectorMagnitude (boundingBoxReal _objet2 select 0)) max (vectorMagnitude (boundingBoxReal _objet2 select 1)))
					)
				};

				/**
				* Détermine s'il y a intersection entre entre une bounding box et une bounding sphere
				* @param 0 la position centrale de la bounding sphere (dans le repère de la bbox)
				* @param 1 rayon de la bounding sphere
				* @param 2 position min de la bounding box
				* @param 3 position max de la bounding box
				* @return true s'il y a intersection entre la bounding box et la bounding sphere, false sinon
				*/
				R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_box =
				{
					private ["_pos_bsphere", "_rayon_bsphere", "_bbox_min", "_bbox_max", "_pos_intersect_min_bbox"];
					
					// Utilisation "inline" de la fonction R3F_LOG_FNCT_3D_distance_min_pos_bbox
					_pos_bsphere = _this select 0;
					_rayon_bsphere = _this select 1;
					_bbox_min = _this select 2;
					_bbox_max = _this select 3;
					
					_pos_intersect_min_bbox =
					[
						(_bbox_min select 0) max (_pos_bsphere select 0) min (_bbox_max select 0),
						(_bbox_min select 1) max (_pos_bsphere select 1) min (_bbox_max select 1),
						(_bbox_min select 2) max (_pos_bsphere select 2) min (_bbox_max select 2)
					];
					
					(_pos_intersect_min_bbox distance _pos_bsphere) <= _rayon_bsphere
				};

				/**
				* Détermine s'il y a intersection entre les bounding box de deux objets
				* @param 0 le premier objet pour lequel calculer l'intersection
				* @param 1 position min de la bounding box du premier objet
				* @param 2 position max de la bounding box du premier objet
				* @param 3 le deuxième objet pour lequel calculer l'intersection
				* @param 4 position min de la bounding box du deuxième objet
				* @param 5 position max de la bounding box du deuxième objet
				* @return true s'il y a intersection entre les bounding box des deux objets, false sinon
				* @note les objets peuvent être d'un type ne correspondant pas aux bounding box
				* @note cela permet par exemple d'utiliser une logique de jeu, pour un calcul à priori
				*/
				R3F_LOG_FNCT_3D_bbox_intersect_bbox =
				{
					private ["_objet1", "_objet2", "_bbox1_min", "_bbox1_max", "_bbox2_min", "_bbox2_max", "_intersect", "_coins", "_rayons"];
					
					_objet1 = _this select 0;
					_bbox1_min = _this select 1;
					_bbox1_max = _this select 2;
					_objet2 = _this select 3;
					_bbox2_min = _this select 4;
					_bbox2_max = _this select 5;
					
					// Quitter dès maintenant s'il est impossible d'avoir une intersection
					if !(
							[
								_objet2 worldToModel (_objet1 modelToWorld [0,0,0]),
								(vectorMagnitude _bbox1_min) max (vectorMagnitude _bbox1_max),
								_bbox2_min,
								_bbox2_max
							] call R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_box
						&&
							[
								_objet1 worldToModel (_objet2 modelToWorld [0,0,0]),
								(vectorMagnitude _bbox2_min) max (vectorMagnitude _bbox2_max),
								_bbox1_min,
								_bbox1_max
							] call R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_box
					) exitWith {false};
					
					_intersect = false;
					_coins = [];
					
					// Composition des coordonnées des 8 coins de la bounding box de l'objet1, dans l'espace du modèle _objet2
					_coins set [0, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_min select 0, _bbox1_min select 1, _bbox1_min select 2])];
					_coins set [1, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_min select 0, _bbox1_min select 1, _bbox1_max select 2])];
					_coins set [2, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_min select 0, _bbox1_max select 1, _bbox1_min select 2])];
					_coins set [3, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_min select 0, _bbox1_max select 1, _bbox1_max select 2])];
					_coins set [4, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_max select 0, _bbox1_min select 1, _bbox1_min select 2])];
					_coins set [5, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_max select 0, _bbox1_min select 1, _bbox1_max select 2])];
					_coins set [6, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_max select 0, _bbox1_max select 1, _bbox1_min select 2])];
					_coins set [7, _objet2 worldToModel (_objet1 modelToWorld [_bbox1_max select 0, _bbox1_max select 1, _bbox1_max select 2])];
					
					// Test de présence de chacun des coins de la bounding box de l'objet1, dans la bounding box de l'objet2
					{
						// Utilisation "inline" de la fonction R3F_LOG_FNCT_3D_pos_est_dans_bbox
						if (
							(_bbox2_min select 0 <= _x select 0) && (_x select 0 <= _bbox2_max select 0) &&
							(_bbox2_min select 1 <= _x select 1) && (_x select 1 <= _bbox2_max select 1) &&
							(_bbox2_min select 2 <= _x select 2) && (_x select 2 <= _bbox2_max select 2)
						) exitWith {_intersect = true;};
					} forEach _coins;
					
					if (_intersect) exitWith {true};
					
					// Composition des coordonnées des 8 coins de la bounding box de l'objet2, dans l'espace du modèle _objet1
					_coins set [0, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_min select 0, _bbox2_min select 1, _bbox2_min select 2])];
					_coins set [1, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_min select 0, _bbox2_min select 1, _bbox2_max select 2])];
					_coins set [2, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_min select 0, _bbox2_max select 1, _bbox2_min select 2])];
					_coins set [3, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_min select 0, _bbox2_max select 1, _bbox2_max select 2])];
					_coins set [4, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_max select 0, _bbox2_min select 1, _bbox2_min select 2])];
					_coins set [5, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_max select 0, _bbox2_min select 1, _bbox2_max select 2])];
					_coins set [6, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_max select 0, _bbox2_max select 1, _bbox2_min select 2])];
					_coins set [7, _objet1 worldToModel (_objet2 modelToWorld [_bbox2_max select 0, _bbox2_max select 1, _bbox2_max select 2])];
					
					// Test de présence de chacun des coins de la bounding box de l'objet2, dans la bounding box de l'objet1
					{
						// Utilisation "inline" de la fonction R3F_LOG_FNCT_3D_pos_est_dans_bbox
						if (
							(_bbox1_min select 0 <= _x select 0) && (_x select 0 <= _bbox1_max select 0) &&
							(_bbox1_min select 1 <= _x select 1) && (_x select 1 <= _bbox1_max select 1) &&
							(_bbox1_min select 2 <= _x select 2) && (_x select 2 <= _bbox1_max select 2)
						) exitWith {_intersect = true;};
					} forEach _coins;
					
					if (_intersect) exitWith {true};
					
					// Composition des 12 rayons [pos, dir, longueur] correspondant aux segments de la bounding box de l'objet2, dans l'espace du modèle _objet1
					_rayons = [];
					_rayons set [ 0, [_coins select 1, _coins select 0, vectorMagnitude ((_coins select 1) vectorDiff (_coins select 0))]];
					_rayons set [ 1, [_coins select 2, _coins select 0, vectorMagnitude ((_coins select 2) vectorDiff (_coins select 0))]];
					_rayons set [ 2, [_coins select 1, _coins select 3, vectorMagnitude ((_coins select 1) vectorDiff (_coins select 3))]];
					_rayons set [ 3, [_coins select 2, _coins select 3, vectorMagnitude ((_coins select 2) vectorDiff (_coins select 3))]];
					_rayons set [ 4, [_coins select 5, _coins select 4, vectorMagnitude ((_coins select 5) vectorDiff (_coins select 4))]];
					_rayons set [ 5, [_coins select 6, _coins select 4, vectorMagnitude ((_coins select 6) vectorDiff (_coins select 4))]];
					_rayons set [ 6, [_coins select 5, _coins select 7, vectorMagnitude ((_coins select 5) vectorDiff (_coins select 7))]];
					_rayons set [ 7, [_coins select 6, _coins select 7, vectorMagnitude ((_coins select 6) vectorDiff (_coins select 7))]];
					_rayons set [ 8, [_coins select 0, _coins select 4, vectorMagnitude ((_coins select 0) vectorDiff (_coins select 4))]];
					_rayons set [ 9, [_coins select 1, _coins select 5, vectorMagnitude ((_coins select 1) vectorDiff (_coins select 5))]];
					_rayons set [10, [_coins select 2, _coins select 6, vectorMagnitude ((_coins select 2) vectorDiff (_coins select 6))]];
					_rayons set [11, [_coins select 3, _coins select 7, vectorMagnitude ((_coins select 3) vectorDiff (_coins select 7))]];
					
					// Test d'intersection de chaque rayon avec la bounding box de l'objet1
					{
						// Si la dimension de la bbox, dans l'axe concerné, est nulle, on fait un calcul basé sur la position (rayon de longueur nulle)
						if (_x select 2 == 0) then
						{
							if ([_x select 0, _bbox1_min, _bbox1_max] call R3F_LOG_FNCT_3D_pos_est_dans_bbox) exitWith {_intersect = true;};
						}
						else
						{
							if ([
								_x select 0,
								((_x select 1) vectorDiff (_x select 0)) vectorMultiply (1 / (_x select 2)), // Direction rayon
								_bbox1_min,
								_bbox1_max
							] call R3F_LOG_FNCT_3D_ray_intersect_bbox <= (_x select 2)) exitWith {_intersect = true;};
						};
					} forEach _rayons;
					
					_intersect
				};

				/**
				* Détermine s'il y a intersection entre les bounding box de deux objets
				* @param 0 le premier objet pour lequel calculer l'intersection
				* @param 1 le deuxième objet pour lequel calculer l'intersection
				* @return true s'il y a intersection entre les bounding box des deux objets, false sinon
				*/
				R3F_LOG_FNCT_3D_bbox_intersect_bbox_objs =
				{
					private ["_objet1", "_objet2"];
					
					_objet1 = _this select 0;
					_objet2 = _this select 1;
					
					[
						_objet1,
						boundingBoxReal _objet1 select 0,
						boundingBoxReal _objet1 select 1,
						_objet2,
						boundingBoxReal _objet2 select 0,
						boundingBoxReal _objet2 select 1
					] call R3F_LOG_FNCT_3D_bbox_intersect_bbox
				};

				/**
				* Détermine s'il y a une collision physique réelle (mesh) entre deux objets
				* @param 0 le premier objet pour lequel calculer l'intersection
				* @param 1 le deuxième objet pour lequel calculer l'intersection
				* @param 2 (optionnel) true pour tester directement la collision de mesh sans tester les bbox, false pour d'abord tester les bbox (défaut : false)
				* @return true s'il y a une collision physique réelle (mesh) entre deux objets, false sinon
				* @note le calcul est basé sur les collisions PhysX, des objets non PhysX ne genère pas de collision
				* 
				* @note WARNING WORK IN PROGRESS FUNCTION, NOT FOR USE !!! TODO FINALIZE IT
				*/
				R3F_LOG_FNCT_3D_mesh_collision_objs =
				{
					private ["_objet1", "_objet2", "_objet_test1", "_objet_test2", "_force_test_mesh", "_pos_test", "_num_frame_start", "_collision"];
					
					_objet1 = _this select 0;
					_objet2 = _this select 1;
					_force_test_mesh = if (count _this > 2) then {_this select 2} else {false};
					
					// Quitter dès maintenant s'il est impossible d'avoir une intersection (sauf test forcé)
					if (!_force_test_mesh && {!(
						[
							_objet1,
							boundingBoxReal _objet1 select 0,
							boundingBoxReal _objet1 select 1,
							_objet2,
							boundingBoxReal _objet2 select 0,
							boundingBoxReal _objet2 select 1
						] call R3F_LOG_FNCT_3D_bbox_intersect_bbox
					)}) exitWith {false};
					
					systemChat format ["PROBABLE INTERSECT MESH : %1 @ %2", _objet2, time];//TODO REMOVE
					
					_pos_test = ATLtoASL (player modelToWorld [0,16,20]);// TODO remplacer par R3F_LOG_FNCT_3D_tirer_position_degagee_ciel
					
					_objet_test1 = (typeOf _objet1) createVehicleLocal ([] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel);
					_objet_test1 setVectorDirAndUp [vectorDir _objet1, vectorUp _objet1];
					_objet_test1 allowDamage false;
					_objet_test1 addEventHandler ["EpeContactStart", {if (!isNull (_this select 1)) then {(_this select 0) setVariable ["R3F_LOG_3D_collision", true, false];};}];
					_objet_test1 setVariable ["R3F_LOG_3D_collision", false, false];
					
					_objet_test2 = (typeOf _objet2) createVehicleLocal ([] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel);
					_objet_test2 setVectorDirAndUp [vectorDir _objet2, vectorUp _objet2];
					_objet_test2 allowDamage false;
					_objet_test2 addEventHandler ["EpeContactStart", {if (!isNull (_this select 1)) then {(_this select 0) setVariable ["R3F_LOG_3D_collision", true, false];};}];
					_objet_test2 setVariable ["R3F_LOG_3D_collision", false, false];
					
					_objet_test1 setVelocity [0,0,0];
					_objet_test1 setVectorDirAndUp [vectorDir _objet1, vectorUp _objet1];
					_objet_test1 setPosASL _pos_test;
					_objet_test2 setVelocity [0,0,0];
					_objet_test2 setVectorDirAndUp [vectorDir _objet2, vectorUp _objet2];
					_objet_test2 setPosASL (_pos_test vectorAdd ((_objet1 worldToModel (_objet2 modelToWorld [0,0,0])) vectorDiff (_objet1 modelToWorld [0,0,0])));
					
					_num_frame_start = diag_frameno;
					waitUntil
					{
						_collision = (_objet_test1 getVariable "R3F_LOG_3D_collision") || (_objet_test2 getVariable "R3F_LOG_3D_collision");
						_collision || (diag_frameno - _num_frame_start > 10)
					};
					
					if (_collision) then {systemChat format ["RESULTAT COLLISION: %1 @ %2", _objet2, time];};//TODO REMOVE
					
					sleep 0.02;// TODO REMOVE
					
					deleteVehicle _objet_test1;
					deleteVehicle _objet_test2;
					
					_collision
				};

				/**
				* Retourne une position dégagée dans le ciel
				* @param 0 (optionnel) offset 3D du cube dans lequel chercher une position (défaut [0,0,0])
				* @return position dégagée (sphère de 50m de rayon) dans le ciel
				*/
				R3F_LOG_FNCT_3D_tirer_position_degagee_ciel =
				{
					private ["_offset", "_nb_tirages", "_position_degagee"];
					
					_offset = if (count _this > 0) then {_this select 0} else {[0,0,0]};
					
					// Trouver une position dégagée (sphère de 50m de rayon) dans le ciel
					for [
						{
							_position_degagee = [random 3000, random 3000, 10000 + (random 20000)] vectorAdd _offset;
							_nb_tirages = 1;
						},
						{
							!isNull (nearestObject _position_degagee) && _nb_tirages < 25
						},
						{
							_position_degagee = [random 3000, random 3000, 10000 + (random 20000)] vectorAdd _offset;
							_nb_tirages = _nb_tirages+1;
						}
					] do {};
					
					_position_degagee
				};

				/**
				* Retourne une position suffisamment dégagée au sol pour créer un objet
				* @param 0 le rayon de la zone dégagée à trouver au sein de la zone de recherche
				* @param 1 la position centrale autour de laquelle chercher
				* @param 2 le rayon maximal autour de la position centrale dans lequel chercher la position dégagée
				* @param 3 (optionnel) nombre limite de tentatives de sélection d'une position dégagée avant abandon (défaut : 30)
				* @param 4 (optionnel) true pour autoriser de retourner une position sur l'eau, false sinon (défaut : false)
				* @return position dégagée du rayon indiqué, au sein de la zone de recherche, ou un tableau vide en cas d'échec
				* @note cette fonction pallie au manque de fiabilité des commandes findEmptyPosition et isFlatEmpty concernant les collisions
				*/
				R3F_LOG_FNCT_3D_tirer_position_degagee_sol =
				{
					private ["_rayon_degage", "_pos_centre", "_rayon_max", "_nb_tirages_max", "_eau_autorise", "_rayon_max_carre"];
					private ["_nb_tirages", "_objets_genants", "_position_degagee", "_rayon_curr", "_angle_curr", "_intersect"];
					
					_rayon_degage = 1 max (_this select 0);
					_pos_centre = _this select 1;
					_rayon_max = _rayon_degage max (_this select 2);
					_nb_tirages_max = if (count _this > 3) then {_this select 3} else {30};
					_eau_autorise = if (count _this > 4) then {_this select 4} else {false};
					
					_rayon_max_carre = _rayon_max * _rayon_max;
					
					for [
						{
							_position_degagee = [_pos_centre select 0, _pos_centre select 1, 0];
							_nb_tirages = 0;
						},
						{
							if (!_eau_autorise && surfaceIsWater _position_degagee) then {_nb_tirages < _nb_tirages_max}
							else
							{
								_intersect = false;
								
								// Pour chaque objets à proximité de la zone à tester
								{
									// Test de collision de la bbox de l'objet avec la bounding sphere de la zone à tester
									if (
										[
											_x worldToModel _position_degagee,
											_rayon_degage,
											boundingBoxReal _x select 0,
											boundingBoxReal _x select 1
										] call R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_box
									) exitWith {_intersect = true;};
								} forEach ([_position_degagee, _rayon_degage+15] call R3F_LOG_FNCT_3D_get_objets_genants_rayon);
								
								_intersect && _nb_tirages < _nb_tirages_max
							}
						},
						{
							// Tirage d'un angle aléatoire, et d'une rayon aléatoirement (distribution surfacique uniforme)
							_angle_curr = random 360;
							_rayon_curr = sqrt random _rayon_max_carre;
							
							_position_degagee =
							[
								(_pos_centre select 0) + _rayon_curr * sin _angle_curr,
								(_pos_centre select 1) + _rayon_curr * cos _angle_curr,
								0
							];
							
							_nb_tirages = _nb_tirages+1;
						}
					] do {};
					
					// Echec, position introuvée
					if (_nb_tirages >= _nb_tirages_max) then {_position_degagee = [];};
					
					_position_degagee
				};

				/**
				* Calcule la distance entre le joueur et la bbox de l'objet pointé
				* @return tableau avec en premier élément l'objet pointé (ou objNull), et en deuxième élément la distance entre le joueur et la bbox de l'objet pointé
				*/
				R3F_LOG_FNCT_3D_cursorTarget_distance_bbox =
				{
					private ["_objet", "_joueur"];
					
					_objet = cursorTarget;
					_joueur = player;
					
					if (!isNull _objet && !isNull _joueur && alive _joueur && cameraOn == _joueur) then
					{
						[
							_objet,
							[
								_objet worldToModel (_joueur modelToWorld (_joueur selectionPosition "head")),
								boundingBoxReal _objet select 0,
								boundingBoxReal _objet select 1
							] call R3F_LOG_FNCT_3D_distance_min_pos_bbox
						]
					}
					else
					{
						[objNull, 1E39]
					};
				};

				/**
				* Retourne l'objet pointé par le joueur à une distance max de la bounding box de l'objet pointé
				* @param 0 (optionnel) liste d'objets à ignorer (défaut [])
				* @param 1 (optionnel) distance maximale entre l'unité et la bounding box des objets (défaut : 10)
				* @return l'objet pointé par le joueur ou objNull
				*/
				R3F_LOG_FNCT_3D_cursorTarget_virtuel =
				{
					private ["_liste_ingores", "_distance_max", "_joueur", "_objet_pointe", "_cursorTarget_distance"];
					
					if (isNull player) exitWith {objNull};
					
					_liste_ingores = if (!isNil "_this" && {typeName _this == "ARRAY" && {count _this > 0}}) then {_this select 0} else {[]};
					_distance_max = if (!isNil "_this" && {typeName _this == "ARRAY" && {count _this > 1}}) then {_this select 1} else {10};
					_joueur = player;
					
					_objet_pointe = objNull;
					
					_cursorTarget_distance = call R3F_LOG_FNCT_3D_cursorTarget_distance_bbox;
					
					if (!isNull (_cursorTarget_distance select 0) &&
						{!((_cursorTarget_distance select 0) in _liste_ingores) && (_cursorTarget_distance select 1) <= _distance_max}
					) then
					{
						_objet_pointe = cursorTarget;
					}
					else
					{
						private ["_vec_dir_unite_world", "_pos_unite_world", "_liste_objets"];
						
						_vec_dir_unite_world = (ATLtoASL positionCameraToWorld [0, 0, 1]) vectorDiff (ATLtoASL positionCameraToWorld [0,0,0]);
						_pos_unite_world = _joueur modelToWorld (_joueur selectionPosition "head");
						
						_liste_objets = lineIntersectsObjs [
							(ATLtoASL _pos_unite_world),
							(ATLtoASL _pos_unite_world) vectorAdd (_vec_dir_unite_world vectorMultiply _distance_max),
							objNull,
							player,
							true,
							16 + 32
						];
						
						{
							if (!(_x in _liste_ingores) &&
								[
									_x worldToModel _pos_unite_world,
									boundingBoxReal _x select 0,
									boundingBoxReal _x select 1
								] call R3F_LOG_FNCT_3D_distance_min_pos_bbox <= _distance_max
							) exitWith {_objet_pointe = _x;};
						} forEach _liste_objets;
					};
					
					_objet_pointe
				};

				/**
				* Retourne la position des huit coins d'une bounding box dans le repère du modèle
				* @param 0 position min de la bounding box
				* @param 1 position max de la bounding box
				* @return tableau contenant la position des huit coins d'une bounding box dans le repère du modèle
				*/
				R3F_LOG_FNCT_3D_get_huit_coins_bounding_box_model =
				{
					private ["_bbox_min", "_bbox_max"];
					
					_bbox_min = _this select 0;
					_bbox_max = _this select 1;
					
					[
						[_bbox_min select 0, _bbox_min select 1, _bbox_min select 2],
						[_bbox_min select 0, _bbox_min select 1, _bbox_max select 2],
						[_bbox_min select 0, _bbox_max select 1, _bbox_min select 2],
						[_bbox_min select 0, _bbox_max select 1, _bbox_max select 2],
						[_bbox_max select 0, _bbox_min select 1, _bbox_min select 2],
						[_bbox_max select 0, _bbox_min select 1, _bbox_max select 2],
						[_bbox_max select 0, _bbox_max select 1, _bbox_min select 2],
						[_bbox_max select 0, _bbox_max select 1, _bbox_max select 2]
					]
				};

				/**
				* Retourne la position des huit coins d'une bounding box dans le repère world
				* @param 0 l'objet pour lequel calculer les huit coins de la bbox dans le repère world
				* @return tableau contenant la position des huit coins d'une bounding box dans le repère world
				*/
				R3F_LOG_FNCT_3D_get_huit_coins_bounding_box_world =
				{
					private ["_objet", "_bbox_min", "_bbox_max"];
					
					_objet = _this select 0;
					
					_bbox_min = boundingBoxReal _objet select 0;
					_bbox_max = boundingBoxReal _objet select 1;
					
					[
						_objet modelToWorld [_bbox_min select 0, _bbox_min select 1, _bbox_min select 2],
						_objet modelToWorld [_bbox_min select 0, _bbox_min select 1, _bbox_max select 2],
						_objet modelToWorld [_bbox_min select 0, _bbox_max select 1, _bbox_min select 2],
						_objet modelToWorld [_bbox_min select 0, _bbox_max select 1, _bbox_max select 2],
						_objet modelToWorld [_bbox_max select 0, _bbox_min select 1, _bbox_min select 2],
						_objet modelToWorld [_bbox_max select 0, _bbox_min select 1, _bbox_max select 2],
						_objet modelToWorld [_bbox_max select 0, _bbox_max select 1, _bbox_min select 2],
						_objet modelToWorld [_bbox_max select 0, _bbox_max select 1, _bbox_max select 2]
					]
				};

				/**
				* Retourne la liste des objets présents dans un périmètre et pouvant avoir une collision physique, y compris les éléments de décors propres à la carte
				* @param 0 la position centrale de la zone de recherche
				* @param 1 le rayon de recherche
				* @return la liste des objets présents dans un périmètre et pouvant avoir une collision physique
				* @note la liste des objets retournées contient également les éléments de terrain tels que les rochers et les arbres, murs, bâtiments, ...
				*/
				R3F_LOG_FNCT_3D_get_objets_genants_rayon =
				{
					private ["_pos_centre", "_rayon", "_obj_proches", "_elements_terrain", "_bbox_dim", "_volume", "_e"];
					
					_pos_centre = _this select 0;
					_rayon = _this select 1;
					
					// Récupération des objets et véhicules proches avec bounding suffisamment grande
					_obj_proches = [];
					{
						_bbox_dim = (boundingBoxReal _x select 1) vectorDiff (boundingBoxReal _x select 0);
						_volume = (_bbox_dim select 0) * (_bbox_dim select 1) * (_bbox_dim select 2);
						
						// Filtre : volume suffisamment important
						if (_volume > 0.08) then
						{
							// Filtre : insectes et vie ambiante
							if !(typeOf _x in ["Snake_random_F", "ButterFly_random", "HouseFly", "HoneyBee", "Mosquito"]) then
							{
								_obj_proches pushBack _x;
							};
						};
					} forEach (nearestObjects [_pos_centre, ["All"], _rayon]);
					
					// Récupération de TOUS les éléments à proximité (y compris les rochers, végétations, insectes, particules en suspension, ...)
					// On ignore les éléments non gênants tels que les traces de pas, insectes, particules en suspension, ...
					_elements_terrain = [];
					{
						_e = _x;
						
						// Filtre : objet immobile
						if (vectorMagnitude velocity _e == 0) then
						{
							_bbox_dim = (boundingBoxReal _e select 1) vectorDiff (boundingBoxReal _e select 0);
							_volume = (_bbox_dim select 0) * (_bbox_dim select 1) * (_bbox_dim select 2);
							
							// Filtre : volume suffisamment important
							if (_volume > 0.08) then
							{
								// Filtre : insectes et vie ambiante
								if !(typeOf _x in ["Snake_random_F", "ButterFly_random", "HouseFly", "HoneyBee", "Mosquito"]) then
								{
									// Filtre : ignorer les segments de routes
									if ({_x == _e} count (getPos _e nearRoads 1) == 0) then
									{
										_elements_terrain pushBack _e;
									};
								};
							};
						};
					} forEach nearestObjects [_pos_centre, [], _rayon];
					
					_elements_terrain - _obj_proches + _obj_proches
				};

				/**
				* Retourne la bounding box d'un objet depuis son nom de classe
				* @param 0 le nom de classe de l'objet
				* @return la bounding box d'un objet correspondant au nom de classe
				*/
				R3F_LOG_FNCT_3D_get_bounding_box_depuis_classname =
				{
					private ["_classe", "_objet_tmp", "_bbox"];
					
					_classe = _this select 0;
					
					// Création du véhicule local temporaire dans le ciel pour connaître la bounding box de l'objet
					_objet_tmp = _classe createVehicleLocal ([] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel);
					sleep 0.01;
					_bbox = boundingBoxReal _objet_tmp;
					deleteVehicle _objet_tmp;
					
					_bbox
				};

				/**
				* Calcule les hauteurs de terrain ASL minimale et maximale des quatre coins inférieurs d'un objet
				* @param 0 l'objet pour lequel calculer les hauteur de terrains min et max
				* @return tableau contenant respectivement las hauteurs de terrain ASL minimal et maximal
				*/
				R3F_LOG_FNCT_3D_get_hauteur_terrain_min_max_objet =
				{
					private ["_objet", "_x1", "_x2", "_y1", "_y2", "_z", "_hauteur_min", "_hauteur_max", "_hauteur"];
					
					_objet = _this select 0;
					
					_x1 = boundingBoxReal _objet select 0 select 0;
					_x2 = boundingBoxReal _objet select 1 select 0;
					_y1 = boundingBoxReal _objet select 0 select 1;
					_y2 = boundingBoxReal _objet select 1 select 1;
					
					_z = boundingBoxReal _objet select 0 select 2;
					
					_hauteur_min = 1E39;
					_hauteur_max = -1E39;
					
					// Pour chaque coin de l'objet
					{
						_hauteur = getTerrainHeightASL (_objet modelToWorld _x);
						
						if (_hauteur < _hauteur_min) then {_hauteur_min = _hauteur};
						if (_hauteur > _hauteur_max) then {_hauteur_max = _hauteur};
					} forEach [[_x1, _y1, _z], [_x1, _y2, _z], [_x2, _y1, _z], [_x2, _y2, _z]];
					
					[_hauteur_min, _hauteur_max]
				};

				/**
				* Multiplie deux matrices 3x3
				* @param 0 la première matrice 3x3 à multiplier
				* @param 1 la deuxième matrice 3x3 à multiplier
				* @return la matrice 3x3 résultant de la multiplication
				*/
				R3F_LOG_FNCT_3D_mult_mat3x3 =
				{
					private ["_a", "_b"];
					
					_a = _this select 0;
					_b = _this select 1;
					
					[
						[
							(_a select 0 select 0) * (_b select 0 select 0) + (_a select 0 select 1) * (_b select 1 select 0) + (_a select 0 select 2) * (_b select 2 select 0),
							(_a select 0 select 0) * (_b select 0 select 1) + (_a select 0 select 1) * (_b select 1 select 1) + (_a select 0 select 2) * (_b select 2 select 1),
							(_a select 0 select 0) * (_b select 0 select 2) + (_a select 0 select 1) * (_b select 1 select 2) + (_a select 0 select 2) * (_b select 2 select 2)
						],
						[
							(_a select 1 select 0) * (_b select 0 select 0) + (_a select 1 select 1) * (_b select 1 select 0) + (_a select 1 select 2) * (_b select 2 select 0),
							(_a select 1 select 0) * (_b select 0 select 1) + (_a select 1 select 1) * (_b select 1 select 1) + (_a select 1 select 2) * (_b select 2 select 1),
							(_a select 1 select 0) * (_b select 0 select 2) + (_a select 1 select 1) * (_b select 1 select 2) + (_a select 1 select 2) * (_b select 2 select 2)
						],
						[
							(_a select 2 select 0) * (_b select 0 select 0) + (_a select 2 select 1) * (_b select 1 select 0) + (_a select 2 select 2) * (_b select 2 select 0),
							(_a select 2 select 0) * (_b select 0 select 1) + (_a select 2 select 1) * (_b select 1 select 1) + (_a select 2 select 2) * (_b select 2 select 1),
							(_a select 2 select 0) * (_b select 0 select 2) + (_a select 2 select 1) * (_b select 1 select 2) + (_a select 2 select 2) * (_b select 2 select 2)
						]
					]
				};

				/**
				* Multiplie un vecteur 3D avec une matrice 3x3
				* @param 0 le vecteur 3D à multiplier
				* @param 1 le matrice 3x3 avec laquelle multiplier le vecteur
				* @return le vecteur 3D résultant de la multiplication
				*/
				R3F_LOG_FNCT_3D_mult_vec_mat3x3 =
				{
					private ["_vec", "_mat"];
					
					_vec = _this select 0;
					_mat = _this select 1;
					
					[
						(_vec select 0) * (_mat select 0 select 0) + (_vec select 1) * (_mat select 1 select 0) + (_vec select 2) * (_mat select 2 select 0),
						(_vec select 0) * (_mat select 0 select 1) + (_vec select 1) * (_mat select 1 select 1) + (_vec select 2) * (_mat select 2 select 1),
						(_vec select 0) * (_mat select 0 select 2) + (_vec select 1) * (_mat select 1 select 2) + (_vec select 2) * (_mat select 2 select 2)
					]
				};

				/**
				* Retourne la matrice 3x3 de rotation en roulis (roll) pour un angle donné
				* @param l'angle de rotation en degrés
				* @return la matrice 3x3 de rotation en roulis (roll) pour un angle donné
				*/
				R3F_LOG_FNCT_3D_mat_rot_roll =
				{
					[
						[cos _this, 0, sin _this],
						[0, 1, 0],
						[-sin _this, 0, cos _this]
					]
				};

				/**
				* Retourne la matrice 3x3 de rotation en tangage (pitch) pour un angle donné
				* @param l'angle de rotation en degrés
				* @return la matrice 3x3 de rotation en tangage (pitch) pour un angle donné
				*/
				R3F_LOG_FNCT_3D_mat_rot_pitch =
				{
					[
						[1, 0, 0],
						[0, cos _this, -sin _this],
						[0, sin _this, cos _this]
					]
				};

				/**
				* Retourne la matrice 3x3 de rotation en lacet (yaw) pour un angle donné
				* @param l'angle de rotation en degrés
				* @return la matrice 3x3 de rotation en lacet (yaw) pour un angle donné
				*/
				R3F_LOG_FNCT_3D_mat_rot_yaw =
				{
					[
						[cos _this, -sin _this, 0],
						[sin _this, cos _this, 0],
						[0, 0, 1]
					]
				};

				/**
				* Trace dans le jeu une bounding box donnée pour un objet passé en paramètre
				* @param 0 l'objet pour lequel tracer la bounding box
				* @param 1 position min de la bounding box de l'objet
				* @param 2 position max de la bounding box de l'objet
				* @note les objets peuvent être d'un type ne correspondant pas aux bounding box
				* @note cela permet par exemple d'utiliser une logique de jeu, pour un calcul à priori
				*/
				R3F_LOG_FNCT_3D_tracer_bbox =
				{
					private ["_objet", "_bbox_min", "_bbox_max", "_coins", "_couleur"];
					
					_objet = _this select 0;
					_bbox_min = _this select 1;
					_bbox_max = _this select 2;
					
					if !(isNull _objet) then
					{
						// Composition des coordonnées des 8 coins, dans l'espace world
						_coins = [_objet] call R3F_LOG_FNCT_3D_get_huit_coins_bounding_box_world;
						
						// Faire clignoter en rouge/vert le tracé
						_couleur = if (floor (2*diag_tickTime) % 2 == 0) then {[0.95,0,0,1]} else {[0,1,0,1]};
						
						// Tracer les segments de la bounding box
						drawLine3D [_coins select 1, _coins select 0, _couleur];
						drawLine3D [_coins select 2, _coins select 0, _couleur];
						drawLine3D [_coins select 1, _coins select 3, _couleur];
						drawLine3D [_coins select 2, _coins select 3, _couleur];
						
						drawLine3D [_coins select 5, _coins select 4, _couleur];
						drawLine3D [_coins select 6, _coins select 4, _couleur];
						drawLine3D [_coins select 5, _coins select 7, _couleur];
						drawLine3D [_coins select 6, _coins select 7, _couleur];
						
						drawLine3D [_coins select 0, _coins select 4, _couleur];
						drawLine3D [_coins select 1, _coins select 5, _couleur];
						drawLine3D [_coins select 2, _coins select 6, _couleur];
						drawLine3D [_coins select 3, _coins select 7, _couleur];
					};
				};

				/**
				* Trace dans le jeu la bounding box de l'objet passé en paramètre
				* @param 0 l'objet pour lequel tracer la bounding box
				*/
				R3F_LOG_FNCT_3D_tracer_bbox_obj =
				{
					private ["_objet"];
					
					_objet = _this select 0;
					
					if !(isNull _objet) then
					{
						[_objet, boundingBoxReal _objet select 0, boundingBoxReal _objet select 1] call R3F_LOG_FNCT_3D_tracer_bbox;
					};
				};
				
				R3F_LOG_FNCT_determiner_fonctionnalites_logistique = 
				{
					private ["_classe", "_tab_classe_heritage", "_config", "_idx"];
					private ["_can_be_depl_heli_remorq_transp", "_can_lift", "_can_tow", "_can_transport_cargo", "_can_transport_cargo_cout"];
					private ["_can_be_moved_by_player", "_can_be_lifted", "_can_be_towed", "_can_be_transported_cargo", "_can_be_transported_cargo_cout"];

					_classe = _this select 0;

					// Calcul de l'arborescence d'héritage
					_tab_classe_heritage = [];
					for [
						{_config = configFile >> "CfgVehicles" >> _classe},
						{isClass _config},
						{_config = inheritsFrom _config}
					] do
					{
						_tab_classe_heritage pushBack (toLower configName _config);
					};

					// Calcul des fonctionnalités

					_can_be_depl_heli_remorq_transp = true;
					{
						if (_x in R3F_LOG_objets_depl_heli_remorq_transp) exitWith {_can_be_depl_heli_remorq_transp = true;};
					} forEach _tab_classe_heritage;

					_can_be_moved_by_player = true;
					_can_be_lifted = true;
					_can_be_towed = true;
					_can_be_transported_cargo = true;
					_can_be_transported_cargo_cout = 0;

					if (_can_be_depl_heli_remorq_transp) then
					{
						{
							if (true || _x in R3F_LOG_CFG_can_be_moved_by_player) exitWith {_can_be_moved_by_player = true;};
						} forEach _tab_classe_heritage;
						
						{
							if (true || _x in R3F_LOG_CFG_can_be_lifted) exitWith {_can_be_lifted = true;};
						} forEach _tab_classe_heritage;
						
						{
							if (true || _x in R3F_LOG_CFG_can_be_towed) exitWith {_can_be_towed = true;};
						} forEach _tab_classe_heritage;
						
						{
							_idx = R3F_LOG_classes_objets_transportables find _x;
							if (_idx != -1) exitWith
							{
								_can_be_transported_cargo = true;
								_can_be_transported_cargo_cout = 0;
							};
						} forEach _tab_classe_heritage;
					};

					_can_lift = false;
					{
						if (true || _x in R3F_LOG_CFG_can_lift) exitWith {_can_lift = true;};
					} forEach _tab_classe_heritage;

					_can_tow = false;
					{
						if (true || _x in R3F_LOG_CFG_can_tow) exitWith {_can_tow = true;};
					} forEach _tab_classe_heritage;

					_can_transport_cargo = true;
					_can_transport_cargo_cout = 9000000;
					{
						_idx = R3F_LOG_classes_transporteurs find _x;
						if (_idx != -1) exitWith
						{
							_can_transport_cargo = true;
							_can_transport_cargo_cout = 9000000;
						};
					} forEach _tab_classe_heritage;

					// Cargo de capacité nulle
					if (_can_transport_cargo_cout <= 0) then {_can_transport_cargo = false;};

					// Retour des fonctionnalités
					[
						_can_be_depl_heli_remorq_transp,
						_can_be_moved_by_player,
						_can_lift,
						_can_be_lifted,
						_can_tow,
						_can_be_towed,
						_can_transport_cargo,
						_can_transport_cargo_cout,
						_can_be_transported_cargo,
						_can_be_transported_cargo_cout
					]
				};
				
				R3F_LOG_FNCT_calculer_chargement_vehicule = 
				{
					private ["_transporteur", "_objets_charges", "_chargement_actuel", "_chargement_maxi"];

					_transporteur = _this select 0;

					_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];

					// Calcul du chargement actuel
					_chargement_actuel = 0;
					{
						if (isNil {_x getVariable "R3F_LOG_fonctionnalites"}) then
						{
							_chargement_actuel = _chargement_actuel + (([typeOf _x] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_be_transported_cargo_cout);
						}
						else
						{
							_chargement_actuel = _chargement_actuel + (_x getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_be_transported_cargo_cout);
						};
						
					} forEach _objets_charges;

					// Recherche de la capacit� maximale du transporteur
					if (isNil {_transporteur getVariable "R3F_LOG_fonctionnalites"}) then
					{
						_chargement_maxi = ([typeOf _transporteur] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_transport_cargo_cout;
					}
					else
					{
						_chargement_maxi = _transporteur getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_transport_cargo_cout;
					};

					[_chargement_actuel, _chargement_maxi]
				};
				
				R3F_LOG_FNCT_transporteur_charger_auto = 
				{
					waitUntil
					{
						if (R3F_LOG_mutex_local_verrou) then
						{
							false
						}
						else
						{
							R3F_LOG_mutex_local_verrou = true;
							true
						}
					};

					private ["_transporteur", "_liste_a_charger", "_chargement", "_chargement_actuel", "_chargement_maxi", "_objets_charges", "_cout_chargement_objet"];
					private ["_objet_ou_classe", "_quantite", "_objet", "_classe", "_bbox", "_bbox_dim", "_pos_degagee", "_fonctionnalites", "_i"];

					_transporteur = _this select 0;
					_liste_a_charger = _this select 1;

					_chargement = [_transporteur] call R3F_LOG_FNCT_calculer_chargement_vehicule;
					_chargement_actuel = _chargement select 0;
					_chargement_maxi = _chargement select 1;
					_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];

					// Pour chaque �l�ment de la liste � charger
					{
						if (typeName _x == "ARRAY" && {count _x > 0}) then
						{
							_objet_ou_classe = _x select 0;
							
							if (typeName _objet_ou_classe == "STRING" && count _x > 1) then
							{
								_quantite = _x select 1;
							}
							else
							{
								_quantite = 1;
							};
						}
						else
						{
							_objet_ou_classe = _x;
							_quantite = 1;
						};
						
						if (typeName _objet_ou_classe == "STRING") then
						{
							_classe = _objet_ou_classe;
							_bbox = [_classe] call R3F_LOG_FNCT_3D_get_bounding_box_depuis_classname;
							_bbox_dim = (vectorMagnitude (_bbox select 0)) max (vectorMagnitude (_bbox select 1));
							
							// Recherche d'une position d�gag�e. Les v�hicules doivent �tre cr�� au niveau du sol sinon ils ne peuvent �tre utilis�s.
							if (_classe isKindOf "AllVehicles") then
							{
								_pos_degagee = [_bbox_dim, getPos _transporteur, 200, 50] call R3F_LOG_FNCT_3D_tirer_position_degagee_sol;
							}
							else
							{
								_pos_degagee = [] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel;
							};
							
							if (count _pos_degagee == 0) then {_pos_degagee = getPosATL _transporteur;};
						}
						else
						{
							_classe = typeOf _objet_ou_classe;
						};
						
						_fonctionnalites = [_classe] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique;
						_cout_chargement_objet = _fonctionnalites select R3F_LOG_IDX_can_be_transported_cargo_cout;
						
						// S'assurer que le type d'objet � charger est transportable
						if !(_fonctionnalites select R3F_LOG_IDX_can_be_transported_cargo) then
						{
							diag_log format ["[Auto-load ""%1"" in ""%2""] : %3",
								getText (configFile >> "CfgVehicles" >> _classe >> "displayName"),
								getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName"),
								"The object is not a transporable class."];
							
							systemChat format ["[Auto-load ""%1"" in ""%2""] : %3",
								getText (configFile >> "CfgVehicles" >> _classe >> "displayName"),
								getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName"),
								"The object is not a transporable class."];
						}
						else
						{
							for [{_i = 0}, {_i < _quantite}, {_i = _i+1}] do
							{
								// Si l'objet � charger est donn� en tant que nom de classe, on le cr�e
								if (typeName _objet_ou_classe == "STRING") then
								{
									// Recherche d'une position d�gag�e. Les v�hicules doivent �tre cr�� au niveau du sol sinon ils ne peuvent �tre utilis�s.
									if (_classe isKindOf "AllVehicles") then
									{
										_objet = _classe createVehicle _pos_degagee;
										_objet setVectorDirAndUp [[-cos getDir _transporteur, sin getDir _transporteur, 0] vectorCrossProduct surfaceNormal _pos_degagee, surfaceNormal _pos_degagee];
										_objet setVelocity [0, 0, 0];
									}
									else
									{
										_objet = _classe createVehicle _pos_degagee;
									};
								}
								else
								{
									_objet = _objet_ou_classe;
								};
								
								if (!isNull _objet) then
								{
									// V�rifier qu'il n'est pas d�j� transport�
									if (isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull]) &&
										(isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull]) || (!alive (_objet getVariable ["R3F_LOG_est_deplace_par", objNull])) || (!isPlayer (_objet getVariable ["R3F_LOG_est_deplace_par", objNull])))
									) then
									{
										if (isNull (_objet getVariable ["R3F_LOG_remorque", objNull])) then
										{
											// Si l'objet loge dans le v�hicule
											if (_chargement_actuel + _cout_chargement_objet <= _chargement_maxi) then
											{
												_chargement_actuel = _chargement_actuel + _cout_chargement_objet;
												_objets_charges pushBack _objet;
												
												_objet setVariable ["R3F_LOG_est_transporte_par", _transporteur, true];
												_objet attachTo [R3F_LOG_PUBVAR_point_attache, [] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel];
											}
											else
											{
												diag_log format ["[Auto-load ""%1"" in ""%2""] : %3",
													getText (configFile >> "CfgVehicles" >> _classe >> "displayName"),
													getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName"),
													STR_R3F_LOG_action_charger_pas_assez_de_place];
												
												systemChat format ["[Auto-load ""%1"" in ""%2""] : %3",
													getText (configFile >> "CfgVehicles" >> _classe >> "displayName"),
													getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName"),
													STR_R3F_LOG_action_charger_pas_assez_de_place];
												
												if (typeName _objet_ou_classe == "STRING") then
												{
													deleteVehicle _objet;
												};
											};
										}
										else
										{
											diag_log format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> _classe >> "displayName")];
											systemChat format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> _classe >> "displayName")];
										};
									}
									else
									{
										diag_log format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> _classe >> "displayName")];
										systemChat format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> _classe >> "displayName")];
									};
								};
							};
						};
					} forEach _liste_a_charger;

					// On m�morise sur le r�seau le nouveau contenu du v�hicule
					_transporteur setVariable ["R3F_LOG_objets_charges", _objets_charges, true];

					R3F_LOG_mutex_local_verrou = false;
				};

				R3F_fnc_init = 
				{

			

					R3F_LOG_CFG_can_tow = [];
					R3F_LOG_CFG_can_be_towed = [];
					R3F_LOG_CFG_can_lift = [];
					R3F_LOG_CFG_can_be_lifted = [];
					R3F_LOG_CFG_can_transport_cargo = [];
					R3F_LOG_CFG_can_be_transported_cargo = [];
					R3F_LOG_CFG_can_be_moved_by_player = [];
					
					// Initialise les listes vides de config_creation_factory.sqf
					R3F_LOG_CFG_CF_whitelist_full_categories = [];
					R3F_LOG_CFG_CF_whitelist_medium_categories = [];
					R3F_LOG_CFG_CF_whitelist_light_categories = [];
					R3F_LOG_CFG_CF_blacklist_categories = [];
					
					[] call {
						/**
						* MAIN CONFIGURATION FILE
						* 
						* English and French comments
						* Commentaires anglais et fran�ais
						* 
						* (EN)
						* This file contains the configuration variables of the logistics system.
						* For the configuration of the creation factory, see the file "config_creation_factory.sqf".
						* IMPORTANT NOTE : when a logistics feature is given to an object/vehicle class name, all the classes which inherit
						*                  of the parent/generic class (according to the CfgVehicles) will also have this feature.
						*                  CfgVehicles tree view example : http://madbull.arma.free.fr/A3_stable_1.20.124746_CfgVehicles_tree.html
						* 
						* (FR)
						* Fichier contenant les variables de configuration du syst�me de logistique.
						* Pour la configuration de l'usine de cr�ation, voir le fichier "config_creation_factory.sqf".
						* NOTE IMPORTANTE : lorsqu'une fonctionnalit� logistique est accord�e � un nom de classe d'objet/v�hicule, les classes
						*                   h�ritant de cette classe m�re/g�n�rique (selon le CfgVehicles) se verront �galement dot�es de cette fonctionnalit�.
						*                   Exemple d'arborescence du CfgVehicles : http://madbull.arma.free.fr/A3_stable_1.20.124746_CfgVehicles_tree.html
						*/

						/**
						* DISABLE LOGISTICS ON OBJECTS BY DEFAULT
						* 
						* (EN)
						* Define if objects and vehicles have logistics features by default,
						* or if it must be allowed explicitely on specific objects/vehicles.
						* 
						* If false : all objects are enabled according to the class names listed in this configuration file
						*            You can disable some objects with : object setVariable ["R3F_LOG_disabled", true];
						* If true :  all objects are disabled by default
						*            You can enable some objects with : object setVariable ["R3F_LOG_disabled", false];
						* 
						* 
						* (FR)
						* D�fini si les objets et v�hicules disposent des fonctionnalit�s logistiques par d�faut,
						* ou si elles doivent �tre autoris�s explicitement sur des objets/v�hicules sp�cifiques.
						* 
						* Si false : tous les objets sont actifs en accord avec les noms de classes list�s dans ce fichier
						*            Vous pouvez d�sactiver certains objets avec : objet setVariable ["R3F_LOG_disabled", true];
						* Si true :  tous les objets sont inactifs par d�faut
						*            Vous pouvez activer quelques objets avec : objet setVariable ["R3F_LOG_disabled", false];
						*/
						R3F_LOG_CFG_disabled_by_default = false;

						/**
						* LOCK THE LOGISTICS FEATURES TO SIDE, FACTION OR PLAYER
						* 
						* (EN)
						* Define the lock mode of the logistics features for an object.
						* An object can be locked to the a side, faction, a player (respawn) or a unit (life).
						* If the object is locked, the player can unlock it according to the
						* value of the config variable R3F_LOG_CFG_unlock_objects_timer.
						* 
						* If "none" : no lock features, everyone can used the logistics features.
						* If "side" : the object is locked to the last side which interacts with it.
						* If "faction" : the object is locked to the last faction which interacts with it.
						* If "player" : the object is locked to the last player which interacts with it. The lock is transmitted after respawn.
						* If "unit" : the object is locked to the last player which interacts with it. The lock is lost when the unit dies.
						* 
						* Note : for military objects (not civilian), the lock is initialized to the object's side.
						* 
						* See also the config variable R3F_LOG_CFG_unlock_objects_timer.
						* 
						* (FR)
						* D�fini le mode de verrouillage des fonctionnalit�s logistics pour un objet donn�.
						* Un objet peut �tre verrouill� pour une side, une faction, un joueur (respawn) ou une unit� (vie).
						* Si l'objet est verrouill�, le joueur peut le d�verrouiller en fonction de la
						* valeur de la variable de configiration R3F_LOG_CFG_unlock_objects_timer.
						* 
						* Si "none" : pas de verrouillage, tout le monde peut utiliser les fonctionnalit�s logistiques.
						* Si "side" : l'objet est verrouill� pour la derni�re side ayant interagit avec lui.
						* Si "faction" : l'objet est verrouill� pour la derni�re faction ayant interagit avec lui.
						* Si "player" : l'objet est verrouill� pour le dernier joueur ayant interagit avec lui. Le verrou est transmis apr�s respawn.
						* Si "unit" : l'objet est verrouill� pour le dernier joueur ayant interagit avec lui. Le verrou est perdu quand l'unit� meurt.
						* 
						* Note : pour les objets militaires (non civils), le verrou est initialis� � la side de l'objet.
						* 
						* Voir aussi la variable de configiration R3F_LOG_CFG_unlock_objects_timer.
						*/
						R3F_LOG_CFG_lock_objects_mode = "side";

						/**
						* COUNTDOWN TO UNLOCK AN OBJECT
						* 
						* Define the countdown duration (in seconds) to unlock a locked object.
						* Set to -1 to deny the unlock of objects.
						* See also the config variable R3F_LOG_CFG_lock_objects_mode.
						* 
						* D�fini la dur�e (en secondes) du compte-�-rebours pour d�verrouiller un objet.
						* Mettre � -1 pour qu'on ne puisse pas d�verrouiller les objets.
						* Voir aussi la variable de configiration R3F_LOG_CFG_lock_objects_mode.
						*/
						R3F_LOG_CFG_unlock_objects_timer = 30;

						/**
						* ALLOW NO GRAVITY OVER GROUND
						* 
						* Define if movable objects with no gravity simulation can be set in height over the ground (no ground contact).
						* The no gravity objects corresponds to most of decoration and constructions items.
						* 
						* D�fini si les objets d�pla�able sans simulation de gravit� peuvent �tre position en hauteur sans �tre contact avec le sol.
						* Les objets sans gravit� correspondent � la plupart des objets de d�cors et de construction.
						*/
						R3F_LOG_CFG_no_gravity_objects_can_be_set_in_height_over_ground = true;

						/**
						* LANGUAGE
						* 
						* Automatic language selection according to the game language.
						* New languages can be easily added (read below).
						* 
						* S�lection automatique de la langue en fonction de la langue du jeu.
						* De nouveaux langages peuvent facilement �tre ajout�s (voir ci-dessous).
						*/
						R3F_LOG_CFG_language = switch (language) do
						{
							case "English":{"en"};
							case "French":{"fr"};
							
							// Feel free to create you own language file named "XX_strings_lang.sqf", where "XX" is the language code.
							// Make a copy of an existing language file (e.g. en_strings_lang.sqf) and translate it.
							// Then add a line with this syntax : case "YOUR_GAME_LANGUAGE":{"LANGUAGE_CODE"};
							// For example :
							
							//case "Czech":{"cz"}; // Not supported. Need your own "cz_strings_lang.sqf"
							//case "Polish":{"pl"}; // Not supported. Need your own "pl_strings_lang.sqf"
							//case "Portuguese":{"pt"}; // Not supported. Need your own "pt_strings_lang.sqf"
							//case "YOUR_GAME_LANGUAGE":{"LANGUAGE_CODE"};  // Need your own "LANGUAGE_CODE_strings_lang.sqf"
							
							default {"en"}; // If language is not supported, use English
						};

						/**
						* CONDITION TO ALLOW LOGISTICS
						* 
						* (EN)
						* This variable allow to set a dynamic SQF condition to allow/deny all logistics features only on specific clients.
						* The variable must be a STRING delimited by quotes and containing a valid SQF condition to evaluate during the game.
						* For example you can allow logistics only on few clients having a known game ID by setting the variable to :
						* "getPlayerUID player in [""76xxxxxxxxxxxxxxx"", ""76yyyyyyyyyyyyyyy"", ""76zzzzzzzzzzzzzzz""]"
						* Or based on the profile name : "profileName in [""john"", ""jack"", ""james""]"
						* Or only for the server admin : "serverCommandAvailable "#kick"""
						* The condition is evaluted in real time, so it can use condition depending on the mission progress : "alive officer && taskState task1 == ""Succeeded"""
						* Or to deny logistics in a circular area defined by a marker : "player distance getMarkerPos ""markerName"" > getMarkerSize ""markerName"" select 0"
						* Note that quotes of the strings inside the string condition must be doubled.
						* Note : if the condition depends of the aimed objects/vehicle, you can use the command cursorTarget
						* To allow the logistics to everyone, just set the condition to "true".
						* 
						* (FR)
						* Cette variable permet d'utiliser une condition SQF dynamique pour autoriser ou non les fonctions logistiques sur des clients sp�cifiques.
						* La variable doit �tre une CHAINE de caract�res d�limit�e par des guillemets et doit contenir une condition SQF valide qui sera �valu�e durant la mission.
						* Par exemple pour autoriser la logistique sur seulement quelques joueurs ayant un ID de jeu connu, la variable peut �tre d�fini comme suit :
						* "getPlayerUID player in [""76xxxxxxxxxxxxxxx"", ""76yyyyyyyyyyyyyyy"", ""76zzzzzzzzzzzzzzz""]"
						* Ou elle peut se baser sur le nom de profil : "profileName in [""maxime"", ""martin"", ""marc""]"
						* Ou pour n'autoriser que l'admin de serveur : "serverCommandAvailable "#kick"""
						* Les condition sont �valu�es en temps r�el, et peuvent donc d�pendre du d�roulement de la mission : "alive officier && taskState tache1 == ""Succeeded"""
						* Ou pour interdire la logistique dans la zone d�fini par un marqueur circulaire : "player distance getMarkerPos ""markerName"" > getMarkerSize ""markerName"" select 0"
						* Notez que les guillemets des cha�nes de caract�res dans la cha�ne de condition doivent �tre doubl�s.
						* Note : si la condition d�pend de l'objet/v�hicule point�, vous pouvez utiliser la commande cursorTarget
						* Pour autoriser la logistique chez tout le monde, il suffit de d�finir la condition � "true".
						*/
						R3F_LOG_CFG_string_condition_allow_logistics_on_this_client = "true";

						/**
						* CONDITION TO ALLOW CREATION FACTORY
						* 
						* (EN)
						* This variable allow to set a dynamic SQF condition to allow/deny the access to the creation factory only on specific clients.
						* The variable must be a STRING delimited by quotes and containing a valid SQF condition to evaluate during the game.
						* For example you can allow the creation factory only on few clients having a known game ID by setting the variable to :
						* "getPlayerUID player in [""76xxxxxxxxxxxxxxx"", ""76yyyyyyyyyyyyyyy"", ""76zzzzzzzzzzzzzzz""]"
						* Or based on the profile name : "profileName in [""john"", ""jack"", ""james""]"
						* Or only for the server admin : "serverCommandAvailable "#kick"""
						* Note that quotes of the strings inside the string condition must be doubled.
						* Note : if the condition depends of the aimed objects/v�hicule, you can use the command cursorTarget
						* Note also that the condition is evaluted in real time, so it can use condition depending on the mission progress :
						* "alive officer && taskState task1 == ""Succeeded"""
						* To allow the creation factory to everyone, just set the condition to "true".
						* 
						* (FR)
						* Cette variable permet d'utiliser une condition SQF dynamique pour rendre accessible ou non l'usine de cr�ation sur des clients sp�cifiques.
						* La variable doit �tre une CHAINE de caract�res d�limit�e par des guillemets et doit contenir une condition SQF valide qui sera �valu�e durant la mission.
						* Par exemple pour autoriser l'usine de cr�ation sur seulement quelques joueurs ayant un ID de jeu connu, la variable peut �tre d�fini comme suit :
						* "getPlayerUID player in [""76xxxxxxxxxxxxxxx"", ""76yyyyyyyyyyyyyyy"", ""76zzzzzzzzzzzzzzz""]"
						* Ou elle peut se baser sur le nom de profil : "profileName in [""maxime"", ""martin"", ""marc""]"
						* Ou pour n'autoriser que l'admin de serveur : "serverCommandAvailable "#kick"""
						* Notez que les guillemets des cha�nes de caract�res dans la cha�ne de condition doivent �tre doubl�s.
						* Note : si la condition d�pend de l'objet/v�hicule point�, vous pouvez utiliser la commande cursorTarget
						* Notez aussi que les condition sont �valu�es en temps r�el, et peuvent donc d�pendre du d�roulement de la mission :
						* "alive officier && taskState tache1 == ""Succeeded"""
						* Pour autoriser l'usine de cr�ation chez tout le monde, il suffit de d�finir la condition � "true".
						*/
						R3F_LOG_CFG_string_condition_allow_creation_factory_on_this_client = "true";
					};

					// Chargement du fichier de langage
					[] call {
						STR_R3F_LOG_action_heliporter = "Lift the object";
						STR_R3F_LOG_action_heliporter_fait = "Object ""%1"" attached.";
						STR_R3F_LOG_action_heliport_larguer = "Drop the object";
						STR_R3F_LOG_action_heliport_larguer_fait = "Object ""%1"" dropped.";
						STR_R3F_LOG_action_heliport_attente = "Hooking... (%1)";
						STR_R3F_LOG_action_heliport_echec_attente = "Lift aborted ! Stay hover during the hooking.";

						STR_R3F_LOG_action_deplacer_objet = "Take ""%1""";
						STR_R3F_LOG_action_relacher_objet = "Release ""%1""";
						STR_R3F_LOG_action_aligner_pente = "Adjust to the slope";
						STR_R3F_LOG_action_aligner_sol = "Adjust to the ground";
						STR_R3F_LOG_action_aligner_horizon = "Adjust horizontally";
						STR_R3F_LOG_action_tourner = "Turn left/right (X / C keys)";
						STR_R3F_LOG_action_rapprocher = "Closer/further (F / R keys)";
						STR_R3F_LOG_ne_pas_monter_dans_vehicule = "You can't get in a vehicle while you're carrying this object !";

						STR_R3F_LOG_action_charger_deplace = "Load in the vehicle";
						STR_R3F_LOG_action_selectionner_objet_charge = "Load ""%1"" in...";
						STR_R3F_LOG_action_charger_selection = "... load in ""%1""";
						STR_R3F_LOG_action_selectionner_objet_fait = "Now select the destination for ""%1""...";
						STR_R3F_LOG_action_charger_en_cours = "Loading in progress...";
						STR_R3F_LOG_action_charger_fait = "The object ""%1"" has been loaded in ""%2"".";
						STR_R3F_LOG_action_charger_pas_assez_de_place = "There is not enough space for this object in this vehicle !";

						STR_R3F_LOG_action_remorquer_direct = "Tow ""%1""";
						STR_R3F_LOG_action_remorquer_deplace = "Tow the object";
						STR_R3F_LOG_action_detacher = "Untow the object";
						STR_R3F_LOG_action_detacher_fait = "Object untowed.";
						STR_R3F_LOG_action_detacher_impossible_pour_ce_vehicule = "Only the pilot can detach this object.";

						STR_R3F_LOG_action_contenu_vehicule = "View the vehicle's content";
						STR_R3F_LOG_action_decharger_en_cours = "Unloading in progress...";
						STR_R3F_LOG_action_decharger_fait = "The object ""%1"" has been unloaded from the vehicle.";
						STR_R3F_LOG_action_decharger_deja_fait = "The object has already been unloaded !";
						STR_R3F_LOG_action_decharger_deplacable_exceptionnel = "Once released, this object will no more be movable manually.<br/>Do you confirm the action ?";

						STR_R3F_LOG_action_ouvrir_usine = "Open the creation factory";
						STR_R3F_LOG_action_creer_en_cours = "Creation in progress...";
						STR_R3F_LOG_action_creer_fait = "The object ""%1"" has been created.";
						STR_R3F_LOG_action_creer_pas_assez_credits = "The factory has not enough credits to create this object.";
						STR_R3F_LOG_action_revendre_usine_direct = "Send back ""%1"" to the factory";
						STR_R3F_LOG_action_revendre_usine_deplace = "Send back to the factory";
						STR_R3F_LOG_action_revendre_usine_selection = "... send back to the factory";
						STR_R3F_LOG_action_revendre_en_cours = "Sending back to the factory...";
						STR_R3F_LOG_action_revendre_fait = "The object ""%1"" has been sent back to the factory.";
						STR_R3F_LOG_action_revendre_decharger_avant = "You can't sent it back while its cargo content is not empty !";

						STR_R3F_LOG_mutex_action_en_cours = "The current operation isn't finished !";
						STR_R3F_LOG_joueur_dans_objet = "There is a player in the object ""%1"" !";
						STR_R3F_LOG_objet_en_cours_transport = "The object ""%1"" is already in transit !";
						STR_R3F_LOG_objet_remorque_en_cours = "Impossible because the object ""%1"" is towing another object !";
						STR_R3F_LOG_trop_loin = "Impossible because the object ""%1"" is too far !";

						STR_R3F_LOG_dlg_CV_titre = "Vehicle's content";
						STR_R3F_LOG_dlg_CV_capacite_vehicule = "Loading : %1/%2";
						STR_R3F_LOG_dlg_CV_btn_decharger = "UNLOAD";
						STR_R3F_LOG_dlg_CV_btn_fermer = "CANCEL";

						STR_R3F_LOG_dlg_LO_titre = "Creation factory";
						STR_R3F_LOG_dlg_LO_credits_restants = "Remaining credits : %1";
						STR_R3F_LOG_dlg_LO_btn_creer = "CREATE";
						STR_R3F_LOG_dlg_LO_btn_fermer = "CANCEL";

						STR_R3F_LOG_nom_fonctionnalite_proprietes = "Properties";
						STR_R3F_LOG_nom_fonctionnalite_side = "Side";
						STR_R3F_LOG_nom_fonctionnalite_places = "Seating";
						STR_R3F_LOG_nom_fonctionnalite_passif = "It can be :";
						STR_R3F_LOG_nom_fonctionnalite_passif_deplace = "Moved by player";
						STR_R3F_LOG_nom_fonctionnalite_passif_heliporte = "Lifted";
						STR_R3F_LOG_nom_fonctionnalite_passif_remorque = "Towed";
						STR_R3F_LOG_nom_fonctionnalite_passif_transporte = "Transported";
						STR_R3F_LOG_nom_fonctionnalite_passif_transporte_capacite = "load cost %1";
						STR_R3F_LOG_nom_fonctionnalite_actif = "It can :";
						STR_R3F_LOG_nom_fonctionnalite_actif_heliporte = "Lift";
						STR_R3F_LOG_nom_fonctionnalite_actif_remorque = "Tow";
						STR_R3F_LOG_nom_fonctionnalite_actif_transporte = "Transport";
						STR_R3F_LOG_nom_fonctionnalite_actif_transporte_capacite = "max load %1";

						STR_R3F_LOG_deverrouillage_en_cours = "Unlocking... (%1)";
						STR_R3F_LOG_deverrouillage_echec_attente = "Unlock canceled ! Hold the aiming of the object during the countdown.";
						STR_R3F_LOG_deverrouillage_succes_attente = "Object unlocked.";
						STR_R3F_LOG_action_deverrouiller = "Unlock ""%1""";
						STR_R3F_LOG_action_deverrouiller_impossible = "Object locked";
					};
					
						
					/*
					* On inverse l'ordre de toutes les listes de noms de classes pour donner
					* la priorit� aux classes sp�cifiques sur les classes g�n�riques
					*/

					// On passe tous les noms de classes en minuscules
					
										
					// Gestion compatibilit� fichier de config 3.0 => 3.1 (d�finition de valeurs par d�faut)
					if (isNil "R3F_LOG_CFG_lock_objects_mode") then {R3F_LOG_CFG_lock_objects_mode = "side";};
					if (isNil "R3F_LOG_CFG_unlock_objects_timer") then {R3F_LOG_CFG_unlock_objects_timer = 30;};
					if (isNil "R3F_LOG_CFG_CF_sell_back_bargain_rate") then {R3F_LOG_CFG_CF_sell_back_bargain_rate = 0.75;};
					if (isNil "R3F_LOG_CFG_CF_creation_cost_factor") then {R3F_LOG_CFG_CF_creation_cost_factor = [];};
					
					/* FIN import config */
					

					// On cr�e le point d'attache qui servira aux attachTo pour les objets � charger virtuellement dans les v�hicules
					R3F_LOG_PUBVAR_point_attache = "Land_HelipadEmpty_F" createVehicle [0,0,0];
					R3F_LOG_PUBVAR_point_attache setPosASL [0,0,0];
					R3F_LOG_PUBVAR_point_attache setVectorDirAndUp [[0,1,0], [0,0,1]];
					
					// Partage du point d'attache avec tous les joueurs
					publicVariable "R3F_LOG_PUBVAR_point_attache";
					
					/** Liste des objets � ne pas perdre dans un vehicule/cargo d�truit */
					R3F_LOG_liste_objets_a_proteger = [];
					
					/* Prot�ge les objets pr�sents dans R3F_LOG_liste_objets_a_proteger */
					[] spawn {
						/**
						* Vérifie périodiquement que les objets à protéger et ne pas perdre aient besoin d'être déchargés/téléportés.
						* Script à faire tourner dans un fil d'exécution dédié sur le serveur.
						* 
						* Copyright (C) 2014 Team ~R3F~
						* 
						* This program is free software under the terms of the GNU General Public License version 3.
						* You should have received a copy of the GNU General Public License
						* along with this program.  If not, see <http://www.gnu.org/licenses/>.
						*/

						while {true} do
						{
							// Pour chaque objet à protéger
							{
								private ["_objet", "_bbox_dim", "_pos_respawn", "_pos_degagee", "_rayon"];
								
								_objet = _x;
								
								if (!isNull _objet) then
								{
									// Si l'objet est transporté/héliporté/remorqué
									if !(isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull])) then
									{
										// Mais que le transporteur est détruit/héliporté/remorqué
										if !(alive (_objet getVariable "R3F_LOG_est_transporte_par")) then
										{
											// Récupération de la position de respawn en accord avec le paramètre passé dans "do_not_lose_it"
											if (typeName (_objet getVariable "R3F_LOG_pos_respawn") == "ARRAY") then
											{
												_pos_respawn = _objet getVariable "R3F_LOG_pos_respawn";
											}
											else
											{
												if (_objet getVariable "R3F_LOG_pos_respawn" == "cargo_pos") then
												{
													_pos_respawn = getPos (_objet getVariable "R3F_LOG_est_transporte_par");
												}
												else
												{
													_pos_respawn = getMarkerPos (_objet getVariable "R3F_LOG_pos_respawn");
												};
											};
											
											_bbox_dim = (vectorMagnitude (boundingBoxReal _objet select 0)) max (vectorMagnitude (boundingBoxReal _objet select 1));
											
											// Si mode de respawn != "exact_spawn_pos"
											if (isNil {_objet getVariable "R3F_LOG_dir_respawn"}) then
											{
												// Recherche d'une position dégagée (on augmente progressivement le rayon jusqu'à trouver une position)
												for [{_rayon = 5 max (2*_bbox_dim); _pos_degagee = [];}, {count _pos_degagee == 0 && _rayon <= 100 + (8*_bbox_dim)}, {_rayon = _rayon + 20 + (5*_bbox_dim)}] do
												{
													_pos_degagee = [
														_bbox_dim,
														_pos_respawn,
														_rayon,
														100 min (5 + _rayon^1.2)
													] call R3F_LOG_FNCT_3D_tirer_position_degagee_sol;
												};
												
												// En cas d'échec de la recherche de position dégagée
												if (count _pos_degagee == 0) then {_pos_degagee = _pos_respawn;};
												
												// On ramène l'objet sur la position
												detach _objet;
												_objet setPos _pos_degagee;
											}
											else
											{
												// On ramène l'objet sur la position
												detach _objet;
												_objet setPosASL _pos_respawn;
												_objet setDir (_objet getVariable "R3F_LOG_dir_respawn");
											};
											
											// On retire l'objet du contenu du véhicule (s'il est dedans)
											_objets_charges = (_objet getVariable "R3F_LOG_est_transporte_par") getVariable ["R3F_LOG_objets_charges", []];
											if (_objet in _objets_charges) then
											{
												_objets_charges = _objets_charges - [_objet];
												(_objet getVariable "R3F_LOG_est_transporte_par") setVariable ["R3F_LOG_objets_charges", _objets_charges, true];
											};
											
											_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
											
											sleep 4;
										};
									};
								};
							} forEach R3F_LOG_liste_objets_a_proteger;
							
							sleep 90;
						};
					};

					
					/**
					* Suite � une PVEH, ex�cute une commande en fonction de la localit� de l'argument
					* @param 0 l'argument sur lequel ex�cuter la commande
					* @param 1 la commande � ex�cuter (cha�ne de caract�res)
					* @param 2 les �ventuels param�tres de la commande (optionnel)
					* @note il faut passer par la fonction R3F_LOG_FNCT_exec_commande_MP
					*/
					R3F_LOG_FNCT_PVEH_commande_MP =
					{
						private ["_argument", "_commande", "_parametre"];
						_argument = _this select 1 select 0;
						_commande = _this select 1 select 1;
						_parametre = if (count (_this select 1) == 3) then {_this select 1 select 2} else {0};
						
						// Commandes � argument global et effet local
						switch (_commande) do
						{
							// Aucune pour l'instant
							// ex : case "switchMove": {_argument switchMove _parametre;};
						};
						
						// Commandes � argument local et effet global

						switch (_commande) do
						{
							case "setDir": {_argument setDir _parametre;};
							case "setVelocity": {_argument setVelocity _parametre;};
							case "detachSetVelocity": {detach _argument; _argument setVelocity _parametre;};
						};
					
						// Commandes � faire uniquement sur le serveur
						if (isServer) then
						{
							if (_commande == "setOwnerTo") then
							{
								_argument setOwner (owner _parametre);
							};
						};
					};
					"R3F_LOG_PV_commande_MP" addPublicVariableEventHandler R3F_LOG_FNCT_PVEH_commande_MP;
					
					/**
					* Ordonne l'ex�cution d'une commande quelque soit la localit� de l'argument ou de l'effet
					* @param 0 l'argument sur lequel ex�cuter la commande
					* @param 1 la commande � ex�cuter (cha�ne de caract�res)
					* @param 2 les �ventuels param�tres de la commande (optionnel)
					* @usage [_objet, "setDir", 160] call R3F_LOG_FNCT_exec_commande_MP
					*/
					R3F_LOG_FNCT_exec_commande_MP =
					{
						R3F_LOG_PV_commande_MP = _this;
						publicVariable "R3F_LOG_PV_commande_MP";
						["R3F_LOG_PV_commande_MP", R3F_LOG_PV_commande_MP] spawn R3F_LOG_FNCT_PVEH_commande_MP;
					};
					
					/** Pseudo-mutex permettant de n'ex�cuter qu'un script de manipulation d'objet � la fois (true : v�rouill�) */
					R3F_LOG_mutex_local_verrou = false;
										
					// Indices du tableau des fonctionnalit�s retourn� par R3F_LOG_FNCT_determiner_fonctionnalites_logistique
					R3F_LOG_IDX_can_be_depl_heli_remorq_transp = 0;
					R3F_LOG_IDX_can_be_moved_by_player = 1;
					R3F_LOG_IDX_can_lift = 2;
					R3F_LOG_IDX_can_be_lifted = 3;
					R3F_LOG_IDX_can_tow = 4;
					R3F_LOG_IDX_can_be_towed = 5;
					R3F_LOG_IDX_can_transport_cargo = 6;
					R3F_LOG_IDX_can_transport_cargo_cout = 7;
					R3F_LOG_IDX_can_be_transported_cargo = 8;
					R3F_LOG_IDX_can_be_transported_cargo_cout = 9;
					R3F_LOG_CST_zero_log = [true, true, true, true, true, true, true, 90000000, true, 0];
										
					
					
					
					// Un serveur d�di� n'en a pas besoin
					if !(isDedicated) then
					{
						// Le client attend que le serveur ai cr�� et publi� la r�f�rence de l'objet servant de point d'attache
						waitUntil {!isNil "R3F_LOG_PUBVAR_point_attache"};
						
						/** Indique quel objet le joueur est en train de d�placer, objNull si aucun */
						R3F_LOG_joueur_deplace_objet = objNull;
						
						/** Objet actuellement s�lectionner pour �tre charg�/remorqu� */
						R3F_LOG_objet_selectionne = objNull;
						
						/** Tableau contenant toutes les usines cr��es */
						R3F_LOG_CF_liste_usines = [];
						
						[] call 
						{
							/**
							* Biblioth�que de fonctions permettant la visualisation 3D d'objets
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							/**
							* D�marre le mode de visualisation 3D
							*/
							R3F_LOG_VIS_FNCT_demarrer_visualisation =
							{
								// Cr�ation d'une cam�ra
								R3F_LOG_VIS_cam = "camera" camCreate ([[5000, 5000, 0]] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel);
								R3F_LOG_VIS_cam cameraEffect ["Internal", "BACK"];
								R3F_LOG_VIS_cam camSetFocus [-1, -1];
								showCinemaBorder false;
								R3F_LOG_VIS_cam camCommit 0;
								camUseNVG (sunOrMoon == 0);
								
								R3F_LOG_VIS_objet = objNull;
								
								// Fil d'ex�cution r�alisant une rotation continue de la cam�ra autour de l'objet � visualiser
								0 spawn
								{
									// Tant qu'on ne quitte pas la visualisation
									while {!isNull R3F_LOG_VIS_cam} do
									{
										private ["_objet", "_distance_cam", "_azimut_cam"];
										
										// Attente d'un objet � visualiser
										waitUntil {!isNull R3F_LOG_VIS_objet};
										
										_objet = R3F_LOG_VIS_objet;
										
										_distance_cam = 2.25 * (
												[boundingBoxReal _objet select 0 select 0, boundingBoxReal _objet select 0 select 2]
											distance
												[boundingBoxReal _objet select 1 select 0, boundingBoxReal _objet select 1 select 2]
										);
										_azimut_cam = 0;
										
										R3F_LOG_VIS_cam camSetTarget _objet;
										R3F_LOG_VIS_cam camSetPos (_objet modelToWorld [_distance_cam * sin _azimut_cam, _distance_cam * cos _azimut_cam, _distance_cam * 0.33]);
										R3F_LOG_VIS_cam camCommit 0;
										
										// Rotation autour de l'objet
										while {R3F_LOG_VIS_objet == _objet} do
										{
											_azimut_cam = _azimut_cam + 3.25;
											
											R3F_LOG_VIS_cam camSetPos (_objet modelToWorld [_distance_cam * sin _azimut_cam, _distance_cam * cos _azimut_cam, _distance_cam * 0.33]);
											R3F_LOG_VIS_cam camCommit 0.05;
											
											sleep 0.05;
										};
									};
								};
							};

							/**
							* Termine le mode de visualisation 3D
							*/
							R3F_LOG_VIS_FNCT_terminer_visualisation =
							{
								if (!isNull R3F_LOG_VIS_objet) then {detach R3F_LOG_VIS_objet; deleteVehicle R3F_LOG_VIS_objet;};
								R3F_LOG_VIS_objet = objNull;
								
								R3F_LOG_VIS_cam cameraEffect ["Terminate", "BACK"];
								camDestroy R3F_LOG_VIS_cam;
								R3F_LOG_VIS_cam = objNull;
							};

							/**
							* Visualiser un type d'objet en 3D
							* 
							* @param 0 le nom de classe de l'objet � visualiser
							*/
							R3F_LOG_VIS_FNCT_voir_objet =
							{
								private ["_classe_a_visualiser", "_objet", "_position_attache"];
								
								if (isNil "R3F_LOG_VIS_cam") then
								{
									call R3F_LOG_VIS_FNCT_demarrer_visualisation;
								};
								
								_classe_a_visualiser = _this select 0;
								
								// Ignorer les objets non instanciables
								if (_classe_a_visualiser != "" && {isClass (configFile >> "CfgVehicles" >> _classe_a_visualiser) && {getNumber (configFile >> "CfgVehicles" >> _classe_a_visualiser >> "scope") > 0}}) then
								{
									// Ignorer si l'objet � visualiser est le m�me que pr�c�demment
									if (isNull R3F_LOG_VIS_objet || {_classe_a_visualiser != typeOf R3F_LOG_VIS_objet}) then
									{
										// Cr�er et placer l'objet dans le ciel
										_position_attache = [[5000, 5000, 0]] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel;
										_objet = _classe_a_visualiser createVehicleLocal _position_attache;
										_objet attachTo [R3F_LOG_PUBVAR_point_attache, _position_attache];
										
										if (!isNull R3F_LOG_VIS_objet) then {detach R3F_LOG_VIS_objet; deleteVehicle R3F_LOG_VIS_objet;};
										R3F_LOG_VIS_objet = _objet;
									};
								};
							};
						
						};
						
						R3F_LOG_FNCT_objet_relacher = 
						{
							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								R3F_LOG_joueur_deplace_objet = objNull;
								sleep 0.25;
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_objet_deplacer = 
						{
							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								R3F_LOG_objet_selectionne = objNull;
								
								private ["_objet", "_decharger", "_joueur", "_dir_joueur", "_arme_courante", "_muzzle_courant", "_mode_muzzle_courant", "_restaurer_arme"];
								private ["_vec_dir_rel", "_vec_dir_up", "_dernier_vec_dir_up", "_avant_dernier_vec_dir_up", "_normale_surface"];
								private ["_pos_rel_objet_initial", "_pos_rel_objet", "_dernier_pos_rel_objet", "_avant_dernier_pos_rel_objet"];
								private ["_elev_cam_initial", "_elev_cam", "_offset_hauteur_cam", "_offset_bounding_center", "_offset_hauteur_terrain"];
								private ["_offset_hauteur", "_dernier_offset_hauteur", "_avant_dernier_offset_hauteur"];
								private ["_hauteur_terrain_min_max_objet", "_offset_hauteur_terrain_min", "_offset_hauteur_terrain_max"];
								private ["_action_relacher", "_action_aligner_pente", "_action_aligner_sol", "_action_aligner_horizon", "_action_tourner", "_action_rapprocher"];
								private ["_idx_eh_fired", "_idx_eh_keyDown", "_idx_eh_keyUp", "_time_derniere_rotation", "_time_derniere_translation"];
								
								_objet = _this select 0;
								_decharger = if (count _this >= 4) then {_this select 3} else {false};
								_joueur = player;
								_dir_joueur = getDir _joueur;
								
								if (isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull]) && (isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull]) || (!alive (_objet getVariable ["R3F_LOG_est_deplace_par", objNull])) || (!isPlayer (_objet getVariable ["R3F_LOG_est_deplace_par", objNull])))) then
								{
									if (true || isNull (_objet getVariable ["R3F_LOG_remorque", objNull])) then
									{
										if (count crew _objet >= 0 || getNumber (configFile >> "CfgVehicles" >> (typeOf _objet) >> "isUav") == 1) then
										{
											[_objet, _joueur] call R3F_LOG_FNCT_definir_proprietaire_verrou;
											
											_objet setVariable ["R3F_LOG_est_deplace_par", _joueur, true];
											
											
											R3F_LOG_joueur_deplace_objet = _objet;
											
											if (_decharger) then
											{
												// Orienter l'objet en fonction de son profil
												if (((boundingBoxReal _objet select 1 select 1) - (boundingBoxReal _objet select 0 select 1)) != 0 && // Div par 0
													{
														((boundingBoxReal _objet select 1 select 0) - (boundingBoxReal _objet select 0 select 0)) > 3.2 &&
														((boundingBoxReal _objet select 1 select 0) - (boundingBoxReal _objet select 0 select 0)) /
														((boundingBoxReal _objet select 1 select 1) - (boundingBoxReal _objet select 0 select 1)) > 1.25
													}
												) then
												{R3F_LOG_deplace_dir_rel_objet = 90;} else {R3F_LOG_deplace_dir_rel_objet = 0;};
												
												// Calcul de la position relative, de sorte � �loigner l'objet suffisamment pour garder un bon champ de vision
												_pos_rel_objet_initial = [
													(boundingCenter _objet select 0) * cos R3F_LOG_deplace_dir_rel_objet - (boundingCenter _objet select 1) * sin R3F_LOG_deplace_dir_rel_objet,
													((-(boundingBoxReal _objet select 0 select 0) * sin R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 0) * sin R3F_LOG_deplace_dir_rel_objet)) +
													((-(boundingBoxReal _objet select 0 select 1) * cos R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 1) * cos R3F_LOG_deplace_dir_rel_objet)) +
													2 + 0.3 * (
														((boundingBoxReal _objet select 1 select 1)-(boundingBoxReal _objet select 0 select 1)) * abs sin R3F_LOG_deplace_dir_rel_objet +
														((boundingBoxReal _objet select 1 select 0)-(boundingBoxReal _objet select 0 select 0)) * abs cos R3F_LOG_deplace_dir_rel_objet
													),
													-(boundingBoxReal _objet select 0 select 2)
												];
												
												_elev_cam_initial = acos ((ATLtoASL positionCameraToWorld [0, 0, 1] select 2) - (ATLtoASL positionCameraToWorld [0, 0, 0] select 2));
												
												_pos_rel_objet_initial set [2, 0.1 + (_joueur selectionPosition "head" select 2) + (_pos_rel_objet_initial select 1) * tan (89 min (-89 max (90-_elev_cam_initial)))];
											}
											else
											{
												R3F_LOG_deplace_dir_rel_objet = (getDir _objet) - _dir_joueur;
												
												_pos_rel_objet_initial = _joueur worldToModel (_objet modelToWorld [0,0,0]);
												
												// Calcul de la position relative de l'objet, bas�e sur la position initiale, et s�curis�e pour ne pas que l'objet rentre dans le joueur lors de la rotation
												// L'ajout de ce calcul a �galement rendu inutile le test avec la fonction R3F_LOG_FNCT_unite_marche_dessus lors de la prise de l'objet
												_pos_rel_objet_initial = [
													_pos_rel_objet_initial select 0,
													(_pos_rel_objet_initial select 1) max
													(
														((-(boundingBoxReal _objet select 0 select 0) * sin R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 0) * sin R3F_LOG_deplace_dir_rel_objet)) +
														((-(boundingBoxReal _objet select 0 select 1) * cos R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 1) * cos R3F_LOG_deplace_dir_rel_objet)) +
														1.2
													),
													_pos_rel_objet_initial select 2
												];
												
												_elev_cam_initial = acos ((ATLtoASL positionCameraToWorld [0, 0, 1] select 2) - (ATLtoASL positionCameraToWorld [0, 0, 0] select 2));
											};
											R3F_LOG_deplace_distance_rel_objet = _pos_rel_objet_initial select 1;
											
											// D�termination du mode d'alignement initial en fonction du type d'objet, de ses dimensions, ...
											R3F_LOG_deplace_mode_alignement = switch (true) do
											{
												case !(_objet isKindOf "Static"): {"sol"};
												// Objet statique allong�
												case (
														((boundingBoxReal _objet select 1 select 1) - (boundingBoxReal _objet select 0 select 1)) != 0 && // Div par 0
														{
															((boundingBoxReal _objet select 1 select 0) - (boundingBoxReal _objet select 0 select 0)) /
															((boundingBoxReal _objet select 1 select 1) - (boundingBoxReal _objet select 0 select 1)) > 1.75
														}
													): {"pente"};
												// Objet statique carr� ou peu allong�
												default {"horizon"};
											};
											
											// On demande � ce que l'objet soit local au joueur pour r�duire les latences (setDir, attachTo p�riodique)
											if (!local _objet) then
											{
												private ["_time_demande_setOwner"];
												_time_demande_setOwner = time;
												[_objet, "setOwnerTo", _joueur] call R3F_LOG_FNCT_exec_commande_MP;
												waitUntil {local _objet || time > _time_demande_setOwner + 1.5};
											};
											
											// On pr�vient tout le monde qu'un nouveau objet va �tre d�place pour ingorer les �ventuelles blessures
											R3F_LOG_PV_nouvel_objet_en_deplacement = _objet;
											publicVariable "R3F_LOG_PV_nouvel_objet_en_deplacement";
											["R3F_LOG_PV_nouvel_objet_en_deplacement", R3F_LOG_PV_nouvel_objet_en_deplacement] call R3F_LOG_FNCT_PVEH_nouvel_objet_en_deplacement;
											
											// M�morisation de l'arme courante et de son mode de tir
											_arme_courante = currentWeapon _joueur;
											_muzzle_courant = currentMuzzle _joueur;
											_mode_muzzle_courant = currentWeaponMode _joueur;
											
											// Sous l'eau on n'a pas le choix de l'arme
											if (!surfaceIsWater getPos _joueur) then
											{
												// Prise du PA si le joueur en a un
												if (handgunWeapon _joueur != "") then
												{
													_restaurer_arme = false;
													for [{_idx_muzzle = 0}, {currentWeapon _joueur != handgunWeapon _joueur}, {_idx_muzzle = _idx_muzzle+1}] do
													{
														_joueur action ["SWITCHWEAPON", _joueur, _joueur, _idx_muzzle];
													};
												}
												// Sinon pas d'arme dans les mains
												else
												{
													_restaurer_arme = true;
													_joueur action ["SWITCHWEAPON", _joueur, _joueur, 99999];
												};
											} else {_restaurer_arme = false;};
											
											sleep 0.5;
											
											// V�rification qu'on ai bien obtenu la main (conflit d'acc�s simultan�s)
											if (_objet getVariable "R3F_LOG_est_deplace_par" == _joueur && isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull])) then
											{
												R3F_LOG_deplace_force_setVector = false; // Mettre � true pour forcer la r�-otientation de l'objet, en for�ant les filtres anti-flood
												R3F_LOG_deplace_force_attachTo = false; // Mettre � true pour forcer le repositionnement de l'objet, en for�ant les filtres anti-flood
												
												// Ajout des actions de gestion de l'orientation
												_action_relacher = _joueur addAction [("<t color=""#ee0000"">" + format [STR_R3F_LOG_action_relacher_objet, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")] + "</t>"), {_this call R3F_LOG_FNCT_objet_relacher}, nil, 10, true, true];
												_action_aligner_pente = _joueur addAction [("<t color=""#00eeff"">" + STR_R3F_LOG_action_aligner_pente + "</t>"), {R3F_LOG_deplace_mode_alignement = "pente"; R3F_LOG_deplace_force_setVector = true;}, nil, 6, false, true, "", "R3F_LOG_deplace_mode_alignement != ""pente"""];
												_action_aligner_sol = _joueur addAction [("<t color=""#00eeff"">" + STR_R3F_LOG_action_aligner_sol + "</t>"), {R3F_LOG_deplace_mode_alignement = "sol"; R3F_LOG_deplace_force_setVector = true;}, nil, 6, false, true, "", "R3F_LOG_deplace_mode_alignement != ""sol"""];
												_action_aligner_horizon = _joueur addAction [("<t color=""#00eeff"">" + STR_R3F_LOG_action_aligner_horizon + "</t>"), {R3F_LOG_deplace_mode_alignement = "horizon"; R3F_LOG_deplace_force_setVector = true;}, nil, 6, false, true, "", "R3F_LOG_deplace_mode_alignement != ""horizon"""];
												_action_tourner = _joueur addAction [("<t color=""#00eeff"">" + STR_R3F_LOG_action_tourner + "</t>"), {R3F_LOG_deplace_dir_rel_objet = R3F_LOG_deplace_dir_rel_objet + 12; R3F_LOG_deplace_force_setVector = true;}, nil, 6, false, false];
												_action_rapprocher = _joueur addAction [("<t color=""#00eeff"">" + STR_R3F_LOG_action_rapprocher + "</t>"), {R3F_LOG_deplace_distance_rel_objet = R3F_LOG_deplace_distance_rel_objet - 0.4; R3F_LOG_deplace_force_attachTo = true;}, nil, 6, false, false];
												
												// Rel�cher l'objet d�s que le joueur tire. Le detach sert � rendre l'objet solide pour ne pas tirer au travers.
												_idx_eh_fired = _joueur addEventHandler ["Fired", {if (!surfaceIsWater getPos player) then {detach R3F_LOG_joueur_deplace_objet; R3F_LOG_joueur_deplace_objet = objNull;};}];
												
												// Gestion des �v�nements KeyDown et KeyUp pour faire tourner l'objet avec les touches X/C
												R3F_LOG_joueur_deplace_key_rotation = "";
												R3F_LOG_joueur_deplace_key_translation = "";
												_time_derniere_rotation = 0;
												_time_derniere_translation = 0;
												_idx_eh_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown",
												{
													switch (_this select 1) do
													{
														case 45: {R3F_LOG_joueur_deplace_key_rotation = "X"; true};
														case 46: {R3F_LOG_joueur_deplace_key_rotation = "C"; true};
														case 33: {R3F_LOG_joueur_deplace_key_translation = "F"; true};
														case 19: {R3F_LOG_joueur_deplace_key_translation = "R"; true};
														default {false};
													}
												}];
												_idx_eh_keyUp = (findDisplay 46) displayAddEventHandler ["KeyUp",
												{
													switch (_this select 1) do
													{
														case 45: {R3F_LOG_joueur_deplace_key_rotation = ""; true};
														case 46: {R3F_LOG_joueur_deplace_key_rotation = ""; true};
														case 33: {R3F_LOG_joueur_deplace_key_translation = ""; true};
														case 19: {R3F_LOG_joueur_deplace_key_translation = ""; true};
														default {false};
													}
												}];
												
												// Initialisation de l'historique anti-flood
												_offset_hauteur = _pos_rel_objet_initial select 2;
												_dernier_offset_hauteur = _offset_hauteur + 100;
												_avant_dernier_offset_hauteur = _dernier_offset_hauteur + 100;
												_dernier_pos_rel_objet = _pos_rel_objet_initial;
												_avant_dernier_pos_rel_objet = _dernier_pos_rel_objet;
												_vec_dir_rel = [sin R3F_LOG_deplace_dir_rel_objet, cos R3F_LOG_deplace_dir_rel_objet, 0];
												_vec_dir_up = [_vec_dir_rel, [0, 0, 1]];
												_dernier_vec_dir_up = [[0,0,0] vectorDiff (_vec_dir_up select 0), _vec_dir_up select 1];
												_avant_dernier_vec_dir_up = [_dernier_vec_dir_up select 0, [0,0,0] vectorDiff (_dernier_vec_dir_up select 1)];
												
												_objet attachTo [_joueur, _pos_rel_objet_initial];
												
												// Si �chec transfert local, mode d�grad� : on conserve la direction de l'objet par rapport au joueur
												if (!local _objet) then {[_objet, "setDir", R3F_LOG_deplace_dir_rel_objet] call R3F_LOG_FNCT_exec_commande_MP;};
												
												R3F_LOG_mutex_local_verrou = false;
												
												// Boucle de gestion des �v�nements et du positionnement pendant le d�placement
												while {!isNull R3F_LOG_joueur_deplace_objet && _objet getVariable "R3F_LOG_est_deplace_par" == _joueur && alive _joueur} do
												{
													// Gestion de l'orientation de l'objet en fonction du terrain
													if (local _objet) then
													{
														// En fonction de la touche appuy�e (X/C), on fait pivoter l'objet
														if (R3F_LOG_joueur_deplace_key_rotation == "X" || R3F_LOG_joueur_deplace_key_rotation == "C") then
														{
															// Un cycle sur deux maxi (flood) on modifie de l'angle
															if (time - _time_derniere_rotation > 0.045) then
															{
																if (R3F_LOG_joueur_deplace_key_rotation == "X") then {R3F_LOG_deplace_dir_rel_objet = R3F_LOG_deplace_dir_rel_objet + 4;};
																if (R3F_LOG_joueur_deplace_key_rotation == "C") then {R3F_LOG_deplace_dir_rel_objet = R3F_LOG_deplace_dir_rel_objet - 4;};
																
																R3F_LOG_deplace_force_setVector = true;
																_time_derniere_rotation = time;
															};
														} else {_time_derniere_rotation = 0;};
														
														_vec_dir_rel = [sin R3F_LOG_deplace_dir_rel_objet, cos R3F_LOG_deplace_dir_rel_objet, 0];
														
														// Conversion de la normale du sol dans le rep�re du joueur car l'objet est attachTo
														_normale_surface = surfaceNormal getPos _objet;
														_normale_surface = (player worldToModel ASLtoATL (_normale_surface vectorAdd getPosASL player)) vectorDiff (player worldToModel ASLtoATL (getPosASL player));
														
														// Red�finir l'orientation en fonction du terrain et du mode d'alignement
														_vec_dir_up = switch (R3F_LOG_deplace_mode_alignement) do
														{
															case "sol": {[[-cos R3F_LOG_deplace_dir_rel_objet, sin R3F_LOG_deplace_dir_rel_objet, 0] vectorCrossProduct _normale_surface, _normale_surface]};
															case "pente": {[_vec_dir_rel, _normale_surface]};
															default {[_vec_dir_rel, [0, 0, 1]]};
														};
														
														// On r�-oriente l'objet, lorsque n�cessaire (pas de flood)
														if (R3F_LOG_deplace_force_setVector ||
															(
																// Vecteur dir suffisamment diff�rent du dernier
																(_vec_dir_up select 0) vectorCos (_dernier_vec_dir_up select 0) < 0.999 &&
																// et diff�rent de l'avant dernier (pas d'oscillations sans fin)
																vectorMagnitude ((_vec_dir_up select 0) vectorDiff (_avant_dernier_vec_dir_up select 0)) > 1E-9
															) ||
															(
																// Vecteur up suffisamment diff�rent du dernier
																(_vec_dir_up select 1) vectorCos (_dernier_vec_dir_up select 1) < 0.999 &&
																// et diff�rent de l'avant dernier (pas d'oscillations sans fin)
																vectorMagnitude ((_vec_dir_up select 1) vectorDiff (_avant_dernier_vec_dir_up select 1)) > 1E-9
															)
														) then
														{
															_objet setVectorDirAndUp _vec_dir_up;
															
															_avant_dernier_vec_dir_up = _dernier_vec_dir_up;
															_dernier_vec_dir_up = _vec_dir_up;
															
															R3F_LOG_deplace_force_setVector = false;
														};
													};
													
													sleep 0.015;
													
													// En fonction de la touche appuy�e (F/R), on fait avancer ou reculer l'objet
													if (R3F_LOG_joueur_deplace_key_translation == "F" || R3F_LOG_joueur_deplace_key_translation == "R") then
													{
														// Un cycle sur deux maxi (flood) on modifie de l'angle
														if (time - _time_derniere_translation > 0.045) then
														{
															if (R3F_LOG_joueur_deplace_key_translation == "F") then
															{
																R3F_LOG_deplace_distance_rel_objet = R3F_LOG_deplace_distance_rel_objet - 0.075;
															}
															else
															{
																R3F_LOG_deplace_distance_rel_objet = R3F_LOG_deplace_distance_rel_objet + 0.075;
															};
															
															// Borne min-max de la distance
															R3F_LOG_deplace_distance_rel_objet = R3F_LOG_deplace_distance_rel_objet min (
																	(
																		vectorMagnitude [
																			(-(boundingBoxReal _objet select 0 select 0)) max (boundingBoxReal _objet select 1 select 0),
																			(-(boundingBoxReal _objet select 0 select 1)) max (boundingBoxReal _objet select 1 select 1),
																			0
																		] + 2
																	) max (_pos_rel_objet_initial select 1)
															) max (
																(
																	((-(boundingBoxReal _objet select 0 select 0) * sin R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 0) * sin R3F_LOG_deplace_dir_rel_objet)) +
																	((-(boundingBoxReal _objet select 0 select 1) * cos R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 1) * cos R3F_LOG_deplace_dir_rel_objet)) +
																	1.2
																)
															);
															
															R3F_LOG_deplace_force_attachTo = true;
															_time_derniere_translation = time;
														};
													} else {_time_derniere_translation = 0;};
													
													// Calcul de la position relative de l'objet, bas�e sur la position initiale, et s�curis�e pour ne pas que l'objet rentre dans le joueur lors de la rotation
													// L'ajout de ce calcul a �galement rendu inutile le test avec la fonction R3F_LOG_FNCT_unite_marche_dessus lors de la prise de l'objet
													_pos_rel_objet = [
														_pos_rel_objet_initial select 0,
														R3F_LOG_deplace_distance_rel_objet max
														(
															((-(boundingBoxReal _objet select 0 select 0) * sin R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 0) * sin R3F_LOG_deplace_dir_rel_objet)) +
															((-(boundingBoxReal _objet select 0 select 1) * cos R3F_LOG_deplace_dir_rel_objet) max (-(boundingBoxReal _objet select 1 select 1) * cos R3F_LOG_deplace_dir_rel_objet)) +
															1.2
														),
														_pos_rel_objet_initial select 2
													];
													
													_elev_cam = acos ((ATLtoASL positionCameraToWorld [0, 0, 1] select 2) - (ATLtoASL positionCameraToWorld [0, 0, 0] select 2));
													_offset_hauteur_cam = (vectorMagnitude [_pos_rel_objet select 0, _pos_rel_objet select 1, 0]) * tan (89 min (-89 max (_elev_cam_initial - _elev_cam)));
													_offset_bounding_center = ((_objet modelToWorld boundingCenter _objet) select 2) - ((_objet modelToWorld [0,0,0]) select 2);
													
													// Calcul de la hauteur de l'objet en fonction de l'�l�vation de la cam�ra et du terrain
													if (_objet isKindOf "Static") then
													{
														// En mode horizontal, la plage d'offset terrain est calcul�e de sorte � conserver au moins un des quatre coins inf�rieurs en contact avec le sol
														if (R3F_LOG_deplace_mode_alignement == "horizon") then
														{
															_hauteur_terrain_min_max_objet = [_objet] call R3F_LOG_FNCT_3D_get_hauteur_terrain_min_max_objet;
															_offset_hauteur_terrain_min = (_hauteur_terrain_min_max_objet select 0) - (getPosASL _joueur select 2) + _offset_bounding_center;
															_offset_hauteur_terrain_max = (_hauteur_terrain_min_max_objet select 1) - (getPosASL _joueur select 2) + _offset_bounding_center;
															
															// On autorise un l�ger enterrement jusqu'� 40% de la hauteur de l'objet
															_offset_hauteur_terrain_min = _offset_hauteur_terrain_min min (_offset_hauteur_terrain_max - 0.4 * ((boundingBoxReal _objet select 1 select 2) - (boundingBoxReal _objet select 0 select 2)) / (_dernier_vec_dir_up select 1 select 2));
														}
														// Dans les autres modes d'alignement, on autorise un l�ger enterrement jusqu'� 40% de la hauteur de l'objet
														else
														{
															_offset_hauteur_terrain_max = getTerrainHeightASL (getPos _objet) - (getPosASL _joueur select 2) + _offset_bounding_center;
															_offset_hauteur_terrain_min = _offset_hauteur_terrain_max - 0.4 * ((boundingBoxReal _objet select 1 select 2) - (boundingBoxReal _objet select 0 select 2)) / (_dernier_vec_dir_up select 1 select 2);
														};
														
														if (R3F_LOG_CFG_no_gravity_objects_can_be_set_in_height_over_ground) then
														{
															_offset_hauteur = _offset_hauteur_terrain_min max ((-1.4 + _offset_bounding_center) max ((2.75 + _offset_bounding_center) min ((_pos_rel_objet select 2) + _offset_hauteur_cam)));
														}
														else
														{
															_offset_hauteur = _offset_hauteur_terrain_min max (_offset_hauteur_terrain_max min ((_pos_rel_objet select 2) + _offset_hauteur_cam)) + (getPosATL _joueur select 2);
														};
													}
													else
													{
														_offset_hauteur_terrain = getTerrainHeightASL (getPos _objet) - (getPosASL _joueur select 2) + _offset_bounding_center;
														_offset_hauteur = _offset_hauteur_terrain max ((-1.4 + _offset_bounding_center) max ((300 + _offset_bounding_center) min ((_pos_rel_objet select 2) + _offset_hauteur_cam)));
													};
													
													// On repositionne l'objet par rapport au joueur, lorsque n�cessaire (pas de flood)
													if (R3F_LOG_deplace_force_attachTo ||
														(
															// Positionnement en hauteur suffisamment diff�rent
															abs (_offset_hauteur - _dernier_offset_hauteur) > 0.025 &&
															// et diff�rent de l'avant dernier (pas d'oscillations sans fin)
															abs (_offset_hauteur - _avant_dernier_offset_hauteur) > 1E-9
														) ||
														(
															// Position relative suffisamment diff�rente
															vectorMagnitude (_pos_rel_objet vectorDiff _dernier_pos_rel_objet) > 0.025 &&
															// et diff�rente de l'avant dernier (pas d'oscillations sans fin)
															vectorMagnitude (_pos_rel_objet vectorDiff _avant_dernier_pos_rel_objet) > 1E-9
														)
													) then
													{
														_objet attachTo [_joueur, [
															_pos_rel_objet select 0,
															_pos_rel_objet select 1,
															_offset_hauteur
														]];
														
														_avant_dernier_offset_hauteur = _dernier_offset_hauteur;
														_dernier_offset_hauteur = _offset_hauteur;
														
														_avant_dernier_pos_rel_objet = _dernier_pos_rel_objet;
														_dernier_pos_rel_objet = _pos_rel_objet;
														
														R3F_LOG_deplace_force_attachTo = false;
													};
													
													// On interdit de monter dans un v�hicule tant que l'objet est port�
													if (vehicle _joueur != _joueur) then
													{
														systemChat STR_R3F_LOG_ne_pas_monter_dans_vehicule;
														_joueur action ["GetOut", vehicle _joueur];
														_joueur action ["Eject", vehicle _joueur];
														sleep 1;
													};
													
													// Le joueur change d'arme, on stoppe le d�placement et on ne reprendra pas l'arme initiale
													if (currentWeapon _joueur != "" && currentWeapon _joueur != handgunWeapon _joueur && !surfaceIsWater getPos _joueur) then
													{
														R3F_LOG_joueur_deplace_objet = objNull;
														_restaurer_arme = false;
													};
													
													sleep 0.015;
												};
												
												// Si l'objet est relach� (et donc pas charg� dans un v�hicule)
												if (isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull])) then
												{
													// L'objet n'est plus port�, on le repose. Le l�ger setVelocity vers le haut sert � defreezer les objets qui pourraient flotter.
													// TODO gestion collision, en particulier si le joueur meurt
													[_objet, "detachSetVelocity", [0, 0, 0.1]] call R3F_LOG_FNCT_exec_commande_MP;
												};
												
												_joueur removeEventHandler ["Fired", _idx_eh_fired];
												(findDisplay 46) displayRemoveEventHandler ["KeyDown", _idx_eh_keyDown];
												(findDisplay 46) displayRemoveEventHandler ["KeyUp", _idx_eh_keyUp];
												
												_joueur removeAction _action_relacher;
												_joueur removeAction _action_aligner_pente;
												_joueur removeAction _action_aligner_sol;
												_joueur removeAction _action_aligner_horizon;
												_joueur removeAction _action_tourner;
												_joueur removeAction _action_rapprocher;
												
												_objet setVariable ["R3F_LOG_est_deplace_par", objNull, true];
											}
											// Echec d'obtention de l'objet
											else
											{
												_objet setVariable ["R3F_LOG_est_deplace_par", objNull, true];
												R3F_LOG_mutex_local_verrou = false;
											};
											
											R3F_LOG_joueur_deplace_objet = objNull;
											
											// Reprise de l'arme et restauration de son mode de tir, si n�cessaire
											if (alive _joueur && !surfaceIsWater getPos _joueur && _restaurer_arme) then
											{
												for [{_idx_muzzle = 0},
													{currentWeapon _joueur != _arme_courante ||
													currentMuzzle _joueur != _muzzle_courant ||
													currentWeaponMode _joueur != _mode_muzzle_courant},
													{_idx_muzzle = _idx_muzzle+1}] do
												{
													_joueur action ["SWITCHWEAPON", _joueur, _joueur, _idx_muzzle];
												};
											};
											
											sleep 5; // D�lai de 5 secondes pour attendre la chute/stabilisation
											if (!isNull _objet) then
											{
												if (isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull]) ||
													{(!alive (_objet getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet getVariable "R3F_LOG_est_deplace_par"))}
												) then
												{
													R3F_LOG_PV_fin_deplacement_objet = _objet;
													publicVariable "R3F_LOG_PV_fin_deplacement_objet";
													["R3F_LOG_PV_fin_deplacement_objet", R3F_LOG_PV_fin_deplacement_objet] call R3F_LOG_FNCT_PVEH_fin_deplacement_objet;
												};
											};
										}
										else
										{
											hintC format [STR_R3F_LOG_joueur_dans_objet, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
											R3F_LOG_mutex_local_verrou = false;
										};
									}
									else
									{
										hintC format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
										R3F_LOG_mutex_local_verrou = false;
									};
								}
								else
								{
									hintC format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
									R3F_LOG_mutex_local_verrou = false;
								};
							};
						};
						
						R3F_LOG_FNCT_heliporteur_heliporter = 
						{
							/**
							* Héliporte un objet avec un héliporteur
							* 
							* @param 0 l'héliporteur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_heliporteur", "_objet"];
								
								_heliporteur = _this select 0;
								
								// Recherche de l'objet à héliporter
								_objet = objNull;
								{
									if (
										(_x getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select R3F_LOG_IDX_can_be_lifted) &&
										_x != _heliporteur && !(_x getVariable "R3F_LOG_disabled") &&
										((getPosASL _heliporteur select 2) - (getPosASL _x select 2) > 2 && (getPosASL _heliporteur select 2) - (getPosASL _x select 2) < 15)
									) exitWith {_objet = _x;};
								} forEach (nearestObjects [_heliporteur, ["All"], 20]);
								
								if (!isNull _objet) then
								{
									if !(_objet getVariable "R3F_LOG_disabled") then
									{
										if ((isNull (_objet getVariable "R3F_LOG_est_deplace_par") || (!alive (_objet getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet getVariable "R3F_LOG_est_deplace_par")))) then
										{
											// Finalement on autorise l'héliport d'un véhicule avec du personnel à bord
											//if (count crew _objet == 0 || getNumber (configFile >> "CfgVehicles" >> (typeOf _objet) >> "isUav") == 1) then
											//{
												// Ne pas héliporter quelque chose qui remorque autre chose
												//if (isNull (_objet getVariable ["R3F_LOG_remorque", objNull])) then
												//{
													private ["_duree", "_ctrl_titre", "_ctrl_fond", "_ctrl_jauge", "_time_debut", "_attente_valide", "_pas_de_hook"];
													
													_heliporteur setVariable ["R3F_LOG_heliporte", _objet, true];
													_objet setVariable ["R3F_LOG_est_transporte_par", _heliporteur, true];
													
													// Attacher sous l'héliporteur au ras du sol
													_objet attachTo [_heliporteur, [
														0,
														0,
														(boundingBoxReal _heliporteur select 0 select 2) - (boundingBoxReal _objet select 0 select 2) - (getPos _heliporteur select 2) + 0.5
													]];
													
													// Ré-aligner dans le sens de la longueur si besoin
													if (((boundingBoxReal _objet select 1 select 0) - (boundingBoxReal _objet select 0 select 0)) >
														((boundingBoxReal _objet select 1 select 1) - (boundingBoxReal _objet select 0 select 1))) then
													{
														[_objet, "setDir", 90] call R3F_LOG_FNCT_exec_commande_MP;
													};
													
													systemChat format [STR_R3F_LOG_action_heliporter_fait, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
													
													// Boucle de contrôle pendant l'héliportage
													[_heliporteur, _objet] spawn
													{
														private ["_heliporteur", "_objet", "_a_ete_souleve"];
														
														_heliporteur = _this select 0;
														_objet = _this select 1;
														
														
														while {_heliporteur getVariable "R3F_LOG_heliporte" == _objet} do
														{
															
															
															// Si l'hélico se fait détruire ou si l'objet héliporté entre en contact avec le sol, on largue l'objet
															if (!alive _heliporteur) exitWith
															{
																_heliporteur setVariable ["R3F_LOG_heliporte", objNull, true];
																_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
																
																// Détacher l'objet et lui appliquer la vitesse de l'héliporteur (inertie)
																[_objet, "detachSetVelocity", velocity _heliporteur] call R3F_LOG_FNCT_exec_commande_MP;
																
																systemChat format [STR_R3F_LOG_action_heliport_larguer_fait, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
															};
															
															sleep 0.1;
														};
													};

												//}
												//else
												//{
												//	systemChat format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
												//};
											//}
											//else
											//{
											//	systemChat format [STR_R3F_LOG_joueur_dans_objet, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
											//};
										}
										else
										{
											systemChat format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
										};
									};
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};

						};
						R3F_LOG_FNCT_heliporteur_larguer = 
						{
							/**
							* Larguer un objet en train d'�tre h�liport�
							* 
							* @param 0 l'h�liporteur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_heliporteur", "_objet"];
								
								_heliporteur = _this select 0;
								_objet = _heliporteur getVariable "R3F_LOG_heliporte";
								
								_heliporteur setVariable ["R3F_LOG_heliporte", objNull, true];
								_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
								
								// D�tacher l'objet et lui appliquer la vitesse de l'h�liporteur (inertie)
								[_objet, "detachSetVelocity", velocity _heliporteur] call R3F_LOG_FNCT_exec_commande_MP;
								
								systemChat format [STR_R3F_LOG_action_heliport_larguer_fait, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_heliporteur_init = 
						{
							/**
							* Initialise un v�hicule h�liporteur
							* 
							* @param 0 l'h�liporteur
							*/

							private ["_heliporteur"];

							_heliporteur = _this select 0;

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_heliporteur getVariable "R3F_LOG_heliporte"}) then
							{
								_heliporteur setVariable ["R3F_LOG_heliporte", objNull, false];
							};

							_heliporteur addAction [("<t color=""#00dd00"">" + STR_R3F_LOG_action_heliporter + "</t>"), {_this call R3F_LOG_FNCT_heliporteur_heliporter}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_heliporter_valide"];

							_heliporteur addAction [("<t color=""#00dd00"">" + STR_R3F_LOG_action_heliport_larguer + "</t>"), {_this call R3F_LOG_FNCT_heliporteur_larguer}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_heliport_larguer_valide"];
						};
						
						R3F_LOG_FNCT_remorqueur_detacher =
						{
							/**
							* D�tacher un objet d'un v�hicule
							* 
							* @param 0 l'objet � d�tacher
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_remorqueur", "_objet"];
								
								_objet = _this select 0;
								_remorqueur = _objet getVariable "R3F_LOG_est_transporte_par";
								
								// Ne pas permettre de d�crocher un objet s'il est en fait h�liport�
								if (_remorqueur getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_tow) then
								{
									[_objet, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
									
									_remorqueur setVariable ["R3F_LOG_remorque", objNull, true];
									_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
									
									// Le l�ger setVelocity vers le haut sert � defreezer les objets qui pourraient flotter.
									[_objet, "detachSetVelocity", [0, 0, 0.1]] call R3F_LOG_FNCT_exec_commande_MP;
									
									
									
								}
								else
								{
									hintC STR_R3F_LOG_action_detacher_impossible_pour_ce_vehicule;
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_remorqueur_remorquer_deplace =
						{
							/**
							* Remorque l'objet d�plac� par le joueur avec un remorqueur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_objet", "_remorqueur", "_offset_attach_y"];
								
								_objet = R3F_LOG_joueur_deplace_objet;
								_remorqueur = [_objet, 5] call R3F_LOG_FNCT_3D_cursorTarget_virtuel;
								
								if (!isNull _remorqueur && {
									_remorqueur getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select R3F_LOG_IDX_can_tow &&
									alive _remorqueur && (true || isNull (_remorqueur getVariable "R3F_LOG_remorque")) && (vectorMagnitude velocity _remorqueur < 6) && !(_remorqueur getVariable "R3F_LOG_disabled")
								}) then
								{
									[_remorqueur, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
									
									_remorqueur setVariable ["R3F_LOG_remorque", _objet, true];
									_objet setVariable ["R3F_LOG_est_transporte_par", _remorqueur, true];
									
									// On place le joueur sur le c�t� du v�hicule en fonction qu'il se trouve � sa gauche ou droite
									if ((_remorqueur worldToModel (player modelToWorld [0,0,0])) select 0 > 0) then
									{
										player attachTo [_remorqueur, [
											(boundingBoxReal _remorqueur select 1 select 0) + 0.5,
											(boundingBoxReal _remorqueur select 0 select 1),
											(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal player select 0 select 2)
										]];
										
										player setDir 270;
									}
									else
									{
										player attachTo [_remorqueur, [
											(boundingBoxReal _remorqueur select 0 select 0) - 0.5,
											(boundingBoxReal _remorqueur select 0 select 1),
											(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal player select 0 select 2)
										]];
										
										player setDir 90;
									};
									
									// Faire relacher l'objet au joueur
									R3F_LOG_joueur_deplace_objet = objNull;
									
									
									
									// Quelques corrections visuelles pour des classes sp�cifiques
									if (typeOf _remorqueur == "B_Truck_01_mover_F") then {_offset_attach_y = 1.0;}
									else {_offset_attach_y = 0.2;};
									
									// Attacher � l'arri�re du v�hicule au ras du sol
									_objet attachTo [_remorqueur, [
										(boundingCenter _objet select 0),
										(boundingBoxReal _remorqueur select 0 select 1) + (boundingBoxReal _objet select 0 select 1) + _offset_attach_y,
										(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal _objet select 0 select 2)
									]];
									
									detach player;
									
									// Si l'objet est une arme statique, on corrige l'orientation en fonction de la direction du canon
									if (_objet isKindOf "StaticWeapon") then
									{
										private ["_azimut_canon"];
										
										_azimut_canon = ((_objet weaponDirection (weapons _objet select 0)) select 0) atan2 ((_objet weaponDirection (weapons _objet select 0)) select 1);
										
										// Seul le D30 a le canon pointant vers le v�hicule
										if !(_objet isKindOf "D30_Base") then // All in Arma
										{
											_azimut_canon = _azimut_canon + 180;
										};
										
										[_objet, "setDir", (getDir _objet)-_azimut_canon] call R3F_LOG_FNCT_exec_commande_MP;
									};
									
									sleep 7;
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_remorqueur_remorquer_direct =
						{
							/**
							* Remorque l'objet point� au v�hicule remorqueur valide le plus proche
							* 
							* @param 0 l'objet � remorquer
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_objet", "_remorqueur", "_offset_attach_y"];
								
								_objet = _this select 0;
								
								// Recherche du remorqueur valide le plus proche
								_remorqueur = objNull;
								{
									if (
										_x != _objet && (_x getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select R3F_LOG_IDX_can_tow) &&
										alive _x && isNull (_x getVariable "R3F_LOG_est_transporte_par") &&
										isNull (_x getVariable "R3F_LOG_remorque") && (vectorMagnitude velocity _x < 6) &&
										!([_x, player] call R3F_LOG_FNCT_objet_est_verrouille) && !(_x getVariable "R3F_LOG_disabled") &&
										{
											private ["_delta_pos"];
											
											_delta_pos =
											(
												_objet modelToWorld
												[
													boundingCenter _objet select 0,
													boundingBoxReal _objet select 1 select 1,
													boundingBoxReal _objet select 0 select 2
												]
											) vectorDiff (
												_x modelToWorld
												[
													boundingCenter _x select 0,
													boundingBoxReal _x select 0 select 1,
													boundingBoxReal _x select 0 select 2
												]
											);
											
											// L'arri�re du remorqueur est proche de l'avant de l'objet point�
											abs (_delta_pos select 0) < 3 && abs (_delta_pos select 1) < 5
										}
									) exitWith {_remorqueur = _x;};
								} forEach (nearestObjects [_objet, ["All"], 30]);
								
								if (!isNull _remorqueur) then
								{
									if (isNull (_objet getVariable "R3F_LOG_est_transporte_par") && (isNull (_objet getVariable "R3F_LOG_est_deplace_par") || (!alive (_objet getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet getVariable "R3F_LOG_est_deplace_par")))) then
									{
										[_remorqueur, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
										
										_remorqueur setVariable ["R3F_LOG_remorque", _objet, true];
										_objet setVariable ["R3F_LOG_est_transporte_par", _remorqueur, true];
										
										// On place le joueur sur le c�t� du v�hicule en fonction qu'il se trouve � sa gauche ou droite
										if ((_remorqueur worldToModel (player modelToWorld [0,0,0])) select 0 > 0) then
										{
											player attachTo [_remorqueur, [
												(boundingBoxReal _remorqueur select 1 select 0) + 0.5,
												(boundingBoxReal _remorqueur select 0 select 1),
												(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal player select 0 select 2)
											]];
											
											player setDir 270;
										}
										else
										{
											player attachTo [_remorqueur, [
												(boundingBoxReal _remorqueur select 0 select 0) - 0.5,
												(boundingBoxReal _remorqueur select 0 select 1),
												(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal player select 0 select 2)
											]];
											
											player setDir 90;
										};
										
										
										// Quelques corrections visuelles pour des classes sp�cifiques
										if (typeOf _remorqueur == "B_Truck_01_mover_F") then {_offset_attach_y = 1.0;}
										else {_offset_attach_y = 0.2;};
										
										// Attacher � l'arri�re du v�hicule au ras du sol
										_objet attachTo [_remorqueur, [
											(boundingCenter _objet select 0),
											(boundingBoxReal _remorqueur select 0 select 1) + (boundingBoxReal _objet select 0 select 1) + _offset_attach_y,
											(boundingBoxReal _remorqueur select 0 select 2) - (boundingBoxReal _objet select 0 select 2)
										]];
										
										R3F_LOG_objet_selectionne = objNull;
										
										detach player;
										
										// Si l'objet est une arme statique, on corrige l'orientation en fonction de la direction du canon
										if (_objet isKindOf "StaticWeapon") then
										{
											private ["_azimut_canon"];
											
											_azimut_canon = ((_objet weaponDirection (weapons _objet select 0)) select 0) atan2 ((_objet weaponDirection (weapons _objet select 0)) select 1);
											
											// Seul le D30 a le canon pointant vers le v�hicule
											if !(_objet isKindOf "D30_Base") then // All in Arma
											{
												_azimut_canon = _azimut_canon + 180;
											};
											
											[_objet, "setDir", (getDir _objet)-_azimut_canon] call R3F_LOG_FNCT_exec_commande_MP;
										};
										
										sleep 7;
									}
									else
									{
										hintC format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
									};
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};
						
						R3F_LOG_FNCT_remorqueur_init = 
						{
							/**
							* Initialise un v�hicule remorqueur
							* 
							* @param 0 le remorqueur
							*/

							private ["_remorqueur"];

							_remorqueur = _this select 0;

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_remorqueur getVariable "R3F_LOG_remorque"}) then
							{
								_remorqueur setVariable ["R3F_LOG_remorque", objNull, false];
							};

							_remorqueur addAction [("<t color=""#00dd00"">" + STR_R3F_LOG_action_remorquer_deplace + "</t>"), {_this call R3F_LOG_FNCT_remorqueur_remorquer_deplace}, nil, 7, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_joueur_deplace_objet != _target && R3F_LOG_action_remorquer_deplace_valide"];
						};
						
						R3F_LOG_FNCT_transporteur_charger_deplace =
						{
							/**
							* Charger l'objet d�plac� par le joueur dans un transporteur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_objet", "_transporteur"];
								
								_objet = R3F_LOG_joueur_deplace_objet;
								_transporteur = [_objet, 5] call R3F_LOG_FNCT_3D_cursorTarget_virtuel;
								
								if (!isNull _transporteur && {
									_transporteur getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select R3F_LOG_IDX_can_transport_cargo &&
									alive _transporteur && (vectorMagnitude velocity _transporteur < 6) && !(_transporteur getVariable "R3F_LOG_disabled") &&
									(abs ((getPosASL _transporteur select 2) - (getPosASL player select 2)) < 2.5)
								}) then
								{
									if (isNull (_objet getVariable ["R3F_LOG_remorque", objNull])) then
									{
										private ["_objets_charges", "_chargement", "_cout_chargement_objet"];
										
										_chargement = [_transporteur] call R3F_LOG_FNCT_calculer_chargement_vehicule;
										_cout_chargement_objet = _objet getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_be_transported_cargo_cout;
										
										// Si l'objet loge dans le v�hicule
										if ((_chargement select 0) + _cout_chargement_objet <= (_chargement select 1)) then
										{
											[_transporteur, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
											
											// On m�morise sur le r�seau le nouveau contenu du v�hicule
											_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];
											_objets_charges = _objets_charges + [_objet];
											_transporteur setVariable ["R3F_LOG_objets_charges", _objets_charges, true];
											
											_objet setVariable ["R3F_LOG_est_transporte_par", _transporteur, true];
											
											// Faire relacher l'objet au joueur
											R3F_LOG_joueur_deplace_objet = objNull;
											waitUntil {_objet getVariable "R3F_LOG_est_deplace_par" != player};
											
											_objet attachTo [R3F_LOG_PUBVAR_point_attache, [] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel];
											
											systemChat format [STR_R3F_LOG_action_charger_fait,
												getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName"),
												getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName")];
										}
										else
										{
											hintC STR_R3F_LOG_action_charger_pas_assez_de_place;
										};
									}
									else
									{
										hintC format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
									};
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_transporteur_charger_selection =
						{
							/**
							* Charger l'objet s�lectionn� (R3F_LOG_objet_selectionne) dans un transporteur
							* 
							* @param 0 le transporteur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_objet", "_transporteur"];
								
								_objet = R3F_LOG_objet_selectionne;
								_transporteur = _this select 0;
								
								if (!(isNull _objet) && !(_objet getVariable "R3F_LOG_disabled")) then
								{
									if (isNull (_objet getVariable "R3F_LOG_est_transporte_par") && (isNull (_objet getVariable "R3F_LOG_est_deplace_par") || (!alive (_objet getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet getVariable "R3F_LOG_est_deplace_par")))) then
									{
										if (isNull (_objet getVariable ["R3F_LOG_remorque", objNull])) then
										{
											if (count crew _objet >= 0 || getNumber (configFile >> "CfgVehicles" >> (typeOf _objet) >> "isUav") == 1) then
											{
												private ["_objets_charges", "_chargement", "_cout_chargement_objet"];
												
												_chargement = [_transporteur] call R3F_LOG_FNCT_calculer_chargement_vehicule;
												_cout_chargement_objet = _objet getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_be_transported_cargo_cout;
												
												// Si l'objet loge dans le v�hicule
												if ((_chargement select 0) + _cout_chargement_objet <= (_chargement select 1)) then
												{
													if (true || _objet distance _transporteur <= 30) then
													{
														[_transporteur, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
														
														// On m�morise sur le r�seau le nouveau contenu du v�hicule
														_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];
														_objets_charges = _objets_charges + [_objet];
														_transporteur setVariable ["R3F_LOG_objets_charges", _objets_charges, true];
														
														_objet setVariable ["R3F_LOG_est_transporte_par", _transporteur, true];
														
														systemChat STR_R3F_LOG_action_charger_en_cours;
														
														sleep 2;
														
														// Gestion conflit d'acc�s
														if (_objet getVariable "R3F_LOG_est_transporte_par" == _transporteur && _objet in (_transporteur getVariable "R3F_LOG_objets_charges")) then
														{
															_objet attachTo [R3F_LOG_PUBVAR_point_attache, [] call R3F_LOG_FNCT_3D_tirer_position_degagee_ciel];
															
															systemChat format [STR_R3F_LOG_action_charger_fait,
																getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName"),
																getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName")];
														}
														else
														{
															_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
															hintC format ["ERROR : " + STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
														};
													}
													else
													{
														hintC format [STR_R3F_LOG_trop_loin, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
													};
												}
												else
												{
													hintC STR_R3F_LOG_action_charger_pas_assez_de_place;
												};
											}
											else
											{
												hintC format [STR_R3F_LOG_joueur_dans_objet, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
											};
										}
										else
										{
											hintC format [STR_R3F_LOG_objet_remorque_en_cours, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
										};
									}
									else
									{
										hintC format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
									};
								};
								
								R3F_LOG_objet_selectionne = objNull;
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_transporteur_decharger =
						{
							/**
							* D�charger un objet d'un transporteur - appel� deuis l'interface listant le contenu du transporteur
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								R3F_LOG_ID_transporteur_START = 56;
								R3F_LOG_IDC_dlg_CV_liste_contenu = (R3F_LOG_ID_transporteur_START + 3);


								private ["_transporteur", "_objets_charges", "_type_objet_a_decharger", "_objet_a_decharger", "_action_confirmee", "_est_deplacable"];
								
								_transporteur = uiNamespace getVariable "R3F_LOG_dlg_CV_transporteur";
								_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];
								
								if (lbCurSel R3F_LOG_IDC_dlg_CV_liste_contenu == -1) exitWith {R3F_LOG_mutex_local_verrou = false;};
								
								_type_objet_a_decharger = lbData [R3F_LOG_IDC_dlg_CV_liste_contenu, lbCurSel R3F_LOG_IDC_dlg_CV_liste_contenu];
								
								_est_deplacable = ([_type_objet_a_decharger] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_be_moved_by_player;
								
								if (!(_type_objet_a_decharger isKindOf "AllVehicles") && !_est_deplacable) then
								{
									_action_confirmee = [STR_R3F_LOG_action_decharger_deplacable_exceptionnel, "Warning", true, true] call BIS_fnc_GUImessage;
								}
								else
								{
									_action_confirmee = true;
								};
								
								if (_action_confirmee) then
								{
									closeDialog 0;
									
									// Recherche d'un objet du type demand�
									_objet_a_decharger = objNull;
									{
										if (typeOf _x == _type_objet_a_decharger) exitWith
										{
											_objet_a_decharger = _x;
										};
									} forEach _objets_charges;
									
									if !(isNull _objet_a_decharger) then
									{
										[_objet_a_decharger, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
										
										// On m�morise sur le r�seau le nouveau contenu du transporteur (c�d avec cet objet en moins)
										_objets_charges = _transporteur getVariable ["R3F_LOG_objets_charges", []];
										_objets_charges = _objets_charges - [_objet_a_decharger];
										_transporteur setVariable ["R3F_LOG_objets_charges", _objets_charges, true];
										
										_objet_a_decharger setVariable ["R3F_LOG_est_transporte_par", objNull, true];
										
										// Prise en compte de l'objet dans l'environnement du joueur (acc�l�rer le retour des addActions)
										_objet_a_decharger spawn
										{
											sleep 4;
											R3F_LOG_PUBVAR_reveler_au_joueur = _this;
											publicVariable "R3F_LOG_PUBVAR_reveler_au_joueur";
											["R3F_LOG_PUBVAR_reveler_au_joueur", R3F_LOG_PUBVAR_reveler_au_joueur] spawn R3F_LOG_FNCT_PUBVAR_reveler_au_joueur;
										};
										
										if (!(_objet_a_decharger isKindOf "AllVehicles") || _est_deplacable) then
										{
											R3F_LOG_mutex_local_verrou = false;
											[_objet_a_decharger, player, 0, true] spawn R3F_LOG_FNCT_objet_deplacer;
										}
										else
										{
											private ["_bbox_dim", "_pos_degagee", "_rayon"];
											
											systemChat STR_R3F_LOG_action_decharger_en_cours;
											
											_bbox_dim = (vectorMagnitude (boundingBoxReal _objet_a_decharger select 0)) max (vectorMagnitude (boundingBoxReal _objet_a_decharger select 1));
											
											sleep 1;
											
											// Recherche d'une position d�gag�e (on augmente progressivement le rayon jusqu'� trouver une position)
											for [{_rayon = 5 max (2*_bbox_dim); _pos_degagee = [];}, {count _pos_degagee == 0 && _rayon <= 30 + (8*_bbox_dim)}, {_rayon = _rayon + 10 + (2*_bbox_dim)}] do
											{
												_pos_degagee = [
													_bbox_dim,
													_transporteur modelToWorld [0, if (_transporteur isKindOf "AllVehicles") then {(boundingBoxReal _transporteur select 0 select 1) - 2 - 0.3*_rayon} else {0}, 0],
													_rayon,
													100 min (5 + _rayon^1.2)
												] call R3F_LOG_FNCT_3D_tirer_position_degagee_sol;
											};
											
											if (count _pos_degagee > 0) then
											{
												detach _objet_a_decharger;
												_objet_a_decharger setPos _pos_degagee;
												_objet_a_decharger setVectorDirAndUp [[-cos getDir _transporteur, sin getDir _transporteur, 0] vectorCrossProduct surfaceNormal _pos_degagee, surfaceNormal _pos_degagee];
												_objet_a_decharger setVelocity [0, 0, 0];
												
												sleep 0.4; // Car la nouvelle position n'est pas prise en compte instantann�ment
												
												// Si l'objet a �t� cr�� assez loin, on indique sa position relative
												if (_objet_a_decharger distance _transporteur > 40) then
												{
													systemChat format [STR_R3F_LOG_action_decharger_fait + " (%2)",
														getText (configFile >> "CfgVehicles" >> (typeOf _objet_a_decharger) >> "displayName"),
														format ["%1m %2deg", round (_objet_a_decharger distance _transporteur), round ([_transporteur, _objet_a_decharger] call BIS_fnc_dirTo)]
													];
												}
												else
												{
													systemChat format [STR_R3F_LOG_action_decharger_fait, getText (configFile >> "CfgVehicles" >> (typeOf _objet_a_decharger) >> "displayName")];
												};
												R3F_LOG_mutex_local_verrou = false;
											}
											// Si �chec recherche position d�gag�e, on d�charge l'objet comme un d�pla�able
											else
											{
												systemChat "WARNING : no free position found.";
												
												R3F_LOG_mutex_local_verrou = false;
												[_objet_a_decharger, player, 0, true] spawn R3F_LOG_FNCT_objet_deplacer;
											};
										};
									}
									else
									{
										hintC STR_R3F_LOG_action_decharger_deja_fait;
										R3F_LOG_mutex_local_verrou = false;
									};
								}
								else
								{
									R3F_LOG_mutex_local_verrou = false;
								};
							};
						};

						R3F_LOG_FNCT_transporteur_selectionner_objet =
						{
							/**
							* S�lectionne un objet � charger dans un transporteur
							* 
							* @param 0 l'objet � s�lectionner
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								R3F_LOG_objet_selectionne = _this select 0;
								systemChat format [STR_R3F_LOG_action_selectionner_objet_fait, getText (configFile >> "CfgVehicles" >> (typeOf R3F_LOG_objet_selectionne) >> "displayName")];
								
								[R3F_LOG_objet_selectionne, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
								
								// D�selectionner l'objet si le joueur n'en fait rien
								[] spawn
								{
									while {!isNull R3F_LOG_objet_selectionne} do
									{
										if (!alive player) then
										{
											R3F_LOG_objet_selectionne = objNull;
										}
										else
										{
											if (vehicle player != player || (player distance R3F_LOG_objet_selectionne > 40) || !isNull R3F_LOG_joueur_deplace_objet) then
											{
												R3F_LOG_objet_selectionne = objNull;
											};
										};
										
										sleep 0.2;
									};
								};
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};
						
						R3F_LOG_FNCT_transporteur_voir_contenu_vehicule =
						{
							/**
							* Ouvre la bo�te de dialogue du contenu du v�hicule et la pr�rempli en fonction de v�hicule
							* 
							* @param 0 le v�hicule dont il faut afficher le contenu
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							[] call {
								R3F_LOG_ID_transporteur_START = 56;
								R3F_LOG_IDD_dlg_contenu_vehicule = (R3F_LOG_ID_transporteur_START + 1);
								R3F_LOG_IDC_dlg_CV_capacite_vehicule = (R3F_LOG_ID_transporteur_START + 2);
								R3F_LOG_IDC_dlg_CV_liste_contenu = (R3F_LOG_ID_transporteur_START + 3);
								R3F_LOG_IDC_dlg_CV_btn_decharger = (R3F_LOG_ID_transporteur_START + 4);
								R3F_LOG_IDC_dlg_CV_titre = (R3F_LOG_ID_transporteur_START + 10);
								R3F_LOG_IDC_dlg_CV_credits = (R3F_LOG_ID_transporteur_START + 11);
								R3F_LOG_IDC_dlg_CV_btn_fermer = (R3F_LOG_ID_transporteur_START + 12);
								R3F_LOG_IDC_dlg_CV_jauge_chargement = (R3F_LOG_ID_transporteur_START + 13);
							};

							disableSerialization; // A cause des displayCtrl

							private ["_transporteur", "_chargement", "_chargement_precedent", "_contenu"];
							private ["_tab_objets", "_tab_quantite", "_i", "_dlg_contenu_vehicule", "_ctrl_liste"];

							R3F_LOG_objet_selectionne = objNull;

							_transporteur = _this select 0;
							uiNamespace setVariable ["R3F_LOG_dlg_CV_transporteur", _transporteur];

							[_transporteur, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;


							[] call {
								disableSerialization;
								showChat true; comment "Fixes Chat Bug";
								createDialog "RscDisplayHintC";

								_R3F_LOG_dlg_contenu_vehicule = findDisplay 57;
								{_x ctrlshow false;_x ctrlEnable false} foreach (allcontrols R3F_LOG_dlg_contenu_vehicule);

								idc = -1;
								x = 0.0; w = 0.3;
								y = 0.0; h = 0.03;
								sizeEx = 0.023;
								colorBackground[] = {0,0,0,0};
								colorText[] = {1,1,1,1};
								font = "PuristaMedium";

								_R3F_LOG_dlg_CV_titre_fond = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscStructuredText", -1];
								_R3F_LOG_dlg_CV_titre_fond ctrlSetPosition [0.26, 0.145 - R3F_LOG_dlg_CV_jauge_chargement_h-0.005, 0.45, 0.07];
								_R3F_LOG_dlg_CV_titre_fond ctrlSetBackgroundColor ["(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])","(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"];
								_R3F_LOG_dlg_CV_titre_fond ctrlCommit 0;
								
								R3F_LOG_IDC_dlg_CV_titre = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscStructuredText", R3F_LOG_IDC_dlg_CV_titre];
								R3F_LOG_IDC_dlg_CV_titre ctrlSetPosition [0.26, 0.145 - R3F_LOG_dlg_CV_jauge_chargement_h-0.005, 0.45, 0.04];
								R3F_LOG_IDC_dlg_CV_titre ctrlCommit 0;

								_R3F_LOG_IDC_dlg_CV_capacite_vehicule = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscStructuredText", R3F_LOG_IDC_dlg_CV_capacite_vehicule];
								_R3F_LOG_IDC_dlg_CV_capacite_vehicule ctrlSetPosition [0255, 0.185 - R3F_LOG_dlg_CV_jauge_chargement_h-0.005, 0.4, 0.03];
								_R3F_LOG_IDC_dlg_CV_capacite_vehicule ctrlCommit 0;

								_R3F_LOG_dlg_CV_fond_noir = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscStructuredText", -1];
								_R3F_LOG_dlg_CV_fond_noir ctrlSetPosition [0.26, 0.220 - R3F_LOG_dlg_CV_jauge_chargement_h-0.005, 0.45, R3F_LOG_dlg_CV_jauge_chargement_h + 0.010 + 0.54 - 0.005];
								_R3F_LOG_dlg_CV_fond_noir ctrlSetBackgroundColor [0,0,0,0.5];
								_R3F_LOG_dlg_CV_fond_noir ctrlCommit 0;

								_R3F_LOG_dlg_CV_liste_contenu = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscListBox", R3F_LOG_IDC_dlg_CV_liste_contenu];
								_R3F_LOG_dlg_CV_liste_contenu ctrlSetPosition [0.26, 0.225, 0.45, 0.54 - 0.005];
								_R3F_LOG_dlg_CV_liste_contenu ctrlSetBackgroundColor [0,0,0,0.5];

								_R3F_LOG_dlg_CV_liste_contenu ctrladdEventHandler ["LBDblClick",{
									0 spawn R3F_LOG_FNCT_transporteur_decharger;
								}];
								_R3F_LOG_dlg_CV_liste_contenu ctrladdEventHandler ["LBSelChanged",{
									uiNamespace setVariable ["R3F_LOG_dlg_CV_lbCurSel_data", (_this select 0) lbData (_this select 1)];
								}];
								_R3F_LOG_dlg_CV_liste_contenu ctrlCommit 0;

								_R3F_LOG_dlg_CV_credits = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscStructuredText", R3F_LOG_IDC_dlg_CV_credits];
								_R3F_LOG_dlg_CV_credits ctrlSetPosition [0.255, 0.813, 0.19, 0.02];
								_R3F_LOG_dlg_CV_credits ctrlCommit 0;

								_R3F_LOG_dlg_CV_btn_decharger = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscButtonMenu", R3F_LOG_IDC_dlg_CV_btn_decharger];
								_R3F_LOG_dlg_CV_btn_decharger ctrlSetPosition [0.365, 0.765, 0.17, 0.045];
								_R3F_LOG_dlg_CV_btn_decharger ctrladdEventHandler ["ButtonClick",{
									0 spawn R3F_LOG_FNCT_transporteur_decharger;
								}];
								_R3F_LOG_dlg_CV_btn_decharger ctrlCommit 0;

								_R3F_LOG_dlg_CV_btn_fermer = _R3F_LOG_dlg_contenu_vehicule ctrlCreate ["RscButtonMenu", R3F_LOG_IDC_dlg_CV_btn_fermer];
								_R3F_LOG_dlg_CV_btn_fermer ctrlSetPosition [0.54, 0.765, 0.17, 0.045];
								_R3F_LOG_dlg_CV_btn_fermer ctrladdEventHandler ["ButtonClick",{
									closeDialog 0;
								}];
								_R3F_LOG_dlg_CV_btn_fermer ctrlCommit 0;
								
								
							};
							_dlg_contenu_vehicule = findDisplay R3F_LOG_IDD_dlg_contenu_vehicule;

							/**** DEBUT des traductions des labels ****/
							(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_titre) ctrlSetText STR_R3F_LOG_dlg_CV_titre;
							(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_credits) ctrlSetText "[R3F] Logistics";
							(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_btn_decharger) ctrlSetText STR_R3F_LOG_dlg_CV_btn_decharger;
							(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_btn_fermer) ctrlSetText STR_R3F_LOG_dlg_CV_btn_fermer;
							/**** FIN des traductions des labels ****/

							_ctrl_liste = _dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_liste_contenu;

							_chargement_precedent = [];

							while {!isNull _dlg_contenu_vehicule} do
							{
								_chargement = [_transporteur] call R3F_LOG_FNCT_calculer_chargement_vehicule;
								
								// Si le contenu a chang�, on rafraichit l'interface
								if !([_chargement, _chargement_precedent] call BIS_fnc_areEqual) then
								{
									_chargement_precedent = +_chargement;
									
									_contenu = _transporteur getVariable ["R3F_LOG_objets_charges", []];
									
									/** Liste des noms de classe des objets contenu dans le v�hicule, sans doublon */
									_tab_objets = [];
									/** Quantit� associ� (par l'index) aux noms de classe dans _tab_objets */
									_tab_quantite = [];
									/** Co�t de chargement associ� (par l'index) aux noms de classe dans _tab_objets */
									_tab_cout_chargement = [];
									
									// Pr�paration de la liste du contenu et des quantit�s associ�es aux objets
									for [{_i = 0}, {_i < count _contenu}, {_i = _i + 1}] do
									{
										private ["_objet"];
										_objet = _contenu select _i;
										
										if !((typeOf _objet) in _tab_objets) then
										{
											_tab_objets pushBack (typeOf _objet);
											_tab_quantite pushBack 1;
											if (!isNil {_objet getVariable "R3F_LOG_fonctionnalites"}) then
											{
												_tab_cout_chargement pushBack (_objet getVariable "R3F_LOG_fonctionnalites" select R3F_LOG_IDX_can_be_transported_cargo_cout);
											}
											else
											{
												_tab_cout_chargement pushBack (([typeOf _objet] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_be_transported_cargo_cout);
											};
										}
										else
										{
											private ["_idx_objet"];
											_idx_objet = _tab_objets find (typeOf _objet);
											_tab_quantite set [_idx_objet, ((_tab_quantite select _idx_objet) + 1)];
										};
									};
									
									lbClear _ctrl_liste;
									(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_capacite_vehicule) ctrlSetText (format [STR_R3F_LOG_dlg_CV_capacite_vehicule+" pl.", _chargement select 0, _chargement select 1]);
									if (_chargement select 1 != 0) then {(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_jauge_chargement) progressSetPosition ((_chargement select 0) / (_chargement select 1));};
									(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_jauge_chargement) ctrlShow ((_chargement select 0) != 0);
									
									if (count _tab_objets == 0) then
									{
										(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_btn_decharger) ctrlEnable false;
									}
									else
									{
										// Insertion de chaque type d'objets dans la liste
										for [{_i = 0}, {_i < count _tab_objets}, {_i = _i + 1}] do
										{
											private ["_classe", "_quantite", "_icone", "_tab_icone", "_index"];
											
											_classe = _tab_objets select _i;
											_quantite = _tab_quantite select _i;
											_cout_chargement = _tab_cout_chargement select _i;
											_icone = getText (configFile >> "CfgVehicles" >> _classe >> "icon");
											
											// Ic�ne par d�faut
											if (_icone == "") then
											{
												_icone = "\A3\ui_f\data\map\VehicleIcons\iconObject_ca.paa";
											};
											
											// Si le chemin commence par A3\ ou a3\, on rajoute un \ au d�but
											_tab_icone = toArray toLower _icone;
											if (count _tab_icone >= 3 &&
												{
													_tab_icone select 0 == (toArray "a" select 0) &&
													_tab_icone select 1 == (toArray "3" select 0) &&
													_tab_icone select 2 == (toArray "\" select 0)
												}) then
											{
												_icone = "\" + _icone;
											};
											
											// Si ic�ne par d�faut, on rajoute le chemin de base par d�faut
											_tab_icone = toArray _icone;
											if (_tab_icone select 0 != (toArray "\" select 0)) then
											{
												_icone = format ["\A3\ui_f\data\map\VehicleIcons\%1_ca.paa", _icone];
											};
											
											// Si pas d'extension de fichier, on rajoute ".paa"
											_tab_icone = toArray _icone;
											if (count _tab_icone >= 4 && {_tab_icone select (count _tab_icone - 4) != (toArray "." select 0)}) then
											{
												_icone = _icone + ".paa";
											};
											
											_index = _ctrl_liste lbAdd (getText (configFile >> "CfgVehicles" >> _classe >> "displayName") + format [" (%1x %2pl.)", _quantite, _cout_chargement]);
											_ctrl_liste lbSetPicture [_index, _icone];
											_ctrl_liste lbSetData [_index, _classe];
											
											if (uiNamespace getVariable ["R3F_LOG_dlg_CV_lbCurSel_data", ""] == _classe) then
											{
												_ctrl_liste lbSetCurSel _index;
											};
										};
										
										(_dlg_contenu_vehicule displayCtrl R3F_LOG_IDC_dlg_CV_btn_decharger) ctrlEnable true;
									};
								};
								
								sleep 0.15;
							};
						};

						R3F_LOG_FNCT_transporteur_init = 
						{
							/**
							* Initialise un v�hicule transporteur
							* 
							* @param 0 le transporteur
							*/

							private ["_transporteur"];

							_transporteur = _this select 0;

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_transporteur getVariable "R3F_LOG_objets_charges"}) then
							{
								_transporteur setVariable ["R3F_LOG_objets_charges", [], false];
							};

							_transporteur addAction [("<t color=""#dddd00"">" + STR_R3F_LOG_action_charger_deplace + "</t>"), {_this call R3F_LOG_FNCT_transporteur_charger_deplace}, nil, 8, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_joueur_deplace_objet != _target && R3F_LOG_action_charger_deplace_valide"];

							_transporteur addAction [("<t color=""#dddd00"">" + format [STR_R3F_LOG_action_charger_selection, getText (configFile >> "CfgVehicles" >> (typeOf _transporteur) >> "displayName")] + "</t>"), {_this call R3F_LOG_FNCT_transporteur_charger_selection}, nil, 7, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_charger_selection_valide"];

							_transporteur addAction [("<t color=""#dddd00"">" + STR_R3F_LOG_action_contenu_vehicule + "</t>"), {_this call R3F_LOG_FNCT_transporteur_voir_contenu_vehicule}, nil, 4, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_contenu_vehicule_valide"];
						};
						
						R3F_LOG_FNCT_objet_init =
						{
														/**
							* Initialise un objet d�pla�able/h�liportable/remorquable/transportable
							* 
							* @param 0 l'objet
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_objet", "_config", "_nom", "_fonctionnalites"];

							_objet = _this select 0;

							_config = configFile >> "CfgVehicles" >> (typeOf _objet);
							_nom = getText (_config >> "displayName");

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_objet getVariable "R3F_LOG_est_transporte_par"}) then
							{
								_objet setVariable ["R3F_LOG_est_transporte_par", objNull, false];
							};

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_objet getVariable "R3F_LOG_est_deplace_par"}) then
							{
								_objet setVariable ["R3F_LOG_est_deplace_par", objNull, false];
							};

							// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
							if (isNil {_objet getVariable "R3F_LOG_proprietaire_verrou"}) then
							{
								// En mode de lock side : uniquement si l'objet appartient initialement � une side militaire
								if (R3F_LOG_CFG_lock_objects_mode == "side") then
								{
									switch (getNumber (_config >> "side")) do
									{
										case 0: {_objet setVariable ["R3F_LOG_proprietaire_verrou", east, false];};
										case 1: {_objet setVariable ["R3F_LOG_proprietaire_verrou", west, false];};
										case 2: {_objet setVariable ["R3F_LOG_proprietaire_verrou", independent, false];};
									};
								}
								else
								{
									// En mode de lock faction : uniquement si l'objet appartient initialement � une side militaire
									if (R3F_LOG_CFG_lock_objects_mode == "faction") then
									{
										switch (getNumber (_config >> "side")) do
										{
											case 0; case 1; case 2:
											{_objet setVariable ["R3F_LOG_proprietaire_verrou", getText (_config >> "faction"), false];};
										};
									};
								};
							};

							// Si on peut embarquer dans l'objet
							if (isNumber (_config >> "preciseGetInOut")) then
							{
								// Ne pas monter dans un v�hicule qui est en cours de transport
								_objet addEventHandler ["GetIn", R3F_LOG_FNCT_EH_GetIn];
							};

							// Indices du tableau des fonctionnalit�s retourn� par R3F_LOG_FNCT_determiner_fonctionnalites_logistique

							_fonctionnalites = _objet getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log];

							if (R3F_LOG_CFG_unlock_objects_timer != -1) then
							{
								_objet addAction [("<t color=""#ee0000"">" + format [STR_R3F_LOG_action_deverrouiller, _nom] + "</t>"), {_this call R3F_LOG_FNCT_deverrouiller_objet}, false, 11, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_deverrouiller_valide"];
							}
							else
							{
								_objet addAction [("<t color=""#ee0000"">" + STR_R3F_LOG_action_deverrouiller_impossible + "</t>"), {hintC STR_R3F_LOG_action_deverrouiller_impossible;}, false, 11, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_deverrouiller_valide"];
							};

							if (_fonctionnalites select 1) then
							{
								_objet addAction [("<t color=""#00eeff"">" + format [STR_R3F_LOG_action_deplacer_objet, _nom] + "</t>"), {_this call R3F_LOG_FNCT_objet_deplacer}, false, 5, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_deplacer_objet_valide"];
							};

							if (_fonctionnalites select 5) then
							{
								if (_fonctionnalites select 1) then
								{
									_objet addAction [("<t color=""#00dd00"">" + STR_R3F_LOG_action_remorquer_deplace + "</t>"), {_this call R3F_LOG_FNCT_remorqueur_remorquer_deplace}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_joueur_deplace_objet == _target && R3F_LOG_action_remorquer_deplace_valide"];
								};
								
								_objet addAction [("<t color=""#00dd00"">" + format [STR_R3F_LOG_action_remorquer_direct, _nom] + "</t>"), {_this call R3F_LOG_FNCT_remorqueur_remorquer_direct}, nil, 5, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_remorquer_direct_valide"];
								
								_objet addAction [("<t color=""#00dd00"">" + STR_R3F_LOG_action_detacher + "</t>"), {_this call R3F_LOG_FNCT_remorqueur_detacher}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_detacher_valide"];
							};

							if (_fonctionnalites select 8) then
							{
								if (_fonctionnalites select 1) then
								{
									_objet addAction [("<t color=""#dddd00"">" + STR_R3F_LOG_action_charger_deplace + "</t>"), {_this call R3F_LOG_FNCT_transporteur_charger_deplace}, nil, 8, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_joueur_deplace_objet == _target && R3F_LOG_action_charger_deplace_valide"];
								};
								
								_objet addAction [("<t color=""#dddd00"">" + format [STR_R3F_LOG_action_selectionner_objet_charge, _nom] + "</t>"), {_this call R3F_LOG_FNCT_transporteur_selectionner_objet}, nil, 5, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_selectionner_objet_charge_valide"];
							};

							if (_fonctionnalites select 1) then
							{
								_objet addAction [("<t color=""#ff9600"">" + STR_R3F_LOG_action_revendre_usine_deplace + "</t>"), {_this call R3F_LOG_FNCT_usine_revendre_deplace}, nil, 7, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_revendre_usine_deplace_valide"];
							};
						};

						R3F_LOG_FNCT_objet_est_verrouille =
						{
														/**
							* D�termine si un objet est verrouill� ou non pour un joueur donn�
							* 
							* @param 0 l'objet pour lequel savoir s'il est verrouill�
							* @param 1 l'unit� pour laquelle savoir si l'objet est verrouill�
							* 
							* @return true si l'objet est verrouill�, false sinon
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_objet", "_unite", "_objet_verrouille"];

							_objet = _this select 0;
							_unite = _this select 1;

							_objet_verrouille = switch (R3F_LOG_CFG_lock_objects_mode) do
							{
								case "side": {_objet getVariable ["R3F_LOG_proprietaire_verrou", side group _unite] != side group _unite};
								case "faction": {_objet getVariable ["R3F_LOG_proprietaire_verrou", faction _unite] != faction _unite};
								case "player": {_objet getVariable ["R3F_LOG_proprietaire_verrou", name _unite] != name _unite};
								case "unit": {_objet getVariable ["R3F_LOG_proprietaire_verrou", _unite] != _unite};
								default {false};
							};

							_objet_verrouille
						};

						R3F_LOG_FNCT_deverrouiller_objet =
						{
							/**
							* Gestion du d�verrouillage d'un objet et du compte-�-rebours
							* 
							* @param 0 l'objet � d�verrouiller
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							if (R3F_LOG_mutex_local_verrou) then
							{
								hintC STR_R3F_LOG_mutex_action_en_cours;
							}
							else
							{
								R3F_LOG_mutex_local_verrou = true;
								
								private ["_objet", "_duree", "_ctrl_titre", "_ctrl_fond", "_ctrl_jauge", "_time_debut", "_attente_valide", "_cursorTarget_distance"];
								
								_objet = _this select 0;
								
								// Mise � jour du propri�taire du verrou
								[_objet, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
								
								systemChat STR_R3F_LOG_deverrouillage_succes_attente;
								
								R3F_LOG_mutex_local_verrou = false;
							};
						};

						R3F_LOG_FNCT_definir_proprietaire_verrou =
						{
							/**
							* D�fini le propri�taire (side/faction/player) du verrou d'un objet
							* 
							* @param 0 l'objet pour lequel d�finir le propri�taire du verrou
							* @param 1 l'unit� pour laquelle d�finir le verrou
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_objet", "_unite"];

							_objet = _this select 0;
							_unite = _this select 1;

							// Si le verrou de l'objet ne correspond pas � l'unit�, on red�fini sa valeur pour lui correspondre
							if (isNil {_objet getVariable "R3F_LOG_proprietaire_verrou"} || {[_objet, _unite] call R3F_LOG_FNCT_objet_est_verrouille}) then
							{
								switch (R3F_LOG_CFG_lock_objects_mode) do
								{
									case "side": {_objet setVariable ["R3F_LOG_proprietaire_verrou", side group _unite, true];};
									case "faction": {_objet setVariable ["R3F_LOG_proprietaire_verrou", faction _unite, true];};
									case "player": {_objet setVariable ["R3F_LOG_proprietaire_verrou", name _unite, true];};
									case "unit": {_objet setVariable ["R3F_LOG_proprietaire_verrou", _unite, true];};
								};
							};
						};
						
						R3F_LOG_FNCT_formater_fonctionnalites_logistique =
						{
							/**
							* Affiche dans la zone "hint" les fonctionnalités logistique disponibles pour une classe donnée
							* 
							* @param 0 le nom de classe pour lequel consulter les fonctionnalités logistique
							* @return structuredText des fonctionnalités logistique
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_classe", "_fonctionnalites", "_side", "_places", "_infos", "_j", "_tab_inheritance_tree"];

							_classe = _this select 0;

							if !(isClass (configFile >> "CfgVehicles" >> _classe)) exitWith {};

							_fonctionnalites = [_classe] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique;

							_side = switch (getNumber (configFile >> "CfgVehicles" >> _classe >> "side")) do
							{
								case 0: {"EAST"};
								case 1: {"WEST"};
								case 2: {"GUER"};
								case 3: {"CIV"};
								default {"NONE"};
							};

							_places = 0;
							if (!isNil "R3F_LOG_VIS_objet" && {!isNull R3F_LOG_VIS_objet && {typeOf R3F_LOG_VIS_objet == _classe}}) then
							{
								{
									_places = _places + (R3F_LOG_VIS_objet emptyPositions _x);
								} forEach ["Commander", "Driver", "Gunner", "Cargo"];
							};

							_infos = "<t align='left'>";
							_infos = _infos + format ["%1 : %2<br/>", STR_R3F_LOG_nom_fonctionnalite_side, _side];
							if (_places != 0) then {_infos = _infos + format ["%1 : %2<br/>", STR_R3F_LOG_nom_fonctionnalite_places, _places]} else {_infos = _infos + "<br/>";};
							_infos = _infos + "<br/>";
							_infos = _infos + format ["%1<br/>", STR_R3F_LOG_nom_fonctionnalite_passif];
							_infos = _infos + format ["<t color='%2'>- %1</t><br/>", STR_R3F_LOG_nom_fonctionnalite_passif_deplace, if (_fonctionnalites select R3F_LOG_IDX_can_be_moved_by_player) then {"#00eeff"} else {"#777777"}];
							_infos = _infos + format ["<t color='%2'>- %1</t><br/>", STR_R3F_LOG_nom_fonctionnalite_passif_heliporte, if (_fonctionnalites select R3F_LOG_IDX_can_be_lifted) then {"#00ee00"} else {"#777777"}];
							_infos = _infos + format ["<t color='%2'>- %1</t><br/>", STR_R3F_LOG_nom_fonctionnalite_passif_remorque, if (_fonctionnalites select R3F_LOG_IDX_can_be_towed) then {"#00ee00"} else {"#777777"}];
							_infos = _infos + format ["<t color='%2'>- %1%3</t><br/>",
								STR_R3F_LOG_nom_fonctionnalite_passif_transporte,
								if (_fonctionnalites select R3F_LOG_IDX_can_be_transported_cargo) then {"#f5f500"} else {"#777777"},
								if (_fonctionnalites select R3F_LOG_IDX_can_be_transported_cargo) then {format [" (" + STR_R3F_LOG_nom_fonctionnalite_passif_transporte_capacite + ")", _fonctionnalites select R3F_LOG_IDX_can_be_transported_cargo_cout]} else {""}
							];
							_infos = _infos + "<br/>";
							_infos = _infos + format ["%1<br/>", STR_R3F_LOG_nom_fonctionnalite_actif];
							_infos = _infos + format ["<t color='%2'>- %1</t><br/>", STR_R3F_LOG_nom_fonctionnalite_actif_heliporte, if (_fonctionnalites select R3F_LOG_IDX_can_lift) then {"#00ee00"} else {"#777777"}];
							_infos = _infos + format ["<t color='%2'>- %1</t><br/>", STR_R3F_LOG_nom_fonctionnalite_actif_remorque, if (_fonctionnalites select R3F_LOG_IDX_can_tow) then {"#00ee00"} else {"#777777"}];
							_infos = _infos + format ["<t color='%2'>- %1%3</t><br/>",
								STR_R3F_LOG_nom_fonctionnalite_actif_transporte,
								if (_fonctionnalites select R3F_LOG_IDX_can_transport_cargo) then {"#f5f500"} else {"#777777"},
								if (_fonctionnalites select R3F_LOG_IDX_can_transport_cargo) then {format [" (" + STR_R3F_LOG_nom_fonctionnalite_actif_transporte_capacite + ")", _fonctionnalites select R3F_LOG_IDX_can_transport_cargo_cout]} else {""}
							];
							_infos = _infos + "</t>";

							parseText _infos
						};

						R3F_LOG_FNCT_formater_nombre_entier_milliers =
						{
							/**
							* Formate un nombre entier avec des séparateurs de milliers
							* 
							* @param 0 le nombre à formater
							* @return chaîne de caractère représentant le nombre formaté
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_nombre", "_centaines", "_str_signe", "_str_nombre", "_str_centaines"];

							_nombre = _this select 0;

							_str_signe = if (_nombre < 0) then {"-"} else {""};
							_nombre = floor abs _nombre;

							_str_nombre = "";
							while {_nombre >= 1000} do
							{
								_centaines = _nombre - (1000 * floor (0.001 * _nombre));
								_nombre = floor (0.001 * _nombre);
								
								if (_centaines < 100) then
								{
									if (_centaines < 10) then
									{
										_str_centaines = "00" + str _centaines;
									}
									else
									{
										_str_centaines = "0" + str _centaines;
									};
								}
								else
								{
									_str_centaines = str _centaines;
								};
								
								_str_nombre = "." + _str_centaines + _str_nombre;
							};

							_str_signe + str _nombre + _str_nombre
						};
						
						// Liste des variables activant ou non les actions de menu
						R3F_LOG_action_charger_deplace_valide = false;
						R3F_LOG_action_charger_selection_valide = false;
						R3F_LOG_action_contenu_vehicule_valide = false;
						
						R3F_LOG_action_remorquer_deplace_valide = false;
						
						R3F_LOG_action_heliporter_valide = false;
						R3F_LOG_action_heliport_larguer_valide = false;
						
						R3F_LOG_action_deplacer_objet_valide = false;
						R3F_LOG_action_remorquer_direct_valide = false;
						R3F_LOG_action_detacher_valide = false;
						R3F_LOG_action_selectionner_objet_charge_valide = false;
						
						R3F_LOG_action_ouvrir_usine_valide = false;
						R3F_LOG_action_revendre_usine_direct_valide = false;
						R3F_LOG_action_revendre_usine_deplace_valide = false;
						R3F_LOG_action_revendre_usine_selection_valide = false;
						
						R3F_LOG_action_deverrouiller_valide = false;
						
						/** Sur ordre (publicVariable), r�v�ler la pr�sence d'un objet au joueur (acc�l�rer le retour des addActions) */
						R3F_LOG_FNCT_PUBVAR_reveler_au_joueur =
						{
							private ["_objet"];
							_objet = _this select 1;
							
							if (alive player) then
							{
								player reveal _objet;
							};
						};
						"R3F_LOG_PUBVAR_reveler_au_joueur" addPublicVariableEventHandler R3F_LOG_FNCT_PUBVAR_reveler_au_joueur;
						
						/** Event handler GetIn : ne pas monter dans un v�hicule qui est en cours de transport */
						R3F_LOG_FNCT_EH_GetIn =
						{
							//if (local (_this select 2)) then
							//{
							//	_this spawn
							//	{
							//		sleep 0.1;
							//		if ((!(isNull (_this select 0 getVariable "R3F_LOG_est_deplace_par")) && (alive (_this select 0 getVariable "R3F_LOG_est_deplace_par")) && (isPlayer (_this select 0 getVariable "R3F_LOG_est_deplace_par"))) || !(isNull (_this select 0 getVariable "R3F_LOG_est_transporte_par"))) then
							//		{
							//			(_this select 2) action ["GetOut", _this select 0];
							//			(_this select 2) action ["Eject", _this select 0];
							//			if (player == _this select 2) then {hintC format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf (_this select 0)) >> "displayName")];};
							//		};
							//	};
							//};
						};
						
						// Actions � faire quand le joueur est apparu
						0 spawn
						{
							waitUntil {!isNull player};
							
							// Ajout d'un event handler "WeaponDisassembled" pour g�rer le cas o� une arme est d�mont�e alors qu'elle est en cours de transport
							player addEventHandler ["WeaponDisassembled",
							{
								private ["_objet"];
								
								// R�cup�ration de l'arme d�mont�e avec cursorTarget au lieu de _this (http://feedback.arma3.com/view.php?id=18090)
								_objet = cursorTarget;
								
								if (!isNull _objet && {!isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull])}) then
								{
									_objet setVariable ["R3F_LOG_est_deplace_par", objNull, true];
								};
							}];
						};
						
						/** Variable publique passer � true pour informer le script surveiller_nouveaux_objets.sqf de la cr�ation d'un objet */
						R3F_LOG_PUBVAR_nouvel_objet_a_initialiser = false;
						
						/* V�rification permanente des conditions donnant acc�s aux addAction */
						[] spawn {
							/**
							* Evalue r�guli�rement les conditions � v�rifier pour autoriser les actions logistiques
							* Permet de diminuer la fr�quence des v�rifications des conditions normalement faites
							* dans les addAction (~60Hz) et donc de limiter la consommation CPU.
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							private ["_joueur", "_vehicule_joueur", "_cursorTarget_distance", "_objet_pointe", "_objet_pas_en_cours_de_deplacement", "_fonctionnalites", "_pas_de_hook"];
							private ["_objet_deverrouille", "_objet_pointe_autre_que_deplace", "_objet_pointe_autre_que_deplace_deverrouille", "_isUav", "_usine_autorisee_client"];

							sleep 2;

							while {true} do
							{
								_joueur = player;
								_vehicule_joueur = vehicle _joueur;
								
								_cursorTarget_distance = call R3F_LOG_FNCT_3D_cursorTarget_distance_bbox;
								_objet_pointe = _cursorTarget_distance select 0;
								
								if (call compile R3F_LOG_CFG_string_condition_allow_logistics_on_this_client &&
									!R3F_LOG_mutex_local_verrou && _vehicule_joueur == _joueur && !isNull _objet_pointe && _cursorTarget_distance select 1 < 3.75
								) then
								{
									R3F_LOG_objet_addAction = _objet_pointe;
									
									_fonctionnalites = _objet_pointe getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log];
									
									_objet_pas_en_cours_de_deplacement = (isNull (_objet_pointe getVariable ["R3F_LOG_est_deplace_par", objNull]) ||
										{(!alive (_objet_pointe getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet_pointe getVariable "R3F_LOG_est_deplace_par"))});
									
									_isUav =  (getNumber (configFile >> "CfgVehicles" >> (typeOf _objet_pointe) >> "isUav") == 1);
									
									_usine_autorisee_client = call compile R3F_LOG_CFG_string_condition_allow_creation_factory_on_this_client;
									
									// L'objet est-il d�verrouill�
									_objet_deverrouille = !([_objet_pointe, _joueur] call R3F_LOG_FNCT_objet_est_verrouille);
									
									// Trouver l'objet point� qui se trouve derri�re l'objet en cours de d�placement
									_objet_pointe_autre_que_deplace = [R3F_LOG_joueur_deplace_objet, 3.75] call R3F_LOG_FNCT_3D_cursorTarget_virtuel;
									
									if (!isNull _objet_pointe_autre_que_deplace) then
									{
										// L'objet (point� qui se trouve derri�re l'objet en cours de d�placement) est-il d�verrouill�
										_objet_pointe_autre_que_deplace_deverrouille = !([_objet_pointe_autre_que_deplace, _joueur] call R3F_LOG_FNCT_objet_est_verrouille);
									};
									
									// Si l'objet est un objet d�pla�able
									if (_fonctionnalites select 1) then
									{
										// Condition action deplacer_objet
										R3F_LOG_action_deplacer_objet_valide = (count crew _objet_pointe >= 0 || _isUav) && (isNull R3F_LOG_joueur_deplace_objet) &&
											_objet_pas_en_cours_de_deplacement && isNull (_objet_pointe getVariable "R3F_LOG_est_transporte_par") &&
											_objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
										
										// Condition action revendre_usine_deplace
										R3F_LOG_action_revendre_usine_deplace_valide = _usine_autorisee_client && R3F_LOG_CFG_CF_sell_back_bargain_rate != -1 &&
											_objet_pointe getVariable ["R3F_LOG_CF_depuis_usine", false] && (count crew _objet_pointe >= 0 || _isUav) &&
											(R3F_LOG_joueur_deplace_objet == _objet_pointe) && !(_objet_pointe getVariable "R3F_LOG_disabled") && !isNull _objet_pointe_autre_que_deplace &&
											{
												!(_objet_pointe_autre_que_deplace getVariable ["R3F_LOG_CF_disabled", true]) &&
												_objet_pointe_autre_que_deplace getVariable ["R3F_LOG_CF_side_addAction", side group _joueur] == side group _joueur &&
												(abs ((getPosASL _objet_pointe_autre_que_deplace select 2) - (getPosASL player select 2)) < 2.5) &&
												alive _objet_pointe_autre_que_deplace && (vectorMagnitude velocity _objet_pointe_autre_que_deplace < 6)
											};
									};
									
									// Si l'objet est un objet remorquable
									if (_fonctionnalites select 5) then
									{
										// Et qu'il est d�pla�able
										if (_fonctionnalites select 1) then
										{
											// Condition action remorquer_deplace
											R3F_LOG_action_remorquer_deplace_valide = !(_objet_pointe getVariable "R3F_LOG_disabled") && (count crew _objet_pointe >= 0 || _isUav) &&
												(R3F_LOG_joueur_deplace_objet == _objet_pointe) && !isNull _objet_pointe_autre_que_deplace &&
												{
													(_objet_pointe_autre_que_deplace getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 4) && alive _objet_pointe_autre_que_deplace &&
													isNull (_objet_pointe_autre_que_deplace getVariable "R3F_LOG_remorque") &&
													(vectorMagnitude velocity _objet_pointe_autre_que_deplace < 6) &&
													_objet_pointe_autre_que_deplace_deverrouille && !(_objet_pointe_autre_que_deplace getVariable "R3F_LOG_disabled")
												};
										};
										
										// Condition action selectionner_objet_remorque
										R3F_LOG_action_remorquer_direct_valide = (count crew _objet_pointe >= 0 || _isUav) && isNull R3F_LOG_joueur_deplace_objet &&
											isNull (_objet_pointe getVariable ["R3F_LOG_remorque", objNull]) &&
											_objet_pas_en_cours_de_deplacement && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled") &&
											{
												{
													_x != _objet_pointe && (_x getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 4) &&
													alive _x &&	isNull (_x getVariable "R3F_LOG_remorque") && (vectorMagnitude velocity _x < 6) &&
													!([_x, _joueur] call R3F_LOG_FNCT_objet_est_verrouille) && !(_x getVariable "R3F_LOG_disabled") &&
													{
														private ["_delta_pos"];
														
														_delta_pos =
														(
															_objet_pointe modelToWorld
															[
																boundingCenter _objet_pointe select 0,
																boundingBoxReal _objet_pointe select 1 select 1,
																boundingBoxReal _objet_pointe select 0 select 2
															]
														) vectorDiff (
															_x modelToWorld
															[
																boundingCenter _x select 0,
																boundingBoxReal _x select 0 select 1,
																boundingBoxReal _x select 0 select 2
															]
														);
														
														// L'arri�re du remorqueur est proche de l'avant de l'objet point�
														abs (_delta_pos select 0) < 3 && abs (_delta_pos select 1) < 5
													}
												} count (nearestObjects [_objet_pointe, ["All"], 30]) != 0
											};
										
										// Condition action detacher
										R3F_LOG_action_detacher_valide = (isNull R3F_LOG_joueur_deplace_objet) &&
											!isNull (_objet_pointe getVariable "R3F_LOG_est_transporte_par") && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
									};
									
									// Si l'objet est un objet transportable
									if (_fonctionnalites select 8) then
									{
										// Et qu'il est d�pla�able
										if (_fonctionnalites select 1) then
										{
											// Condition action charger_deplace
											R3F_LOG_action_charger_deplace_valide = (count crew _objet_pointe == 0 || _isUav) && (R3F_LOG_joueur_deplace_objet == _objet_pointe) &&
												!(_objet_pointe getVariable "R3F_LOG_disabled") && !isNull _objet_pointe_autre_que_deplace &&
												{
													(_objet_pointe_autre_que_deplace getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 6) &&
													(abs ((getPosASL _objet_pointe_autre_que_deplace select 2) - (getPosASL player select 2)) < 2.5) &&
													alive _objet_pointe_autre_que_deplace && (vectorMagnitude velocity _objet_pointe_autre_que_deplace < 6) &&
													_objet_pointe_autre_que_deplace_deverrouille && !(_objet_pointe_autre_que_deplace getVariable "R3F_LOG_disabled")
												};
										};
										
										// Condition action selectionner_objet_charge
										R3F_LOG_action_selectionner_objet_charge_valide = (count crew _objet_pointe == 0 || _isUav) && isNull R3F_LOG_joueur_deplace_objet &&
											isNull (_objet_pointe getVariable "R3F_LOG_est_transporte_par") &&
											_objet_pas_en_cours_de_deplacement && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
									};
									
									// Si l'objet est un v�hicule remorqueur
									if (_fonctionnalites select 4) then
									{
										// Condition action remorquer_deplace
										R3F_LOG_action_remorquer_deplace_valide = (alive _objet_pointe) && (!isNull R3F_LOG_joueur_deplace_objet) &&
											!(R3F_LOG_joueur_deplace_objet getVariable "R3F_LOG_disabled") && (R3F_LOG_joueur_deplace_objet != _objet_pointe) &&
											(R3F_LOG_joueur_deplace_objet getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 5) &&
											isNull (_objet_pointe getVariable "R3F_LOG_remorque") && (vectorMagnitude velocity _objet_pointe < 6) &&
											_objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
									};
									
									// Si l'objet est un v�hicule transporteur
									if (_fonctionnalites select 6) then
									{
										// Condition action charger_deplace
										R3F_LOG_action_charger_deplace_valide = alive _objet_pointe && (!isNull R3F_LOG_joueur_deplace_objet) &&
											!(R3F_LOG_joueur_deplace_objet getVariable "R3F_LOG_disabled") && (R3F_LOG_joueur_deplace_objet != _objet_pointe) &&
											(R3F_LOG_joueur_deplace_objet getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 8) &&
											(vectorMagnitude velocity _objet_pointe < 6) && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
										
										// Condition action charger_selection
										R3F_LOG_action_charger_selection_valide = alive _objet_pointe && (isNull R3F_LOG_joueur_deplace_objet) &&
											(!isNull R3F_LOG_objet_selectionne) && (R3F_LOG_objet_selectionne != _objet_pointe) &&
											!(R3F_LOG_objet_selectionne getVariable "R3F_LOG_disabled") &&
											(R3F_LOG_objet_selectionne getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 8) &&
											(vectorMagnitude velocity _objet_pointe < 6) && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
										
										// Condition action contenu_vehicule
										R3F_LOG_action_contenu_vehicule_valide = alive _objet_pointe && (isNull R3F_LOG_joueur_deplace_objet) &&
											(vectorMagnitude velocity _objet_pointe < 6) && _objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
									};
									
									// Condition action ouvrir_usine
									R3F_LOG_action_ouvrir_usine_valide = _usine_autorisee_client && isNull R3F_LOG_joueur_deplace_objet &&
										!(_objet_pointe getVariable "R3F_LOG_CF_disabled") && alive _objet_pointe &&
										_objet_pointe getVariable ["R3F_LOG_CF_side_addAction", side group _joueur] == side group _joueur;
									
									// Condition action revendre_usine_deplace
									R3F_LOG_action_revendre_usine_deplace_valide = _usine_autorisee_client && R3F_LOG_CFG_CF_sell_back_bargain_rate != -1 && alive _objet_pointe &&
										(!isNull R3F_LOG_joueur_deplace_objet) && R3F_LOG_joueur_deplace_objet getVariable ["R3F_LOG_CF_depuis_usine", false] &&
										!(R3F_LOG_joueur_deplace_objet getVariable "R3F_LOG_disabled") && (R3F_LOG_joueur_deplace_objet != _objet_pointe) &&
										(vectorMagnitude velocity _objet_pointe < 6) && !(_objet_pointe getVariable "R3F_LOG_CF_disabled") &&
										_objet_pointe getVariable ["R3F_LOG_CF_side_addAction", side group _joueur] == side group _joueur;
									
									// Condition action revendre_usine_selection
									R3F_LOG_action_revendre_usine_selection_valide = _usine_autorisee_client && R3F_LOG_CFG_CF_sell_back_bargain_rate != -1 && alive _objet_pointe &&
										(isNull R3F_LOG_joueur_deplace_objet) && R3F_LOG_objet_selectionne getVariable ["R3F_LOG_CF_depuis_usine", false] &&
										(!isNull R3F_LOG_objet_selectionne) && (R3F_LOG_objet_selectionne != _objet_pointe) && !(R3F_LOG_objet_selectionne getVariable "R3F_LOG_disabled") &&
										(vectorMagnitude velocity _objet_pointe < 6) && !(_objet_pointe getVariable "R3F_LOG_CF_disabled") &&
										_objet_pointe getVariable ["R3F_LOG_CF_side_addAction", side group _joueur] == side group _joueur;
									
									// Condition action revendre_usine_direct
									R3F_LOG_action_revendre_usine_direct_valide = _usine_autorisee_client && R3F_LOG_CFG_CF_sell_back_bargain_rate != -1 &&
										_objet_pointe getVariable ["R3F_LOG_CF_depuis_usine", false] && (count crew _objet_pointe == 0 || _isUav) &&
										isNull R3F_LOG_joueur_deplace_objet && isNull (_objet_pointe getVariable ["R3F_LOG_est_transporte_par", objNull]) &&
										_objet_pas_en_cours_de_deplacement &&
										{
											_objet_pointe distance _x < 20 && !(_x getVariable "R3F_LOG_CF_disabled") &&
											_x getVariable ["R3F_LOG_CF_side_addAction", side group _joueur] == side group _joueur
										} count R3F_LOG_CF_liste_usines != 0;
									
									// Condition d�verrouiller objet
									R3F_LOG_action_deverrouiller_valide = _objet_pas_en_cours_de_deplacement && !_objet_deverrouille && !(_objet_pointe getVariable "R3F_LOG_disabled");
								}
								else
								{
									R3F_LOG_action_deplacer_objet_valide = false;
									R3F_LOG_action_remorquer_direct_valide = false;
									R3F_LOG_action_detacher_valide = false;
									R3F_LOG_action_selectionner_objet_charge_valide = false;
									R3F_LOG_action_remorquer_deplace_valide = false;
									R3F_LOG_action_charger_deplace_valide = false;
									R3F_LOG_action_charger_selection_valide = false;
									R3F_LOG_action_contenu_vehicule_valide = false;
									R3F_LOG_action_ouvrir_usine_valide = false;
									R3F_LOG_action_selectionner_objet_revendre_usine_valide = false;
									R3F_LOG_action_revendre_usine_direct_valide = false;
									R3F_LOG_action_revendre_usine_deplace_valide = false;
									R3F_LOG_action_revendre_usine_selection_valide = false;
									R3F_LOG_action_deverrouiller_valide = false;
								};
								
								// Si le joueur est pilote dans un h�liporteur
								if (call compile R3F_LOG_CFG_string_condition_allow_logistics_on_this_client &&
									!R3F_LOG_mutex_local_verrou && _vehicule_joueur != _joueur && driver _vehicule_joueur == _joueur && {_vehicule_joueur getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 2}
								) then
								{
									R3F_LOG_objet_addAction = _vehicule_joueur;
									
									// Note : pas de restriction li�e � R3F_LOG_proprietaire_verrou pour l'h�liportage
									
									// A partir des versions > 1.32, on interdit le lift si le hook de BIS est utilis�
									if (productVersion select 2 > 132) then
									{
										// Call compile car la commande getSlingLoad n'existe pas en 1.32
										_pas_de_hook = _vehicule_joueur call compile format ["isNull getSlingLoad _this"];
									}
									else
									{
										_pas_de_hook = true;
									};
									
									// Condition action heliporter
									R3F_LOG_action_heliporter_valide = !(_vehicule_joueur getVariable "R3F_LOG_disabled") && _pas_de_hook &&
										isNull (_vehicule_joueur getVariable "R3F_LOG_heliporte") && (vectorMagnitude velocity _vehicule_joueur < 6) &&
										{
											{
												(_x getVariable ["R3F_LOG_fonctionnalites", R3F_LOG_CST_zero_log] select 3) &&
												_x != _vehicule_joueur && !(_x getVariable "R3F_LOG_disabled") &&
												((getPosASL _vehicule_joueur select 2) - (getPosASL _x select 2) > 2 && (getPosASL _vehicule_joueur select 2) - (getPosASL _x select 2) < 15)
											} count (nearestObjects [_vehicule_joueur, ["All"], 15]) != 0
										};
									
									// Condition action heliport_larguer
									R3F_LOG_action_heliport_larguer_valide = !isNull (_vehicule_joueur getVariable "R3F_LOG_heliporte") && !(_vehicule_joueur getVariable "R3F_LOG_disabled") &&
										(vectorMagnitude velocity _vehicule_joueur < 25) && ((getPosASL _vehicule_joueur select 2) - (0 max getTerrainHeightASL getPos _vehicule_joueur) < 40);
								}
								else
								{
									R3F_LOG_action_heliporter_valide = false;
									R3F_LOG_action_heliport_larguer_valide = false;
								};
								
								sleep 0.4;
							};
						};
						
						/* Auto-d�tection permanente des objets sur le jeu */
						[] spawn {
							/**
							* Recherche p�riodiquement les nouveaux objets pour leur ajouter les fonctionnalit�s de logistique si besoin
							* Script � faire tourner dans un fil d'ex�cution d�di�
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							sleep 4;

							private
							[
								"_compteur_cyclique", "_liste_nouveaux_objets", "_liste_vehicules_connus", "_liste_statiques", "_liste_nouveaux_statiques",
								"_liste_statiques_connus", 	"_liste_statiques_cycle_precedent", "_count_liste_objets", "_i", "_objet", "_fonctionnalites",
								"_liste_purge", "_seuil_nb_statiques_avant_purge", "_seuil_nb_vehicules_avant_purge"
							];

							// Contiendra la liste des objets d�j� parcourus r�cup�r�s avec la commande "vehicles"
							_liste_vehicules_connus = [];
							// Contiendra la liste des objets d�rivant de "Static" (caisse de mun, drapeau, ...) d�j� parcourus r�cup�r�s avec la commande "nearestObjects"
							_liste_statiques_connus = [];
							// Contiendra la liste des objets "Static" r�cup�r�s lors du tour de boucle pr�c�cent (optimisation des op�rations sur les tableaux)
							_liste_statiques_cycle_precedent = [];


							_compteur_cyclique = 0;
							_seuil_nb_statiques_avant_purge = 150;
							_seuil_nb_vehicules_avant_purge = 150;

							while {true} do
							{
								if (!isNull player) then
								{
									// Tout les 4 ou sur ordre, on r�cup�re les nouveaux v�hicules du jeu
									if (_compteur_cyclique == 0 || R3F_LOG_PUBVAR_nouvel_objet_a_initialiser) then
									{
										R3F_LOG_PUBVAR_nouvel_objet_a_initialiser = false; // Acquittement local
										
										// Purge de _liste_vehicules_connus quand n�cessaire
										if (count _liste_vehicules_connus > _seuil_nb_vehicules_avant_purge) then
										{
											_liste_purge = [];
											{
												if (!isNull _x) then
												{
													_liste_purge pushBack _x;
												};
											} forEach _liste_vehicules_connus;
											
											_liste_vehicules_connus = _liste_purge;
											_seuil_nb_vehicules_avant_purge = count _liste_vehicules_connus + 75;
										};
										
										// Purge de _liste_statiques_connus quand n�cessaire
										if (count _liste_statiques_connus > _seuil_nb_statiques_avant_purge) then
										{
											_liste_purge = [];
											{
												if (!isNull _x &&
													{
														!isNil {_x getVariable "R3F_LOG_fonctionnalites"} ||
														(_x getVariable ["R3F_LOG_CF_depuis_usine", false])
													}
												) then
												{
													_liste_purge pushBack _x;
												};
											} forEach _liste_statiques_connus;
											
											_liste_statiques_connus = _liste_purge;
											_seuil_nb_statiques_avant_purge = count _liste_statiques_connus + 150;
										};
										
										// R�cup�ration des nouveaux v�hicules
										_liste_nouveaux_objets = vehicles - _liste_vehicules_connus;
										_liste_vehicules_connus = _liste_vehicules_connus + _liste_nouveaux_objets;
									}
									else
									{
										_liste_nouveaux_objets = [];
									};
									_compteur_cyclique = (_compteur_cyclique + 1) mod 4;
									
									// En plus des nouveaux v�hicules, on r�cup�re les statiques (caisse de mun, drapeau, ...) proches du joueur non connus
									// Optimisation "_liste_statiques_cycle_precedent" : et qui n'�taient pas proches du joueur au cycle pr�c�dent
									_liste_statiques = nearestObjects [player, ["Static"], 25];
									if (count _liste_statiques != 0) then
									{
										_liste_nouveaux_statiques = _liste_statiques - _liste_statiques_cycle_precedent - _liste_statiques_connus;
										_liste_statiques_connus = _liste_statiques_connus + _liste_nouveaux_statiques;
										_liste_statiques_cycle_precedent = _liste_statiques;
									}
									else
									{
										_liste_nouveaux_statiques = [];
										_liste_statiques_cycle_precedent = [];
									};
									
									_liste_nouveaux_objets = _liste_nouveaux_objets + _liste_nouveaux_statiques;
									_count_liste_objets = count _liste_nouveaux_objets;
									
									if (_count_liste_objets > 0) then
									{
										// On parcoure tous les nouveaux objets en 3 secondes
										for [{_i = 0}, {_i < _count_liste_objets}, {_i = _i + 1}] do
										{
											_objet = _liste_nouveaux_objets select _i;
											_fonctionnalites = [typeOf _objet] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique;
											
											// Si au moins une fonctionnalit�
											if (
												_fonctionnalites select 0 ||
												_fonctionnalites select 2 ||
												_fonctionnalites select 4 ||
												_fonctionnalites select 6
											) then
											{
												_objet setVariable ["R3F_LOG_fonctionnalites", _fonctionnalites, false];
												
												if (isNil {_objet getVariable "R3F_LOG_disabled"}) then
												{
													_objet setVariable ["R3F_LOG_disabled", R3F_LOG_CFG_disabled_by_default, false];
												};
												
												// Si l'objet est un objet d�pla�able/h�liportable/remorquable/transportable
												if (_fonctionnalites select 0) then
												{
													[_objet] call R3F_LOG_FNCT_objet_init;
												};
												
												// Si l'objet est un v�hicule h�liporteur
												if (_fonctionnalites select 2) then
												{
													[_objet] call R3F_LOG_FNCT_heliporteur_init;
												};
												
												// Si l'objet est un v�hicule remorqueur
												if (_fonctionnalites select 4) then
												{
													[_objet] call R3F_LOG_FNCT_remorqueur_init;
												};
												
												// Si l'objet est un v�hicule transporteur
												if (_fonctionnalites select 6) then
												{
													[_objet] call R3F_LOG_FNCT_transporteur_init;
												};
											};
											
											// Si l'objet a �t� cr�� depuis une usine, on ajoute la possibilit� de revendre � l'usine, quelque soit ses fonctionnalit�s logistiques
											if (_objet getVariable ["R3F_LOG_CF_depuis_usine", false]) then
											{
												_objet addAction [("<t color=""#ff9600"">" + format [STR_R3F_LOG_action_revendre_usine_direct, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")] + "</t>"), {_this call R3F_LOG_FNCT_usine_revendre_direct}, nil, 5, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_revendre_usine_direct_valide"];
											};
											
											sleep (0.07 max (3 / _count_liste_objets));
										};
									}
									else
									{
										sleep 3;
									};
								}
								else
								{
									sleep 2;
								};
							};
						};
						
						/*
						* Syst�me assurant la protection contre les blessures lors du d�placement d'objets
						* On choisit de ne pas faire tourner le syst�me sur un serveur d�di� par �conomie de ressources.
						* Seuls les joueurs et les IA command�es par les joueurs (locales) seront prot�g�s.
						* Les IA n'�tant pas command�es par un joueur ne seront pas prot�g�es, ce qui est un moindre mal.
						*/

						[] spawn {
							/**
							* Système assurant la protection contre les blessures des unités locales lors du déplacement manuels d'objets
							* Les objets en cours de transport/heliport/remorquage ne sont pas concernés.
							* 
							* Copyright (C) 2014 Team ~R3F~
							* 
							* This program is free software under the terms of the GNU General Public License version 3.
							* You should have received a copy of the GNU General Public License
							* along with this program.  If not, see <http://www.gnu.org/licenses/>.
							*/

							/** Contient la liste de tous les objets en cours de déplacements manuels */
							R3F_LOG_liste_objets_en_deplacement = [];

							/**
							* Fonction PVEH ajoutant les nouveaux objets en cours de déplacement dans la liste
							* @param 1 le nouvel objet en cours de déplacement
							*/
							R3F_LOG_FNCT_PVEH_nouvel_objet_en_deplacement =
							{
								private ["_objet"];
								
								_objet = _this select 1;
								
								R3F_LOG_liste_objets_en_deplacement = R3F_LOG_liste_objets_en_deplacement - [_objet];
								R3F_LOG_liste_objets_en_deplacement pushBack _objet;
								
								_objet allowDamage false;
							};
							"R3F_LOG_PV_nouvel_objet_en_deplacement" addPublicVariableEventHandler R3F_LOG_FNCT_PVEH_nouvel_objet_en_deplacement;

							/**
							* Fonction PVEH retirant de la liste les objets dont le déplacement est terminé
							* @param 1 l'objet dont le déplacement est terminé
							*/
							R3F_LOG_FNCT_PVEH_fin_deplacement_objet =
							{
								private ["_objet"];
								
								_objet = _this select 1;
								
								R3F_LOG_liste_objets_en_deplacement = R3F_LOG_liste_objets_en_deplacement - [_this select 1];
								
								// Limitation : si l'objet a été "allowDamage false" par ailleurs, il ne le sera plus. Voir http://feedback.arma3.com/view.php?id=19211
								_objet allowDamage true;
							};
							"R3F_LOG_PV_fin_deplacement_objet" addPublicVariableEventHandler R3F_LOG_FNCT_PVEH_fin_deplacement_objet;

							/**
							* Fonction traitant les event handler HandleDamage des unités locales,
							* si la blessure provient d'un objet en déplacement, la blessure est ignorée
							* @param voir https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HandleDamage
							* @return niveau de blessure inchangé si due au déplacement d'un objet, sinon rien pour laisser A3 gérer la blessure
							* @note implémentation de la commande getHit manquante ( http://feedback.arma3.com/view.php?id=18261 )
							*/
							R3F_LOG_FNCT_EH_HandleDamage =
							{
								private ["_unite", "_selection", "_blessure", "_source"];
								
								_unite = _this select 0;
								_selection = _this select 1;
								_blessure = _this select 2;
								_source = _this select 3;
								
								if (
									// Filtre sur les blessures de type choc/collision
									_this select 4 == "" && {(isNull _source || _source == _unite || _source in R3F_LOG_liste_objets_en_deplacement)
									&& {
										// Si l'unité est potentiellement en collision avec un objet en cours de déplacement
										{
											!isNull _x &&
											{
												// Calcul de collision possible unité-objet
												[
													_x worldToModel (_unite modelToWorld [0,0,0]), // position de l'unité dans le repère de l'objet en déplacement
													(boundingBoxReal _x select 0) vectorDiff [12, 12, 12], // bbox min élargie (zone de sûreté)
													(boundingBoxReal _x select 1) vectorAdd [12, 12, 12] // bbox max élargie (zone de sûreté)
												] call R3F_LOG_FNCT_3D_pos_est_dans_bbox
											}
										} count R3F_LOG_liste_objets_en_deplacement != 0
									}
								}) then
								{
									// Retourner la valeur de blessure précédente de l'unité
									if (_selection == "") then
									{
										damage _unite
									}
									else
									{
										_unite getHit _selection
									};
								};
							};

							sleep 5;

							while {true} do
							{
								private ["_idx_objet"];
								
								// Vérifier que les unités locales à la machine sont gérées, et ne plus gérées celles qui ne sont plus locales
								// Par chaque unité
								{
									// Unité non gérée
									if (isNil {_x getVariable "R3F_LOG_idx_EH_HandleDamage"}) then
									{
										// Et qui est locale
										if (local _x) then
										{
											// Event handler de à chaque blessure, vérifiant si elle est due à un objet en déplacement
											_x setVariable ["R3F_LOG_idx_EH_HandleDamage", _x addEventHandler ["HandleDamage", {_this call R3F_LOG_FNCT_EH_HandleDamage}]];
										};
									}
									// Unité déjà gérée
									else
									{
										// Mais qui n'est plus locale
										if (!local _x) then
										{
											// Suppresion des event handler de gestion des blessures
											_x removeEventHandler ["HandleDamage", _x getVariable "R3F_LOG_idx_EH_HandleDamage"];
											_x setVariable ["R3F_LOG_idx_EH_HandleDamage", nil];
										};
									};
								} forEach call {// Calcul du paramètre du forEach
									/*
									* Sur un serveur non-dédié, on ne protège que le joueur et son groupe (économie de ressources)
									* Les IA non commandées par des joueurs ne seront donc pas protégées, ce qui est un moindre mal.
									*/
									if (isServer && !isDedicated) then {if (!isNull player) then {units group player} else {[]}}
									/*
									* Chez un joueur (ou un serveur dédié), on protège toutes les unités locales.
									* Dans la pratique un serveur dédié n'appelle pas ce script, par choix, pour économiser les ressources.
									*/
									else {allUnits}
								};
								
								// Vérifier l'intégrité de la liste des objets en cours de déplacements, et la nettoyer si besoin
								for [{_idx_objet = 0}, {_idx_objet < count R3F_LOG_liste_objets_en_deplacement}, {;}] do
								{
									private ["_objet"];
									
									_objet = R3F_LOG_liste_objets_en_deplacement select _idx_objet;
									
									if (isNull _objet) then
									{
										R3F_LOG_liste_objets_en_deplacement = R3F_LOG_liste_objets_en_deplacement - [objNull];
										
										// On recommence la validation de la liste
										_idx_objet = 0;
									}
									else
									{
										// Si l'objet n'est plus déplacé par une unité valide
										if !(isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull]) ||
											{alive (_objet getVariable "R3F_LOG_est_deplace_par") && isPlayer (_objet getVariable "R3F_LOG_est_deplace_par")}
										) then
										{
											["R3F_LOG_PV_fin_deplacement_objet", _objet] call R3F_LOG_FNCT_PVEH_fin_deplacement_objet;
											
											// On recommence la validation de la liste
											_idx_objet = 0;
										}
										// Si l'objet est toujours en déplacement, on poursuit le parcours de la liste
										else {_idx_objet = _idx_objet+1;};
									};
								};
								
								sleep 90;
							};
						};
					};
					
					R3F_LOG_active = true;
				};
				
				GOM_fnc_aircraftLoadoutSavePreset = 
				{
					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_index = 0;
						_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];
					_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];

					_preset = [typeof _veh,ctrlText 1401,GetPylonMagazines _veh,((GetPylonMagazines _veh) apply {_index = _index + 1;_veh AmmoOnPylon _index}),[lbText [2100,lbCursel 2100],getObjectTextures _veh],_pylonOwners,_priorities,true];

					if (!(_presets isEqualTo []) AND {count (_presets select {ctrlText 1401 isequalTo (_x select 1)}) > 0}) exitWith {systemchat "Preset exists! Chose another name!";playsound "Simulation_Fatal"};


					if (ctrlText 1401 isEqualTo "") exitWith {systemchat "Invalid name! Choose another one!";playSound "Simulation_Fatal"};
					_presets pushback _preset;
					profileNamespace setVariable ["GOM_fnc_aircraftLoadoutPresets",_presets];
							_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

					systemchat format ["Saved %1 preset: %2!",_vehDispName,str ctrlText 1401];
					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					lbsetcursel [2101,((lbsize 2101) -1)];
					true
				};

				GOM_fnc_aircraftLoadoutDeletePreset = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];

					_toDelete = _presets select {(_x select 1) isEqualTo lbText [2101,lbcursel 2101]};
					if (count _toDelete isequalto 0)  exitWith {systemchat "Preset not found!";playsound "Simulation_Fatal"};
					_presets = _presets - [_toDelete select 0];
					profileNamespace setVariable ["GOM_fnc_aircraftLoadoutPresets",_presets];
						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					true
				};

				GOM_fnc_aircraftLoadoutLoadPreset = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					if (lbCursel 2101 < 0) exitWith {systemchat "No preset selected."};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_preset = [];
					{if((_x select 0) isEqualTo typeOf _veh AND (_x select 1) isEqualTo lbText [2101,lbcursel 2101]) then{_preset = _x;}}forEach _presets;
					_preset params ["_vehType","_presetName","_pylons","_pylonAmmoCounts","_textureParams","_pylonOwners","_pylonPriorities",["_restrictedLoadout",true]];

					[_obj,true,_pylons,_pylonAmmoCounts] call	GOM_fnc_setPylonsRearm;
					[_veh,_pylonPriorities] remoteExec ["setPylonsPriority",0,true];
					_textureParams params ["_textureName","_textures"];
					{

						_veh setObjectTextureGlobal [_foreachIndex,_x];

					} forEach _textures;


					true
				};

				GOM_fnc_setPylonOwner = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];
					_ownerName = "Pilot";
					if (_pylonOwner isEqualTo []) then {_pylonOwner = [0];_ownerName = "Gunner"} else {_pylonOwner = []};

					ctrlSetText [1605,format ["%1 control",_ownerName]];

					_veh setVariable ["GOM_fnc_aircraftLoadoutPylonOwner",_pylonOwner,true];
					//_update = [_obj] call GOM_fnc_updateDialog;
					true
				};

				GOM_fnc_setPylonsRearm = 
				{

					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};
					params ["_obj",["_rearm",false],["_pylons",[]],["_pylonAmmoCounts",[]]];
					_nul = [_obj,_rearm,_pylons,_pylonAmmoCounts] spawn {

						params ["_obj",["_rearm",false],["_pylons",[]],["_pylonAmmoCounts",[]]];

							_veh = call compile lbData [1500,lbcursel 1500];



						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if (_veh getVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false]) exitWith {systemchat "Aircraft is currently being rearmed!"};
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",true,true];
						_activePylonMags = GetPylonMagazines _veh;
						if (_rearm) exitWith {

							[_obj] call GOM_fnc_clearAllPylons;
								_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];

							{
								_pylonOwner = if (_pylonOwners isequalto []) then {[]} else {_pylonOwners select (_foreachindex + 1)};

							[_veh,[_foreachindex+1,_x,true,_pylonOwner]] remoteexec ["setPylonLoadOut",0] ;
							[_veh,[_foreachIndex + 1,0]] remoteexec ["SetAmmoOnPylon",0] ;
							} foreach _pylons;
					{
							_mag = _activePylonMags select _forEachIndex;


								_pylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",[]];
								_pylonOwner = if (_pylonOwners isequalto []) then {[]} else {_pylonOwners select (_foreachindex + 1)};
								_maxAmount = (_pylonAmmoCounts select _forEachIndex);





							if (_maxamount < 24) then {

							for "_i" from 0 to _maxamount do {
							[_veh,[_foreachIndex + 1,_i]] remoteexec ["SetAmmoOnPylon",0];
							if (_i > 0) then {

							_sound = [_veh,_foreachIndex] call GOM_fnc_pylonSound;
							};
							};
							} else {

							[_veh,[_foreachIndex + 1,_maxamount]] remoteexec ["SetAmmoOnPylon",0] ;
							_sound = [_veh,_foreachIndex] call GOM_fnc_pylonSound;
							};



						} forEach _pylons;
						playSound "Click";
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false,true];
						_veh setVehicleAmmo 1;
						systemchat "All pylons, counter measures and board guns rearmed!";
					true
					};



					_mounts = [];
						{



								_mount = [_veh,_forEachIndex+1,_x] spawn {
									params ["_veh","_ind","_mag"];

						_maxAmount = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");





							if (_maxamount < 24) then {

							for "_i" from (_veh AmmoOnPylon _ind) to _maxamount do {
									[_veh,[_ind,_i]] remoteexec ["SetAmmoOnPylon",0];

							if (_i > 0) then {

							_sound = [_veh,_ind - 1] call GOM_fnc_pylonSound;
							}
							};
							} else {
									[_veh,[_ind,_maxamount]] remoteexec ["SetAmmoOnPylon",0];

							_sound = [_veh, _ind - 1] call GOM_fnc_pylonSound;
							};
						};
						_mounts pushback _mount;

						} forEach _activePylonMags;
						waituntil {!alive _veh OR {scriptdone _x} count _mounts isequalto count _mounts};
						playSound "Click";
						_veh setVariable ["GOM_fnc_aircraftLoadoutRearmingInProgress",false,true];
						_veh setVehicleAmmo 1;

						systemchat "All pylons, counter measures and board guns rearmed!";

					};
					true
				};

				GOM_fnc_setPylonsRepair = 
				{

					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};
					params ["_obj"];

					_veh = call compile  lbData [1500,lbcursel 1500];




					_repair = [_veh,_obj] spawn {
						params ["_veh","_obj"];
						_curDamage = damage _veh;
						_abort = false;
						_timer = 0;
						_highestDamaged = 0;
						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if(count getAllHitPointsDamage _veh == 0) then {_highestDamaged = damage _veh} else{
						{if(_x > 0.0) exitWith {_highestDamaged = _x;};} forEach (getAllHitPointsDamage _veh select 2);};
						if (_highestDamaged isEqualTo 0 && damage _veh == 0) exitWith {systemchat "Aircraft is already at 100% integrity!"};


						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");

							_repairTick = (1 / 10);
							_timeNeeded = ceil (_curDamage / _repairtick);

							_damDisp = [((_curDamage * 100) - 100) * -1] call GOM_fnc_roundByDecimals;
						_empty = false;
						

						
						while {
							(!isNil {{if(_x > 0.0) exitWith {_x};} forEach (getAllHitPointsDamage _veh select 2)}
							OR damage _veh > 0) AND alive _veh AND !_abort AND !_empty} do {
						

						_curDamage = damage _veh;

							_timeNeeded = ceil (_curDamage / _repairtick);

						_veh setdamage (_curDamage - _repairTick + 0.1);
						_veh setdamage _curDamage - _repairTick;
					_sound = [_veh] call GOM_fnc_pylonSound;

							_damDisp = [((_curDamage * 100) - 100) * -1] call GOM_fnc_roundByDecimals;
						
							_timeout = time + 1;
							_timer = _timer + 1;
										//_update = [_obj] call GOM_fnc_updateDialog;

						};
					};




					playSound "Click";

					true
				};

				GOM_fnc_setPylonsRefuel = 
				{
					if (lbCursel 1500 < 0) exitWith {systemchat "No aircraft selected!";false};

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];


					_refuel = [_veh,_obj] spawn {
						params ["_veh","_obj"];
						_curFuel = fuel _veh;
						_abort = false;
						_timer = 0;
						if (!alive _veh) exitWith {systemchat "Aircraft is destroyed!"};
						if (_curFuel isEqualTo 1) exitWith {systemchat "Aircraft is already at 100% fuel capacity!"};
						_maxFuel = getNumber (configfile >> "CfgVehicles" >> typeof _veh >> "fuelCapacity");
						_sourceDispname = selectRandom ["love and light","the love of friendship","a wondrous device","gimlis magic barrel"];

						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
						_fuel = round(_curFuel * _maxfuel);

						_missingFuel = _maxfuel - _fuel;
						_fillrate = 1800;
						_timeNeeded = ((_missingFuel / _fillrate) * 60);
						if(_timeNeeded isEqualTo 0) exitWith {systemChat "Aircraft is already at 100% fuel capacity!"};
						_fuelTick = ((1 - _curFuel) / _timeNeeded);
						_fuelPerTick = 1800 / 60;



						_empty = false;
						_leaking = false;
						while {fuel _veh < 0.99 AND alive _veh AND !_abort AND !_empty} do {


						_curFuel = fuel _veh;

						[_veh,(_curFuel + _fuelTick)] remoteExec ["setFuel",_veh];

						_fuel = [(_curFuel * _maxfuel),1] call GOM_fnc_roundByDecimals;

						_missingFuel = _maxfuel - _fuel;

								_timeNeeded = round ((_missingFuel / _fillrate) * 60);

							_timeout = time + 1;
							_timer = _timer + 1;
						};
							if (!_abort AND !_empty AND !_leaking) then {	systemchat format ["%1 filled up!",_vehDispName];

					} else {

					if (_abort) then {systemchat "Refuelling aborted!"};

					};

							playSound "Click";
						};
					true

				};

				GOM_fnc_getWeekday = 
				{

					params [["_date",date]];

					_date params ["_year","_m","_q"];

					_yeararray = toarray str _year apply {_x-48};

					_yeararray params ["_y1","_y2","_y3","_y4"];
					_J = ((_y1) * 10) + (_y2);
					_K = ((_y3) * 10) + (_y4);

					if (_m < 3) then {_m = _m + 12};

					["","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"] select (_q + floor ( ((_m + 1) * 26) / 10 ) + _K + floor (_K / 4) + floor (_J / 4) - (2 * _J)) mod 7

				};

				GOM_fnc_titleText = 
				{

					date params ["_year","_month","_day"];
					_checkdate = [_year,_month,_day];

					_lastCheck = player getVariable ["GOM_fnc_titleTextCheckDate",[[0,0,0],""]];
					_lastCheck params ["_lastDate","_weekDay"];

					if !(_checkDate isequalto _lastDate) then {

					_weekday = [] call GOM_fnc_getWeekday;
					player setvariable ["GOM_fnc_titleTextCheckDate",[_checkdate,_weekday]];

					};
					_date = format ["%1, %2.%3.%4",_weekday,_day,_month,_year];//suck it americans

					_posCheck = player getvariable ["GOM_fnc_titleTextPosChange",[[0,0,0],"",""]];
					_posCheck params ["_checkPos","_nearestloc","_coords"];


					if (player distance2d _checkPos > 50) then {
					_playerpos = getposasl player;
					_coords = mapGridPosition _playerpos;
					_nearLocs = nearestlocations [_playerpos,["NameMarine","NameVillage","NameCity","NameCityCapital"],5000,_playerpos];
					_nearlocs apply {text _x != ""};
					_nearestloc = "";
					if (_nearlocs isequalto []) then {_nearestloc = ""} else {
					_nearestloc = text (_nearlocs select 0) + " - ";
					};
					player setvariable ["GOM_fnc_titleTextPosChange",[_playerpos,_nearestLoc,_coords]];
					};


					_t = toString [71,114,117,109,112,121,32,79,108,100,32,77,97,110,115,32,65,105,114,99,114,97,102,116,32,76,111,97,100,111,117,116];

					_time = [daytime,"HH:MM:SS"] call BIS_fnc_timeToString;
					_text = format ["<t align='left' size='0.75'>%1Grid ""%2""<t align='center'>--- %3 ---<t align='right'>%4<br />%5",_nearestloc,_coords,_t,_date,_time];


					(findDisplay 57 displayctrl 1101) ctrlSetStructuredText parsetext _text;

				};

				GOM_fnc_roundByDecimals = 
				{

					params ["_num",["_digits",2]];
					round (_num * (10 ^ _digits)) / (10 ^ _digits)

				};

				GOM_fnc_updateDialog = 
				{

					params ["_obj",["_preset",false]];


					if (lbCursel 1500 < 0) exitWith {



						_obj = player;

					_availableTexts = ["<t color='#E51B1B'>Not available!</t>","<t color='#1BE521'>Available!</t>"];


					_fueltext = "";
					_repairtext = "";
					_rearmtext = "";

					_text = "";
					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

					};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_dispName = lbText [1500,lbCurSel 1500];

					if (lbcursel 2101 >= 0) exitWith {

					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					_preset = (_presets select {(_x select 0) isEqualTo typeOf _veh AND {(_x select 1) isEqualTo lbText [2101,lbcursel 2101]}}) select 0;
					_preset params ["_vehType","_presetName","_pylons","_pylonAmmoCounts","_textureParams","_pylonOwners","_priorities","_serialNumber"];
					_textureParams params ["_textureName","_textures"];

					_pylonInfoText = "";
					_sel = 0;
					_align = ["<t align='left'>","<t align='center'>","<t align='right'>"];
					_count = 0;
					_priorities = 	_veh getVariable ["GOM_fnc_pylonPriorities",[]];

					{
						_count = _count + 1;
						_owner = "Pilot";
						if !(_pylonOwners isEqualTo []) then {

						_owner = if ((_pylonowners select _forEachIndex+1) isEqualTo []) then {"Pilot"} else {"Gunner"};
					};

					_pylonDispname = getText (configfile >> "CfgMagazines" >> _x >> "displayName");
					_setAlign = _align select _sel;
						_sel = _sel + 1;
					_break = "";
					if (_sel > 2) then {_sel = 0;_break = "<br />"};
					if (count _pylons <= 6) then {_setAlign = "<t align='left'>";_break = "<br />"};

						_priority = "N/A";
						if (count _priorities > 0) then {

					_priority = _priorities select _foreachindex;
					};
							_pylonInfoText = _pylonInfoText + format ["%1Pyl%2: %3 Prio. %4 %5 (%6).%7",_setAlign,_count,_owner,_priority,_pylonDispname,_pylonAmmoCounts select _forEachIndex,_break];

						} forEach _pylons;
								_text = format ["<t align='center' size='0.75'>Selected %1 preset: %2 Tail No. %5<br /><br /><t align='left'>Livery: %3<br />%4",_dispName,_presetName,_textureName,_pylonInfoText,_serialNumber];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

						};

							if (lbCursel 1502 < 0 AND lbCursel 1501 >= 0) exitWith {


						_pylonInfoText = "";
						_sel = 0;
						_align = ["<t align='left'>","<t align='center'>","<t align='right'>"];
						_count = 0;
							_priorities = 	_veh getVariable ["GOM_fnc_pylonPriorities",[]];
						{
							_priority = "N/A";
							if (count _priorities > 0) then {

						_priority = _priorities select _foreachindex;
					};
							_count = _count + 1;
							_owner = "N/A";

						_ammo = _veh AmmoOnPylon (_foreachindex+1);

						_pylonDispname = getText (configfile >> "CfgMagazines" >> _x >> "displayName");
						_setAlign = _align select _sel;
							_sel = _sel + 1;
						_break = "";
						if (_sel > 2) then {_sel = 0;_break = "<br />"};
						if (count _pylons <= 6) then {_setAlign = "<t align='left'>";_break = "<br />"};
							_pylonInfoText = _pylonInfoText + format ["%1Pyl%2: %3 Prio. %4 %5 (%6).%7",_setAlign,_count,_owner,_priority,_pylonDispname,_ammo,_break];

						} forEach GetPylonMagazines _veh;
								_text = format ["<t align='center' size='0.75'>%1 current loadout:<br /><br /><t align='left' size='0.75'><br />%2",_dispName,_pylonInfoText];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;

						};

						_driverName = name assigneddriver _veh;

						_rank = [assignedDriver _veh,"displayName"] call BIS_fnc_rankParams;
						_rank = _rank + " ";
						if (assigneddriver _veh isEqualTo objnull) then {_driverName = "No Pilot";_rank = ""};

						_mag = "N/A";
						_get = "";
						if (lbcursel 1502 > -1) then {_get = (lbdata [1502,(lbCursel 1502)]);};
						_ind2 = "N/A";
						_pylonMagDispName = getText (configfile >> "CfgMagazines" >> _get >> "displayName");
						_pylonMagType = getText (configfile >> "CfgMagazines" >> _get >> "displayNameShort");
						_pylonMagDetails = getText (configfile >> "CfgMagazines" >> _get >> "descriptionShort");
						if (_pylonMagDispName isequalto "") then {_pylonMagDispName = "N/A"};
						if (_pylonMagType isequalto "") then {_pylonMagType = "N/A"};
						if (_pylonMagDetails isequalto "") then {_pylonMagDetails = "N/A"};
						_pyl = "N/A";
						if (lbcursel 1501 > -1) then {_pyl = (lbdata [1501,(lbCursel 1501)]);};

						_curFuel = fuel _veh;

						_maxFuel = getNumber (configfile >> "CfgVehicles" >> typeof _veh >> "fuelCapacity");
						_fuel = [(_curFuel * _maxfuel),1] call GOM_fnc_roundByDecimals;

							_missingFuel = _maxfuel - _fuel;

						_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];

						_pylonOwnerName = "Pilot";
						_nextOwnerName = "Gunner";
						if !(_pylonOwner isEqualTo []) then {_pylonOwnerName = "Gunner"};
						_ownerText = format ["Operated by: %1",_pylonOwnerName];

						_integrity = [((damage _veh * 100) - 100) * -1] call GOM_fnc_roundByDecimals;

						_pylontext = format ["Mount %1 on %2 - %3<br /><br /><t align='left'>Weapon Type: %4<br />Details: %5",_pylonMagDispName,_pyl,_ownertext,_pylonMagType,_pylonMagDetails];

							if (lbcursel 1502 < 0) then {_pylontext = ""};

							_kills = _veh getVariable ["GOM_fnc_aircraftLoadoutTrackStats",[]];

							_killtext = if (_kills isequalto []) then {"Confirmed kills:<br />None"} else {
							_kills params ["_infantry","_staticWeapon","_cars","_armored","_chopper","_plane","_ship","_building","_parachute"];

							_typeNamesS = ["infantry","static weapon","vehicle","armored vehicle","helicopter","plane","ship","building","parachuting kitten"];
							_typeNamesPL = ["infantry","static weapons","vehicles","armored vehicles","helicopters","planes","ships","buildings","parachuting kittens"];

							_out = "Confirmed kills:<br />";
							_index = -1;
							_killText = _kills apply {_index = _index + 1;_kind = ([_typeNamesS select _index,_typeNamesPL select _index] select (_x > 1));
								if (_x > 0) then {

									_out = _out + (format ["%1 %2, ",_x,_kind])};

							};
					_out = _out select [0,count _out - 2];
					_out = _out + ".";
					_out
							};

					_landings = _veh getvariable ["GOM_fnc_aircraftStatsLandings",0];

					_landingtext = format ["Successful landings: %1<br />",_landings];
					if (typeof _veh iskindof "Helicopter") then {_landingtext = "<br />"};
					if (lbcursel 1502 >= 0) then {_landingtext = "";_killtext = ""};


						_tailNumber = [] call GOM_fnc_aircraftGetSerialNumber;


						_text = format ["<t align='center' size='0.75'>%1 - %11, Integrity: %2%3<br />Pilot: %4%5<br />Fuel: %6l / %7l<br />%8<br />%9<br />%10",_dispName,_integrity,"%",_rank,_driverName,_fuel,_maxFuel,_pylontext,_landingtext,_killtext,_tailnumber];

						(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext _text;
					true
				};

				GOM_fnc_updateVehiclesLB = 
				{


					params ["_obj"];


					_vehicles = (_obj nearEntities [["Air", "Car", "Motorcycle", "Tank", "StaticWeapon"],50]) select {alive _x};
					_lastVehs = _obj getVariable ["GOM_fnc_setPylonLoadoutVehicles",[]];
					if (_vehicles isEqualTo []) exitWith {true};
					if (_vehicles isEqualTo _lastVehs AND !(lbsize 1500 isequalto 0)) exitWith {true};//only update this when really needed, called on each frame
					_obj setVariable ["GOM_fnc_setPylonLoadoutVehicles",_vehicles,true];


					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>No aircraft in range (50m)!";
					lbclear 1500;


					{

						_dispName = gettext (configfile >> "CfgVehicles" >> typeof _x >> "displayName");
						_form = format ["%1",_dispName];
						lbAdd [1500,_form];
						lbSetData [1500,_foreachIndex,_x call BIS_fnc_objectVar];
					} forEach _vehicles;

				};

				GOM_fnc_CheckComponents = 
				{

					params ["_ctrlParams","_obj"];
					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_vehDispName = getText (configfile >> "CfgVehicles" >> typeOf _veh >> "displayName");
					_ctrlParams params ["_ctrl","_state"];
					_set = [false,true] select _state;

					if (_set) then {

						if (str _ctrl find "2800" > -1) then {systemchat format ["%1 will now report remote targets!",_vehDispName];_veh setVehicleReportRemoteTargets _set};

						if (str _ctrl find "2801" > -1) then {systemchat format ["%1 will now receive remote targets!",_vehDispName];_veh setVehicleReceiveRemoteTargets _set};

						if (str _ctrl find "2802" > -1) then {systemchat format ["%1 will now report its own position!",_vehDispName];_veh setVehicleReportOwnPosition _set};

						} else {

						if (str _ctrl find "2800" > -1) then {systemchat format ["%1 will no longer report remote targets!",_vehDispName];_veh setVehicleReportRemoteTargets _set};

						if (str _ctrl find "2801" > -1) then {systemchat format ["%1 will no longer receive remote targets!",_vehDispName];_veh setVehicleReceiveRemoteTargets _set};

						if (str _ctrl find "2802" > -1) then {systemchat format ["%1 will no longer report its own position!",_vehDispName];_veh setVehicleReportOwnPosition _set};



					};
					playSound "Click";
					true
				};

				GOM_fnc_clearAllPylons = 
				{


					if (!(findDisplay 57 isequalto displaynull) AND lbcursel 1500 < 0) exitWith {"No aircraft selected!"};
					params [["_veh",call compile lbData [1500,lbcursel 1500]]];
					_nosound = false;
					if (findDisplay 57 isequalto displaynull) then {_nosound = true} else {_veh = call compile lbdata [1500,lbcursel 1500]};
					_activePylonMags = GetPylonMagazines _veh;

					{

						[_veh,[_foreachIndex + 1,"",true]] remoteexec ["setPylonLoadOut",0];
						[_veh,[_foreachIndex + 1,0]] remoteexec ["SetAmmoOnPylon",0];
						if (!_nosound) then {

					_sound = [_veh,_foreachindex] call GOM_fnc_pylonSound;
					};

						} forEach _activePylonMags;

							if (!_nosound) then {
						playSound "Click";
					};
						_pylonWeapons = [];
						{ _pylonWeapons append getArray (_x >> "weapons") } forEach ([_veh, configNull] call BIS_fnc_getTurrets);
						{ [_veh,_x] remoteexec ["removeWeaponGlobal",0] } forEach ((weapons _veh) - _pylonWeapons);

						systemchat "All pylons cleared!";
					true
				};

				GOM_fnc_aircraftSetSerialNumber = 
				{


					params [["_veh",call compile (lbData [1500,lbcursel 1500])],["_number",ctrltext 1400]];


					_selections = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "hiddenSelections");
					_textures = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "hiddenSelectionsTextures");
					_numberTextures = _textures select {toUpper _x find "NUMBER" > 0};



					if (lbcursel 1501 >= 0 OR lbcursel 1502 >= 0) exitWith {false};
					if (_numberTextures isequalto []) exitWith {
						ctrlSetText [1400,"N/A"];
						systemchat "Aircraft does not support tail numbers.";playsound "Simulation_Fatal"; false};
					_index = _textures find (_numberTextures select 0);

					if (count _number > 3) then {_number = _number select [0,3];systemchat "Invalid Number, using first 3 digits instead!";ctrlSetText [1400,_number select [0,3]];
					};
					_numberArray = toarray _number;

					_zeroesneeded = 3 - count _numberarray;
					_fill = [];
					_fill resize (3 - count _numberarray);
					_fill = _fill apply {48};

					_numberarray = _fill + _numberarray;
					_numberarray = _numberarray apply {parsenumber tostring [_x]};
					_count = 0;
					_numberarray apply {

						_oldSuffix = (_textures select _index) select [count (_textures select _index) - 7,7];
						_oldPrefix = (_textures select _index) select [0,count (_textures select _index) - 9];
						_newTexture = _oldPrefix + "0" + str _x + _oldsuffix;
						_veh setObjectTextureGlobal [(_index + _count),_newTexture];
						_count = _count + 1;

					};
					_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
					systemchat format ["Changed %1 tail number to: %2",_vehDispName,str _number];

				};

				GOM_fnc_pylonSound = 
				{

					params ["_veh",["_pylon",-1]];

					_soundpos = getPosASL _veh;
					if (_pylon >= 0) then {

					_selections = selectionnames _veh;
					_presort = _selections select {(toupper _x find "PYLON") >= 0 AND parsenumber (_x select [count _x - 3,3]) > 0};
					_presort apply {[parsenumber (_x select [count _x - 3,3]),_x]};
					_presort sort true;

					};

						_rndSound = selectRandom ['FD_Target_PopDown_Large_F','FD_Target_PopDown_Small_F','FD_Target_PopUp_Small_F'];
						_getPath = getArray (configfile >> "CfgSounds" >> _rndSound >> "sound");
						_path = _getPath select 0;

					true
				};

				GOM_fnc_properWeaponRemoval = 
				{

					params ["_veh","_pylonToCheck"];

					_currentweapons = weapons _veh;
					_pylons = GetPylonMagazines _veh;
					_pylonWeapons = _pylons apply {getText ((configfile >> "CfgMagazines" >> _x >> "pylonWeapon"))};
					_weaponToCheck = _pylonweapons select lbcursel 1501;
					_check = (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1);
					_check2 = _pylonweapons select {_x isEqualTo _weaponToCheck};
					if (count (_pylonweapons select {_x isEqualTo _weaponToCheck}) isEqualTo 1) then {_veh removeWeaponGlobal _weaponToCheck;Systemchat ("Removed " + _weaponToCheck)};//remove the current pylon weapon if no other pylon is using it

				};

				GOM_fnc_installPylons = 
				{

					params ["_veh","_pylonNum","_mag","_finalAmount","_magDispName","_pylonName"];
					_weaponCheck = [_veh,_mag] call GOM_fnc_properWeaponRemoval;
					_check = _veh getVariable ["GOM_fnc_airCraftLoadoutPylonInstall",[]];

					if (_pylonNum in _check) exitWith {systemchat "Installation in progress!"};
					_pylonOwner = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwner",[]];

					_pylonOwnerName = "Pilot";
					_nextOwnerName = "Gunner";
					if !(_pylonOwner isEqualTo []) then {_pylonOwnerName = "Gunner"};
					_initArray = GetPylonMagazines _veh;
					_init = [];
					_initArray apply {_init pushback []};//should solve r3vos bug, might be because undefined pylon owner
					_storePylonOwners = _veh getVariable ["GOM_fnc_aircraftLoadoutPylonOwners",_init];//maybe r3vos bug
					_storePylonOwners set [_pylonNum,_pylonOwner];
					_veh setVariable ["GOM_fnc_aircraftLoadoutPylonOwners",_storePylonOwners,true];

					_check pushback _pylonNum;
					_veh setVariable ["GOM_fnc_airCraftLoadoutPylonInstall",_check,true];



						[_veh,[_pylonNum,"",true,_pylonOwner]] remoteexec ["setPylonLoadOut",0];
						[_veh,[_pylonNum,_mag,true,_pylonOwner]] remoteexec ["setPylonLoadOut",0];



						[_veh,[_pylonNum,0]] remoteexec ["SetAmmoOnPylon",0];

						//[_ammosource,_mag,_veh] call GOM_fnc_handleAmmoCost;
					if (_finalamount <= 24) then {

					for "_i" from 1 to _finalamount do {


						[_veh,[_pylonNum,_i]] remoteexec ["SetAmmoOnPylon",0];
						_sound = [_veh,_pylonNum-1] call GOM_fnc_pylonSound;

					};

					} else {

						[_veh,[_pylonNum,_finalamount]] remoteexec ["SetAmmoOnPylon",0];
						_sound = [_veh,_pylonNum-1] call GOM_fnc_pylonSound;
					};
						//_ammosource setvariable ["GOM_fnc_aircraftLoadoutBusyAmmoSource",false,true];
					_checkOut = _veh getVariable ["GOM_fnc_airCraftLoadoutPylonInstall",[]];
					_checkOut = _checkOut - [_pylonNum];
					_veh setVariable ["GOM_fnc_airCraftLoadoutPylonInstall",_checkOut,true];

					systemchat format ["Successfully installed %1 %2 on %3!",_finalAmount,_magDispName,_pylonName];
					true
				};

				GOM_fnc_pylonInstallWeapon = 
				{

					params ["_obj"];



					if (lbCursel 1502 < 0 OR lbCursel 1501 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];

					_mag = lbdata [1502,lbCurSel 1502];
					_magDispName = getText (configfile >> "CfgMagazines" >> _mag >> "displayName");

					_maxAmount = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");

					_setAmount = parsenumber (ctrlText 1400);//only allows numbers

					_finalAmount = _setAmount min _maxAmount max 0;//limit range

					if (_setAmount > _maxAmount) then {systemchat "Invalid number, defaulting to allowed amount.";playsound "Simulation_Fatal";ctrlsetText [1400,str _maxAmount]};

					_pylonNum = lbCurSel 1501 + 1;
					_pylonName = lbdata [1501,lbCurSel 1501];


					_add = [_veh,_pylonNum,_mag,_finalAmount,_magDispName,_pylonName] spawn GOM_fnc_installPylons;


					playSound "Click";
					true
				};

				GOM_fnc_aircraftLoadoutPaintjob = 
				{

					params ["_obj",["_apply",false]];

					if (lbCursel 1500 < 0) exitWith {false};
					lbClear 2100;
					lbAdd [2100,"Livery"];
					_veh = call compile  lbData [1500,lbcursel 1500];
						_colorConfigs = "true" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources");
						_vehDispName = getText (configfile >> "CfgVehicles" >> typeof _veh >> "displayName");
						_colorTextures = [""];
						if (count _colorConfigs > 0) then {

							_colorNames = [""];
							{
							_colorNames pushback (getText (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "displayName"));
							lbAdd [2100,(getText (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "displayName"))];
							_colorTextures pushback (getArray (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources" >> configName _x >> "textures"));
						} foreach _colorConfigs;

						if (_apply AND lbCurSel 2100 > 0) then {

						{
						_index = (_colorTextures select (lbCurSel 2100)) find _x;
						_veh setObjectTextureGlobal [_index, (_colorTextures select (lbCurSel 2100)) select _index];
					} foreach (_colorTextures select (lbCurSel 2100));
					};
						playSound "Click";
					};

					true
				};

				GOM_fnc_aircraftGetSerialNumber = 
				{

					if (lbcursel 1500 < 0) exitwith {false};

					params [["_veh",call compile (lbdata [1500,lbcursel 1500])]];

					_textures = getObjectTextures _veh;
					_numberTextures = _textures select {toUpper _x find "NUMBER" > 0};

					if (_numberTextures isequalto [] AND lbcursel 1501 < 0 AND lbcursel 1502 < 0) exitWith {ctrlSetText [1400,"N/A"];
					"N/A"};

					_texture = _numbertextures select 0;
					_index = _textures find _texture;
					_output = "";

					_numbertextures apply {

						_number = _x select [count _x - 8,1];
						_index = _index + 1;
						_output = _output + _number;

					};
					_output

				};

				GOM_fnc_updateAmmoCountDisplay = 
				{

					if (lbCursel 1500 >= 0 AND lbCursel 1501 < 0 AND lbCursel 1502 < 0) exitWith {

					ctrlSettext [1600,format ["Set Serial Number",""]];
					(findDisplay 57 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Serial Number:";
					ctrlSetText [1400,[] call GOM_fnc_aircraftGetSerialNumber];

					};

					if (lbCursel 1500 < 0) exitWith {false};
					if (lbCursel 1501 < 0) exitWith {false};
					if (lbCursel 1502 < 0) exitWith {false};


					ctrlSettext [1600,"Install Weapon"];

					(findDisplay 57 displayctrl 1105) ctrlSetStructuredText parsetext "<t align='center'>Amount:";

					_mag = lbdata [1502,lbCursel 1502];
					_count = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");

					ctrlSetText [1400,str _count];

					true
				};

				GOM_fnc_setPylonPriority = 
				{

					params ["_obj"];

					if (lbCursel 1501 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_count = 0;
					_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",(GetPylonMagazines _veh) apply {_count = _count + 1;_count}];//I fucking love apply

					_selectedPriority = _priorities select lbcursel 1501;
					if ("NOCOUNT" in _this) exitWith {

						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
					};

					_keys = findDisplay 57 getVariable ["GOM_fnc_keyDown",["","",false,false,false]];
					_keys params ["","",["_keyshift",false],["_keyctrl",false],["_keyALT",false]];

						if (_keyshift) exitWith {
							_selectedPriority = _selectedPriority - 1;
						if (_selectedPriority < 1) then {_selectedPriority = count _priorities};


							_priorities set [lbcursel 1501,_selectedPriority];

						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];

							};
						if (_keyALT) exitWith {
							_priorities = _priorities apply {_selectedPriority};
							systemchat format ["All pylons priority set to %1",_selectedPriority];
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1",_selectedPriority]];

						};

						if (_keyctrl) exitWith {
					systemchat format ["All pylons priority set to 1",""];
							_priorities = _priorities apply {1};
						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", 1]];

						};

					_selectedPriority = _selectedPriority + 1;

						if (_selectedPriority > count _priorities) then {_selectedPriority = 1};

							_priorities set [lbcursel 1501,_selectedPriority];

						_veh setVariable ["GOM_fnc_pylonPriorities",_priorities,true];
						[_veh,_priorities] remoteExec ["setPylonsPriority",0,true];
						ctrlsettext [1610,format ["Priority: %1", _selectedPriority]];


				};

				GOM_fnc_fillPylonsLB = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];


					_pylon = lbData [1501,lbcursel 1501];
					_getCompatibles = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons" >> _pylon >> "hardpoints");

					if (_getCompatibles isEqualTo []) then {

						//darn BI for using "Pylons" and "pylons" all over the place as if it doesnt fucking matter ffs honeybadger

						_getCompatibles = getArray (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "pylons" >> _pylon >> "hardpoints");

					};



					lbClear 1502;

					_validPylonMags = GOM_list_allPylonMags;
					_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};

					
					if (GOM_fnc_allowAllPylons) then {

						_validPylonMags = GOM_list_allPylonMags;
						_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};

					} else {

						_validPylonMags = GOM_list_allPylonMags select {!((getarray (configfile >> "CfgMagazines" >> _x >> "hardpoints") arrayIntersect _getCompatibles) isEqualTo [])};
						_validDispNames = _validPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};
					};

					{

						lbAdd [1502,_validDispNames select _foreachIndex];
						lbsetData [1502,_foreachIndex,_x];

					} forEach _validPylonMags;
					true
				};

				GOM_fnc_updatePresetLB = 
				{

					params ["_obj"];

					if (lbCursel 1500 < 0) exitWith {false};
					_veh = call compile  lbData [1500,lbcursel 1500];
					_presets = profileNamespace getVariable ["GOM_fnc_aircraftLoadoutPresets",[]];
					

					_validPresets = _presets select {(_x select 0) isEqualTo typeOf _veh};
					lbClear 2101;
					{

						lbAdd [2101,_x select 1];

					} forEach _validPresets;
					true
				};

				GOM_fnc_setPylonLoadoutLBPylonsUpdate = 
				{

					params ["_obj"];


					if (lbCursel 1500 < 0) exitWith {false};

					_veh = call compile  lbData [1500,lbcursel 1500];
					_updateLB = [_obj] call GOM_fnc_updatePresetLB;
					_validPylons = (("isClass _x" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons")) apply {configname _x});

					lbClear 1501;
					{

						lbAdd [1501,_x];
						lbsetData [1501,_foreachIndex,_x];

					} forEach _validPylons;

						_colorConfigs = "true" configClasses (configfile >> "CfgVehicles" >> typeof _veh >> "textureSources");
						if (_colorConfigs isequalto []) then {lbclear 2100;lbAdd [2100,"No paintjobs available."];lbSetCurSel [2100,0]};

					findDisplay 57 displayCtrl 2800 cbSetChecked (vehicleReportRemoteTargets _veh);
					findDisplay 57 displayCtrl 2801 cbSetChecked (vehicleReceiveRemoteTargets _veh);
					findDisplay 57 displayCtrl 2802 cbSetChecked (vehicleReportOwnPosition _veh);

					playSound "Click";
					true
				};

				GOM_fnc_aircraftLoadout = 
				{

					params ["_obj", "_allPylons"];
					GOM_fnc_allowAllPylons = _allPylons;
					_display = [] call JEW_fnc_dynamicLoadout;
					playSound "Click";
					(findDisplay 57 displayctrl 1100) ctrlSetStructuredText parsetext "<t align='center'>Select an aircraft!";

					lbclear 1500;
					lbclear 1501;
					lbclear 1502;


					lbadd [2100,"Livery"];
					lbSetCurSel [2100,0];


					_getvar = _obj call BIS_fnc_objectVar;
					findDisplay 57 displayCtrl 1500 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;lbsetcursel [1502,-1];lbclear 1501;lbsetcursel [1501,-1];[%1] call GOM_fnc_setPylonLoadoutLBPylonsUpdate;
					;[%1] call GOM_fnc_aircraftLoadoutPaintjob;",_getvar]];
						findDisplay 57 displayCtrl 1501 ctrlAddEventHandler ["LBSelChanged",format ["lbclear 1502;[%1] call GOM_fnc_fillPylonsLB;[%1,'NOCOUNT'] call GOM_fnc_setPylonPriority
					",_getvar]];
						findDisplay 57 displayCtrl 1502 ctrlAddEventHandler ["LBSelChanged",format ["[%1] call GOM_fnc_updateAmmoCountDisplay;",_getvar]];

						findDisplay 57 displayCtrl 2100 ctrlAddEventHandler ["LBSelChanged",format ["[%1,true] call GOM_fnc_aircraftLoadoutPaintjob",_getvar]];
						findDisplay 57 displayCtrl 2101 ctrlAddEventHandler ["LBSelChanged",format ["",_getvar]];
						buttonSetAction [1600, format ["[%1] call GOM_fnc_pylonInstallWeapon;[] call GOM_fnc_aircraftSetSerialNumber",_getvar]];
						buttonSetAction [1601, format ["[%1] call GOM_fnc_clearAllPylons",_getvar]];
						buttonSetAction [1602, format ["[%1] call GOM_fnc_setPylonsRepair",_getvar]];
						buttonSetAction [1603, format ["[%1] call GOM_fnc_setPylonsRefuel",_getvar]];
						buttonSetAction [1604, format ["[%1] call GOM_fnc_setPylonsReArm",_getvar]];
						buttonSetAction [1605, format ["[%1] call GOM_fnc_setPylonOwner",_getvar]];
						buttonSetAction [1606, format ["[%1] call GOM_fnc_aircraftLoadoutSavePreset",_getvar]];
						buttonSetAction [1607, format ["[%1] call GOM_fnc_aircraftLoadoutDeletePreset",_getvar]];
						buttonSetAction [1608, format ["[%1] call GOM_fnc_aircraftLoadoutLoadPreset",_getvar]];


						buttonSetAction [1610, format ["[%1] call GOM_fnc_setPylonPriority",_getvar]];

						findDisplay 57 displayAddEventHandler ["KeyDown",{findDisplay 57 setVariable ["GOM_fnc_keyDown",_this];if (_this select 3) then {ctrlEnable [1607,true];
							ctrlSetText [1607,"Delete"];
							ctrlSetText [1610,format ["Set all to 1",""]];
						};
						if (_this select 4) then {
						_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
						if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Set all to %1",_selectedPriority]];
						}
						};


					
						}];
						findDisplay 57 displayAddEventHandler ["KeyUp",{findDisplay 57 setVariable ["GOM_fnc_keyDown",[]];if (_this select 3) then {ctrlEnable [1607,false];ctrlSetText [1607,"CTRL"];

						_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
							if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Priority: %1",_selectedPriority]];
					};
						;};


					if (_this select 4) then {	_veh = call compile lbdata [1500,lbcursel 1500];
						_priorities = _veh getVariable ["GOM_fnc_pylonPriorities",[]];
							if (lbcursel 1501 >= 0) then {

						_selectedPriority = _priorities select lbcursel 1501;
						ctrlSetText [1610,format ["Priority: %1",_selectedPriority]];
					};
					;}



					}];
					ctrlEnable [1607,false];
					ctrlSetText [1607,"CTRL"];

					findDisplay 57 displayCtrl 2800 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					findDisplay 57 displayCtrl 2801 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					findDisplay 57 displayCtrl 2802 ctrlAddEventHandler ["CheckedChanged",format ["[_this,%1] call GOM_fnc_CheckComponents",_getvar]];
					_color = [0,0,0,0.6];
					_dark = [1100,1101,1102,1103,1104,1105,1400,1401,1500,1501,1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,2100,2101];
					{

						findDisplay 57 displayCtrl _x ctrlSetBackgroundColor _color;


					} forEach _dark;
					GOM_fnc_aircraftLoadoutObject = _obj;
					_ID = addMissionEventHandler ["EachFrame",{



						_vehicles = [GOM_fnc_aircraftLoadoutObject] call GOM_fnc_updateVehiclesLB;

						if (displayNull isEqualTo findDisplay 57) exitWith {

							removeMissionEventHandler ["EachFrame",_thisEventHandler];
							_display = [] spawn GOM_fnc_showResourceDisplay;
							playSound "Click";

						};

						_check = [_obj] call GOM_fnc_updateDialog;
						[] call GOM_fnc_titleText;

						true

					}];
					GOM_fnc_aircraftLoadoutObject setvariable ["GOM_fnc_aircraftloadoutEH",_ID];

					true
				};

				JEW_fnc_dynamicLoadout =
				{
					disableSerialization;
					showChat true; comment "Fixes Chat Bug";
					createDialog "RscDisplayHintC";

					_GOM_dialog_aircraftLoadout = findDisplay 57;
					{_x ctrlshow false;_x ctrlEnable false} foreach (allcontrols _GOM_dialog_aircraftLoadout);


					profileNamespace setVariable ["JEW_LoadoutDisplay",_GOM_dialog_aircraftLoadout];

					_GOMRscStructuredText_1100 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1100];
					_GOMRscStructuredText_1100 ctrlSetStructuredText parseText "<t align='center'>";
					_GOMRscStructuredText_1100 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.26909723 * safezoneH + safezoneY, 0.39160157 * safezoneW, 0.15277778 * safezoneH];
					_GOMRscStructuredText_1100 ctrlCommit 0;



					_GOMRscStructuredText_1101 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1101];
					_GOMRscStructuredText_1101 ctrlSetStructuredText parseText "<t align='center'>--- Grumpy Old Mans Aircraft Loadout ---";
					_GOMRscStructuredText_1101 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.39160157 * safezoneW, 0.04340278 * safezoneH];
					_GOMRscStructuredText_1101 ctrlCommit 0;



					_GOMRscListbox_1500 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1500];
					_GOMRscListbox_1500 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1500 ctrlCommit 0;



					_GOMRscListbox_1501 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1501];
					_GOMRscListbox_1501 ctrlSetPosition [0.37597657 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1501 ctrlCommit 0;



					_GOMRscListbox_1502 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscListBox", 1502];
					_GOMRscListbox_1502 ctrlSetPosition [0.44824219 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.26388889 * safezoneH];
					_GOMRscListbox_1502 ctrlCommit 0;



					_GOMRscStructuredText_1102 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1102];
					_GOMRscStructuredText_1102 ctrlSetStructuredText parseText "<t align='center'>Select Vehicle";
					_GOMRscStructuredText_1102 ctrlSetPosition [0.3046875 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1102 ctrlCommit 0;



					_GOMRscStructuredText_1103 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1103];
					_GOMRscStructuredText_1103 ctrlSetStructuredText parseText "<t align='center'>Select Pylon";
					_GOMRscStructuredText_1103 ctrlSetPosition [0.37597657 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1103 ctrlCommit 0;



					_GOMRscStructuredText_1104 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1104];
					_GOMRscStructuredText_1104 ctrlSetStructuredText parseText "<t align='center'>Select Weapon";
					_GOMRscStructuredText_1104 ctrlSetPosition [0.44824219 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1104 ctrlCommit 0;



					_GOMRscButton_1600 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1600];
					_GOMRscButton_1600 ctrlSetStructuredText parseText "Install Weapon";
					_GOMRscButton_1600 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.5 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1600 ctrlCommit 0;



					_GOMRscButton_1601 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1601];
					_GOMRscButton_1601 ctrlSetStructuredText parseText "Clear all pylons";
					_GOMRscButton_1601 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.73090278 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1601 ctrlCommit 0;



					_GOMRscStructuredText_1105 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1105];
					_GOMRscStructuredText_1105 ctrlSetStructuredText parseText "<t align='center'>Amount:";
					_GOMRscStructuredText_1105 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.06152344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1105 ctrlCommit 0;



					_GOMRscEdit_1400 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscEdit", 1400];
					_GOMRscEdit_1400 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.46701389 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscEdit_1400 ctrlCommit 0;



					_GOMRscButton_1602 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1602];
					_GOMRscButton_1602 ctrlSetText "Repair";
					_GOMRscButton_1602 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.44444445 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1602 ctrlCommit 0;



					_GOMRscButton_1603 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1603];
					_GOMRscButton_1603 ctrlSetText "Refuel";
					_GOMRscButton_1603 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.47743056 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1603 ctrlCommit 0;



					_GOMRscButton_1604 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1604];
					_GOMRscButton_1604 ctrlSetText "Rearm";
					_GOMRscButton_1604 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.51041667 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1604 ctrlCommit 0;



					_GOMRscCheckbox_2800 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2800];
					_GOMRscCheckbox_2800 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2800 ctrlCommit 0;



					_GOMRscCheckbox_2801 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2801];
					_GOMRscCheckbox_2801 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.63194445 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2801 ctrlCommit 0;



					_GOMRscCheckbox_2802 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCheckBox", 2802];
					_GOMRscCheckbox_2802 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.66493056 * safezoneH + safezoneY, 0.01074219 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCheckbox_2802 ctrlCommit 0;



					_GOMRscStructuredText_1003 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1003];
					_GOMRscStructuredText_1003 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Report Remote Targets";
					_GOMRscStructuredText_1003 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.08789063 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1003 ctrlCommit 0;



					_GOMRscStructuredText_1004 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1004];
					_GOMRscStructuredText_1004 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Receive Remote Targets";
					_GOMRscStructuredText_1004 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.63194445 * safezoneH + safezoneY, 0.08789063 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1004 ctrlCommit 0;



					_GOMRscStructuredText_1005 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscStructuredText", 1005];
					_GOMRscStructuredText_1005 ctrlSetStructuredText parseText "<t align='left' size='0.7'>Report Own Position";
					_GOMRscStructuredText_1005 ctrlSetPosition [0.53125 * safezoneW + safezoneX, 0.66493056 * safezoneH + safezoneY, 0.09277344 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscStructuredText_1005 ctrlCommit 0;



					_GOMRscFrame_1800 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1800];
					_GOMRscFrame_1800 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.40136719 * safezoneW, 0.52604167 * safezoneH];
					_GOMRscFrame_1800 ctrlCommit 0;



					_GOMRscButton_1610 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1610];
					_GOMRscButton_1610 ctrlSetText "Priority: 1";
					_GOMRscButton_1610 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.53298612 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1610 ctrlCommit 0;



					_GOMRscButton_1605 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1605];
					_GOMRscButton_1605 ctrlSetText "Pilot control";
					_GOMRscButton_1605 ctrlSetPosition [0.52050782 * safezoneW + safezoneX, 0.56597223 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1605 ctrlCommit 0;



					_GOMRscCombo_2100 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCombo", 2100];
					_GOMRscCombo_2100 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.54340278 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCombo_2100 ctrlCommit 0;



					_GOMRscFrame_1801 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1801];
					_GOMRscFrame_1801 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1801 ctrlCommit 0;



					_GOMRscFrame_1802 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1802];
					_GOMRscFrame_1802 ctrlSetPosition [0.37109375 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1802 ctrlCommit 0;



					_GOMRscFrame_1803 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1803];
					_GOMRscFrame_1803 ctrlSetPosition [0.44335938 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07226563 * safezoneW, 0.30729167 * safezoneH];
					_GOMRscFrame_1803 ctrlCommit 0;



					_GOMRscFrame_1804 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1804];
					_GOMRscFrame_1804 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.09895834 * safezoneH];
					_GOMRscFrame_1804 ctrlCommit 0;



					_GOMRscFrame_1805 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1805];
					_GOMRscFrame_1805 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.53298612 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.06597223 * safezoneH];
					_GOMRscFrame_1805 ctrlCommit 0;



					_GOMRscFrame_1806 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1806];
					_GOMRscFrame_1806 ctrlSetPosition [0.515625 * safezoneW + safezoneX, 0.59895834 * safezoneH + safezoneY, 0.10839844 * safezoneW, 0.08854167 * safezoneH];
					_GOMRscFrame_1806 ctrlCommit 0;



					_GOMRscFrame_1807 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1807];
					_GOMRscFrame_1807 ctrlSetPosition [0.29882813 * safezoneW + safezoneX, 0.22569445 * safezoneH + safezoneY, 0.40136719 * safezoneW, 0.20833334 * safezoneH];
					_GOMRscFrame_1807 ctrlCommit 0;



					_GOMRscCombo_2101 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscCombo", 2101];
					_GOMRscCombo_2101 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.57638889 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscCombo_2101 ctrlCommit 0;



					_GOMRscFrame_1808 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1808];
					_GOMRscFrame_1808 ctrlSetPosition [0.62402344 * safezoneW + safezoneX, 0.43402778 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.14236112 * safezoneH];
					_GOMRscFrame_1808 ctrlCommit 0;



					_GOMRscEdit_1401 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscEdit", 1401];
					_GOMRscEdit_1401 ctrlSetText "Your Preset";
					_GOMRscEdit_1401 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.65277778 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscEdit_1401 ctrlCommit 0;



					_GOMRscButton_1606 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1606];
					_GOMRscButton_1606 ctrlSetText "Save";
					_GOMRscButton_1606 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.68576389 * safezoneH + safezoneY, 0.03125 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1606 ctrlCommit 0;



					_GOMRscButton_1607 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1607];
					_GOMRscButton_1607 ctrlSetText "Delete";
					_GOMRscButton_1607 ctrlSetPosition [0.66503907 * safezoneW + safezoneX, 0.68576389 * safezoneH + safezoneY, 0.03125 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1607 ctrlCommit 0;



					_GOMRscFrame_1809 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscFrame", 1809];
					_GOMRscFrame_1809 ctrlSetPosition [0.62402344 * safezoneW + safezoneX, 0.57638889 * safezoneH + safezoneY, 0.07714844 * safezoneW, 0.14236112 * safezoneH];
					_GOMRscFrame_1809 ctrlCommit 0;



					_GOMRscButton_1608 = _GOM_dialog_aircraftLoadout ctrlCreate ["RscButton", 1608];
					_GOMRscButton_1608 ctrlSetText "Load Preset";
					_GOMRscButton_1608 ctrlSetPosition [0.62890625 * safezoneW + safezoneX, 0.609375 * safezoneH + safezoneY, 0.06738282 * safezoneW, 0.02256945 * safezoneH];
					_GOMRscButton_1608 ctrlCommit 0;


					_GOM_dialog_aircraftLoadout;
				};

				DCON_fnc_Garage = 
				{
					if !(isNull(uiNamespace getVariable [ "DCON_Garage_Display", objNull ])) exitwith {};

					if(isNil "DCON_Garage_SpawnType") then {
						DCON_Garage_SpawnType = 0;
					};

					_pos = _this select 0;
					_dir = _this select 1;
					_spawns = [];

					_helipad = "Land_HelipadEmpty_F" createVehicleLocal _pos;
					waitUntil{!isNull _helipad};

					_helipad setPos _pos;
					
					BIS_fnc_arsenal_fullGarage = true;
					BIS_fnc_garage_center = _helipad;
					DCON_Garage_CanSpawn = 0;
					DCON_Garage_Vehicle = objNull;

					DCON_Garage_Color = [0,0,0,1];

					comment "no idea what this does but it works";
					disableSerialization;

					_display = findDisplay 46 createDisplay "RscDisplayGarage";
					uiNamespace setVariable ["DCON_Garage_Display", _display];

					_xPos = safezoneX + safezoneW;
					_yPos = safezoneY + safezoneH;

					_yPos = _yPos - 0.11;

					comment "select spawn type";
					_combo = _display ctrlCreate ["RscCombo", -1];
					_combo ctrlSetPosition [0.3455,_yPos,0.304,0.04];
					_combo ctrlSetFont "PuristaMedium";
					_combo ctrlSetTooltip "Spawn Type";
					_combo ctrlSetEventHandler ["LBSelChanged", 
					'
						DCON_Garage_SpawnType = _this select 1;
					'];
					_combo lbAdd "None";
					_combo lbAdd "Getin Driver";
					_combo lbAdd "Flying";

					_combo lbSetCurSel DCON_Garage_SpawnType;

					_combo ctrlCommit 0;

					_yPos = _yPos - 0.07;

					comment "r/woooosh";
					_btn = _display ctrlCreate ["RscButton", -1];
					_btn ctrlSetPosition [0.3455,_yPos,0.304,0.06];
					_btn ctrlSetText "SPAWN";
					_btn ctrlSetFont "PuristaMedium";
					_btn ctrlSetTooltip "WooOOOOSH!!";
					_btn ctrlSetEventHandler ["MouseButtonUp", 
					'
						_display = (uiNamespace getVariable "DCON_Garage_Display");
						
						DCON_Garage_CanSpawn = 1;
						
						_display closeDisplay 1;
					'];
					_btn ctrlCommit 0;

					comment "part of the function that doesn't work for some reason";
					_slider = _display ctrlCreate ["RscXSliderH", -1];
					_slider ctrlSetPosition [0,0.5,1,0];
					_slider ctrlSetBackgroundColor [0,0,0,0.4];
					_slider ctrlSetText "SPAWN";
					_slider ctrlSetFont "PuristaMedium";
					_slider ctrlSetTooltip "WooOOOOSH!!";
					_slider ctrlSetEventHandler ["SliderPosChanged",'
						_value = (_this select 1)  / 10;
						
						DCON_Garage_Color set [0,_value];

						[] call DCON_fnc_Garage_UpdateColor;
					'];
					_slider ctrlCommit 0;

					_controls = allControls _display;

					comment "I sat here for about an hour manually going through each control trying to find the ones I hated. See my pain";
					_spawn = _controls spawn {
						if true exitWith {};
						{
							hint str _x;
							_x ctrlSetBackgroundColor [1, 0, 0, 1];
							sleep 1;
						} forEach _this;
					};
					_spawns pushBack _spawn;

					comment "they come back for some reason idk";
					_spawn = _display spawn {
						while{true} do {
							(_this displayCtrl 28644) ctrlShow false;
							(_this displayCtrl 25815) ctrlShow false;
							(_this displayCtrl 44347) ctrlEnable false;
							comment "(_this displayCtrl 44046) ctrlShow false";
							sleep 0.01;
						};
					};
					_spawns pushBack _spawn;

					comment "The intent is to provide players with a sense of pride and accomplishment by pressing the enter key";
					_display displayAddEventHandler ["KeyUp",{
						_key = _this select 1;

						if(_key == 28) then {
							_display = (uiNamespace getVariable "DCON_Garage_Display");

							_display closeDisplay 1;

							DCON_Garage_CanSpawn = 1;
							[] call DCON_fnc_Garage_CreateVehicle;
						};
					}];

					_spawn = [_pos,_dir] spawn {
						_pos = _this select 0;
						_dir = _this select 1;
						_found = false;

						while {true} do {
							_objs = [_pos select 0,_pos select 1] nearEntities [["Air", "Car", "Tank", "Ship", "staticWeapon"], 30];
							reverse _objs;

							_model = uiNamespace getVariable "bis_fnc_garage_centertype";
							_model = _model splitString ":" select 0;
							if(_model find "\a3\" == -1) then {
								_model = "\"+_model;
							};
							if(_model find ".p3d" == -1) then {
								_model = _model+".p3d";
							};

							{
								_found = DCON_Garage_Vehicle getVariable "dcon_garage_veh";
								if(!isNil "_found") exitWith {};

								_id = _x call BIS_fnc_netId;
								_info = (getModelInfo _x) select 1;
								if(_info find "\a3\" == -1) then {
									_info = "\"+_info;
								};
								if(_info find ".p3d" == -1) then {
									_info = _info+".p3d";
								};
								_ignore = _x getVariable "dcon_garage_veh";

								if(_id find "0:" >= 0 && _info == _model && isNil "_ignore") exitWith {
									_veh = _x;

									_veh setVariable ["dcon_garage_veh",true];

									DCON_Garage_Vehicle = _veh;

									_display = (uiNamespace getVariable "DCON_Garage_Display");

									

									_pylons = (configProperties [configFile >> "CfgVehicles" >> typeOf _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons"]) apply {configName _x};
									if(count _pylons == 0) exitWith {};

									["DCON_Garage_FrameEvent", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
								};

							} forEach _objs;

							DCON_Garage_Vehicle setPos _pos;

							sleep 0.1;
						};
					};
					_spawns pushBack _spawn;

					_spawn = [_pos,_dir] spawn {
						_pos = _this select 0;
						_dir = _this select 1;

						while {true} do {
							DCON_Garage_Vehicle setPos _pos;
						};
					};
					_spawns pushBack _spawn;

					waitUntil {
						isNull _display;
					};

					{
						ctrlDelete (_x select 0);
					} forEach DCON_Garage_Loadout_Controls;

					["DCON_Garage_FrameEvent", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

					deleteVehicle _helipad;

					{
						terminate _x;
					} forEach _spawns;

					_veh = BIS_fnc_garage_center;
					_roles = [];
					{
						_roles pushBack [(agent _x),(assignedVehicleRole (agent _x))];
					}foreach (agents select {(agent _x) isKindOf "B_Soldier_VR_F"});

					if(DCON_Garage_CanSpawn == 1) then {
						[_roles] call DCON_fnc_Garage_CreateVehicle;
					}
					else
					{
						deleteVehicle _veh;
					};

				};

				DCON_fnc_Garage_CodeEditor_Open = 
				{
					disableSerialization;

					_garageDisplay = (uiNamespace getVariable "DCON_Garage_Display");

					_display = _garageDisplay createDisplay "RscDisplayGarage";
					uiNamespace setVariable ["DCON_Garage_CodeEditor_Display", _display];

					_bg = _display ctrlCreate ["RscBackground", -1];
					_bg ctrlSetPosition [0.086,0,0.78,0.18];
					_bg ctrlSetBackgroundColor [0,0,0,0.8];
					_bg ctrlCommit 0;

					comment "technically this is exploting, please don't ban me";
					_exec = _display ctrlCreate ["RscAttributeExec", 200];
					_exec ctrlSetPosition [0.086,0,0.78,0.18];
					_exec ctrlCommit 0;

					((_display) displayCtrl 14466) ctrlEnable false;

					ctrlSetFocus ((_display) displayCtrl 13766);

					sleep 3;

					_display closeDisplay 1;
				};

				DCON_fnc_Garage_CreateVehicle = 
				{
					params ["_roles"];
					_veh  = BIS_fnc_garage_center;

					_type = typeOf _veh;
					_textures = getObjectTextures _veh;
					_animationNames = animationNames _veh;
					_animationValues = [];
					_current_mags = (getPylonMagazines (_veh));
					_special = "CAN_COLLIDE";
					_movein = false;

					{
						_animationValues pushBack (_veh animationPhase _x);
					} forEach _animationNames;

					deleteVehicle _veh;
					waitUntil {!alive _veh};
					sleep 0.1;

					switch (DCON_Garage_SpawnType) do {
						case 1 : {
							_movein = true;
						};
						case 2 : {
							_movein = true;
							_special = "FLY";
						};
					};

					_veh = createvehicle [_type,_pos,[],0,_special];
					_veh setVariable ["dcon_garage_veh",true,true];

					comment "i died about 200 times before implementing this..";
					if!(_veh isKindOf "plane") then {
						_veh setDir _dir;
					};

					{
						_veh animate [_x,_animationValues select _forEachIndex,true];
					} forEach _animationNames;

					{
						_veh setObjectTextureGlobal [_forEachIndex,_x];
					} forEach _textures;

					{
						_veh setPylonLoadOut [_forEachIndex+1, _x,true];
					} forEach _current_mags;


					{
						_unit = (_x select 0);
						_unitPos = position _unit;
						_unitGroup = group player;

						deleteVehicle _unit;

						_type = "";
						switch(playerSide) do
						{
							case west: {
								_type = "B_crew_F";
							};
							case east: {
								_type = "O_crew_F";
							};
							case resistance: {
								_type = "I_crew_F";
							};
							case civilian: {
								_type = "C_man_1";
							};
							default {
								_type = "B_crew_F";
							}
						};
						
						_seatInVeh =  _x select 1;
						if(!(_seatInVeh isEqualTo [])) then
						{
							_spawnedUnit = _unitGroup createUnit [_type, _unitPos, [], 0, "NONE"];

							_positionInVehicle = toLower (_seatInVeh select 0);
							switch (_positionInVehicle) do
							{
								case "driver": {_spawnedUnit moveInDriver _veh};
								case "cargo": {
									if(count _seatInVeh == 2) then {
										_spawnedUnit moveInCargo [_veh, ((_seatInVeh select 1) select 0)];
									}
									else {
										_spawnedUnit moveInCargo _veh;
									};
								};
								case "turret": {_spawnedUnit moveInTurret [_veh, _seatInVeh select 1]};
							};
						};
					}foreach _roles;
				
					if(_movein) then {
						moveout player;
						waitUntil {vehicle player == player};
						if(isNull (driver _veh)) then
						{
							player moveInDriver _veh;
						}
						else
						{
							player moveInAny _veh;
						};
						
					};

					comment "clean up your mess..";
					_veh spawn {
						waitUntil {sleep 1;!alive _this;};
						sleep 40;
						deleteVehicle _this;
					};
				};

				DCON_fnc_Garage_UpdateColor = 
				{
					comment "no idea why this doesn't work ¯\_(ツ)_/¯";

					_veh = DCON_Garage_Vehicle;
					_color = DCON_Garage_Color;

					hint str _color;

					_color2 = format ["#(rgb,8,8,3)color(%1,%2,%3,%4)",_color select 0,_color select 1,_color select 2,_color select 3];

					_veh setObjectTexture [0, _color2];
					_veh setObjectTexture [1, _color2];
					_veh setObjectTexture [2, _color2];
					_veh setObjectTexture [3, _color2];
					_veh setObjectTexture [4, _color2];
					_veh setObjectTexture [5, _color2];
				};

				DCON_fnc_Garage_Open = 
				{
					_pos = (getPos player vectorAdd (eyeDirection player vectorMultiply 15));
					_dir = getDir player;
					[_pos,_dir] spawn DCON_fnc_Garage;	
				};


				WPN_fnc_execute = 
				{
					_weaponName = _this select 0;
					_magName = _this select 1;
					_amount = parseNumber (_this select 2);
					_latestSearch = _this select 3;
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");

					
					if(_amount <= 0) exitWith {};
					if(_amount > 300) then {_amount = 300;};


					for "_i" from 0 to _amount-1 do
					{
						vehicle player addMagazine _magName;
					};
					(vehicle player) addWeapon _weaponName;

					_textbox = (_display displayCtrl 1400);
					hint (ctrlText _textbox);
					profileNamespace setVariable["WeaponryParams",[_latestSearch, _weaponName, _magName, _amount]];				
				};
				
				WPN_fnc_findMagazines = 
				{
					disableSerialization;
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
					_weaponName = _this select 0;


					_magNames = getArray(configFile >> "CfgWeapons" >> _weaponName >> "magazines");
					_listbox = _display displayCtrl 1501;
					lbClear _listbox;
					{_listbox lbAdd _x} forEach _magNames;
					
				};
				
				WPN_fnc_findWeapons = 
				{
					disableSerialization;

					_weaponName = _this select 0;

					waitUntil {count (missionNamespace getVariable ["allWeapons",[]]) > 0};

					_allWeapons = missionNamespace getVariable "allWeapons";
					_display = (profileNamespace getVariable "JEW_WeaponryDisplay");

					_correctWeapons = _allWeapons select {_x find toLower(_weaponName) != -1};
					_listbox = _display displayCtrl 1500;

					lbClear _listbox;
					{_listbox lbAdd _x} forEach _correctWeapons;
				};
					
				WPN_fnc_open = 
				{
					disableSerialization;
					
					_defaults =  profileNamespace getVariable["WeaponryParams",["Enter Weapon Name","","Amount of Mags"]];

					_defaults params ["_latestSearch","_defaultWeapon","_defaultMagazine","_defaultAmount"];

					_display = [] call JEW_fnc_weaponry;
					
					(_display displayCtrl 1400) ctrlSetText "Loading Weapons";


					(_display displayCtrl 1400) ctrlSetText _latestSearch;

					_show_func = [_latestSearch] spawn WPN_fnc_findWeapons;
					waitUntil{scriptDone _show_func};

					if(typename _defaultAmount == typename 0) then { _defaultAmount = str _defaultAmount; };

					(_display displayCtrl 1401) ctrlSetText _defaultAmount;

					if(!(_defaultMagazine isEqualTo "")) then {
						(_display displayCtrl 1501) lbAdd _defaultMagazine;
						(_display displayCtrl 1501) lbSetCurSel 0;
					};
				};
				
				JEW_fnc_weaponry = 
				{
					disableSerialization;
					_d_weaponry = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_WeaponryDisplay",_d_weaponry];
					
					_btn_weaponryExecute = _d_weaponry ctrlCreate ["RscButtonMenu", 2600];
					_btn_weaponryExecute ctrlSetText "OK";
					_btn_weaponryExecute ctrlSetPosition [0.650884 * safezoneW + safezoneX,0.471994 * safezoneH + safezoneY,0.0721618 * safezoneW,0.0280062 * safezoneH];
					_btn_weaponryExecute ctrladdEventHandler ["ButtonClick",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500)), (_display displayCtrl 1501) lbText (lbCurSel (_display displayCtrl 1501)),ctrlText (_display displayCtrl 1401),ctrlText (_display displayCtrl 1400)] spawn WPN_fnc_execute;
						_display closeDisplay 1;
					}];
					_btn_weaponryExecute ctrlCommit 0;
					
					
					_btn_weaponryCancel = _d_weaponry ctrlCreate ["RscButtonMenu", 2700];
					_btn_weaponryCancel ctrlSetText "CANCEL";
					_btn_weaponryCancel ctrlSetPosition [0.650884 * safezoneW + safezoneX,0.542009 * safezoneH + safezoneY,0.0721618 * safezoneW,0.0280062 * safezoneH];
					_btn_weaponryCancel ctrladdEventHandler ["ButtonClick",{
						(profileNamespace getVariable "JEW_WeaponryDisplay") closeDisplay 1;
					}];
					_btn_weaponryCancel ctrlCommit 0;
					
					
					_frm_weaponryBack = _d_weaponry ctrlCreate ["RscFrame", 1800];
					_frm_weaponryBack ctrlSetPosition [0.257274 * safezoneW + safezoneX,0.191931 * safezoneH + safezoneY,0.485452 * safezoneW,0.602134 * safezoneH];
					_frm_weaponryBack ctrlCommit 0;
					
					
					_list_weaponryWeapons = _d_weaponry ctrlCreate ["RscListBox", 1500];
					_list_weaponryWeapons ctrlSetPosition [0.263834 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
					_list_weaponryWeapons ctrladdEventHandler ["LBSelChanged",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						
						hint format['%1',(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500))];
						[(_display displayCtrl 1500) lbText (lbCurSel (_display displayCtrl 1500))] spawn WPN_fnc_findMagazines;
					}];
					_list_weaponryWeapons ctrlCommit 0;
					
					
					_list_weaponryMagazines = _d_weaponry ctrlCreate ["RscListBox", 1501];	
					_list_weaponryMagazines ctrlSetPosition [0.45408 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.177125 * safezoneW,0.518116 * safezoneH];
					_list_weaponryMagazines ctrladdEventHandler ["LBSelChanged",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						hint format['%1',(_display displayCtrl 1501) lbText (lbCurSel (_display displayCtrl 1501))];
					}];
					_list_weaponryMagazines ctrlCommit 0;
					
					
					_edit_weaponryWeapons = _d_weaponry ctrlCreate ["RscEdit", 1400];
					_edit_weaponryWeapons ctrlSetPosition [0.263834 * safezoneW + safezoneX,0.219938 * safezoneH + safezoneY,0.177125 * safezoneW,0.0280062 * safezoneH];
					_edit_weaponryWeapons ctrlSetTooltip "Enter Weapon Name";
					_edit_weaponryWeapons ctrladdEventHandler ["KeyUp",{
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[ctrlText (_display displayCtrl 1400)] spawn WPN_fnc_findWeapons;
					}];
					_edit_weaponryWeapons ctrlCommit 0;
					
					
					_edit_weaponryAmount = _d_weaponry ctrlCreate ["RscEdit", 1401];
					_edit_weaponryAmount ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.219938 * safezoneH + safezoneY,0.177125 * safezoneW,0.0280062 * safezoneH];
					_edit_weaponryAmount ctrlSetTooltip "Amount of Mags";
					_edit_weaponryAmount ctrlCommit 0;
					
					_d_weaponry;
				};
								
				
				
				LIT_fnc_execute = 
				{
					
					params ["_H","_L"];

					openMap true;
					[_H,_L] onMapSingleClick { 
						params ["_H","_L"];
						
						_tar = (driver (vehicle player));
						
						(vehicle _tar) flyInHeight _H;

						(group _tar) move _pos;

						_tar = (group _tar);
						if(waypointType [_tar,(currentWaypoint _tar)] isEqualTo "LOITER") then {

							_tar = [_tar,currentWaypoint _tar];
							_tar setWaypointPosition [_pos,0];
							_tar setWaypointLoiterType "CIRCLE_L";
							_tar setWaypointLoiterRadius _L ;

						}
						else {

							_tar = _tar addwaypoint [_pos, 0];
							_tar setWaypointType "LOITER";
							_tar setWaypointLoiterType "CIRCLE_L";
							_tar setWaypointLoiterRadius _L ; 

						};
						_tar setWaypointBehaviour "CARELESS";
						_tar setWaypointCombatMode "BLUE";
						_tar setWaypointForceBehaviour true;
						
						onMapSingleClick "";
						
					};

					vehicle player setVariable ["LoiterParams",[_H,_L]];
				};
				
				LIT_fnc_open = 
				{
					
					_display = [] call JEW_fnc_loiter;


					disableSerialization;

					_defaults =  vehicle player getVariable ["LoiterParams",[1500,1500]];



					{
					_control = _display displayCtrl _x;

					_control_text = _display displayCtrl (ctrlIDC _control - 900);

					_type = "";

					switch (ctrlIDC _control) do
					{
						case 1900: {_type = "Altitude"};
						case 1901: {_type = "Radius"};
					};

					_control sliderSetRange [500,4000];
					_control slidersetSpeed [100,100,100];
					_control sliderSetPosition (_defaults select _forEachIndex);
					_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_defaults select _forEachIndex];

					} forEach [1900,1901];
				};
				
				LIT_fnc_sliderChanged = 
				{
					disableSerialization;

					_control = _this select 0;
					_newValue = _this select 1;
					_display = ctrlParent _control;
					_control_text = _display displayCtrl (ctrlIDC _control - 900);

					_type = "";

					switch (ctrlIDC _control) do
					{
						case 1900: {_type = "Altitude"};
						case 1901: {_type = "Radius"};
					};

					_control_text ctrlSetStructuredText parseText format["<t align='center'>%1: %2</t>",_type,_newValue];


				};
				
				JEW_fnc_loiter = 
				{
					disableSerialization;
					_d_loiter = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_WeaponryDisplay",_d_loiter];

					
					_btn_loiterExecute = _d_loiter ctrlCreate ["RscButtonMenu", 2600];
					_btn_loiterExecute ctrlSetText "OK";
					_btn_loiterExecute ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.528006 * safezoneH + safezoneY,0.0590415 * safezoneW,0.0280062 * safezoneH];
					_btn_loiterExecute ctrladdEventHandler ["ButtonClick",{
						
						_display = (profileNamespace getVariable "JEW_WeaponryDisplay");
						[sliderPosition (_display displayCtrl 1900), sliderPosition (_display displayCtrl 1901)] spawn LIT_fnc_execute;
						_display closeDisplay 1;

					}];
					_btn_loiterExecute ctrlCommit 0;
					
					
					_btn_loiterCancel = _d_loiter ctrlCreate ["RscButtonMenu", 2700];
					_btn_loiterCancel ctrlSetText "CANCEL";
					_btn_loiterCancel ctrlSetPosition [0.519681 * safezoneW + safezoneX,0.528006 * safezoneH + safezoneY,0.0590415 * safezoneW,0.0280062 * safezoneH];
					_btn_loiterCancel ctrladdEventHandler ["ButtonClick",{
						(profileNamespace getVariable "JEW_WeaponryDisplay") closeDisplay 1;
					}];
					_btn_loiterCancel ctrlCommit 0;
					
					
					_frm_loiterBack = _d_loiter ctrlCreate ["RscFrame", 1800];
					_frm_loiterBack ctrlSetPosition [0.375357 * safezoneW + safezoneX,0.27595 * safezoneH + safezoneY,0.236166 * safezoneW,0.294066 * safezoneH];
					_frm_loiterBack ctrlCommit 0;
					
					
					_gui_loiterBack = _d_loiter ctrlCreate ["IGUIBack", 2200];
					_gui_loiterBack ctrlSetPosition [0.375357 * safezoneW + safezoneX,0.27595 * safezoneH + safezoneY,0.236166 * safezoneW,0.294066 * safezoneH];
					_gui_loiterBack ctrlCommit 0;
					
					
					_slider_loiterAltitude = _d_loiter ctrlCreate ["RscSlider", 1900];
					_slider_loiterAltitude ctrlSetText "Altitude";
					_slider_loiterAltitude ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.317959 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_slider_loiterAltitude ctrladdEventHandler ["SliderPosChanged",{
						[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;
					}];
					_slider_loiterAltitude ctrlCommit 0;
					
					
					_slider_loiterRadius = _d_loiter ctrlCreate ["RscSlider", 1901];	
					_slider_loiterAltitude ctrlSetText "Radius";
					_slider_loiterRadius ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.415981 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_slider_loiterRadius ctrladdEventHandler ["SliderPosChanged",{
						[_this select 0, _this select 1] spawn LIT_fnc_sliderChanged;
					}];
					_slider_loiterRadius ctrlCommit 0;
					
					
					_text_loiterAltitude = _d_loiter ctrlCreate ["RscStructuredText", 1000];
					_text_loiterAltitude ctrlSetTooltip "Altitude";
					_text_loiterAltitude ctrlSetText "<t align='center'>Altitude</t>";
					_text_loiterAltitude ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.359969 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_text_loiterAltitude ctrlCommit 0;
					
					
					_text_loiterRadius = _d_loiter ctrlCreate ["RscStructuredText", 1001];
					_text_loiterRadius ctrlSetTooltip "Radius";
					_text_loiterRadius ctrlSetText "<t align='center'>Radius</t>";
					_text_loiterRadius ctrlSetPosition [0.408158 * safezoneW + safezoneX,0.471994 * safezoneH + safezoneY,0.170564 * safezoneW,0.0280062 * safezoneH];
					_text_loiterRadius ctrlCommit 0;
					
					_d_loiter;
				};
				
				
				
				JEW_fnc_main = 
				{
					
					disableSerialization;
					_d_main = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";
					
					profileNamespace setVariable ["JEW_MainDisplay",_d_main];
					
					_frm_loiterBack = _d_main ctrlCreate ["RscFrame", 1800];
					_frm_loiterBack ctrlSetPosition [0.427838 * safezoneW + safezoneX,0.233941 * safezoneH + safezoneY,0.144324 * safezoneW,0.434097 * safezoneH];
					_frm_loiterBack ctrlCommit 0;
					
					
					_btn_virtualArsenal = _d_main ctrlCreate ["RscButton", 1600];
					_btn_virtualArsenal ctrlSetText "Virtual Arsenal";
					_btn_virtualArsenal ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.261946 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_virtualArsenal ctrladdEventHandler ["ButtonClick",{
						
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						['Open', true] spawn BIS_fnc_arsenal;
						_display closeDisplay 1;

					}];
					_btn_virtualArsenal ctrlCommit 0;
					
					
					_btn_virtualGarage = _d_main ctrlCreate ["RscButton", 1601];
					_btn_virtualGarage ctrlSetText "Virtual Garage";
					_btn_virtualGarage ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.345965 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_virtualGarage ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						[] call DCON_fnc_Garage_Open;


					}];
					_btn_virtualGarage ctrlCommit 0;
					
					
					_btn_limitedPylon = _d_main ctrlCreate ["RscButton", 1602];
					_btn_limitedPylon ctrlSetText "Pylons - Limited";
					_btn_limitedPylon ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.429984 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_limitedPylon ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						_loadoutObject = [player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo ''));
						[_loadoutObject, false] call GOM_fnc_aircraftLoadout;

					}];
					_btn_limitedPylon ctrlCommit 0;
					
					
					_btn_unlimitedPylon = _d_main ctrlCreate ["RscButton", 1603];
					_btn_unlimitedPylon ctrlSetText "Pylons - Unlimited";
					_btn_unlimitedPylon ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.514003 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_unlimitedPylon ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;

						_loadoutObject = [player, getConnectedUAV player] select (!isNull getConnectedUAV player && !((UAVControl (getConnectedUAV player) select 1) isEqualTo ''));
						[_loadoutObject, true] call GOM_fnc_aircraftLoadout;

					}];
					_btn_unlimitedPylon ctrlCommit 0;
					
					
					_btn_weaponry = _d_main ctrlCreate ["RscButton", 1604];
					_btn_weaponry ctrlSetText "Add Weapons";
					_btn_weaponry ctrlSetPosition [0.454079 * safezoneW + safezoneX,0.598022 * safezoneH + safezoneY,0.0918423 * safezoneW,0.0420094 * safezoneH];
					_btn_weaponry ctrladdEventHandler ["ButtonClick",{		
						_display = (profileNamespace getVariable "JEW_MainDisplay");
						_display closeDisplay 1;
						
						[] spawn WPN_fnc_open;

					}];
					_btn_weaponry ctrlCommit 0;

				};
				
				
				
				JEW_fnc_enableDriverAssist =
				{
					private _veh = objectParent player;

					if (!alive _veh || alive driver _veh || effectiveCommander _veh != player) exitWith {};

					private _class = format ["%1_UAV_AI", ["B","O","I"] select (([BLUFOR,OPFOR,INDEPENDENT] find playerSide) max 0)];
					private _ai = createAgent [_class, _veh, [], 0, "NONE"];

					_ai allowDamage false;
					_ai setVariable ["A3W_driverAssistOwner", player, true];
					[_ai, ["Autodrive","",""]] remoteExec ["A3W_fnc_setName", 0, _ai];
					_ai moveInDriver _veh;

					[_veh, _ai] spawn
					{
						params ["_veh", "_ai"];

						_time = time;
						waitUntil {local _veh || time - _time > 3};

						waitUntil {driver _veh != _ai};
						
						deleteVehicle _ai;

					};

				};
				
				JEW_fnc_disableDriverAssist = 
				{
					private _veh = if (isNil "_veh") then { objectParent player } else { _veh };
					private _driver = driver _veh;

					if (!isAgent teamMember _driver || !((_driver getVariable ["A3W_driverAssistOwner", objNull]) in [player,objNull])) exitWith {};

					deleteVehicle _driver;

				};
				
				JEW_fnc_prevStatement = 
				{
					private _display = d_mainConsole;
					private _nextButton = _display displayCtrl 90111;
					private _prevButton = _display displayCtrl 90110;
					private _expression = _display displayCtrl 5252;

					private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
					private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

					_statementIndex = (_statementIndex + 1) min ((count _prevStatements - 1) max 0);
					profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

					private _prevStatement = _prevStatements select _statementIndex;
					_expression ctrlSetText _prevStatement;
					_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
					_nextButton ctrlEnable (_statementIndex > 0);
				};

				JEW_fnc_nextStatement = 
				{
					private _display = d_mainConsole;
					private _prevButton = _display displayCtrl 90110;
					private _nextButton = _display displayCtrl 90111;
					private _expression = _display displayCtrl 5252;

					private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
					private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

					_statementIndex = (_statementIndex - 1) max 0;
					profileNamespace setVariable ["DebugStatementsIndex", _statementIndex];

					private _nextStatement = _prevStatements select _statementIndex;
					_expression ctrlSetText _nextStatement;

					_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
					_nextButton ctrlEnable (_statementIndex > 0);
				};

				JEW_fnc_addStatement = 
				{
					private _display = d_mainConsole;
					private _prevButton = _display displayCtrl 90110;
					private _nextButton = _display displayCtrl 90111;
					private _expression = _display displayCtrl 5252;

					private _statement = ctrlText _expression;

					private _statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
					private _prevStatements = profileNamespace getVariable ["DebugStatements", []];

					if !((_prevStatements param [0, ""]) isEqualTo _statement) then {

						reverse _prevStatements;
						_prevStatements pushBack _statement;
						reverse _prevStatements;

						if (count _prevStatements > 50) then {
							_prevStatements resize 50;
						};

						profileNamespace setVariable ["DebugStatementsIndex", 0];
						profileNamespace setVariable ["DebugStatements", _prevStatements];

						_prevButton ctrlEnable (count _prevStatements > 1);
						_nextButton ctrlEnable false;
					};

				};
				
				JEW_fnc_execLocal = 
				{
					_text = ctrlText edit_debugConsoleInput;
					if(_text isEqualTo "") exitWith
					{
						hint "No code to execute.";
					};
					[] call JEW_fnc_addStatement;
					_code = compile _text;
					[] call _code;
				};

				JEW_fnc_execGlobal = 
				{
					_text = ctrlText edit_debugConsoleInput;
					if (_text isEqualTo "") exitWith
					{
						hint "No code to execute.";
					};
					[] call JEW_fnc_addStatement;

					_code = compile _text;
					_code remoteExec ["bis_fnc_call", 0, false];
				};

				JEW_fnc_execServer = 
				{
					_text = ctrlText edit_debugConsoleInput;
					if (_text isEqualTo "") exitWith
					{
						hint "JEW: Console Error: No code to execute.";
					};
					[] call JEW_fnc_addStatement;
					_code = compile _text;
					_code remoteExec ["bis_fnc_call", 2, false];
				};

				JEW_fnc_execPlayer = 
				{
					params ["_playerName"];
					_text = ctrlText edit_debugConsoleInput;
					if (_text isEqualTo "") exitWith
					{
						hint "JEW: Console Error: No code to execute.";
					};
					[] call JEW_fnc_addStatement;
					_code = compile _text;
					_code remoteExec ["bis_fnc_call", _playerName, false];
				};

				JEW_open_mainConsole = 
				{
					disableSerialization;
					d_mainConsole = (findDisplay 46) createDisplay "RscDisplayEmpty";
					showChat true; comment "Fixes Chat Bug";

					txt_background1 = d_mainConsole ctrlCreate ["RscText", 5248];
					txt_background1 ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY, 0.257813 * safezoneW,0.196044 * safezoneH];
					txt_background1 ctrlSetBackgroundColor [-1,-1,-1,0.7];
					txt_background1 ctrlCommit 0;
					
					txt_mainMenuTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5249];
					txt_mainMenuTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>RAZER MENU V1</t>";
					txt_mainMenuTitle ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.257813 * safezoneW,0.055 * safezoneH];
					txt_mainMenuTitle ctrlSetBackgroundColor [0,0,0,0.5];
					txt_mainMenuTitle ctrlCommit 0;
					
					btn_forceVoteAdmin = d_mainConsole ctrlCreate ["RscButtonMenu", 5250];
					
					btn_forceVoteAdmin ctrlSetStructuredText parseText "<t size='0.9' align='center'>FORCE-VOTE ADMIN</t>";
					btn_forceVoteAdmin ctrlSetPosition [0.37625 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0979687 * safezoneW,0.055 * safezoneH];
					btn_forceVoteAdmin ctrladdEventHandler ["ButtonClick",{
						newAdmin = lb_playerList lbText (lbCurSel lb_playerList);
						[[newAdmin],
						{
							newAdmin = _this select 0;
							disableSerialization;
							d_adminTransfer = (findDisplay 46) createDisplay "RscDisplayEmpty";
							showChat true;
							_mouseDetection2 = d_adminTransfer ctrlCreate ["RscButton", 8888];
							_mouseDetection2 ctrlSetPosition [-0.000156274 * safezoneW + safezoneX,-0.00599999 * safezoneH + safezoneY,1.00547 * safezoneW,1.023 * safezoneH];
							_mouseDetection2 ctrladdEventHandler ["MouseMoving",
							"
								serverCommand format ['#Vote Admin %1', newAdmin];
								d_adminTransfer closeDisplay 0;
							"];
							_mouseDetection2 ctrlSetBackgroundColor [0,0,0,0];
							_mouseDetection2 ctrlCommit 0;
						}] remoteExec ["spawn",-2];
					}];
					btn_forceVoteAdmin ctrlCommit 0;

					txt_debugConsoleTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5251];
					txt_debugConsoleTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center' font='PuristaBold'>DEBUG CONSOLE</t>";
					txt_debugConsoleTitle ctrlSetPosition [0.371096 * safezoneW + safezoneX,0.429984 * safezoneH + safezoneY,0.257813 * safezoneW,0.03 * safezoneH];
					txt_debugConsoleTitle ctrlSetBackgroundColor [0,0,0,0.5];
					txt_debugConsoleTitle ctrlCommit 0;
					
					edit_debugConsoleInput = d_mainConsole ctrlCreate ["RscEditMulti", 5252];
					edit_debugConsoleInput ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.464712 * safezoneH + safezoneY,0.257813 * safezoneW,0.266059 * safezoneH];
					edit_debugConsoleInput ctrlSetBackgroundColor [-1,-1,-1,0.8];
					edit_debugConsoleInput ctrlSetTooltip "Script here";
					edit_debugConsoleInput ctrlCommit 0;

					lb_playerList = d_mainConsole ctrlCreate ["RscListbox", 5253];
					lb_playerList ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0670312 * safezoneW,0.341 * safezoneH];
					{ _pL_index = lb_playerList lbAdd name _x; } forEach allPlayers;
					lb_playerList ctrlCommit 0;
					
					btn_serverExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5254];
					btn_serverExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Server</t>";
					btn_serverExecute ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0825 * safezoneW,0.03 * safezoneH];
					btn_serverExecute ctrladdEventHandler ["ButtonClick",{
						[] spawn JEW_fnc_execServer;
					}];
					btn_serverExecute ctrlCommit 0;
					
					btn_globalExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5255];
					btn_globalExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Global</t>";
					btn_globalExecute ctrlSetPosition [0.45875 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0876563 * safezoneW,0.03 * safezoneH];
					btn_globalExecute ctrladdEventHandler ["ButtonClick",{
						[] spawn JEW_fnc_execGlobal;
					}];
					btn_globalExecute ctrlCommit 0;
					
					btn_localExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5256];
					btn_localExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Local</t>";
					btn_localExecute ctrlSetPosition [0.551563 * safezoneW + safezoneX,0.742 * safezoneH + safezoneY,0.0773437 * safezoneW,0.03 * safezoneH];
					btn_localExecute ctrladdEventHandler ["ButtonClick",{
						[] spawn JEW_fnc_execLocal;
					}];
					btn_localExecute ctrlCommit 0;
					
					btn_playerExecute = d_mainConsole ctrlCreate ["RscButtonMenu", 5257];
					btn_playerExecute ctrlSetStructuredText parseText "<t size='1' align='center'>Player</t>";
					btn_playerExecute ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.654 * safezoneH + safezoneY,0.0670312 * safezoneW,0.03 * safezoneH];
					btn_playerExecute ctrladdEventHandler ["ButtonClick",{
						[lb_playerList lbText (lbCurSel lb_playerList)] spawn JEW_fnc_execPlayer;
					}];
					btn_playerExecute ctrlCommit 0;

					btn_prevButton = d_mainConsole ctrlCreate ["RscButtonMenu", 90110];
					btn_prevButton ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.783229 * safezoneH + safezoneY,0.103125 * safezoneW,0.03 * safezoneH];
					btn_prevButton ctrlCommit 0;
					btn_prevButton ctrlSetStructuredText parseText "<t size='1' align='center'>Prev Statement</t>";
					btn_prevButton ctrlAddEventHandler ["MouseButtonUp", {_this call JEW_fnc_prevStatement; true}];

					btn_nextButton = d_mainConsole ctrlCreate ["RscButtonMenu", 90111];
					btn_nextButton ctrlSetPosition [0.5257817 * safezoneW + safezoneX,0.783229 * safezoneH + safezoneY,0.103125 * safezoneW,0.03 * safezoneH]; 
					btn_nextButton ctrlCommit 0;
					btn_nextButton ctrlSetStructuredText parseText "<t size='1' align='center'>Next Statement</t>";
					btn_nextButton ctrlAddEventHandler ["MouseButtonUp", {_this call JEW_fnc_nextStatement; true}];


					_statementIndex = profileNamespace getVariable ["DebugStatementsIndex", 0];
					_prevStatements = profileNamespace getVariable ["DebugStatements", []];

					btn_prevButton ctrlEnable (_statementIndex < count _prevStatements - 1);
					btn_nextButton ctrlEnable (_statementIndex > 0);

					txt_playerListTitle = d_mainConsole ctrlCreate ["RscStructuredText", 5258];
					txt_playerListTitle ctrlSetStructuredText parseText "<t color='#FFFFFF' shadow='2' size='1' align='center'>Player List</t>";
					txt_playerListTitle ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.269 * safezoneH + safezoneY,0.0670312 * safezoneW,0.03 * safezoneH];
					txt_playerListTitle ctrlSetBackgroundColor [0,0,0,0.5];
					txt_playerListTitle ctrlCommit 0;
					
					btn_playerESP = d_mainConsole ctrlCreate ["RscButtonMenu", 5259];
					btn_playerESP ctrlSetStructuredText parseText "<t size='0.9' align='center'>Player<br />ESP</t>";
					btn_playerESP ctrlSetPosition [0.37625 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_playerESP ctrladdEventHandler ["ButtonClick",{
						if (isNil 'JEWESPTggle') then {JEWESPTggle = 1};
						if (JEWESPTggle == 1) then {
							JEWESPTggle = 0;
							titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
							[("
								MissionEH_3DESP = addMissionEventHandler ['Draw3D',
								{
									{
										if (((player distance _x) < 3000) && (_x != player)) then {
											if (side _x != side player) then {
												switch (side _x) do {
													case west: { drawIcon3D ['', [0.4, 0.4, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
													case east: { drawIcon3D ['', [1, 0.4, 0.4, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
													case independent: { drawIcon3D ['', [0.4, 1, 0.4, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
													default { drawIcon3D ['', [0, 0, 0, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false]; };
												};
											} else {
												drawIcon3D ['', [1, 1, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, (getPosATL _x select 2) + 2.3], 1, 1, 45, (format ['%1', name _x]), 2, 0.025, 'PuristaMedium', 'center', false];
											};
										};
									} forEach allPlayers;
								}];
							")] call {(with missionNamespace do compile (_this select 0));};
						} else {
							JEWESPTggle = 1;
							titleText ["<t color='#42D6FC'>ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
							[("removeMissionEventHandler['Draw3D',MissionEH_3DESP];")] call {(with missionNamespace do compile (_this select 0));};
						};
					}];
					btn_playerESP ctrlCommit 0;
					
					btn_AIESP = d_mainConsole ctrlCreate ["RscButtonMenu", 5260];
					btn_AIESP ctrlSetStructuredText parseText "<t size='0.9' align='center'>AI<br />ESP</t>";
					btn_AIESP ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_AIESP ctrladdEventHandler ["ButtonClick",{
						if (isNil 'JEWhostileAIESPTggle') then {JEWhostileAIESPTggle = 1};
						if (JEWhostileAIESPTggle == 1) then {
							JEWhostileAIESPTggle = 0;
							titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
							JEWhostileAIEsp = addMissionEventHandler ['Draw3D',{
								{
									if ((side _x != side player) && ((player distance _x) < 3000)) then {
										drawIcon3D["", [1, 0, 0, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%1m", round(player distance _x)]), 1, 0.04, "EtelkaNarrowMediumPro"];
									} else {
										if (((player distance _x) < 3000) && (name _x != name player)) then {
											drawIcon3D["", [0, 0.5, 1, 1], [visiblePosition _x select 0, visiblePosition _x select 1, 2], 0.1, 0.1, 45, (format["%1m", round(player distance _x)]), 1, 0.04, "EtelkaNarrowMediumPro"];
										};
									};
								} forEach call {
									_hostileai = [];
									{
										if ((_x isKindOf "Man") && (side _x != side player)) then {
											_hostileai pushBack _x;
										} else {
											if ((count crew _x) != 0) then {
												for "_i" from 0 to (count crew _x)-1 do {
													_l = (crew _x) select _i;
													if (side _l != side player) then {
														_hostileai pushBack _l;
													};
												};
											};
										};
									} forEach allUnits - allPlayers;
									_hostileai
								};
							}];
						} else {
							JEWhostileAIESPTggle = 1;
							titleText ["<t color='#42D6FC'>ENEMY AI ESP </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
							removeMissionEventHandler['Draw3D',JEWhostileAIEsp];
						};
					}];
					btn_AIESP ctrlCommit 0;
					
					btn_mapAware = d_mainConsole ctrlCreate ["RscButtonMenu", 5261];
					btn_mapAware ctrlSetStructuredText parseText "<t size='0.9' align='center'>Map<br />Aware</t>";
					btn_mapAware ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_mapAware ctrladdEventHandler ["ButtonClick",{
						if (isNil "mapAwareTggle") then {mapAwareTggle = 1};
						if (mapAwareTggle == 1) then {
							mapAwareTggle = 0;
							["EH_RevealUnitsOnMap", "onEachFrame", 
							{
								{
									player reveal vehicle _x;
								} forEach allUnits;
							}] call BIS_fnc_addStackedEventHandler;
							titleText ["<t color='#42D6FC'>MAP-AWARE </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						} else {
							mapAwareTggle = 1;
							["EH_RevealUnitsOnMap", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
							titleText ["<t color='#42D6FC'>MAP-AWARE </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_mapAware ctrlCommit 0;
					
					btn_infStamina = d_mainConsole ctrlCreate ["RscButtonMenu", 5262];
					btn_infStamina ctrlSetStructuredText parseText "<t size='0.9' align='center'>Infinite<br />Stamina</t>";
					btn_infStamina ctrlSetPosition [0.530937 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_infStamina ctrladdEventHandler ["ButtonClick",{
						if (isNil "infStaminaTggle") then {infStaminaTggle = 1};
						if (infStaminaTggle == 1) then {
							infStaminaTggle = 0;
							player enableFatigue false;
							EH_cardio = player addEventHandler ["Respawn", {player enableFatigue false;}];
							titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						} else {
							infStaminaTggle = 1;
							player enableFatigue true;
							player removeEventHandler ["Respawn", EH_cardio];
							titleText ["<t color='#42D6FC'>CARDIO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_infStamina ctrlCommit 0;
					
					btn_godMode = d_mainConsole ctrlCreate ["RscButtonMenu", 5263];
					btn_godMode ctrlSetStructuredText parseText "<t size='0.9' align='center'>God<br />Mode</t>";
					btn_godMode ctrlSetPosition [0.5825 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
					btn_godMode ctrladdEventHandler ["ButtonClick",{
						if (isNil "godModeTggle") then {godModeTggle = 1};
						if (godModeTggle == 1) then {
							godModeTggle = 0;
							player allowDamage false;
							EH_god = player addEventHandler ["Respawn", {player enableFatigue false;}];
							titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						} else {
							godModeTggle = 1;
							player allowDamage true;
							player removeEventHandler ["Respawn", EH_god];
							titleText ["<t color='#42D6FC'>GOD </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_godMode ctrlCommit 0;
					
					btn_noRecoil = d_mainConsole ctrlCreate ["RscButtonMenu", 5264];
					btn_noRecoil ctrlSetStructuredText parseText "<t size='0.9' align='center'>Disable<br />Recoil</t>";
					btn_noRecoil ctrlSetPosition [0.479375 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_noRecoil ctrladdEventHandler ["ButtonClick",{
						if (isNil "disableRecoilTggle") then {disableRecoilTggle = 1};
						if (disableRecoilTggle == 1) then {
							disableRecoilTggle = 0;
							player setUnitRecoilCoefficient 0;
							player setCustomAimCoef 0.1;
							EH_disableRecoil = player addEventHandler ["Respawn", {player enableFatigue false;}];
							titleText ["<t color='#42D6FC'>NO-RECOIL </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						} else {
							disableRecoilTggle = 1;
							player setUnitRecoilCoefficient 1;
							player setCustomAimCoef 1;
							player removeEventHandler ["Respawn", EH_disableRecoil];
							titleText ["<t color='#42D6FC'>NO-RECOIL </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_noRecoil ctrlCommit 0;
					
					btn_infAmmo = d_mainConsole ctrlCreate ["RscButtonMenu", 5265];
					btn_infAmmo ctrlSetStructuredText parseText "<t size='0.9' align='center'>Infinite<br />Ammo</t>";
					btn_infAmmo ctrlSetPosition [0.530937 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.0464063 * safezoneW,0.055 * safezoneH];
					btn_infAmmo ctrladdEventHandler ["ButtonClick",{
						if (isNil "infAmmoTggle") then {infAmmoTggle = 1};
						if (infAmmoTggle == 1) then {
							infAmmoTggle = 0;
							titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
							[] spawn {
								while {infAmmoTggle == 0} do {
									player setVehicleAmmo 1;
									vehicle player setVehicleAmmo 1;
									sleep 0.5;
								};
							};
						} else {
							infAmmoTggle = 1;
							titleText ["<t color='#42D6FC'>INFAMMO </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_infAmmo ctrlCommit 0;
					
					btn_aiIgnore = d_mainConsole ctrlCreate ["RscButtonMenu", 5266];
					btn_aiIgnore ctrlSetStructuredText parseText "<t size='0.9' align='center'>AI<br />Ignore</t>";
					btn_aiIgnore ctrlSetPosition [0.5825 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.04125 * safezoneW,0.055 * safezoneH];
					btn_aiIgnore ctrladdEventHandler ["ButtonClick",{
						if (isNil "aiIgnoreTggle") then {aiIgnoreTggle = 1};
						if (aiIgnoreTggle == 1) then {
							aiIgnoreTggle = 0;
							player setCaptive true;
							EH_aiIgnore = player addEventHandler ["Respawn", {player enableFatigue false;}];
							titleText ["<t color='#42D6FC'>AI Ignore </t><t color='#FFFFFF'>[ON]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						} else {
							aiIgnoreTggle = 1;
							player setCaptive false;
							player removeEventHandler ["Respawn", EH_aiIgnore];
							titleText ["<t color='#42D6FC'>AI Ignore </t><t color='#FFFFFF'>[OFF]</t>", "PLAIN DOWN", -1, true, true];
							playSound "Hint";
						};
					}];
					btn_aiIgnore ctrlCommit 0;
				};
				
				_keybinds = [] spawn { 
					waitUntil { !(IsNull (findDisplay 46)) };				
					
					[] spawn {
						while {true} do {

						if ({"rhs_mag_kh55sm" in ([(configFile >> "CfgMagazines" >> _x),true] call BIS_fnc_returnParents)} count magazines vehicle player > 0
							&& !("rhs_weap_kh55sm_Launcher" in weapons (vehicle player))) then {
							
							
							vehicle player addWeapon "rhs_weap_kh55sm_Launcher";
						};
								
						sleep 2;
						};
					};

					private["_keyDown"];
					[] spawn {
						waitUntil {!isNull player && player == player};
						waitUntil{!isNil "BIS_fnc_init"};
						waitUntil {!(IsNull (findDisplay 46))};
						GOM_list_allPylonMags = ("count( getArray (_x >> 'hardpoints')) > 0" configClasses (configfile >> "CfgMagazines")) apply {configname _x};
						GOM_list_allPylonMags = [GOM_list_allPylonMags, [], {getText (configfile >> "CfgMagazines" >> _x >> "displayName")}, "ASCEND"] call BIS_fnc_sortBy;
						GOM_list_validDispNames = GOM_list_allPylonMags apply {getText (configfile >> "CfgMagazines" >> _x >> "displayName")};
						DCON_Garage_Loadout_Controls = [];
						_load = [] spawn {
							if(count (missionNamespace getVariable ["allWeapons",[]]) == 0) then {
								disableSerialization;
								
								_allWeapons = ("isclass _x && {getnumber (_x >> 'scope') != 0}" configclasses (configfile >> "cfgweapons")) select {(configName _x) call BIS_fnc_itemType select 0 isEqualTo "Weapon" || (configName _x) call BIS_fnc_itemType select 0 isEqualTo "VehicleWeapon"} apply {toLower (configName _x)};
								
								_allWeapons sort true;
								missionNamespace setVariable ["allWeapons", _allWeapons];
							};
							systemChat "All weapons loaded";
						}; 



						systemChat "Personal arsenal loaded";
						private["_i", "_keyDown"];
						_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
						
							_key = _this select 1;
							switch true do
							{
								case (_key in actionKeys 'User1'): {[] call JEW_fnc_main};
								case (_key in actionKeys 'User6'): {player moveInAny cursorTarget};
								case (_key in actionKeys 'User2'): {[0] spawn JEW_open_mainConsole};
							};
							false;
						}];

						player enablefatigue false;
						
						player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0}"];		
						player addAction ["Enable driver assist", {[] spawn JEW_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
						player addAction ["Disable driver assist", {[] spawn JEW_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
							
						player setVariable ["ControlPanelID",[
							player addAction  
							[
								"Open control panel",  
								{ 
								params ["_target", "_caller", "_actionId", "_arguments"]; 
								createDialog "tu95_main_dialog"; 
								}, 
								[], 
								7,  
								true,  
								true,  
								"", 
								"currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
							],
						
							player addAction  
							[
								"Open control panel",  
								{ 
								params ["_target", "_caller", "_actionId", "_arguments"]; 
								createDialog "ss21_main_dialog"; 
								}, 
								[], 
								7,  
								true,  
								true,  
								"", 
								"currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
							]]
						];
						
						player addEventhandler ["Respawn", {
		
							player enableFatigue false;
							
							player addAction ["Loiter Waypoint Command", {[] spawn LIT_fnc_open;}, [], 0.5, false, true, "", "_veh = objectParent player; {alive _veh && {_veh isKindOf _x} count ['Plane'] > 0}"];		
							player addAction ["Enable driver assist", {[] spawn JEW_fnc_enableDriverAssist;}, [], 0.5, false, true, "", "_veh = objectParent player; alive _veh && !alive driver _veh && {effectiveCommander _veh == player && player in [gunner _veh, commander _veh] && {_veh isKindOf _x} count ['LandVehicle','Ship'] > 0 && !(_veh isKindOf 'StaticWeapon')}"];
							player addAction ["Disable driver assist", {[] spawn JEW_fnc_disableDriverAssist;}, [], 0.5, false, true, "", "_driver = driver objectParent player; isAgent teamMember _driver && {(_driver getVariable ['A3W_driverAssistOwner', objNull]) in [player,objNull]}"];
							
							player setVariable ["ControlPanelID",[

								player addAction  
								[ 
									"Open control panel",  
									{ 
									params ["_target", "_caller", "_actionId", "_arguments"]; 
									createDialog "tu95_main_dialog"; 
									}, 
									[], 
									7,  
									true,  
									true,  
									"", 
									"currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
								],


								player addAction  
								[ 
									"Open control panel",  
									{ 
									params ["_target", "_caller", "_actionId", "_arguments"]; 
									createDialog "ss21_main_dialog"; 
									}, 
									[], 
									7,  
									true,  
									true,  
									"", 
									"currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
								]]
							];
						}];
						player addEventHandler ["GetInMan", {
							params ["_vehicle", "_role", "_unit", "_turret"];
							
							_vehicle = vehicle player;
							
							
							if(_vehicle getVariable ["ControlPanelID",-1] isEqualTo -1) then {
							
								_vehicle setVariable ["ControlPanelID",
									[_vehicle addAction  
									[
									"Open control panel",  
									{ 
										params ["_target", "_caller", "_actionId", "_arguments"]; 
										createDialog "tu95_main_dialog"; 
									}, 
									[], 
									7,  
									true,  
									true,  
									"", 
									"currentWeapon vehicle player isEqualTo 'rhs_weap_kh55sm_Launcher'" 
									],
									
									
									_vehicle addAction  
									[ 
									"Open control panel",  
									{ 
										params ["_target", "_caller", "_actionId", "_arguments"]; 
										createDialog "ss21_main_dialog"; 
									}, 
									[], 
									7,  
									true,  
									true,  
									"", 
									"currentWeapon vehicle player isEqualTo 'RHS_9M79_1Launcher'" 
									]]	   
								];
							};	
						}];

					};

					EH_mapTP = player addEventHandler ["Respawn", {
						JEW_fnc_mapTP = {if (!_shift and _alt) then {(vehicle player) setPos _pos;};};
						JEW_keybind_mapTP = ["JEWfncMapTP", "onMapSingleClick", JEW_fnc_MapTP] call BIS_fnc_addStackedEventHandler;
					}];
					SystemChat "...< Keybinds Initialized >...";
				};
				SystemChat "...< Client Initialized >...";
				SystemChat "-----------------------------";
				SystemChat "...< HOME - Main Console >...";
			};
		};
				
				
		}] remoteExec ["spawn",0,"GustavisveryCOOL"];
};

script_notifyWhenDone_Gustav = [] spawn {
	waitUntil { scriptDone script_initCOOLJIPgustav };
	for "_i" from 0 to 10 do {
		SystemChat "...< Init Complete >...";
		sleep 5;
	};
};
