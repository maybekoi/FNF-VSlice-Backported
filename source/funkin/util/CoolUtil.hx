package funkin.util;

import lime.utils.Assets;

using StringTools;

import flixel.tweens.FlxEase;

class CoolUtil
{
	public static function getEaseFromString(ease:String):Dynamic {
		return switch(ease.toLowerCase()) {
			case "backin": FlxEase.backIn;
			case "backinout": FlxEase.backInOut;
			case "backout": FlxEase.backOut;
			case "bouncein": FlxEase.bounceIn;
			case "bounceinout": FlxEase.bounceInOut;
			case "bounceout": FlxEase.bounceOut;
			case "circin": FlxEase.circIn;
			case "circinout": FlxEase.circInOut;
			case "circout": FlxEase.circOut;
			case "cubein": FlxEase.cubeIn;
			case "cubeinout": FlxEase.cubeInOut;
			case "cubeout": FlxEase.cubeOut;
			case "elasticin": FlxEase.elasticIn;
			case "elasticinout": FlxEase.elasticInOut;
			case "elasticout": FlxEase.elasticOut;
			case "expoin": FlxEase.expoIn;
			case "expoinout": FlxEase.expoInOut;
			case "expoout": FlxEase.expoOut;
			case "quadin": FlxEase.quadIn;
			case "quadinout": FlxEase.quadInOut;
			case "quadout": FlxEase.quadOut;
			case "quartin": FlxEase.quartIn;
			case "quartinout": FlxEase.quartInOut;
			case "quartout": FlxEase.quartOut;
			case "quintin": FlxEase.quintIn;
			case "quintinout": FlxEase.quintInOut;
			case "quintout": FlxEase.quintOut;
			case "sinein": FlxEase.sineIn;
			case "sineinout": FlxEase.sineInOut;
			case "sineout": FlxEase.sineOut;
			case "smoothstepin": FlxEase.smoothStepIn;
			case "smoothstepinout": FlxEase.smoothStepInOut;
			case "smoothstepout": FlxEase.smoothStepOut;
			case "smootherstepin": FlxEase.smootherStepIn;
			case "smootherstepinout": FlxEase.smootherStepInOut;
			case "smootherstepout": FlxEase.smootherStepOut;
			default: FlxEase.linear;
		};
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
