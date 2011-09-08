package com.renaun.caltrain.vo
{
public class StationVO
{
	public function StationVO()
	{
	}
	
	public var stopID:int = 0;
	public var name:String = "";
	public var stopLat:Number = 0.0;
	public var stopLon:Number = 0.0;
	
	public function toString():String
	{
		return name;
	}
}
}