SystemChat "...< Loading >...";		



script_notifyWhenDone_Gustav = [] spawn 
{
	waitUntil { !(missionNamespace getVariable ["script_initCOOLJIPgustavFinal",""] isEqualTo "") && scriptDone (missionNamespace getVariable "script_initCOOLJIPgustavFinal") };
	for "_i" from 0 to 10 do 
	{
		SystemChat "...< Init Complete >...";
		sleep 5;
	};
};
