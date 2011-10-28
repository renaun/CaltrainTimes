package com.renaun.caltrain.model
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.getQualifiedClassName;


public class CaltrainStrings
{
	/**
	 * The Singleton 'self-reference' served up by getInstance().
	 */
	private static var _singletonClass:CaltrainStrings = null;
	
	/**
	 * Uses a scope constrained Constructor and ensures that the only 
	 * class eligible to call the SingletonClass is itself.
	 */
	public function CaltrainStrings()
	{
	}
	
	/**
	 * The 'single' access point for your SingletonClass.
	 */
	public static function getInstance():CaltrainStrings
	{
		if (_singletonClass == null)
			_singletonClass= new CaltrainStrings();
		
		return _singletonClass;
	}
	
	public static function getStationName(key:String):String
	{
		return "";
	}
	
	public static var strings:Object = {};
	
	[Bindable]
	public static var titlePart1:String = "Caltrain";
	[Bindable]
	public static var titlePart2:String = "Times";

	public static function loadStrings(locale:String):void
	{
		currentLocale = locale;
		var file:File = File.applicationDirectory.resolvePath("assets/locale/"+locale+"/strings");
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var data:String = stream.readUTFBytes(file.size);
		stream.close();
		var values:Array = data.split("\n");
		var val:Array;
		for (var i :int = 0; i  < values.length; i++) 
		{
			val = values[i].split("=");
			//trace(i + ": " + val[0] + " = " + val[1]);
			//trace(""+val[1]);
			strings[val[0]] = val[1];
		}
		
	}
	
	public static function getString(name:String):String
	{
		return strings[name];
	}
	
	public static var currentLocale:String = "en_US";
	
	public static const LOCALE_ENGLISH:String = "en_US";
	public static const LOCALE_CHINESE:String = "zh_CH";
	public static const LOCALE_SPANISH:String = "es_ES";
	public static const LOCALE_GERMAN:String = "de_DE";

	
}	

	
}
