import com.renaun.caltrain.model.CaltrainStrings;
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
import flash.events.TransformGestureEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.net.SharedObject;
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

private var lastStationType:String = "";

/**
 *  DB related properties
 */
private var dbFile:File;
private var sqlConn:SQLConnection;
private var sqlStatement:SQLStatement;

/**
 *  GPS related properties
 */
private var geo:Geolocation;
private var timer:Timer;// = new Timer(300);
private var geoValueCount:int = 0;
private var rotDelta:Number = 0.06;

/**
 *  Localization
 */
private var strGPSDisabled:String = "Please enable location services.";
private var strGPSNotSupported:String = "Location services not supported.";
private var strGPSTimeout:String = "Location services taking too long, check gps settings.";
private var strGPSMatch:String = "{1} is the closest station.";
private var strTrainAlerts:String = "Tweets found for {1} train{.";
private var strTrainAlerts2:String = "Tweets found for {1} trains.";

[Bindable]
public static var hasGPS:Boolean = true;

/**
 * 	Class that handles Twitter calls.
 */
private var twitterUtil:CaltrainTwitterUtil;

/**
 * 	Value to set between Weekday or Weekend schedule times. 
 * 	2 = Weekday
 * 	3 = Weekend
 */
public static var todaysServiceID:int = 2;
public static var isSaturday:Boolean = false;

/**
 * 	Things to do at startup of application (not called when apps comes activate
 *  from being in the background).
 */
protected function init():void
{	
	//trace(Capabilities.screenDPI + " - " + Capabilities.serverString);
	// TODO save the local setting and remember it here
	var obj:SharedObject = SharedObject.getLocal("localeCaltrainTimes");
	if (obj.data && obj.data.locale != null)
	{
		setLocaleStrings(obj.data.locale + "");
	}
	else
	{
		obj.data.locale = CaltrainStrings.LOCALE_ENGLISH;
		obj.flush();
		setLocaleStrings(CaltrainStrings.LOCALE_ENGLISH);
	}
	//setLocaleStrings("en_US");
	
	
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
	
	// Check if DB is present, if not copy over to applicationStorageDirectory
	var src:Array = [];
	try
	{
		dbFile = File.applicationStorageDirectory.resolvePath("caltrain.db");
		if (!dbFile.exists || (dbFile.creationDate as Date).fullYear < 2012)
		{
			File.applicationDirectory.resolvePath("caltrain.db").copyTo(dbFile, true);
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
		CaltrainTimes.isSaturday = d.getDay() == 6;
		if (d.getDay() == 0 || d.getDay() == 6)
			CaltrainTimes.todaysServiceID = 3;
		/* 2012 Removed for 2012 since there is no exceptions yet
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
		*/
	}
	catch (sqlError:SQLError)
	{
		trace("SQLError: " + sqlError.details);
	}
	catch (error:Error)
	{
		trace("error: " + error.message);		
	}
	
	stations = new ArrayList(src);
	
	// Listen for changes in the grpTrainSchedule states to know if we need to transition to show full schedule
	this.grpTrainSchedule.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, currentStateChangeHandler);
}

/**
 * 	Generic method to process SQL statements in one place
 */
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

/**
 * 	Called after everything has been created, laid out, and on stage.
 */
protected function appReady():void
{
	// Give the trainschedule some valid stations to create itemrenderers and such, not seen
	setSelector("from");
	this.grpTrainSchedule.setStations(stations.getItemAt(1) as StationVO, stations.getItemAt(stations.length-8) as StationVO);
	
	// Resize Handler
	this.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, resizeHandler);
	
	// Listen for back button on Android
	if (Capabilities.manufacturer.indexOf("Android") > -1)
	{
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
	}

	// GPS testing code
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

/**
 *  Handle Android Back button
 */
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

/**
 * 	Handler resizing of app, usually on orientation changes
 */
protected function resizeHandler(event:StageOrientationEvent):void
{
	if (this.grpAlerts.currentState == "details")
		this.grpAlerts.y = this.grpAlerts.detailsY;
	else if (this.grpAlerts.currentState == "alert")
		this.grpAlerts.y = this.grpAlerts.alertY;
	else
		this.grpAlerts.y = this.grpAlerts.alertY+ this.grpAlerts.alertBoxHeight;
}

/**
 * 	Handles logic for station selects
 */
private function stationSelected(station:StationVO, direction:Number):void
{
	if (isSwaping && station == null)
	{
		return;	
	}
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
		this.grpTrainSchedule.setStations(selectedStationFrom, selectedStationTo, isSwaping);
		if (!isSwaping)
			this.grpTrainSchedule.currentState = "times";
		
		if (!twitterUtil)
			twitterUtil = new CaltrainTwitterUtil();
		var xbound:int = (selectedStationFrom.stopLat < selectedStationTo.stopLat) ? 1 : -1;
		if (twitterUtil.currentDirection != xbound)
			removeAlerts();
			
		twitterUtil.currentDirection = xbound;
		twitterUtil.findTweetsForTrains(this.grpTrainSchedule.trainTimes, alertCallback);
	}
	else
	{
		removeAlerts();
		this.grpTrainSchedule.currentState = "default";
		this.grpTrainSchedule.lstTimes.dataProvider = null;
	}
}

/**
 * 	Remove alert box and train alert highlights
 */
private function removeAlerts():void
{
	this.grpTrainSchedule.clearAlertTrains();
	this.grpAlerts.removeAlerts();
}

/**
 * 	Handle showing messages for the trains that are between the two stations.
 */
private function alertCallback(trainAlertMatches:Array):void
{
	// TODO go through list and set trains to
	this.grpTrainSchedule.setAlertTrains(trainAlertMatches);
	this.grpAlerts.setAlerts(twitterUtil.todaysFilteredTweets);
	var str:String;
	if (trainAlertMatches.length > 1)
		str = strTrainAlerts2.replace("{1}", trainAlertMatches.length);
	else if (trainAlertMatches.length > 0)
		str = strTrainAlerts.replace("{1}", trainAlertMatches.length);
	//trace("alertCallback: " + str);
	this.grpAlerts.setMessage(str);

}

/**
 * 	When train schedule view changes we want to hide/show stations.
 */
private function currentStateChangeHandler(event:StateChangeEvent):void
{
	trace("cSC: " + event.newState + " - " + event.oldState);
	if (event.newState == "details")
	{
		if (!isSwaping)
		{
			moveGrpStations.xFrom = grpStations.x;
			moveGrpStations.xTo = -grpFrom.width;
			moveGrpStations.play();
			fadeGrpStations.alphaFrom = 1;
			fadeGrpStations.alphaTo = 0;
			fadeGrpStations.play();
		}
		setSelector("details");
		this.currentState = "stationsHidden";
	}
	else
	{
		if (event.newState == "times" && event.oldState == "details" && !isSwaping)
		{
			moveGrpStations.xFrom = -grpFrom.width;
			moveGrpStations.xTo = 0;
			moveGrpStations.play();
			fadeGrpStations.alphaFrom = 0;
			fadeGrpStations.alphaTo = 1;
			fadeGrpStations.play();
		}
		this.currentState = "default";
	}
}

/**
 * 	Turn on/off GPS logic.
 */
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
				//Register to receive location updates. 
				geo.addEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler); 
				geo.addEventListener(StatusEvent.STATUS, statusGPSHandler);
			} 
			else
			{
				this.grpAlerts.setMessage(strGPSDisabled, true);
				findNearestStation(); // turn off
			}
		}
		else
		{
			this.grpAlerts.setMessage(strGPSNotSupported, true);
			findNearestStation(); // turn off
		}
	}
}

/**
 * 	GPS Animating the icon and timeout check.
 */
private function timerTickHandler(event:TimerEvent):void
{
	this.imgGPS2.visible = !this.imgGPS2.visible;
	if ((event.target as Timer).currentCount == 30)
	{		
		this.grpAlerts.setMessage(strGPSTimeout, true);		
		findNearestStation(); // turn off
	}
}

/**
 * 	Check to see if it gets muted while checking.
 */
private function statusGPSHandler(event:StatusEvent):void
{
	if (event.code == "Geolocation.Muted")
	{
		this.grpAlerts.setMessage(strGPSDisabled, true);		
		findNearestStation(); // turn off
	}
}

/**
 * 	Handle the GPS location data.
 */
private function geolocationUpdateHandler(event:GeolocationEvent):void 
{ 
	trace("geo: " + geoValueCount);
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
		this.grpStations.lstStations.setStation(stopID, -1);
		this.grpAlerts.setMessage(strGPSMatch.replace("{1}", stopName) , true);
	}
}

/**
 * 	Helper Time format function
 */
public static function formatTime(time:int, type:String = "hour"):String
{
	var parts:Array = formatTimeParts(time, type);
	if (type == "mins")
	{
		return parts[0] + parts[1] + " " + parts[2] + " " + parts[3];
	}
	else
	{
		if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
			return parts[1] + parts[0]+"";
		else
			return parts[0] + parts[1]+"";	
	}
}

public static function formatTimeParts(time:int, type:String = "hour"):Array
{
	var parts:Array = [];
	var hour:int = time / 60;
	var minute:int = time % 60;
	if (type == "mins")
	{
		parts[0] = (hour > 0) ? hour+"" : "";
		parts[1] = "";
		if (parts[0] != "")
			parts[1] = (hour>1) ? CaltrainStrings.getString("hours.plural") : CaltrainStrings.getString("hours.single");
		parts[2] = minute;
		parts[3] = CaltrainStrings.getString("minutes");
		return parts;
	}
	else
	{
		parts[0] = ((hour%12 == 0) ? "12" : (hour%12)) + ":" + ((minute < 10) ? "0" + minute : minute);
		parts[1] = ((hour < 12 || hour >= 24) ? CaltrainStrings.getString("time.am") : CaltrainStrings.getString("time.pm"));
		return parts; ;
	}
}

/**
 * 	Swap feature when you double click on a station.
 */
public var isSwaping:Boolean = false;
public function swapStations():void
{
	var fromTmp:StationVO = selectedStationFrom;
	var toTmp:StationVO = selectedStationTo;
	isSwaping = true;
//	stationSelected(null, -1);
//	stationSelected(null, 1);
//trace(fromTmp.stopID + " - " + toTmp.stopID);
	if (fromTmp)
		this.grpStations.lstStations.setStation(fromTmp.stopID, 1, true);
	if (toTmp)
		this.grpStations.lstStations.setStation(toTmp.stopID, -1, true);
	isSwaping = false;
}
/**
 * 	Station boxes state logic
 */
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
	}
	else if (type == "to" && (force || selectedStationTo == null))
	{
		lastStationType = type;
		this.grpFrom.currentState = "disabled";
		this.grpTo.currentState = "defaultText";
		this.grpStations.lstStations.currentSelector = 1;
	}
	else if (type == "details")
	{
		this.grpFrom.currentState = "active";
		this.grpTo.currentState = "active";
	}
}
public function setLocaleStrings(locale:String, runtime:Boolean = false):void
{
	CaltrainStrings.loadStrings(locale);
	var obj:SharedObject = SharedObject.getLocal("localeCaltrainTimes");
	if (obj.data)
	{
		obj.data.locale = locale;
		obj.flush();
	}
	// Set all Strings - choose to do direct instead of use binding
	//lblHeaderText.text = CaltrainStrings.getString("titlePart1");
	//lblHeaderText2.text = CaltrainStrings.getString("titlePart2");
	
	// TODO add rest of sstyle change sot Edit, TrainSchedule headers, alerts
	if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
	{
		grpFrom.lblPrefix.styleName = "text1Chinese";
		grpFrom.lblEdit.styleName = "editTextChinese";
		grpFrom.lblStation.styleName = "text2Chinese";
		if (selectedStationFrom)
			grpFrom.setStation(selectedStationFrom);
		grpTo.lblPrefix.styleName = "text1Chinese";
		grpTo.lblEdit.styleName = "editTextChinese";
		grpTo.lblStation.styleName = "text2Chinese";
		if (selectedStationTo)
			grpTo.setStation(selectedStationTo);
		grpInstructions.lblTitle.styleName = "text1Chinese";
		grpInstructions.lblHelp1.styleName = "alertText2Chinese";
		grpInstructions.lblHelp2.styleName = "alertText2Chinese";
		grpInstructions.lblHelp3.styleName = "alertText2Chinese";
		grpInstructions.lblHelp4.styleName = "alertText2Chinese";
		grpInstructions.lblHelp5.styleName = "alertText2Chinese";
		grpInstructions.lblHelp6.styleName = "alertText2Chinese";
		grpInstructions.lblFind.styleName = "text2Chinese";
	}
	else if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_SPANISH)
	{
		grpFrom.lblPrefix.styleName = "text1Spanish";
		grpFrom.lblEdit.styleName = "editText";
		grpFrom.lblStation.styleName = "text2Spanish";
		grpTo.lblPrefix.styleName = "text1Spanish";
		grpTo.lblEdit.styleName = "editText";
		grpTo.lblStation.styleName = "text2Spanish";
		grpInstructions.lblTitle.styleName = "text1Spanish";
		grpInstructions.lblHelp1.styleName = "alertText2";
		grpInstructions.lblHelp2.styleName = "alertText2";
		grpInstructions.lblHelp3.styleName = "alertText2";
		grpInstructions.lblHelp4.styleName = "alertText2";
		grpInstructions.lblHelp5.styleName = "alertText2";
		grpInstructions.lblHelp6.styleName = "alertText2";
		grpInstructions.lblFind.styleName = "text2Spanish";
	}
	else if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_GERMAN)
	{
		grpFrom.lblPrefix.styleName = "text1German";
		grpFrom.lblEdit.styleName = "editTextGerman";
		grpFrom.lblStation.styleName = "text1German";
		grpTo.lblPrefix.styleName = "text1German";
		grpTo.lblEdit.styleName = "editText";
		grpTo.lblStation.styleName = "text1German";
		grpInstructions.lblTitle.styleName = "text1German";
		grpInstructions.lblHelp1.styleName = "alertText2German";
		grpInstructions.lblHelp2.styleName = "alertText2German";
		grpInstructions.lblHelp3.styleName = "alertText2German";
		grpInstructions.lblHelp4.styleName = "alertText2German";
		grpInstructions.lblHelp5.styleName = "alertText2German";
		grpInstructions.lblHelp6.styleName = "alertText2German";
		grpInstructions.lblFind.styleName = "text2";
	}
	else
	{
		grpFrom.lblPrefix.styleName = "text1";
		grpFrom.lblEdit.styleName = "editText";
		grpFrom.lblStation.styleName = "text2";
		grpTo.lblPrefix.styleName = "text1";
		grpTo.lblEdit.styleName = "editText";
		grpTo.lblStation.styleName = "text2";
		grpInstructions.lblTitle.styleName = "text1";
		grpInstructions.lblHelp1.styleName = "alertText2";
		grpInstructions.lblHelp2.styleName = "alertText2";
		grpInstructions.lblHelp3.styleName = "alertText2";
		grpInstructions.lblHelp4.styleName = "alertText2";
		grpInstructions.lblHelp5.styleName = "alertText2";
		grpInstructions.lblHelp6.styleName = "alertText2";
		grpInstructions.lblFind.styleName = "text2";
	}
	
	grpTrainSchedule.lbl1.text = CaltrainStrings.getString("departs");
	grpTrainSchedule.lbl2.text = CaltrainStrings.getString("arrives");
	grpTrainSchedule.lbl3.text = CaltrainStrings.getString("duration");
	grpTrainSchedule.lbl4.text = CaltrainStrings.getString("trainNumber");
	grpTrainSchedule.lbl5.text = CaltrainStrings.getString("fare");
	grpTrainSchedule.btnDays.label = CaltrainStrings.getString("weekday");
	grpTrainSchedule.btnEnds.label = CaltrainStrings.getString("weekend");
	if (runtime)
		grpTrainSchedule.getTimes(true, (grpTrainSchedule.btnEnds.selected) ? 2 : 3);
	
	grpFrom.setDefaultStationValue(CaltrainStrings.getString("selectStation"));
	grpFrom.setTranslatedPrefix(CaltrainStrings.getString("fromStationPrefix"), CaltrainStrings.getString("toStationPrefix"));
	grpFrom.lblEdit.text = CaltrainStrings.getString("edit");
	grpTo.setDefaultStationValue(CaltrainStrings.getString("selectStation"));
	grpTo.setTranslatedPrefix(CaltrainStrings.getString("fromStationPrefix"), CaltrainStrings.getString("toStationPrefix"));
	grpTo.lblEdit.text = CaltrainStrings.getString("edit");
	
	
	strGPSDisabled = CaltrainStrings.getString("gps.disabled");
	strGPSNotSupported = CaltrainStrings.getString("gps.notsupported");
	strGPSTimeout = CaltrainStrings.getString("gps.timeout");
	strGPSMatch = CaltrainStrings.getString("gps.match");
	
	strTrainAlerts = CaltrainStrings.getString("trainAlerts.singular");
	strTrainAlerts2 = CaltrainStrings.getString("trainAlerts.plural");
	
	grpAlerts.lblAlert.text = CaltrainStrings.getString("alertPrefix");
	
	grpInstructions.lblTitle.text = CaltrainStrings.getString("info.title");
	grpInstructions.lblHelp1.text = CaltrainStrings.getString("info.help1");
	grpInstructions.lblHelp2.text = CaltrainStrings.getString("info.help2");
	grpInstructions.lblHelp3.text = CaltrainStrings.getString("info.help3");
	grpInstructions.lblHelp4.text = CaltrainStrings.getString("info.help4");
	grpInstructions.lblHelp5.text = CaltrainStrings.getString("info.help5");
	grpInstructions.lblHelp6.text = CaltrainStrings.getString("info.help6");
	grpInstructions.lblFind.text = CaltrainStrings.getString("info.button");
	
	grpStations.lstStations.updateLocalization();
	
	
}
