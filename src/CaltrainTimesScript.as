import com.renaun.caltrain.vo.StationVO;
import com.renaun.utils.CaltrainTwitterUtil;
import com.renaun.utils.LocationUtil;

import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.GeolocationEvent;
import flash.events.KeyboardEvent;
import flash.events.StageOrientationEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.sensors.Geolocation;
import flash.system.Capabilities;
import flash.text.Font;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.collections.ArrayList;
import mx.events.StateChangeEvent;
import mx.utils.ObjectUtil;

[Embed(source="/assets/dpi160/blackbox.png", scaleGridTop="1", scaleGridLeft="1",scaleGridBottom="45",scaleGridRight="10")]
[Bindable]
public static var BlackBoxDPI160:Class;
[Embed(source="/assets/dpi320/blackbox.png", scaleGridTop="2", scaleGridLeft="2",scaleGridBottom="92",scaleGridRight="21")]
[Bindable]
public static var BlackBoxDPI320:Class;

[Embed(source="/assets/dpi160/SelectorHighlight.png", scaleGridTop="0", scaleGridLeft="150",scaleGridBottom="50",scaleGridRight="170")]
[Bindable]
public static var SelectorHighlightDPI160:Class;
[Embed(source="/assets/dpi240/SelectorHighlight.png", scaleGridTop="0", scaleGridLeft="200",scaleGridBottom="75",scaleGridRight="280")]
[Bindable]
public static var SelectorHighlightDPI240:Class;
[Embed(source="/assets/dpi320/SelectorHighlight.png", scaleGridTop="0", scaleGridLeft="310",scaleGridBottom="100",scaleGridRight="330")]
[Bindable]
public static var SelectorHighlightDPI320:Class;

[Embed(source="/assets/dpi160/station_line.png")]
[Bindable]
public static var StationLineDPI160:Class;
[Embed(source="/assets/dpi240/station_line.png")]
[Bindable]
public static var StationLineDPI240:Class;
[Embed(source="/assets/dpi320/station_line.png")]
[Bindable]
public static var StationLineDPI320:Class;

[Embed(source="/assets/dpi160/station_circle1.png")]
[Bindable]
public static var StationCircle1DPI160:Class;
[Embed(source="/assets/dpi240/station_circle1.png")]
[Bindable]
public static var StationCircle1DPI240:Class;
[Embed(source="/assets/dpi320/station_circle1.png")]
[Bindable]
public static var StationCircle1DPI320:Class;

[Embed(source="/assets/dpi160/station_circle2.png")]
[Bindable]
public static var StationCircle2DPI160:Class;
[Embed(source="/assets/dpi240/station_circle2.png")]
[Bindable]
public static var StationCircle2DPI240:Class;
[Embed(source="/assets/dpi320/station_circle2.png")]
[Bindable]
public static var StationCircle2DPI320:Class;

[Embed(source="/assets/dpi160/station_circle3.png")]
[Bindable]
public static var StationCircle3DPI160:Class;
[Embed(source="/assets/dpi240/station_circle3.png")]
[Bindable]
public static var StationCircle3DPI240:Class;
[Embed(source="/assets/dpi320/station_circle3.png")]
[Bindable]
public static var StationCircle3DPI320:Class;


[Embed(source="/assets/dpi160/station_circle2b.png")]
[Bindable]
public static var StationCircle2bDPI160:Class;
[Embed(source="/assets/dpi240/station_circle2b.png")]
[Bindable]
public static var StationCircle2bDPI240:Class;
[Embed(source="/assets/dpi320/station_circle2b.png")]
[Bindable]
public static var StationCircle2bDPI320:Class;

[Embed(source="/assets/dpi160/station_circle3b.png")]
[Bindable]
public static var StationCircle3bDPI160:Class;
[Embed(source="/assets/dpi240/station_circle3b.png")]
[Bindable]
public static var StationCircle3bDPI240:Class;
[Embed(source="/assets/dpi320/station_circle3b.png")]
[Bindable]
public static var StationCircle3bDPI320:Class;

[Embed(source="/assets/dpi160/results_hdots.png")]
[Bindable]
public static var ResultsHDotsDPI160:Class;
[Embed(source="/assets/dpi240/results_hdots.png")]
[Bindable]
public static var ResultsHDotsDPI240:Class;
[Embed(source="/assets/dpi320/results_hdots.png")]
[Bindable]
public static var ResultsHDotsDPI320:Class;

[Bindable]
public static var stations:ArrayList;

[Bindable]
private var haveAlerts:Boolean = true;

[Bindable]
private var bottomPadding:int = 0;
[Bindable]
public var largeViewWidth:int = 300;

private var selectedStationFrom:StationVO = null;
private var selectedStationTo:StationVO = null;

public var isNorthbound:Boolean = false;
public var hasBothStations:Boolean = false;
public var fromStationNextTimes:Array;
public var routeTimes:Array;


private var dbFile:File;
private var sqlConn:SQLConnection;
private var sqlStatement:SQLStatement;

private var geo:Geolocation;
private var timer:Timer;// = new Timer(300);
private var geoValueCount:int = 0;
private var rotDelta:Number = 0.06;
private var twitterUtil:CaltrainTwitterUtil;


public static var todaysServiceID:int = 2;

protected function init():void
{	
	// Include Font classes to be uncommented if you do not have the fonts
	// you'll need to change styles.css to styles_fonts_in_swc.css
	/*
	var font:Font;
	font = new myHelveBol();
	font = new myHelveNeueBdCn();
	font = new myHelveNeueBdCn2();
	font = new myHelveNeueBlkCn();
	font = new myHelveNeueLtCn();
	font = new myHelveNeueLtCn2();
	font = new myHelveNeueRoman();
	font = new myHelvNeueBolConObl();
	*/
	
	
	var src:Array = [];
	try
	{
		dbFile = File.applicationStorageDirectory.resolvePath("caltrain.db");
		if (!dbFile.exists)
		{
			File.applicationDirectory.resolvePath("caltrain.db").copyTo(dbFile);
			this.grpInstructions.visible = true;
		}
		sqlConn = new SQLConnection();
		sqlConn.open(dbFile);
		
		sqlStatement = new SQLStatement();
		sqlStatement.sqlConnection = sqlConn;
		
		var r:Array = processSQL("SELECT * FROM stops ORDER BY stop_lat DESC");
		if (!r)
			return;
		var s:StationVO;
		for (var j:int = 0; j < r.length; j++) 
		{
			s = new StationVO();
			s.name = r[j]["name"];
			s.stopLat = r[j]["stop_lat"];
			s.stopLon = r[j]["stop_lon"];
			s.stopID = r[j]["stop_id"];
			src.push(s);
		}
		var d:Date = new Date();
		if (d.getDay() == 0 || d.getDay() == 6)
			CaltrainTimes.todaysServiceID = 3;
		else
		{
			var todaysDate:String = d.getFullYear()+"";
			todaysDate += ((d.getMonth()+1 < 10) ? "0" : "") + (d.getMonth()+1);
			todaysDate += ((d.getDate() < 10) ? "0" : "") + d.getDate();
			r = processSQL("SELECT * FROM calendar_dates");
			for (j = 0; j < r.length; j++) 
			{
				
				var date:String = r[j]["service_date"];
				var sID:int = r[j]["service_id"];
				var eT:int = r[j]["exception_type"];
				if (eT == 1 && date == todaysDate)//d.getFullYear()+""+d.getMonth()+""+d.getDate())
					CaltrainTimes.todaysServiceID = sID;
			}
		}
	}
	catch (sqlError:SQLError)
	{
		trace("SQLError: " + sqlError.details);
	}
	catch (error:Error)
	{
		trace("error: " + error.message);		
	}
	
	/*
	var src:Array = ["San Francisco", "22nd Street", "South San Francisco", "San Bruno", "Millbrae", 
		"Burlingame", "San Mateo", "Hayward Park", "Hillsdale", "Bellmont", "San Carlos", "Redwood City", 
		"Menlo Park", "Palo Alto", "California Avenue", "San Antonio", "Mountain View", "Sunnyvale", "Lawrence", 
		"Santa Clara", "College Park", "San Jose Diridon", "Tamien", "Capital", "Blossom Hill", "Morgan Hill", 
		"San Martin", "Gillroy"];
	*/
	stations = new ArrayList(src);
	
	
	this.grpTrainSchedule.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, currentStateChangeHandler);
}

public function processSQL(sql:String):Array
{
	try
	{		
		sqlStatement = new SQLStatement();
		sqlStatement.sqlConnection = sqlConn;
		sqlStatement.text = sql;//"SELECT * FROM stops ORDER BY stop_lat DESC";
		sqlStatement.execute();
		
		var r:Array = sqlStatement.getResult().data;
		if (r)
			return r;
	}
	catch (sqlError:SQLError)
	{
		trace("SQLError: " + sqlError.details);
	}
	catch (error:Error)
	{
		trace("error: " + error.message);		
	}
	return [];
}

protected function appReady():void
{
	
	//this.stage.quality = StageQuality.LOW;
	//var str:String = "" + this.stage.quality + "/" + this.applicationDPI;
	//lblHeaderText2.text = str;
	setSelector("from");
	this.grpTrainSchedule.setStations(stations.getItemAt(1) as StationVO, stations.getItemAt(stations.length-8) as StationVO);
	this.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, resizeHandler);
	
	if (Capabilities.manufacturer.indexOf("Android") > -1)
	{
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
	}
	
//	if (Capabilities.screenResolutionX > 599 && Capabilities.screenResolutionY > 599
//		&& Capabilities.cpuArchitecture != "x86")
//	{
//		largeViewWidth = Math.max(300, this.stage.stageWidth * 0.4);
//		this.currentState = "largeView";
//	}
//	forceLargeViewSizes();
//	
//	
//	
//	
	/*
	var lat:Number = 37.7708301;//-122.394322993;//37.335000;
	var lon:Number = -122.4018971;//37.7764393371;//-121.914998;
	
	
	var sql:String = "SELECT stop_id, name, stop_lon, stop_lat FROM stops";
	var results:Array = processSQL(sql);
	var min:Number = Number.MAX_VALUE;
	var stopID:int = -1;
	var stopName:String = "";
	var dis:Number = 0;
	var p:Point = new Point(lon, lat);
	//var alerts:Array = [];
	for (var i:int = 0; i < results.length; i++) 
	{
		dis = LocationUtil.getDistanceBetweenWaypoints(p, new Point(results[i].stop_lon, results[i].stop_lat));
		//trace("Stop: " + results[i].name + " - " + dis);
		if (dis < min)
		{
			stopName = results[i].name;
			stopID = results[i].stop_id;
			min = dis;
		}
	}
	*/
	//trace("Match: " + stopName + " - " + stopID + " - " + dis);
}

private function forceLargeViewSizes():void
{
	return;//
	if (Capabilities.screenResolutionX > 599 && Capabilities.screenResolutionY > 599
		&& Capabilities.cpuArchitecture != "x86")
	{
		largeViewWidth = Math.max(300, this.stage.stageWidth * 0.4)
		this.grpStations.width = largeViewWidth;
		this.grpTrainSchedule.width = this.width - largeViewWidth;
		this.grpTrainSchedule.grpButtons2.alpha = 1;
		this.grpTrainSchedule.detailsX = this.grpTrainSchedule.x;
		this.grpTrainSchedule.alphaBar = 0;
	}
}

protected function keyEventHandler(event:KeyboardEvent):void
{
	if (event.keyCode != Keyboard.BACK)
		return;
	if (this.grpAlerts.currentState == "details")
	{
		event.preventDefault();
		event.stopImmediatePropagation();
		this.grpAlerts.currentState = "alert"
	}
	else if (this.grpTrainSchedule.currentState == "details")
	{
		event.preventDefault();
		event.stopImmediatePropagation();
		setSelector(lastStationType, true);
	}
}

protected function resizeHandler(event:StageOrientationEvent):void
{
	
	if (this.grpAlerts.currentState == "details")
		this.grpAlerts.y = this.grpAlerts.detailsY;
	else if (this.grpAlerts.currentState == "details")
		this.grpAlerts.y = this.grpAlerts.alertY;
	//trace(event.afterOrientation + " - " + event.beforeOrientation);
	//trace(this.currentState + " - " + grpTo.height + " == " + grpTo.y + " - " + this.stage.stageHeight);
	//trace("[w/h]" + this.width + "/" + this.height);
	//forceLargeViewSizes();
}

private function stationSelected(station:StationVO, direction:Number):void
{
	//trace("Station Selecting: " + station + " - " + direction);
	if (direction < 0)
	{
		selectedStationFrom = station;
		this.grpFrom.setStation(selectedStationFrom);
		setSelector("to");
	}
	else if (direction >= 0)
	{
		selectedStationTo = station;
		this.grpTo.setStation(selectedStationTo);
		setSelector("from");
	}
	hasBothStations = (selectedStationFrom != null && selectedStationTo != null);
	
	if (hasBothStations)
	{
		this.grpTrainSchedule.setStations(selectedStationFrom, selectedStationTo);
		this.grpTrainSchedule.currentState = "times";
		
		if (!twitterUtil)
			twitterUtil = new CaltrainTwitterUtil();
		twitterUtil.findTweetsForTrains(this.grpTrainSchedule.trainTimes, alertCallback);
	}
	else
	{
		this.grpAlerts.removeAlerts();
		this.grpTrainSchedule.currentState = "default";
		this.grpTrainSchedule.lstTimes.dataProvider = null;
	}
}

private function alertCallback():void
{
	this.grpAlerts.setAlerts(twitterUtil.todaysFilteredTweets);
	this.grpAlerts.setMessage("Tweets found for selected trains.");
}

private function currentStateChangeHandler(event:StateChangeEvent):void
{
	if (this.currentState == "largeView")
	{
		forceLargeViewSizes();
		return;
	}
	if (event.newState == "details")
	{
		setSelector("details");
		this.currentState = "stationsHidden";
	}
	else
	{
		this.currentState = "default";
	}
}

private function findNearestStation():void
{
	if (!timer)
	{
		timer = new Timer(700);
		timer.addEventListener(TimerEvent.TIMER, timerTickHandler);
	}
	if (geo)
	{
		geo.removeEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler);
		geo.removeEventListener(StatusEvent.STATUS, statusGPSHandler);
		geo = null;
	}
	if (timer.running)
	{
		this.imgGPS2.visible = false;
		timer.stop();
	}
	else
	{
		timer.reset();
		timer.start();
		if (Geolocation.isSupported) 
		{ 
			//Initialize the location sensor. 
			geoValueCount = 0;
			geo = new Geolocation(); 
			if(!geo.muted || Capabilities.manufacturer.indexOf("iOS"))
			{ 
				//this.output.text += "started GPS " + getTimer();
				//geo.setRequestedUpdateInterval(60000); 
				//Register to receive location updates. 
				geo.addEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler); 
				geo.addEventListener(StatusEvent.STATUS, statusGPSHandler);
			} 
			else
			{
				this.grpAlerts.setMessage("Please enable location services.", true);
				findNearestStation(); // turn off
				//this.output.text += "GPS muted\n";
			}
		}
		else
		{
			this.grpAlerts.setMessage("Location services not supported.", true);
			findNearestStation(); // turn off
			
		}
	}
}


private function timerTickHandler(event:TimerEvent):void
{
	this.imgGPS2.visible = !this.imgGPS2.visible;
}

private function statusGPSHandler(event:StatusEvent):void
{
	if (event.code == "Geolocation.Muted")
	{
		this.grpAlerts.setMessage("Please enable location services..", true);		
		findNearestStation(); // turn off
	}
}

private function geolocationUpdateHandler(event:GeolocationEvent):void 
{ 
	// Let it find a couple values to make sure its a fresh value
	if (geoValueCount++ < 2)
		return;
	var lat:Number = event.latitude;
	var lon:Number = event.longitude;
	
	
	
	var sql:String = "SELECT stop_id, name, stop_lon, stop_lat FROM stops";
	var results:Array = processSQL(sql);
	var min:Number = Number.MAX_VALUE;
	var stopID:int = -1;
	var stopName:String = "";
	var dis:Number = 0;
	var p:Point = new Point(lon, lat);
	//var alerts:Array = [];
	for (var i:int = 0; i < results.length; i++) 
	{
		dis = LocationUtil.getDistanceBetweenWaypoints(p, new Point(results[i].stop_lon, results[i].stop_lat));
		//alerts.push("Stop: " + results[i].name + " - " + dis);
		if (dis < min)
		{
			stopName = results[i].name;
			stopID = results[i].stop_id;
			min = dis;
		}
	}
	
	//this.output.text += "Lat: " + event.latitude.toString(); 
	//this.output.text += " Lon: " + event.longitude.toString() + " " + getTimer() + "\n"; 
	findNearestStation(); // turn off
	
	if (stopID > -1)
	{
		//this.grpAlerts.setAlerts(alerts);
		//this.grpAlerts.setMessage("Found: ["+stopID+"] " + stopName + " - " + lat.toPrecision(3) + "/" + lon.toPrecision(3));
		this.grpStations.lstStations.setStation(stopID, -1);
		this.grpAlerts.setMessage("" + stopName + " is the closet station.", true);
	}
}

public static function formatTime(time:int, type:String = "hour"):String
{
	var hour:int = time / 60;
	var minute:int = time % 60;
	if (type == "mins")
		return ((hour > 0) ? (hour) + "hr" + ((hour>1) ? "s" : "") + " " : "") + minute + "mins"
	return ((hour%12 == 0) ? "12" : (hour%12)) + ":" + ((minute < 10) ? "0" + minute : minute) + "" + ((hour < 12 || hour >= 24) ? "am" : "pm");
}

private var isSwaping:Boolean = false;
private function swapStations():void
{
	var fromTmp:StationVO = selectedStationFrom;
	var toTmp:StationVO = selectedStationTo;
//	stationSelected(null, -1);
//	stationSelected(null, 1);
	isSwaping = true;
	if (fromTmp)
		this.grpStations.lstStations.setStation(fromTmp.stopID, 1);
	if (toTmp)
		this.grpStations.lstStations.setStation(toTmp.stopID, -1);
	isSwaping = false;
}

private var lastStationType:String = "";
private function setSelector(type:String, force:Boolean = false):void
{
	if (isSwaping)
		return;
	//trace("setSelector: " + type + " - " + selectedStationFrom + " - " + selectedStationTo + "/" + force);
	if (type != "details" && this.grpTrainSchedule.currentState == "details")
		this.grpTrainSchedule.currentState = "times";
	if (type == "from" && (force || selectedStationFrom == null))
	{
		lastStationType = type;
		this.grpFrom.currentState = "defaultText";
		this.grpTo.currentState = "disabled";
		this.grpStations.lstStations.currentSelector = -1;
		//this.imgPointer.y = this.grpFrom.y + (this.grpFrom.height-this.imgPointer.height)/2; 
	}
	else if (type == "to" && (force || selectedStationTo == null))
	{
		lastStationType = type;
		this.grpFrom.currentState = "disabled";
		this.grpTo.currentState = "defaultText";
		this.grpStations.lstStations.currentSelector = 1;
		//this.imgPointer.y = this.grpTo.y + (this.grpTo.height-this.imgPointer.height)/2; 
	}
	else if (type == "details")
	{
		this.grpFrom.currentState = "active";
		this.grpTo.currentState = "active";
	}
}
