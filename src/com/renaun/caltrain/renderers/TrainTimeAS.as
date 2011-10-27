package com.renaun.caltrain.renderers
{
	import com.renaun.caltrain.model.CaltrainStrings;
	import com.renaun.caltrain.vo.TimesVO;
	
	import flash.display.GradientType;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	import mx.core.DPIClassification;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.graphics.BitmapFill;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapScaleMode;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.utils.MultiDPIBitmapSource;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class TrainTimeAS extends LabelItemRenderer
	{
		public function TrainTimeAS()
		{
			super();
			styleName = "resultsChinese";
			switch (applicationDPI)
			{
				case DPIClassification.DPI_160:
					minHeight = 50;
					break;
				case DPIClassification.DPI_240:
					minHeight = 75;
					break;
				case DPIClassification.DPI_320:
					minHeight = 100;
					break;
			}
		}
		private var headerDropShadow:DropShadowFilter = new DropShadowFilter(2,132,0,0.5, 2, 2);
		
		protected var bitmapLine:Image;
		
		private var backgroundAlpha:Number = 0;
		private var backgroundColor:uint = 0x000000;
		
		protected var lblFrom:StyleableTextField;
		protected var lblTo:StyleableTextField;
		protected var lblDuration:StyleableTextField;
		protected var lblTrain:StyleableTextField;
		protected var lblFare:StyleableTextField;

		private var shell:Group;

		private var rect:Rect;

		private var mask2:Group;
		
		private var drawAlert:Boolean = false;
		private var lastLocale:String;
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			// the data has changed.  push these changes down in to the 
			// subcomponents here
			if (!value)
				return;
			
			var item:TimesVO = value as TimesVO;
			
			if (lastLocale != CaltrainStrings.currentLocale)
			{
				if (CaltrainStrings.currentLocale == CaltrainStrings.LOCALE_CHINESE)
					styleName = "resultsChinese";
				else
					styleName = "results";
				lastLocale = CaltrainStrings.currentLocale;
			}
			
			drawAlert = item.hasAlert;
			
			lblFrom.text = item.departureTime;
			lblTo.text = item.arrivalTime;
			lblDuration.text = item.duration;
			lblFare.text = item.fare;
			
			var trainNumber:String = item.trainNumber;
			if (item.trainNumber.substr(0,1) == "9")
			{
				var num:int = int(item.trainNumber.substr(1,2));
				trainNumber = "2" + ((num < 10) ? "0" : "") + num;
				if (num == 8 || num == 18 || num == 28)
					num += 2;
				else
					num += 4;
				trainNumber += " 2" + num;
				
			}
			lblTrain.text = trainNumber;
			
			lblFrom.commitStyles();
			lblTo.commitStyles();
			lblDuration.commitStyles();
			lblTrain.commitStyles();
			lblFare.commitStyles();
			
			var c:uint = 0;
			if (item.routeID == 2)
				c = 0xf0ff00;
			else if (item.routeID == 4)
				c = 0x00ff60;
			else if (item.routeID == 1)
				c = 0xA10C11;
			//var c:uint = (itemIndex % 3) == 0 ? 0xFEF0B5 : ((itemIndex % 3) == 1 ? 0 : 0xE31837);
			backgroundColor = c;
			if (c == 0)
				backgroundAlpha = 0;
			else
				backgroundAlpha = 0.2;
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			//super.createChildren();
			// create any additional children for your item renderer here			
			
			if (!bitmapLine)
			{
				bitmapLine = new Image();
				bitmapLine.source = FlexGlobals.topLevelApplication.bitmapResultsHDots;
				bitmapLine.fillMode = BitmapFillMode.REPEAT;
				shell = new Group();
				addChild(bitmapLine);
				bitmapLine.cacheAsBitmap = true;
				
				rect = new Rect();
				var lF:LinearGradient = new LinearGradient();
				var e:Array = [];
				var gE:GradientEntry = new GradientEntry();
				gE.color = 0x336699;
				gE.alpha = 0;
				e.push(gE);
				gE = new GradientEntry();
				gE.color = 0x000000;
				gE.ratio = 0.1;
				e.push(gE);
				gE = new GradientEntry();
				gE.color = 0xffffff;
				gE.ratio = 0.9;
				e.push(gE);
				gE = new GradientEntry();
				gE.color = 0xff0000;
				gE.alpha = 0;
				e.push(gE);
				lF.entries = e;
				rect.fill = lF;
				
				mask2 = new Group();
				mask2.addElement(rect);
				addChild(mask2);
				mask2.cacheAsBitmap = true;
				
				
				bitmapLine.mask = mask2;
			}
			
			if (!lblFrom)
			{
				lblFrom = createLabelDisplay2();
				lblFrom.filters = [headerDropShadow];
			}
			if (!lblTo)
			{
				lblTo = createLabelDisplay2();
				lblTo.filters = [headerDropShadow];
			}
			if (!lblDuration)
			{
				lblDuration = createLabelDisplay2();
				lblDuration.filters = [headerDropShadow];
			}
			if (!lblTrain)
			{
				lblTrain = createLabelDisplay2();
				lblTrain.multiline = true;
				lblTrain.wordWrap = true;
				lblTrain.filters = [headerDropShadow];
			}
			if (!lblFare)
			{
				lblFare = createLabelDisplay2();
				lblFare.filters = [headerDropShadow];
			}
		}
		
		protected function createLabelDisplay2():StyleableTextField
		{
			var lbl:StyleableTextField = StyleableTextField(createInFontContext(StyleableTextField));
			lbl.styleName = this;
			lbl.editable = false;
			lbl.selectable = false;
			lbl.multiline = false;
			lbl.wordWrap = false;
			
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
			graphics.clear();
			graphics.beginFill(backgroundColor, backgroundAlpha);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill(); 
			if (drawAlert)
			{
				/*
				graphics.lineStyle(2, 0x991100, 0.6);
				graphics.drawRect(1,0, unscaledWidth-2, unscaledHeight-2);
				
				graphics.lineStyle(2, 0xEE1100, 0.2);
				graphics.drawRect(3,2, unscaledWidth-4, unscaledHeight-4);
				*/
				
				switch (applicationDPI)
				{
					case DPIClassification.DPI_160:
						graphics.lineStyle(3, 0xa10c11, 0.7);
						graphics.drawRect(1,1, unscaledWidth-2, unscaledHeight-2);
						
						graphics.lineStyle(2, 0xffffff, 0.2);
						graphics.drawRect(4,4, unscaledWidth-8, unscaledHeight-8);
						break;
					case DPIClassification.DPI_240:
						graphics.lineStyle(6, 0xa10c11, 0.7);
						graphics.drawRect(1,3, unscaledWidth-2, unscaledHeight-6);
						
						graphics.lineStyle(4, 0xffffff, 0.2);
						graphics.drawRect(7,9, unscaledWidth-14, unscaledHeight-18);
						break;
					case DPIClassification.DPI_320:
						
						graphics.lineStyle(6, 0xa10c11, 0.7);
						graphics.drawRect(1,3, unscaledWidth-2, unscaledHeight-6);
						
						graphics.lineStyle(4, 0xffffff, 0.2);
						graphics.drawRect(7,9, unscaledWidth-14, unscaledHeight-18);
						break;
				}
				
			}
			
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
			var mWidth:Number = unscaledWidth*.9;
			var mid:int = (unscaledHeight-lblFrom.textHeight)/2;
			
			lblFrom.x = (unscaledWidth-mWidth)/2;
			lblFrom.y = mid;
			lblFrom.width = (mWidth*.24);
			
			lblTo.x = lblFrom.x + lblFrom.width;
			lblTo.y = mid;
			lblTo.width = (mWidth*.24);
			
			lblDuration.x = lblTo.x + lblTo.width;
			lblDuration.y = mid;
			lblDuration.width = (mWidth*.24);
			
			lblTrain.x = lblDuration.x + lblDuration.width;
			lblTrain.y = (unscaledHeight-lblTrain.textHeight)/2;;
			lblTrain.width = (mWidth*.12);
			
			lblFare.x = lblTrain.x + lblTrain.width;
			lblFare.y = mid;
			lblFare.width = (mWidth*.16);
			
			rect.height = shell.height;
						
			mWidth = unscaledWidth*.8;
			bitmapLine.width = mWidth;
			bitmapLine.height = bitmapLine.bitmapData.height;
			bitmapLine.x = unscaledWidth*0.1;
			bitmapLine.y = unscaledHeight-bitmapLine.height/2;
			mask2.x = bitmapLine.x;
			mask2.y = bitmapLine.y;
			rect.width = bitmapLine.width;
			rect.height = bitmapLine.height;
		}
		
	}
}