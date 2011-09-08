package com.renaun.caltrain.components 
{ 
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.mx_internal;
	
	import spark.preloaders.SplashScreen;
	
	use namespace mx_internal
	
	public class MultiDPISplashScreen extends SplashScreen 
	{ 
		[Embed(source="/assets/dpi160/splash.jpg")] 
		private var SplashImage160:Class; 
		[Embed(source="/assets/dpi240/splash.jpg")] 
		private var SplashImage240:Class; 
		[Embed(source="/assets/dpi320/splash.jpg")] 
		private var SplashImage320:Class; 
		
		public function MultiDPISplashScreen() 
		{ 
			super(); 
		} 
		
		override mx_internal function getImageClass(dpi:Number, aspectRatio:String):Class 
		{ 
			if (dpi == DPIClassification.DPI_160)
			{
				if (Capabilities.screenResolutionX < 512 && Capabilities.screenResolutionY < 512
					|| Capabilities.cpuArchitecture == "x86")
					return SplashImage160;
				else
					return SplashImage320;
			}
			else if (dpi == DPIClassification.DPI_240) 
				return SplashImage240; 
			else if (dpi == DPIClassification.DPI_320) 
				return SplashImage320; 
			return null; 
		} 
	} 
}