package com.renaun.caltrain.vo
{
public class TimesVO
{
	public function TimesVO()
	{
	}
	
	public var departureValueTime:int = 0;
	public var departureTime:String = "";
	public var arrivalTime:String = "";
	public var duration:String = "";
	public var fare:String = "";
	public var trainNumber:String = "";
	public var routeID:int = -1;
	public var hasAlert:Boolean = false;
	
	public function toString():String
	{
		return departureTime + " - " + arrivalTime;
	}
}
}