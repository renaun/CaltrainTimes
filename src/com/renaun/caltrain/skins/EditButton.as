package com.renaun.caltrain.skins
{
import mx.core.DPIClassification;

import spark.skins.mobile.ButtonSkin;

public class EditButton extends ButtonSkin
{
	public function EditButton()
	{
		// default DPI_160
		
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{				
				layoutGap = 10;
				layoutPaddingLeft = 12;
				layoutPaddingRight = 12;
				layoutPaddingTop = 12;
				layoutPaddingBottom = 12;
				layoutBorderSize = 2;
				width = 116;
				width = 40;
				upBorderSkin = upImage;//spark.skins.mobile160.assets.MyButton_down;
				downBorderSkin = downImage;//spark.skins.mobile160.assets.MyButton_down;
				
				break;
			}
			case DPIClassification.DPI_240:
			{
				layoutGap = 7;
				layoutPaddingLeft = 9;
				layoutPaddingRight = 9;
				layoutPaddingTop = 11;
				layoutPaddingBottom = 9;
				layoutBorderSize = 1;
				width = 87;
				height = 30;
				// TODO make 240 sized button
				upBorderSkin = upImage240;//spark.skins.mobile160.assets.MyButton_down;
				downBorderSkin = downImage240;//spark.skins.mobile160.assets.MyButton_down;
				
				break;
			}
			default:
			{
				layoutPaddingLeft = 5;
				layoutPaddingRight = 6;
				layoutPaddingTop = 6;
				layoutPaddingBottom = 6;
				width = 50;
				height = 19;
				
				
				upBorderSkin = upImage160;//spark.skins.mobile160.assets.MyButton_down;
				downBorderSkin = downImage160;//spark.skins.mobile160.assets.MyButton_down;
				
				break;
			}
		}
	}
	
	[Embed(source="/assets/dpi320/redbox.png")]
	private var upImage:Class;
	
	[Embed(source="/assets/dpi320/redbox_down.png")]
	private var downImage:Class;
	
	[Embed(source="/assets/dpi240/redbox.png")]
	private var upImage240:Class;
	
	[Embed(source="/assets/dpi240/redbox_down.png")]
	private var downImage240:Class;

	[Embed(source="/assets/dpi160/redbox.png")]
	private var upImage160:Class;
	
	[Embed(source="/assets/dpi160/redbox_down.png")]
	private var downImage160:Class;
	
	override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
	{
	}
}
}