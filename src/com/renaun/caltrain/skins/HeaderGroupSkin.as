package com.renaun.caltrain.skins
{
import mx.core.DPIClassification;

import spark.layouts.HorizontalLayout;
import spark.skins.mobile.SkinnableContainerSkin;

public class HeaderGroupSkin extends SkinnableContainerSkin
{
	
	override protected function createChildren():void
	{      
		super.createChildren();
		var padding:int = 12;
		var paddingTop:int = 8;
		var paddingBottom:int =4;
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{
				padding = 24;
				paddingTop = 14;
				paddingBottom = 8;
				break;
			}
			case DPIClassification.DPI_240:
			{
				padding = 18;
				paddingTop = 11;
				paddingBottom = 8;
				break;
			}
		}
		(hostComponent.layout as HorizontalLayout).paddingTop = paddingTop;
		(hostComponent.layout as HorizontalLayout).paddingBottom = paddingBottom;
		(hostComponent.layout as HorizontalLayout).paddingLeft = padding;
		(hostComponent.layout as HorizontalLayout).paddingRight = padding;
	}
}
}