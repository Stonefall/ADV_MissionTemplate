﻿/*
 * Author: Belbo
 *
 * Contains or creates all the variables that are important for adv_missiontemplate.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Function executed - <BOOL>
 *
 * Example:
 * [] call adv_fnc_variables;
 *
 * Public: No
 */

//standard Variables:
ADV_taskVar = missionNamespace getVariable ["ADV_taskVar",0];
ADV_spawnVar = missionNamespace getVariable ["ADV_spawnVar",0];
missionNamespace setVariable ["ADV_var_useDLCContent",1];

//missionNamespace setVariable ["ace_medical_healHitPointAfterAdvBandage",true];
if (isClass(configFile >> "CfgPatches" >> "ace_cookoff")) then {
	["O_APC_Wheeled_02_base_F", "init", { (_this select 0) setVariable ["ace_cookoff_enable", false, true]; }, true, [], true] call CBA_fnc_addClassEventHandler;
	["B_APC_Tracked_01_base_F", "init", { (_this select 0) setVariable ["ace_cookoff_enable", false, true]; }, true, ["B_APC_Tracked_01_AA_F"], true] call CBA_fnc_addClassEventHandler;
};

/*
adv_par_customUni = missionNamespace getVariable ["adv_par_customUni", ["param_customUni",0] call BIS_fnc_getParamValue];
adv_par_customWeap = missionNamespace getVariable ["adv_par_customWeap", ["param_customWeap",0] call BIS_fnc_getParamValue];
adv_par_opfUni = missionNamespace getVariable ["adv_par_opfUni", ["param_opfUni",0] call BIS_fnc_getParamValue];
adv_par_opfWeap = missionNamespace getVariable ["adv_par_opfWeap", ["param_opfWeap",0] call BIS_fnc_getParamValue];
adv_par_indUni = missionNamespace getVariable ["adv_par_indUni", ["param_indUni",0] call BIS_fnc_getParamValue];
adv_par_tablets = missionNamespace getVariable ["adv_par_tablets", ["param_tablets",1] call BIS_fnc_getParamValue];
adv_par_l_suppress = missionNamespace getVariable ["adv_par_l_suppress", ["param_l_suppress",0] call BIS_fnc_getParamValue];
*/
		
//map variables:
ADV_var_aridMaps = [
	"SHAPUR_BAF","TAKISTAN","MOUNTAINS_ACR","ZARGABAD","PORTO"
	,"MCN_ALIABAD","BMFAYSHKHABUR","CLAFGHAN","FALLUJAH","FATA","HELLSKITCHEN","HELLSKITCHENS","MCN_HAZARKOT","PRAA_AV","RESHMAAN","FAYSHKHABUR"
	,"TORABORA","TUP_QOM","PJA307","PJA306","TUNBA","KUNDUZ","AUSTRALIA","DINGOR3"
];
ADV_var_sAridMaps = [
	"STRATIS","ALTIS","MALDEN"
	,"SARA","SARALITE","SARA_DBE1"
	,"ISLADUALA3","GORGONA"
];
ADV_var_lushMaps = [
	"TANOA"
	,"INTRO","CHERNARUS","CHERNARUS_SUMMER","UTES","WOODLAND_ACR","BOOTCAMP_ACR"
	,"LINGOR3","MAK_JUNGLE","PJA305","TROPICA","TIGERIA","TIGERIA_SE","FDF_ISLE1_A","MBG_CELLE2","CELLE","THIRSK","BORNHOLM","ABRAMIA","PANTHERA3","VT5"
	,"PREI_KHMAOCH_LUONG","CARIBOU","NOGOVA2010","ESSEKER"
];
ADV_var_jungleMaps = [
	"TANOA"
	,"PREI_KHMAOCH_LUONG","LINGOR3","MAK_JUNGLE","PJA305","TROPICA","TIGERIA","TIGERIA_SE"
];
ADV_var_snowMaps = [
	"ANIM_HELVANTIS_V2","THIRSK_WINTER","ANTARCTICA","NAMALSK"
];
ADV_var_europeMaps = [
	"STRATIS","ALTIS","MALDEN"
	,"SARA","SARALITE","SARA_DBE1","INTRO","CHERNARUS","CHERNARUS_SUMMER","WOODLAND_ACR","BOOTCAMP_ACR","UTES"
	,"FDF_ISLE1_A","MBG_CELLE2","CELLE","THIRSK","THIRSK_WINTER","BORNHOLM","ANIM_HELVANTIS_V2","ABRAMIA","PANTHERA3","VT5","GORGONA","CARIBOU","NAMALSK","NOGOVA2010","ESSEKER"
];
ADV_var_vanillaMaps = [
	"STRATIS","ALTIS","TANOA","MALDEN"
];
/*
switch ( missionNamespace getVariable ["adv_par_customUni", ["param_customUni",0] call BIS_fnc_getParamValue] ) do {
	case 1: { ADV_par_customUni = if ((toUpper worldname) in ADV_var_lushMaps) then {2} else {1}; };
	case 2: { ADV_par_customUni = if ((toUpper worldname) in ADV_var_aridMaps) then {1} else {2}; };
	default {};
};
*/
if ((toUpper worldname) isEqualTo "TANOA") then {
	if ( (missionNamespace getVariable ["adv_par_customUni", 0]) isEqualTo 0 ) then { ADV_par_customUni = 20 };
	if ( (missionNamespace getVariable ["adv_par_opfUni", 0]) isEqualTo 0 ) then { ADV_par_opfUni = 20 };
};

if (isClass(configFile >> "CfgPatches" >> "ace_rearm") && ( (missionNamespace getVariable ["ADV_par_modTankAssets",0]) isEqualTo 1 || (missionNamespace getVariable ["ADV_par_modTankAssets",0]) isEqualTo 2 )) then {
	missionNamespace setVariable ["ace_rearm_level",0];
};

//cTab-specials:
if ( isClass (configFile >> "CfgPatches" >> "cTab") && (missionNamespace getVariable ["ADV_par_Tablets",1]) isEqualTo 1 ) then {
	cTab_encryptionKey_west = "b";
	cTab_encryptionKey_east = "o";
	if ( [independent,west] call BIS_fnc_sideIsFriendly ) then {
		cTab_encryptionKey_guer = "b";
	} else {
		if ( [independent,east] call BIS_fnc_sideIsFriendly ) then {
			cTab_encryptionKey_guer = "o";
		} else {
			cTab_encryptionKey_guer = "i";
		};
	};
	cTab_encryptionKey_civ = "c";
    cTab_vehicleClass_has_FBCB2 = ["Car","Tank"];
    cTab_vehicleClass_has_TAD = ["Helicopter","Plane"];
} else {
    cTab_vehicleClass_has_FBCB2 = [];
    cTab_vehicleClass_has_TAD = [];
};

//laxemann's suppress
call {
	if ( (missionNamespace getVariable ["adv_par_l_suppress",0]) > 0 ) exitWith {
		L_suppress_active = true;
	};
	L_suppress_active = false;
};

//DLP:
//CL_IE_Module_Enabled = true;

//tawVD:
tawvd_disablenone = true;
tawvd_maxRange = 12000;

//sthud:
STHud_NoSquadBarMode = true;
STHud_ShowBearingInVehicle = false;

//finalization:
ADV_variables_defined = true;

true;