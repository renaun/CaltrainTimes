package com.renaun.caltrain.skins
{
import mx.core.BitmapAsset;
import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.graphics.BitmapFillMode;
import mx.graphics.BitmapScaleMode;

import spark.components.Image;
import spark.core.SpriteVisualElement;
import spark.layouts.HorizontalLayout;
import spark.skins.mobile.SkinnableContainerSkin;

public class BlackBoxSkin extends SkinnableContainerSkin
{
	
	private var backgroundImage:Image;
	
	override protected function createChildren():void
	{      
		
		var padding:int = 12;
		var paddingTop:int = 12;
		var paddingBottom:int = 4;
		var dpiHeight:int = 47;
		var gap:int = 8;
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{
				padding = 24;
				paddingTop = 24;
				paddingBottom = 8;
				dpiHeight = 94;
				gap = 12;
				break;
			}
			case DPIClassification.DPI_240:
			{
				padding = 18;
				paddingTop = 18;
				paddingBottom = 8;
				dpiHeight = 70;
				gap = 16;
				break;
			}
		}
		height = dpiHeight;
		//(hostComponent.layout as HorizontalLayout).paddingTop = paddingTop;
		//(hostComponent.layout as HorizontalLayout).paddingBottom = paddingBottom;
		var hLayout:HorizontalLayout = (hostComponent.layout as HorizontalLayout);
		if (hLayout)
		{
			hLayout.paddingLeft = padding;
			hLayout.paddingRight = padding;
			hLayout.gap = gap;
			hLayout.verticalAlign = "middle";
		}
		
		if (!backgroundImage)
		{
			backgroundImage = new Image();;
			backgroundImage.source = FlexGlobals.topLevelApplication.blackbox;
			addChild(backgroundImage);
		}
		super.createChildren();
	}
	
	/**
	 *  @private
	 */
	override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
	{
		//super.drawBackground(unscaledWidth, unscaledHeight);
		backgroundImage.width = unscaledWidth;
		backgroundImage.height = unscaledHeight;
	}
	
}
}