/**
 * Attach object to the helicopter
 *
 * @param 0 The helicopter
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
    _objet = _this select 1;

    // Recherche de l'objet à héliporter

    if (!isNull _objet) then
    {
        if !(_objet getVariable "R3F_LOG_disabled") then
        {
            if ((isNull (_objet getVariable "R3F_LOG_est_deplace_par") || (!alive (_objet getVariable "R3F_LOG_est_deplace_par")) || (!isPlayer (_objet getVariable "R3F_LOG_est_deplace_par")))) then
            {

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

                        };

                        sleep 0.1;
                    };
                };

            }
            else
            {
                systemChat format [STR_R3F_LOG_objet_en_cours_transport, getText (configFile >> "CfgVehicles" >> (typeOf _objet) >> "displayName")];
            };
        };
    };

    R3F_LOG_mutex_local_verrou = false;
};
