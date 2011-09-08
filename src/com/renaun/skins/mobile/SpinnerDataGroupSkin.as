package com.renaun.skins.mobile
{
import com.renaun.components.SpinnerDataGroup;

import mx.binding.utils.BindingUtils;
import mx.core.ClassFactory;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.LabelItemRenderer;
import spark.components.Scroller;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;
/**
 * 	Handles the layout and rendering.
 */
public class SpinnerDataGroupSkin extends MobileSkin
{
	public function SpinnerDataGroupSkin()
	{
		super();
	}
	
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	/** 
	 *  @copy spark.skins.spark.ApplicationSkin#hostComponent
	 */
	public var hostComponent:SpinnerDataGroup;
	
	//--------------------------------------------------------------------------
	//
	//  Skin parts 
	//
	//--------------------------------------------------------------------------
	/**
	 *  Scroller skin part.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */ 
	public var scroller:Scroller;
	
	/**
	 *  DataGroup skin part.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */ 
	public var dataGroup:DataGroup;

	/**
	 *  @private 
	 */
	override protected function createChildren():void
	{
		if (!dataGroup)
		{
			// Create data group layout
			var layout:VerticalLayout = new VerticalLayout();
			layout.requestedMinRowCount = 5;
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			layout.gap = 0;
			layout.variableRowHeight = true;
			layout.useVirtualLayout = false;
			
			// Create data group
			dataGroup = new DataGroup();
			dataGroup.layout = layout;
			//dataGroup.itemRenderer = new ClassFactory(spark.components.LabelItemRenderer);
		}
		if (!scroller)
		{
			// Create scroller
			scroller = new Scroller();
			scroller.minViewportInset = 1;
			scroller.hasFocusableChildren = false;
			scroller.ensureElementIsVisibleForSoftKeyboard = false;
			addChild(scroller);
		}
		
		// Associate scroller with data group
		if (!scroller.viewport)
		{
			scroller.viewport = dataGroup;
		}
	}
	
	/**
	 *  @private 
	 */
	override protected function measure():void
	{
		measuredWidth = scroller.getPreferredBoundsWidth();
		measuredHeight = scroller.getPreferredBoundsHeight();
	}
	
	/**
	 *  @private 
	 */
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{   
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		// Scroller
		scroller.minViewportInset = 0;
		setElementSize(scroller, unscaledWidth, unscaledHeight);
		setElementPosition(scroller, 0, 0);
	}
	
	
}
}