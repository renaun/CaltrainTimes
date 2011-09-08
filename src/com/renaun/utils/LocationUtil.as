package com.renaun.utils
{
	import flash.geom.Point;
	
	public class LocationUtil
	{
		private static const TIME_NUMBER : Number = 0.000000277777778;
		private static const MI : Number = 1.15077945;
		private static const KM : Number = 1.85200;
		
		private static const EARTH_RADIUS_MILES:Number = 3961.3;
		private static const EARTH_RADIUS_KM:Number = 6378.1;
		
		public static function getDistanceBetweenWaypoints(wpt1:Point, wpt2:Point, unit:String="mi"):Number
		{
			/***
			 * Haversine Formula (from R.W. Sinnott, "Virtues of the Haversine", Sky and Telescope, vol. 68, no. 2, 1984, p. 159):
			 
			 dlon = lon2 - lon1
			 dlat = lat2 - lat1
			 a = (sin(dlat/2))^2 + cos(lat1) * cos(lat2) * (sin(dlon/2))^2
			 c = 2 * atan2( sqrt(a), sqrt(1-a) )
			 d = R * c (where R is the radius of the Earth)
			 Formula from: http://andrew.hedges.name/experiments/haversine/
			 */
			
			var adjustment : Number = 0;
			var R:Number;
			var distance:Number;
			var a:Number;
			var c:Number;
			
			if( unit == "mi" ) { R = EARTH_RADIUS_MILES; }
			if( unit == "km" ) { R = EARTH_RADIUS_KM; }
			
			var dlon:Number = degreesToRadians(wpt2.x) - degreesToRadians(wpt1.x);
			var dlat:Number = degreesToRadians(wpt2.y) - degreesToRadians(wpt1.y);
			
			// Begin Haversine Forumla
			a = Math.pow(Math.sin(dlat/2),2) + (Math.cos(wpt1.y) * Math.cos(wpt2.y) * Math.pow(Math.sin(dlon/2),2));
			c = 2* Math.atan2( Math.sqrt(Math.abs(a)),Math.sqrt(Math.abs(1-a)) );
			distance = R * c;
			
			return distance;
		}
		
		private static function degreesToRadians(value:Number):Number
		{
			return value * Math.PI/180;
		}
		
	}
}