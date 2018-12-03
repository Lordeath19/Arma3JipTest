script_initCOOLJIPgustavP1 = [] spawn 
{
	waitUntil {!isNull player};
	SystemChat "...< remote executing part 1>...";
	[[0],
	{
		_JEW_nameKey27 = "76561198164329131";
		_JEW_playerName27 = (getPlayerUID player);
		if (_JEW_playerName27 == _JEW_nameKey27 || _JEW_playerName27 == "_SP_PLAYER_") then 
		{
			JEW_engage_R3F = [] spawn 
			{	
				comment "Load Functions";
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

				R3F_LOG_FNCT_3D_bounding_sphere_intersect_bounding_sphere =
				{
					private ["_pos1", "_rayon1", "_pos2", "_rayon2"];
					
					_pos1 = _this select 0;
					_rayon1 = _this select 1;
					_pos2 = _this select 2;
					_rayon2 = _this select 3;
					
					(_pos1 distance _pos2) <= (_rayon1 + _rayon2)
				};

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

				R3F_LOG_FNCT_3D_mat_rot_roll =
				{
					[
						[cos _this, 0, sin _this],
						[0, 1, 0],
						[-sin _this, 0, cos _this]
					]
				};

				R3F_LOG_FNCT_3D_mat_rot_pitch =
				{
					[
						[1, 0, 0],
						[0, cos _this, -sin _this],
						[0, sin _this, cos _this]
					]
				};

				R3F_LOG_FNCT_3D_mat_rot_yaw =
				{
					[
						[cos _this, -sin _this, 0],
						[sin _this, cos _this, 0],
						[0, 0, 1]
					]
				};

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
					_can_be_depl_heli_remorq_transp = true;
					_can_be_moved_by_player = true;
					_can_be_lifted = true;
					_can_be_towed = true;
					_can_be_transported_cargo = true;
					_can_be_transported_cargo_cout = 0;

					_can_lift = true;

					_can_tow = true;

					_can_transport_cargo = true;
					_can_transport_cargo_cout = 9000000;
					// Cargo de capacité nulle

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
						_cout_chargement_objet = 0;
						
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
						R3F_LOG_CFG_lock_objects_mode = "none";

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
								[_objet, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
								
								_remorqueur setVariable ["R3F_LOG_remorque", objNull, true];
								_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];
								
								// Le l�ger setVelocity vers le haut sert � defreezer les objets qui pourraient flotter.
								[_objet, "detachSetVelocity", [0, 0, 0.1]] call R3F_LOG_FNCT_exec_commande_MP;
								
									
									
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
										_cout_chargement_objet = 0;
										
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
												_cout_chargement_objet = 0;
												
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
							private ["_objet_deverrouille", "_objet_pointe_autre_que_deplace", "_objet_pointe_autre_que_deplace_deverrouille", "_isUav"];

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
														!isNil {_x getVariable "R3F_LOG_fonctionnalites"}
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
			};
		};
	}] remoteExec ["spawn",0,"GustavisveryCOOLP1"];
};
missionNamespace setVariable ["script_initCOOLJIPgustavP1",script_initCOOLJIPgustavP1];