package com.renaun.caltrain.renderers
{
import com.renaun.caltrain.model.CaltrainStrings;
import com.renaun.caltrain.vo.StationVO;

import flash.filters.DropShadowFilter;
import flash.text.AntiAliasType;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.graphics.BitmapFillMode;
import mx.styles.CSSStyleDeclaration;

import spark.components.DataGroup;
import spark.components.LabelItemRenderer;
import spark.components.supportClasses.StyleableTextField;
import spark.effects.Fade;
import spark.primitives.BitmapImage;
import spark.primitives.Graphic;
import spark.utils.MultiDPIBitmapSource;


/**
 * 
 * ASDoc comments for this item renderer class
 * 
 */
public class StationRendererAS extends LabelItemRenderer
{
	public function StationRendererAS()
	{
		super();
		this.effectFade = new Fade();
		effectFade.duration = 200;
		
		switch (FlexGlobals.topLevelApplication.runtimeDPI)
		{
			case DPIClassification.DPI_160:
				smallerHeight = 31+28;
				largerHeight = 78;
				xLine = 50;
				xLabel = 76;
				circle1Width = 31;
				circle2Width = 50;
				xCircle = (xLine + 2) - circle1Width/2;
				xCircle1 = (xLine + 2) - circle1Width/2;
				xCircle2 = (xLine + 2) - circle2Width/2;
				this.subtleDropShadow.distance = 1;
				break;
			case DPIClassification.DPI_240:
				smallerHeight = 46+32;
				largerHeight = 117;
				xLine = 75;
				xLabel = 75+39;
				circle1Width = 46;
				circle2Width = 75;
				xCircle = (xLine + 3) - circle1Width/2;
				xCircle1 = (xLine + 3) - circle1Width/2;
				xCircle2 = (xLine + 3) - circle2Width/2;
				this.subtleDropShadow.distance = 2;
				break;
			case DPIClassification.DPI_320:
				smallerHeight = 62+56;
				largerHeight = 156;
				xLine = 100;
				xLabel = 100+52;
				circle1Width = 62;
				circle2Width = 100;
				xCircle = (xLine + 5) - circle1Width/2;
				xCircle1 = (xLine + 5) - circle1Width/2;
				xCircle2 = (xLine + 5) - circle2Width/2;
				this.subtleDropShadow.distance = 2;
				break;
		}
		xLabelStart = xLabel;
		height = smallerHeight;
		mouseChildren = false;
	}
	
	
	public var smallerHeight:int = 120;
	public var largerHeight:int = 160;
	private var circle1Width:int = 52;
	private var circle2Width:int = 90;
	[Bindable]
	private var xLine:int = 60;
	[Bindable]
	private var xCircle:int = 60;
	private var xCircle1:int = 60;
	private var xCircle2:int = 60;
	private var xLabelStart:int = 100;
	[Bindable]
	private var xLabel:int = 100;
	
	private var effectFade:Fade;
	
	private var subtleDropShadow:DropShadowFilter = new DropShadowFilter(2,45,0,0.8, 2, 2);
	
	private var circleGraphic:Graphic;
	protected var circleBitmap:BitmapImage;
	private var lineGraphic:Graphic;
	protected var lineBitmap:BitmapImage;
	private var quickResultsGraphic:Graphic;
	
	private var circle1:MultiDPIBitmapSource;// = FlexGlobals.topLevelApplication.circle1
	private var circle2:MultiDPIBitmapSource;// = FlexGlobals.topLevelApplication.circle2
	private var circle3:MultiDPIBitmapSource;// = FlexGlobals.topLevelApplication.circle3
	
	protected var lblStation:StyleableTextField;
	protected var resultsNorth:StyleableTextField;
	protected var resultsSouth:StyleableTextField;
	
	private var resultsNorthBGColor:uint;
	private var resultsSouthBGColor:uint;
	
	public var direction:int = 0;
	private var lastLocale:String = "";
	
	private var _showTimes:Boolean = false;
	public function get showTimes():Boolean
	{
		return _showTimes;
	}
	
	public function set showTimes(value:Boolean):void
	{
		_showTimes = value;
		//trace(lastLocale + " - " + CaltrainStrings.currentLocale);
		if (lastLocale != CaltrainStrings.currentLocale)
		{
			//trace("Setting styleDeclaration");
			
			resultsSouth.styleChanged(null);
			resultsNorth.styleChanged(null);
			if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
				resultsSouth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuickChinese");
			else
				resultsSouth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuick");
			
			if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
				resultsNorth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuickChinese");
			else
				resultsNorth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuick");
			lastLocale = CaltrainStrings.currentLocale;
		}
		if (!value)
			lastLocale = "";
		if (value)
		{
			
			// get Latest times
			var c:uint = 0;
			var d:Date = new Date();
			var cTime:int = (d.getHours() * 60) + d.getMinutes();
			var stopID:int = (data as StationVO).stopID;
			var serviceID:String = "trips.service_id="+CaltrainTimes.todaysServiceID;
			if (CaltrainTimes.todaysServiceID == 3 && CaltrainTimes.isSaturday)
				serviceID += "(trips.service_id=1 OR trips.service_id=3)";

			var sql:String = "select stop_times.arrival_time, trips.route_id from stop_times, trips where stop_id="+stopID+" AND stop_times.trip_id=trips.trip_id AND "+serviceID+" AND arrival_time>"+cTime+" AND trips.direction=0 order by arrival_time limit 1";
			var results:Array = FlexGlobals.topLevelApplication.processSQL(sql);
			var routeID:int = 0;
			var parts:Array;
			if (results.length > 0)
			{
				routeID = results[0]["route_id"];
				parts = CaltrainTimes.formatTimeParts(results[0]["arrival_time"]);
				var strnn:String = CaltrainStrings.getString("next.northbound");;
				strnn = strnn.replace("{1}", parts[0]);
				strnn = strnn.replace("{2}", parts[1]);
				resultsNorth.text = strnn;
				if (routeID == 2)
					c = 0xf0ff00;
				else if (routeID == 4)
					c = 0x00ff60;
				else if (routeID == 1)
					c = 0xA10C11;
				else
					c = 0x777777;
				resultsNorthBGColor = c;
			}
			resultsNorth.visible = (results.length > 0 && itemIndex > 1);
			//trace("v: " + resultsNorth.visible + " - " + results.length + " - " + itemIndex);
			
			sql = "select stop_times.arrival_time, trips.route_id from stop_times, trips where stop_id="+stopID+" AND stop_times.trip_id=trips.trip_id AND trips.service_id="+serviceID+" AND arrival_time>"+cTime+" AND trips.direction=1 order by arrival_time limit 1";
			results = FlexGlobals.topLevelApplication.processSQL(sql);
			if (results.length > 0)
			{
				routeID = results[0]["route_id"];
				parts = CaltrainTimes.formatTimeParts(results[0]["arrival_time"]);
				var strns:String = CaltrainStrings.getString("next.southbound");
				strns = strns.replace("{1}", parts[0]);
				strns = strns.replace("{2}", parts[1]);
				resultsSouth.text = strns;
				if (routeID == 2)
					c = 0xf0ff00;
				else if (routeID == 4)
					c = 0x00ff60;
				else if (routeID == 1)
					c = 0xA10C11;
				else
					c = 0x777777;
				resultsSouthBGColor = c;
			}
			resultsSouth.visible = (results.length > 0 && itemIndex < (parent as DataGroup).dataProvider.length-2);
			
			resultsNorth.commitStyles();
			resultsSouth.commitStyles();
			invalidateDisplayList();
		}
		effectFade.targets = [resultsNorth, resultsSouth, quickResultsGraphic];
		if (!resultsNorth.visible && resultsSouth.visible)
			effectFade.targets = [resultsSouth, quickResultsGraphic];
		if (!resultsNorth.visible && !resultsSouth.visible)
			effectFade.targets = [quickResultsGraphic];
		if (resultsNorth.visible && !resultsSouth.visible)
			effectFade.targets = [resultsNorth, quickResultsGraphic];
				
		if (value && (resultsNorth.alpha == 0.0 || resultsSouth.alpha == 0.0) && selected) 
		{
			effectFade.alphaFrom = 0;
			effectFade.alphaTo = 1;
			effectFade.play();
		}
		else if (!value &&  (resultsNorth.alpha > 0.05 || resultsSouth.alpha > 0.05))
		{
			effectFade.alphaFrom = 1;
			effectFade.alphaTo = 0;
			effectFade.play();
		}
		
	}
	
	override public function set selected(value:Boolean):void
	{
		super.selected = value;
		
		var lastHeight:int = this.height;
		this.height = (!value) ? smallerHeight : largerHeight;
		(parent as DataGroup).verticalScrollPosition -= (lastHeight-this.height)/2;
		
		// Check Direction to set Circles
		circleBitmap.source = (!value) ? circle1 : ((direction < 0) ? circle2 : circle3);
		
		lblStation.styleChanged(null);
		lblStation.styleDeclaration = 
			styleManager.getStyleDeclaration("."+((!value) ? "stationText1" : "stationText2"));
		lblStation.commitStyles();
	
		xCircle = (!value) ? xCircle1 : xCircle2;
		xLabel = (!value) ? xLabelStart : xLabelStart + (xCircle1-xCircle2);
		
		invalidateDisplayList();
	}
	
	/**
	 * @private
	 *
	 * Override this setter to respond to data changes
	 */
	override public function set data(value:Object):void
	{
		super.data = value;
		if (value == null)
			return;
		
		lblStation.text = value.toString();
		lblStation.commitStyles();				
	} 
	
	/**
	 * @private
	 * 
	 * Override this method to create children for your item renderer 
	 */	
	override protected function createChildren():void
	{
		//super.createChildren();
		
		circle1 = FlexGlobals.topLevelApplication.circle1;
		circle2 = FlexGlobals.topLevelApplication.circle2;
		circle3 = FlexGlobals.topLevelApplication.circle3;
		
		if (!lineBitmap)
		{
			lineBitmap = new BitmapImage();
			lineBitmap.source = FlexGlobals.topLevelApplication.stationLine;
			//lineBitmap.fillMode = "scale";
			lineBitmap.scaleMode = BitmapFillMode.SCALE;
			lineGraphic = new Graphic();
			lineGraphic.addElement(lineBitmap);
			addChild(lineGraphic);
		}
		
		if (!circleBitmap)
		{
			circleBitmap = new BitmapImage();
			circleBitmap.source = FlexGlobals.topLevelApplication.circle1;
			circleGraphic = new Graphic();
			circleGraphic.addElement(circleBitmap);
			addChild(circleGraphic);
		}
		
		if (!quickResultsGraphic)
		{
			quickResultsGraphic = new Graphic();
			quickResultsGraphic.alpha = 0;
			addChild(quickResultsGraphic);
			quickResultsGraphic.filters = [subtleDropShadow];
		}
		
		if (!lblStation)
		{
			lblStation = createLabelDisplay2();
			lblStation.styleDeclaration = styleManager.getStyleDeclaration(".stationText1");
			lblStation.filters = [subtleDropShadow];
		}
		
		if (!resultsNorth)
		{
			resultsNorth = createLabelDisplay2();
			resultsNorth.alpha = 0;
			if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
				resultsNorth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuickChinese");
			else
				resultsNorth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuick");
			resultsNorth.filters = [subtleDropShadow];
		}
		if (!resultsSouth)
		{
			resultsSouth = createLabelDisplay2();
			resultsSouth.alpha = 0;
			if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
				resultsSouth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuickChinese");
			else
				resultsSouth.styleDeclaration = styleManager.getStyleDeclaration(".resultsQuick");
			resultsSouth.filters = [subtleDropShadow];
		}
		
		
		effectFade.targets = [resultsNorth, resultsSouth, quickResultsGraphic];
	}
	
	protected function createLabelDisplay2():StyleableTextField
	{
		var lbl:StyleableTextField = StyleableTextField(createInFontContext(StyleableTextField));
		lbl.editable = false;
		lbl.selectable = false;
		lbl.multiline = false;
		lbl.wordWrap = false;
		lbl.antiAliasType = AntiAliasType.ADVANCED;
		
		addChild(lbl);
		return lbl;
	}
	
	/**
	 * @private
	 * 
	 * Override this method to change how the background is drawn for 
	 * item renderer.  For performance reasons, do not call 
	 * super.drawBackground() if you do not need to.
	 */
	override protected function drawBackground(unscaledWidth:Number, 
											   unscaledHeight:Number):void
	{
		//super.drawBackground(unscaledWidth, unscaledHeight);
		// do any drawing for the background of the item renderer here
		
		// Fixed a bug with Atrix on some render artifacts
		graphics.beginFill(0xa10c11,0);
		graphics.drawRect(0,0,unscaledWidth/10,unscaledHeight);
		graphics.endFill();
	}
	
	/**
	 * @private
	 *  
	 * Override this method to change how the background is drawn for this 
	 * item renderer. For performance reasons, do not call 
	 * super.layoutContents() if you do not need to.
	 */
	override protected function layoutContents(unscaledWidth:Number, 
											   unscaledHeight:Number):void
	{
		super.layoutContents(unscaledWidth, unscaledHeight);
		// layout all the subcomponents here   
		
		// Handle First and Last renderers
		//trace("index: " + itemIndex);
		if (itemIndex == 1)
		{
			lineGraphic.y = unscaledHeight/2;
			lineGraphic.height = Math.ceil(unscaledHeight/2);
		}
		else if (itemIndex == (parent as DataGroup).dataProvider.length-2)
		{
			lineGraphic.y = 0;
			lineGraphic.height = unscaledHeight/2;
		}
		else
		{
			lineGraphic.y = 0;
			lineGraphic.height = unscaledHeight;
		}
		lineGraphic.x = xLine;
		lineBitmap.height = lineGraphic.height;
		lineGraphic.width = lineBitmap.width;
		
		if (circleBitmap.source == circle1)
		{
			circleGraphic.width = circle1Width;
			circleGraphic.height = circle1Width;
			circleGraphic.y = (unscaledHeight-circle1Width)/2;
		}
		else
		{
			circleGraphic.width = circle2Width;
			circleGraphic.height = circle2Width;
			circleGraphic.y = (unscaledHeight-circle2Width)/2;
		}
		circleGraphic.x = xCircle;
		
		
		var mid:int = (unscaledHeight-lblStation.textHeight)/2;
		lblStation.x = xLabel;
		lblStation.y = mid;
		
		var style:CSSStyleDeclaration = styleManager.getStyleDeclaration(".resultsQuick");
		resultsNorth.y = (resultsNorth.textHeight/2);
		resultsSouth.x = unscaledWidth - resultsSouth.textWidth - style.getStyle("paddingRight");
		resultsNorth.x = unscaledWidth - resultsSouth.textWidth - style.getStyle("paddingRight");
		resultsSouth.y = unscaledHeight-(resultsSouth.textHeight*3/2);
		
		var padLeft:int = style.getStyle("paddingLeft");
		var padTop:int = style.getStyle("paddingTop");
		quickResultsGraphic.graphics.clear();
		
		if (resultsNorth.visible)
		{
			quickResultsGraphic.graphics.beginFill(resultsNorthBGColor, 0.2);
			quickResultsGraphic.graphics.drawRect(resultsNorth.x - padLeft, resultsNorth.y-padTop/2, 
				unscaledWidth-(resultsNorth.x - padLeft), padTop + resultsNorth.textHeight);
			quickResultsGraphic.graphics.endFill();
		}
		if (resultsSouth.visible)
		{
			quickResultsGraphic.graphics.beginFill(resultsSouthBGColor, 0.2);
			quickResultsGraphic.graphics.drawRect(resultsSouth.x - padLeft, resultsSouth.y-padTop/2, 
				unscaledWidth-(resultsSouth.x - padLeft), padTop + resultsSouth.textHeight);
			quickResultsGraphic.graphics.endFill();
		}
	}
	
}
}