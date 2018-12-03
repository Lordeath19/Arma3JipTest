/**
 * Détermine les fonctionnalités logistique disponibles pour une classe donnée
 * 
 * @param 0 le nom de classe pour lequel déterminer les fonctionnalités logistique
 * 
 * @return 0 true si can_be_depl_heli_remorq_transp
 * @return 1 true si can_be_moved_by_player
 * @return 2 true si can_be_lifted
 * @return 3 true si can_be_towed
 * @return 4 true si can_be_transported_cargo
 * @return 5 true si can_lift
 * @return 6 true si can_tow
 * @return 7 true si can_transport_cargo
 * 
 * Copyright (C) 2014 Team ~R3F~
 * 
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

_can_be_depl_heli_remorq_transp = true;
_can_be_moved_by_player = true;
_can_lift = true;
_can_be_lifted = true;
_can_tow = true;
_can_be_towed = true;
_can_transport_cargo = true;
_can_transport_cargo_cout = 9000000;
_can_be_transported_cargo = true;
_can_be_transported_cargo_cout = 0;


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