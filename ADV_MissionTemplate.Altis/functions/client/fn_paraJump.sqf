﻿/*
ADV_fnc_paraJump - by Belbo:

Allows player to jump with a parachute over a position that's defined by mapclick (or by position of group leader of the player)

Possible call - has to be executed where unit is local:
	[player] call ADV_fnc_paraJump;
Or, with an addaction:
	ADV_handle_paraJumpAction = OBJECT addAction [("<t color=""#33FFFF"">" + ("Parajump") + "</t>"), {[_this select 1] call ADV_fnc_paraJump},nil,3,false,true,"","player distance cursortarget <5"];
*/

params [
	["_unit",player,[objNull]]
];

if !(local _unit) exitWith {};

//script function defined for use below:
ADV_scriptfnc_paraJump = {
	params [
		["_unit",player,[objNull]],
		["_targetPos",[0,0,0], [[]]]
	];
	
	//has the unit had a backpack?
	_hadBackpack = if !(backpack _unit == "") then {true} else {false};
	if (_hadBackpack) then {
		if (!isNil "aeroson_fnc_getLoadout") then {
			aeroson_loadout = [_unit] call aeroson_fnc_getLoadout;
			if !(isNil "ADV_respawn_EVH") then {
				_unit removeEventHandler ["Respawn", ADV_respawn_EVH]
			};
			ADV_respawn_EVH = _unit addEventhandler ["Respawn",{[(_this select 0), aeroson_loadout] spawn aeroson_fnc_setLoadout;deleteVehicle (_this select 1);systemChat "saved loadout applied.";}];
		} else {
			[_unit,[_unit,"inv"]] call BIS_fnc_saveInventory;
		};
		removeBackpack _unit;
	};
	
	//Parachute is given
	_unit addBackpack "B_Parachute";
	sleep 1;
	//unit is moved to height 1500 on given position
	_targetPos = [_targetPos select 0, _targetPos select 1, 1500];
	_unit setPosATL _targetPos;
	
	//safety:
	waitUntil {((getPosATL _unit) select 2) > 900};
	waitUntil {((getPosATL _unit) select 2) < 110};
	if (isClass(configFile >> "CfgPatches" >> "ace_parachute")) then {
		if !(backpack _unit == "ACE_ReserveParachute") then {
			_unit action ["openParachute", _unit];
		};
	} else {
		_unit action ["openParachute", _unit];
	};
	
	//removal of the parachute:
	waitUntil {sleep 0.5; isTouchingGround _unit};
	if !(isClass(configFile >> "CfgPatches" >> "ace_parachute")) then { _unit playMove "AinvPercMstpSrasWrflDnon_Putdown_AmovPercMstpSrasWrflDnon"; };
	sleep 1;
	_unit action ["PutBag"];
	sleep 1;
	//and readding the old one:
	if (_hadBackpack) then {
		sleep 1;
		if (!isNil "aeroson_fnc_getLoadout") then {
			[_unit, aeroson_loadout] spawn aeroson_fnc_setLoadout;
		} else {
			[_unit,[_unit,"inv"]] call BIS_fnc_loadInventory;
		};
		systemChat "backpack readded.";
	};
};

//actual code:
if (_unit == leader group _unit) then {
	openmap true;
	[_unit] onMapSingleClick "openmap false; [_this select 0,_pos] spawn ADV_scriptfnc_paraJump; onmapsingleclick '';";
} else {
	[_unit,getPosATL (leader group _unit)] spawn ADV_scriptfnc_paraJump;
};

if (true) exitWith {};