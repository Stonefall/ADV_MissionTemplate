﻿/*
 * Author: Belbo
 *
 * Creates a convoy.
 * The convoy will be spawned at the provided location and move to a target location with combat mode "SAFE" and "LIMITED" speed. Upon arrival all carried units will be unloaded.
 * Make SURE the first vehicle has enough space to start moving (eg. no houses blocking a whole turning circcle of the vehicle).
 * The first array of units contains the vehicles that make up the convoy.
 * Second array of units contains the units each vehicle with at least as many free cargo spaces will carry. If there are more units in the array than free cargo spaces, no group will spawn!
 *
 * Arguments:
 * 0: spawn location (can be position, object or marker) - <ARRAY>, <OBJECT>, <STRING>
 * 1: target destination (can be position, object or marker) - <ARRAY>, <OBJECT>, <STRING>
 * 2: vehicles classnames array - <ARRAY> of <STRINGS>
 * 3: units classnames array - <ARRAY> of <STRINGS>
 * 4: side of all units in convoy - <SIDE>
 * 5: Parameters for convoy: - <ARRAY> of <STRINGS> (optional)
 *		1: Speed, can be "LIMITED", "NORMAL", "FULL" - <STRING>
 *		2: Behaviour, can be "CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH" - <STRING>
 *		3: Combat Mode, can be "BLUE", "GREEN", "WHITE", "YELLOW", "RED" - <STRING>
 *		4: Formation, can be "COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND" - <STRING>
 * 6: stations along the way )has to be an array of positions, objects or markers) - <ARRAY> of <ARRAYS, <OBJECTS> or <STRINGS>  (optional)
 *
 * Return Value:
 * Array containing spawned group of vehicles, followed by an array of the groups on the vehicles - <ARRAY> in format: [<GROUP>,[<GROUP>, <GROUP>, ...]]
 *
 * Example:
 * [spawnLogic,destinationLogic,["O_MRAP_02_hmg_F","O_Truck_02_transport_F","O_Truck_02_transport_F","O_Truck_02_transport_F","O_MRAP_02_hmg_F"],["O_Soldier_SL_F","O_Soldier_AR_F","O_Soldier_GL_F","O_Soldier_F","O_soldier_LAT_F","O_medic_F"],east,["LIMITED","SAFE","GREEN","COLUMN"],[stationLogic_1,stationLogic_2]] call ADV_fnc_spawnConvoy;
 *
 * Public: Yes
 */

if (!isServer && hasInterface) exitWith {};

params [
	["_location", [0,0,0], [[],"",objNull]]
	,["_targetLocation", [0,0,0], [[],"",objNull]]
	,["_vehicles", ["O_MRAP_02_hmg_F","O_Truck_02_transport_F","O_Truck_02_transport_F","O_Truck_02_transport_F","O_MRAP_02_hmg_F"], [[],configNull]]
	,["_units", ["O_Soldier_SL_F","O_Soldier_AR_F","O_Soldier_GL_F","O_Soldier_F","O_soldier_LAT_F","O_Soldier_F","O_Soldier_A_F","O_medic_F"], [[],configNull]]
	,["_side", east, [west]]
	,["_modifiers",["LIMITED","AWARE","GREEN","COLUMN"],[[]]]
	,["_stations",[],[[]]]
];

//select target pos depending on given parameter:
private _destination = [_targetLocation] call adv_fnc_getPos;
//select starting pos depending on given parameter:
private _start = [_location] call adv_fnc_getPos;
//different standards for the _modifiers array:
_modifiers params [
	["_speed","LIMITED",[""]]
	,["_behaviour","AWARE",[""]]
	,["_combatMode","GREEN",[""]]
	,["_formation","COLUMN",[""]]
];
//get positions for given stations:
private _stationsPos = _stations apply { [_x] call adv_fnc_getPos };

//create group of vehicles first:
private _grp = [
	_location
	,_vehicles
	,_side
] call ADV_fnc_spawnGroup;
[_grp,10] call adv_fnc_setSafe;

//adds waypoints for way stations:
if !(_stations isEqualTo []) then {
	{
		private _wp = _grp addWaypoint [_x, 1];
		_wp setWaypointType "MOVE";
		_wp setWaypointCompletionRadius 50;
		_wp setWaypointBehaviour _behaviour;
		_wp setWaypointCombatMode _combatMode;
		_wp setWaypointSpeed _speed;
		_wp setWaypointFormation _formation;
		nil;
	} count _stationsPos;
};

//add destination waypoint:
private _wp = _grp addWaypoint [_destination, 10];
_wp setWaypointType "TR UNLOAD";
_wp setWaypointCompletionRadius 50;
_wp setWaypointBehaviour _behaviour;
_wp setWaypointCombatMode _combatMode;
_wp setWaypointSpeed _speed;
_wp setWaypointFormation _formation;
_wp setWaypointStatements ["true", "vehicle this land 'GET OUT'"];

//get all vehicles of vehicle group:
private _allVehiclesConvoy = [_grp] call adv_fnc_getGroupVehicles;
//get all vehicles that can fit a whole group of _units:
private _size = count _units;
private _vehiclesConvoy = [];
{
	if ( (_x emptyPositions "cargo") >= _size ) then {
		_vehiclesConvoy pushBackUnique _x;
	};
} forEach _allVehiclesConvoy;

//assignAsCargo and moveInCargo in one:
private _moveInCargo = {
	params ["_grp","_vehicle"];
	{
		_x assignAsCargo _vehicle;
		_x moveInCargo _vehicle;
		nil;
	} count (units _grp);
};

//collection array for infantry groups:
private _infantryGroups = [];

//spawn a group for each vehicle and move it in cargo positions:
{
	private _grp_inf = [
		[(_start select 0),(_start select 1)-50,0]
		,_units
		,_side
	] call ADV_fnc_spawnGroup;
	[_grp_inf,10] call adv_fnc_setSafe;
	[_grp_inf,_x] call _moveInCargo;
	_infantryGroups pushback _grp_inf;
	[_grp_inf] spawn {
		params ["_grp_inf"];
		sleep 20;
		[
			{ {vehicle _x isEqualTo _x} count (units (_this select 0)) > ((count units (_this select 0))/3) || !alive (leader (_this select 0)) }
			,{ params ["_grp_inf"];[_grp_inf, getPos (leader _grp_inf), 150, 2, true] call CBA_fnc_taskDefend; }
			,[_grp_inf]
		] call CBA_fnc_waitUntilAndExecute;
	};
	nil;
} count _vehiclesConvoy;

//return:
private _return = [_grp,_infantryGroups];
_return;