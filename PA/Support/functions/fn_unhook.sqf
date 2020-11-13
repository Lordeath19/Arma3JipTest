/**
 * Drop the object from the helicopter
 *
 * @param helicopter
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

    R3F_LOG_mutex_local_verrou = false;
};