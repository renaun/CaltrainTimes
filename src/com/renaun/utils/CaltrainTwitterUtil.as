package com.renaun.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

public class CaltrainTwitterUtil
{
	public function CaltrainTwitterUtil()
	{
	}
	
	// 14595117 - user id of bikecar
	// 10087032 - user id of caltrain
	private var urlLoader:URLLoader;
	private var requestCaltrain:URLRequest = new URLRequest("https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=caltrain&count=15&trim_user=true");
	private var requestBikecar:URLRequest = new URLRequest("https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=bikecar&count=15&trim_user=true");
	private var lastData:Array;
	private var lastCallTime:Number = 0;
	
	public var currentDirection:int = 0;
	public var todaysFilteredTweets:Array;
	private var callback:Function = null;
	private var trainsFilter:Dictionary;
	private var findCaltrain:Boolean = true;
	
	public function stopFindingAlerts():void
	{
		callback = null;
		todaysFilteredTweets = [];
	}
	
	public function findTweetsForTrains(trains:Array, callback:Function):void
	{
		trainsFilter = new Dictionary();
		var trainNumber:String = "";
		for (var i:int = 0; i < trains.length; i++) 
		{
			trainNumber = trains[i].trainNumber;
			if (trainNumber.substr(0,1) == "9")
			{
				var num:int = int(trainNumber.substr(1,2));
				trainNumber = "2" + ((num < 10) ? "0" : "") + num;
				trainsFilter[trainNumber] = true;
				if (num == 8 || num == 18 || num == 28)
					num += 2;
				else
					num += 4;
				trainNumber = "2" + num;
				trainsFilter[trainNumber] = true;
				
			}
			else
				trainsFilter[trainNumber] = true;
		}
		todaysFilteredTweets = [];
		
		
		this.callback = callback;
		// Search Caltrains first
		if (!urlLoader)
		{
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
		if (lastCallTime < (new Date()).getTime() - 60000*5)
		{
			//trace("load");
			findCaltrain = true;
			urlLoader.load(requestCaltrain);
		}
		else
		{
			processData(lastData);
		}
	}
	
	protected function completeHandler(event:Event):void
	{
		//trace("load complete");
		if (findCaltrain)
		{
			lastCallTime = (new Date()).getTime();
			lastData = [];
			parseData(urlLoader.data as String, "@caltrain");
			urlLoader.load(requestBikecar);
			findCaltrain = false;
		}
		else
		{
			parseData(urlLoader.data as String, "@bikecar");
			processData(lastData);
			lastData = lastData.sortOn("timeSort");
		}
	}
	
	private function parseData(data:String, feedType:String):void
	{
		//trace("parseData");
		var xml:XML = new XML(data);
		for each (var item:XML in xml..status) 
		{
			var d:Date = stringToDate(item.created_at);
			if (d.getTime() > (new Date()).getTime()-(60000*360)) // 6 hours ago everything else before that is old news
			{
				//trace("parseData2: " + item.text + " - " + item.user.id + " - "+ stringToDate(item.created_at).toDateString());
				lastData.push({label: feedType + ": " + item.text.toString(), id: item.id.toString(), timeSort: d.getTime(), time: d, type: feedType});
			}
		}
		
	}
	
	private function processData(data:Array):void
	{
		//var xml:XML = new XML(data);
		//trace("processData: " + data); 
		var trainMatches:Array = [];
		var uniqueTrains:Dictionary = new Dictionary();
		var pattern:RegExp = /\d\d\d/g; 
		for (var i:int = 0; i < data.length; i++) 
		{
			var results:Array = (data[i].label as String).match(pattern);
			var isMatch:Boolean = false;
			for (var j:int = 0; j < results.length; j++) 
			{
				if (trainsFilter[results[j]] && !uniqueTrains[results[j]])
				{
					trainMatches.push(results[j]);
					uniqueTrains[results[j]] = true;
				}
				isMatch = isMatch || (trainsFilter[results[j]]);
			}
			if (isMatch)
				todaysFilteredTweets.push(data[i]);
		}
		if (todaysFilteredTweets.length > 0)
			callback(trainMatches);
	}
	
	
	protected function errorHandler(event:Event):void
	{
		// TODO Auto-generated method stub
		
		//trace("error: " + event["message"]);
	}
	
	//Wed Aug 24 16:15:27 +0000 2011
	private function stringToDate(source:String):Date
	{
		var parts:Array = source.split(" ");
		parts[4] = "GMT" + parts[4];
		source = parts.join(" ");
		return new Date(source);
	}
	
}
}