package funkin.backend.scripting.lua;
#if ENABLE_LUA

final class NdllFunctions {
	public static var ndllFunctions(default, null):Map<String, Dynamic> = new Map<String, Dynamic>();
	//No tested yet
	public static function getNdllFunctions(?script:Script):Map<String, Dynamic> {
		return [
			#if NDLLS_SUPPORTED
			"createNdllFunction" => function(funcName:String, ndll:String, func:String, nArgs:Int) {
				var func:Dynamic = NdllUtil.getFunction(ndll, func, nArgs);
				ndllFunctions.set(funcName, func);
			},
			"callNdllFunction" => function(funcName:String, args:Array<Dynamic>) {
				var func:Dynamic = ndllFunctions.get(funcName);
				Reflect.callMethod(null, func, args);
			}
			#end
		];
	}
}
#end