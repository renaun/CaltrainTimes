package com.renaun.components
{

import com.renaun.caltrain.renderers.StationRendererAS;
import com.renaun.caltrain.vo.StationVO;
import com.renaun.events.StationSelectEvent;

import flash.events.DataEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.TransformGestureEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.Timer;

import mx.binding.utils.BindingUtils;
import mx.collections.IList;
import mx.collections.ItemResponder;
import mx.core.ClassFactory;
import mx.core.FlexGlobals;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.Scroller;
import spark.components.SkinnableDataContainer;
import spark.components.supportClasses.ItemRenderer;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;

[Event(name="stationSelect", type="com.renaun.events.StationSelectEvent")]

/**
 *  Handles all the logic about items and item selection
 */
public class SpinnerDataGroup extends SkinnableDataContainer
{
	public function SpinnerDataGroup()
	{
		super();
		
		itemRendererFunction = filterPaddingItems;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Skin parts 
	//
	//--------------------------------------------------------------------------
	
	[SkinPart(required="false")]
	/**
	 *  Scroller skin part.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5 
	 *  @productversion Flex 4.5
	 */ 
	public var scroller:Scroller;
	
	protected var scaleStartingPosition:Number = 0;
	
	private var lastHeight:Number;
	protected var singleHeight:Number = 0;
	
	protected var lastSelectedLeftIndex:int = -1;
	protected var lastSelectedRightIndex:int = -1;
	
	protected var padElement1:UIComponent = new UIComponent();
	protected var padElement2:UIComponent = new UIComponent();
	
	protected var timer:Timer;
	
	public var currentSelector:int = -1;
	
	
	//----------------------------------
	//  selectedIndex
	//----------------------------------
	
	private var _selectedIndex:int = 0;
	
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}

	public function set selectedIndex(value:int):void
	{
		_selectedIndex = value;
	}

	//----------------------------------
	//  override methods
	//----------------------------------
	
	
	[Inspectable(category="Data")]
	
	/**
	 *  @private
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override public function set dataProvider(value:IList):void
	{
		// Add padding items
		if (value)
		{
			value.addItemAt(padElement1, 0);
			value.addItem(padElement2);
		}
		super.dataProvider = value;
		
	}
	
	/**
	 *  @private 
	 */
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{   
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if (lastHeight != unscaledHeight && dataGroup && dataGroup.numElements > 2 && dataGroup.getElementAt(1) != null)
		{
			if (singleHeight <= 0)
				singleHeight = (dataGroup.getElementAt(1) as StationRendererAS).smallerHeight;
			scaleStartingPosition = (unscaledHeight-singleHeight) / 2;
			(dataGroup.getElementAt(0) as IVisualElement).height = scaleStartingPosition;
			(dataGroup.getElementAt(dataGroup.numElements-1) as IVisualElement).height = scaleStartingPosition;
			lastHeight = unscaledHeight;
		}
		
	}
	
	protected function updateDisplayListDelayed(event:TimerEvent):void
	{		
		if (lastHeight != unscaledHeight && dataGroup && dataGroup.numElements > 2 && dataGroup.getElementAt(1) != null)
		{
			if (singleHeight <= 0)
				singleHeight = (dataGroup.getElementAt(1) as StationRendererAS).smallerHeight;
			scaleStartingPosition = (unscaledHeight-singleHeight) / 2;
			(dataGroup.getElementAt(0) as IVisualElement).height = scaleStartingPosition;
			(dataGroup.getElementAt(dataGroup.numElements-1) as IVisualElement).height = scaleStartingPosition;
			lastHeight = unscaledHeight;
		}
	}
	
	protected function filterPaddingItems(item:Object):IFactory
	{
		if (item is Object && 
			(item == padElement1 || item == padElement2))
			return null;
		return itemRenderer;		
	}
	
	/**
	 *  @private 
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		if (dataGroup)
			dataGroup.layout.useVirtualLayout = false;
	}
	
	/**
	 *  @private
	 */
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);
		
		if (instance == dataGroup)
		{		
			dataGroup.addEventListener(
				RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
		}
	}
	
	/**
	 *  @private
	 *  Called when an item has been added to this component.
	 */
	protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
	{
		var renderer:IVisualElement = event.renderer;
		
		if (!renderer)
			return;
		
		if (renderer is StationRendererAS)
		{
			(renderer as StationRendererAS).addEventListener(MouseEvent.DOUBLE_CLICK, clickHandler);
			(renderer as StationRendererAS).addEventListener(MouseEvent.CLICK, clickHandler);
		}
	}
	
	protected function clickHandler(event:MouseEvent):void
	{
		//trace("CLICK: " + event.currentTarget + " - " + event.type);
		if (event.isDefaultPrevented())
			return;		
		// Handle selection
		var newIndex:int;
		
		if (event.currentTarget is IItemRenderer)
			newIndex = IItemRenderer(event.currentTarget).itemIndex;
		else
			newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);

		var direction:int = currentSelector;//(event.type == MouseEvent.DOUBLE_CLICK) ? 1 : -1;
		processInteraction(newIndex, direction);
	}
	
	public function updateLocalization():void
	{
		trace("lastSelectedLeftIndex: " + lastSelectedLeftIndex + " - " + lastSelectedRightIndex);
		var otherRenderer:StationRendererAS = dataGroup.getElementAt(lastSelectedLeftIndex) as StationRendererAS;
		if (otherRenderer)
		{
			otherRenderer.showTimes = otherRenderer.showTimes;
		}
		otherRenderer = dataGroup.getElementAt(lastSelectedRightIndex) as StationRendererAS;
		if (otherRenderer)
		{
			otherRenderer.showTimes = otherRenderer.showTimes;
		}
	}
	
	/**
	 * 	Set a station
	 */
	public function setStation(stopID:int, direction:int, force:Boolean = false):void
	{
		var newIndex:int = -1;
		var stationVO:StationVO;

		var len:int = dataGroup.numElements-1;
		var element:StationRendererAS;
		
		for (var i:int = 1; i < len; i++) 
		{
			element = dataGroup.getElementAt(i) as StationRendererAS;
			stationVO = element.data as StationVO;
			if (stationVO && stationVO.stopID == stopID)
			{
				newIndex = i;
				break;
			}
		}
		//trace("sS: " + stopID + " dd: " + newIndex + " - " + lastSelectedLeftIndex);
		if (newIndex > -1 && (newIndex != lastSelectedLeftIndex || force))
			processInteraction(newIndex, direction);
	}
	
	private function processInteraction(newIndex:int, direction:int):void
	{
		if (direction == 0)
			return;
		
		var renderer:StationRendererAS;
		renderer = dataGroup.getElementAt(newIndex) as StationRendererAS;
		if (!renderer)
			return;
		
		var swapIndex:int = (direction < 0) ? lastSelectedLeftIndex : lastSelectedRightIndex;
		var otherIndex:int = (direction >= 0) ? lastSelectedLeftIndex : lastSelectedRightIndex;
		if (direction < 0)
		{
			lastSelectedLeftIndex = newIndex;
		}
		else
		{			
			lastSelectedRightIndex = newIndex;
		}
		
		var startHeight:Number = renderer.height;
		//trace("selection: " + newIndex + " - " + swapIndex);
		if (swapIndex > -1 && swapIndex != newIndex)
		{
			//trace("11renderer.selected: " + renderer.selected);
			renderer = dataGroup.getElementAt(swapIndex) as StationRendererAS;
			if (renderer)
				renderer.selected = false;
		}
		renderer = dataGroup.getElementAt(newIndex) as StationRendererAS;
		var otherIndexSelected:Boolean = false;
		if (renderer)
		{
			//trace("22renderer.selected: " + renderer.selected + " - " + swapIndex + " - " + otherIndex + " - " + newIndex + " l: " + renderer.direction + "/" + direction);
			otherIndexSelected = (renderer.selected && otherIndex == newIndex);
			var isDifferentDirections:Boolean = ((renderer.direction >= 0) && (direction < 0)) || ((renderer.direction < 0) && (direction >= 0));
			renderer.direction = direction;
			renderer.selected = (swapIndex != newIndex || (otherIndexSelected && isDifferentDirections)) ? true : !renderer.selected;
		}
		

		
		if (newIndex == 1)
		{
			padElement1.height = scaleStartingPosition - (renderer.height - singleHeight)/2;
			padElement2.height = scaleStartingPosition;
		}
		else if (newIndex == dataGroup.numElements-2)
		{
			padElement2.height = scaleStartingPosition - (renderer.height - singleHeight)/2;
			padElement1.height = scaleStartingPosition;
		}
		else
		{
			padElement1.height = scaleStartingPosition;
			padElement2.height = scaleStartingPosition;
		}
		//trace("otherIndex: " + otherIndex + " - " + newIndex);
		if (otherIndex == newIndex)
		{
			if (direction >= 0)
			{
				lastSelectedLeftIndex = -1;
			}
			else
			{			
				lastSelectedRightIndex = -1;
			}
			dispatchEvent(new StationSelectEvent(null, -direction));
		}
		if (renderer.selected)
		{
			dispatchEvent(new StationSelectEvent(dataGroup.dataProvider.getItemAt(newIndex) as StationVO, direction));
		}
		else
		{
			//verticalScrollPositionHandler((dataGroup.verticalScrollPosition+(startHeight-renderer.height)) as Object);
			dispatchEvent(new StationSelectEvent(null, direction));
		}
		
		// Remove Quick Times from Renderers when second is called
		var otherRenderer:StationRendererAS = dataGroup.getElementAt(newIndex) as StationRendererAS;
		if (direction < 0 && otherRenderer)
		{
			otherRenderer.showTimes = !(FlexGlobals.topLevelApplication as CaltrainTimes).hasBothStations && renderer.selected;
			otherRenderer = dataGroup.getElementAt(swapIndex) as StationRendererAS;
			if (otherRenderer)
				otherRenderer.showTimes = false;
		}
		else
		{
			otherRenderer = dataGroup.getElementAt(otherIndex) as StationRendererAS;
			if (otherRenderer)
				otherRenderer.showTimes = !(FlexGlobals.topLevelApplication as CaltrainTimes).hasBothStations && otherRenderer.selected && !(otherIndex == newIndex);
		}
	}
	
}
}