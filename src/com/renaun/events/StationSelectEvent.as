package com.renaun.events
{
import com.renaun.caltrain.vo.StationVO;

import flash.events.Event;

public class StationSelectEvent extends Event
{
	public function StationSelectEvent(station:StationVO, direction:int)
	{
		this.station = station;
		this.direction = direction;
		super("stationSelect", true, false);
	}
	
	public var direction:int;
	public var station:StationVO;
	
}
}