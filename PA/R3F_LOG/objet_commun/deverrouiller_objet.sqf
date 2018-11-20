/**
 * Gestion du déverrouillage d'un objet et du compte-à-rebours
 * 
 * @param 0 l'objet à déverrouiller
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
	
	// Mise à jour du propriétaire du verrou
	[_objet, player] call R3F_LOG_FNCT_definir_proprietaire_verrou;
	
	systemChat STR_R3F_LOG_deverrouillage_succes_attente;
	
	R3F_LOG_mutex_local_verrou = false;
};