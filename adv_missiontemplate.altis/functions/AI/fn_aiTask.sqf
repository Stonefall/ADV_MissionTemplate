﻿/*
adv_fnc_simplePatrol:

Creates a simple patrol around a center with the given radius. Group is usually being spawned at a random location preferrably inside the radius.

possible call, has to be executed on either server or headless client:
//regular patrol:
[["O_Soldier_TL_F","O_Soldier_GL_F"],east,"spawnMarker",200,0] call ADV_fnc_simplePatrol;
//spawning attack:
[["O_Soldier_TL_F","O_Soldier_GL_F"],east,"spawnMarker",200,4,["attackMarker",100]] call ADV_fnc_simplePatrol;

_this select 0 = units array - format: array of objects
_this select 1 = side of the units - format: side
_this select 2 = center of the patrol circle - format: object, marker or position
_this select 3 = radius of the patrol circle - format: number (optional)
_this select 4 = behaviour mode:
	0 = regular patrol,
	1 = searching buildings near waypoints,
	2 = garrison buildings in radius around center,
	3 = defend area (buildings are being defended, static guns manned and the group leader will patroul around; radius above 150meters will revert to 150 meters),
	4 = attack location around object, marker or position provided in _this select 5 - if nothing is provided, the next enemy will be targeted,
	- format: number (optional)
_this select 5 = attack position with radius - format: array of two elements, with first being object, marker or position, second being the spread radius around the first element (optional)
*/

if (!isServer && hasInterface) exitWith {};

params [
	["_units", ["O_Soldier_TL_F","O_Soldier_GL_F","O_Soldier_F","O_Soldier_F","O_soldier_AR_F","O_medic_F"], [[]]]
	,["_side", east, [west]]
	,["_location", [0,0,0], [[],"",objNull]]
	,["_radius", 300, [0]]
	,["_mode", 0, [0]]
	,["_attack", [objNull,[0,0,0]], [[]]]
];

private _start = call {
	if (_location isEqualType "") exitWith {getMarkerPos _location};
	if (_location isEqualType objNull) exitWith {getPosATL _location};
	if (_location isEqualType []) exitWith {_location};
	nil;
};

private _dist = random _radius;
private _dir = random 360;
private _pos = [(_start select 0) + (sin _dir) * _dist, (_start select 1) + (cos _dir) * _dist, 0];
private _spawn = [_pos,0,50,10,0,0.4,0] call BIS_fnc_findSafePos;

private _grp = [_units,_side,_spawn] call adv_fnc_spawnGroup;

call {
	if (_mode == 1) exitWith {
		[_grp, _start, _radius, 5, "MOVE", "SAFE", "GREEN", "LIMITED", "STAG COLUMN", "this spawn CBA_fnc_searchNearby", [3,6,9]] call CBA_fnc_taskPatrol;
	};
	if (_mode == 2) exitWith {
		[_start, units _grp, _radius, true, true] call adv_fnc_ZenOccupyHouse;
	};
	if (_mode == 3) exitWith {
		if (_radius > 150) then { _radius = 150 };
		[_grp, _start, _radius, 2, true] call CBA_fnc_taskDefend;
	};
	if (_mode == 4) exitWith {
		_target = call {
			if ((_attack select 0) isEqualType "") exitWith {getMarkerPos (_attack select 0)};
			if ((_attack select 0) isEqualType objNull) exitWith {getPosWorld (_attack select 0)};
			if ((_attack select 0) isEqualType []) exitWith {(_attack select 0)};
			[0,0,0];
		};
		
		if (_target isEqualTo [0,0,0]) then {
			private _leader = (units _grp) select 0;
			private _enemy = [_leader,3000] call adv_fnc_findNearestEnemy;
			_target = getPos _enemy;
		};
		
		_wp = _grp addWaypoint [_target, (_attack select 1)];
		_wp setWaypointType "SAD";
		_wp setWaypointBehaviour "AWARE";
		_wp setWaypointCombatMode "YELLOW";
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointFormation "WEDGE";
	};
	[_grp , _start, _radius] call bis_fnc_taskPatrol;
};
_grp;
