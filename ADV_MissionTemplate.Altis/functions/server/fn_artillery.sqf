﻿/*
Based on the Artillery-Script by Nyaan (edited by Belbo)
[[target_1,target_2],"Sh_155mm_AMOS",[3,7],300,5,50] spawn ADV_fnc_artillery;
*/

/*
_ammotype = [_this, 0, "Sh_155mm_AMOS"] call BIS_fnc_param;		//"Sh_155mm_AMOS": type of ammo to be used ("Sh_155mm_AMOS", "Sh_82mm_AMOS")
_targetArray = [_this, 1, [""]] call BIS_fnc_param;				//[""]: target of artillery fire
_delay = [_this, 2, [3,7]] call BIS_fnc_param;					//4 seconds: delay between each shell
_height = [_this, 3, 300] call BIS_fnc_param;					//300 meter: height shells will fall from
_amount = [_this, 4, 5] call BIS_fnc_param;						//4: total shells fired
_spread = [_this, 5, 50] call BIS_fnc_param;					//50 meter: how close they will be to the target
_playSounds = [_this,6,true] call BIS_fnc_param;				//true: If sounds should be played for dropping projectile
*/

params [
	["_targetArray", [], [[]]],
	["_ammoType", "Sh_155mm_AMOS", [""]],
	["_delay", [3,7], [[]]],
	["_height", 300, [0]],
	["_amount", 5, [0]],
	["_spread", 50, [0]],
	"_targetType", "_targetPos", "_strike", "_sound", "_soundFile"
];

{
	_target = _x;
	if (!isNil "_target") then {
		_targetType = typeName (_target);
		_targetPos = nil;
		for "_x" from 1 to _amount do {
			if (_targetType == "STRING") then {
				_targetPos = [getMarkerPos _target select 0, getMarkerPos _target select 1, _height];
			};
			if (_targetType == "OBJECT") then {
				_targetPos = [getPos _target select 0, getPos _target select 1, _height];
			};
			_strike = createVehicle [_ammotype, _targetPos, [], _spread, "NONE"];
			_strike allowdamage false;
			_strike setvectorup [0,9,0.1];
			_strike setvelocity [0,0,-150];
			waitUntil {((getPosATL _strike) select 2) < 300};
			_sound = ["incoming1.wss","incoming2.wss"] call BIS_fnc_selectRandom;
			_soundFile = format ["a3\data_f_curator\sound\cfgSounds\%1",_sound];
			playSound3D [_soundFile, _strike,false,getPos _strike, 3.3];
			sleep ((_delay select 0) + round (random ((_delay select 1) - (_delay select 0))));
		};
	};
} forEach _targetArray;

if (true) exitWith {};