﻿if !(isClass(configFile >> "CfgPatches" >> "rhs_main")) exitWith {};

params [
	["_veh", objNull, [objNull]]
];

switch true do {
	case (_veh isKindOf "rhsusf_hmmwe_base"): {
		if (ADV_par_modCarAssets == 9) then {
			[_veh,["OLIVE",1],Nil] call BIS_fnc_initVehicle;
		};
	};
	default {};
};

if (true) exitWith {};