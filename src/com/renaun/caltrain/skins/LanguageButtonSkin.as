package com.renaun.caltrain.skins
{
	import mx.core.DPIClassification;
	
	import spark.skins.mobile.ButtonSkin;
	import spark.skins.mobile.supportClasses.ButtonSkinBase;
	
	public class LanguageButtonSkin extends ButtonSkinBase
	{
		public function LanguageButtonSkin()
		{
			super();
			switch (applicationDPI)
			{
				case DPIClassification.DPI_320:
				{
					
					layoutGap = 10;
					layoutPaddingLeft = 20;
					layoutPaddingRight = 20;
					layoutPaddingTop = 20;
					layoutPaddingBottom = 20;
					layoutBorderSize = 2;
					measuredDefaultWidth = 64;
					measuredDefaultHeight = 86;
					
					break;
				}
				case DPIClassification.DPI_240:
				{
					
					layoutGap = 7;
					layoutPaddingLeft = 15;
					layoutPaddingRight = 15;
					layoutPaddingTop = 15;
					layoutPaddingBottom = 15;
					layoutBorderSize = 1;
					measuredDefaultWidth = 48;
					measuredDefaultHeight = 65;
					
					break;
				}
				default:
				{
					
					layoutGap = 5;
					layoutPaddingLeft = 10;
					layoutPaddingRight = 10;
					layoutPaddingTop = 10;
					layoutPaddingBottom = 10;
					layoutBorderSize = 1;
					measuredDefaultWidth = 32;
					measuredDefaultHeight = 43;
					
					break;
				}
			}
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.drawBackground(unscaledWidth, unscaledHeight);
			
			graphics.beginFill(0xc0c0c0, 0.2);
			graphics.drawRect(layoutBorderSize, layoutBorderSize, 
				unscaledWidth - (layoutBorderSize * 2), 
				unscaledHeight - (layoutBorderSize * 2));
			graphics.endFill();
		}
	}
}