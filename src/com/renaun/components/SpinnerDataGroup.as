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
	
	public var growHeight:Number = 158;
	protected var scaleStartingPosition:Number = 0;
	
	private var lastHeight:Number;
	protected var singleHeight:Number = 0;
	
	protected var lastSelectedLeftIndex:int = -1;
	protected var lastSelectedRightIndex:int = -1;
	protected var mouseDownStartX:Number = -1;
	protected var mouseDownStartY:Number = 0;
	
	protected var padElement1:UIComponent = new UIComponent();
	protected var padElement2:UIComponent = new UIComponent();
	
	protected var timer:Timer;
	protected var lastUnscaledWidth:Number = 0;
	protected var lastUnscaledHeight:Number = 0;
	
	
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
		//trace("uDL: " + unscaledWidth + " - " + unscaledHeight);
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		lastUnscaledWidth = unscaledWidth;
		lastUnscaledHeight = unscaledHeight;
		
		//dataGroup.visible = false;
	/*	if (!timer)
		{
			timer = new Timer(100, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, updateDisplayListDelayed);
		}
		timer.reset();
		timer.start();*/
		//dataGroup.visible = true;
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
		//trace("uDL2: " + lastUnscaledWidth + " - " + lastUnscaledHeight);
		
		//dataGroup.visible = true;
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
		
		//BindingUtils.bindSetter(verticalScrollPositionHandler, dataGroup, "verticalScrollPosition", true, true);
	}
	
	/*protected function verticalScrollPositionHandler(value:Object):void
	{
		//scaleStartingPosition * 2;
		if (dataGroup.numElements < 3)
			return;
		var v:Number = Number(value);
		
		var x:int = 0;
		var xabs:int = 0;
		var curY:Number = 0;
		var len:int = dataGroup.numElements-1;
		var scale:Boolean = false;
		var element:ItemRenderer;
		var delta:int = singleHeight/3;

		// TODO Handle Shrinking the first/last for the special case
		
		for (var i:int = 1; i < len; i++) 
		{
			element = dataGroup.getElementAt(i) as ItemRenderer;
			curY = element.y - v;
			x =  curY - scaleStartingPosition;
			xabs = (x ^ (x >> 31)) - (x >> 31);
			scale = (xabs > delta) ? true : false;
			(element as StationRendererAS).highlight = !scale;
			//element.height = singleHeight * scale;
			if (i == 1)
				padElement1.height = scaleStartingPosition - (element.height - singleHeight)/2;
			else if (i == len-1)
				padElement2.height = scaleStartingPosition - (element.height - singleHeight)/2;
		}
		
		
		//trace("v: " + value + " - " + dataGroup.height + " - " + dataGroup.contentHeight);
	}*/
	
	/**
	 *  @private
	 */
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);
		
		if (instance == dataGroup)
		{		
			
			
			// SWIPE this.addEventListener(TransformGestureEvent.GESTURE_SWIPE, gestureHandler);
		
			dataGroup.addEventListener(
				RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
//			dataGroup.addEventListener(
//				RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);

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
		//if (renderer is StationRendererAS)
		//	(renderer as StationRendererAS).addEventListener(TransformGestureEvent.GESTURE_SWIPE, gestureHandler);
		//renderer.addEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
		//renderer.addEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
	}
	
	/**
	 *  @private
	 *  Called when an item has been removed from this component.
	 */
	protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
	{		
		var renderer:Object = event.renderer;
		
		if (!renderer)
			return;
		
		//if (renderer is StationRendererAS)
		//	(renderer as StationRendererAS).removeEventListener(TransformGestureEvent.GESTURE_SWIPE, gestureHandler);
		//renderer.removeEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
		//renderer.removeEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
	}

	protected function item_mouseDownHandler(event:MouseEvent):void
	{
		// someone else handled it already since this is cancellable thanks to 
		// some extra code in SystemManager that redispatches a cancellable version 
		// of the same event
		if (event.isDefaultPrevented())
			return;
		// Move the rest of the way
		
		//removeEventListener(Event.ENTER_FRAME, moveSelectedHandler);
		mouseDownStartX = event.stageX;
		mouseDownStartY = event.stageY;
	}
	
	/**
	 *  @private
	 *  @param event The MouseEvent object.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function item_mouseUpHandler(event:MouseEvent):void
	{
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
	
	protected function gestureHandler(event:TransformGestureEvent):void
	{
		//trace("GESTURE: " + event.currentTarget + " - " + event.target + " - " + event.offsetX);
		//trace(event.localX + "/" + event.localY); 
		//return;
		// someone else handled it already since this is cancellable thanks to 
		// some extra code in SystemManager that redispatches a cancellable version 
		// of the same event
		if (event.isDefaultPrevented() || (event.type != TransformGestureEvent.GESTURE_SWIPE))
			return;
		// Move the rest of the way
		
		var newIndex:int = ((event.localY - dataGroup.getElementAt(0).height)/100)+1;
		// Handle selection
		//var newIndex:int
		
		//if (event.currentTarget is IItemRenderer)
		//	newIndex = IItemRenderer(event.currentTarget).itemIndex;
		//else
		//	newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
		
		// Not same item
		/*
		var test:int = (mouseDownStartY - event.stageY);
		if (test > (event.currentTarget as IVisualElement).height || test < -(event.currentTarget as IVisualElement).height)
			return;
		*/
		
		var direction:int = event.offsetX;//(event.stageX - mouseDownStartX);
		processInteraction(newIndex, direction);
	}
	public function setStation(stopID:int, direction:int):void
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
		if (newIndex > -1)
			processInteraction(newIndex, direction);
	}
	
	private function processInteraction(newIndex:int, direction:int):void
	{
		// Might not want to use stageWidth???
		//if (direction < stage.stageWidth/4 && direction > -stage.stageWidth/4)
		if (direction == 0)
			return;
		mouseDownStartX = -1;
		
		var renderer:StationRendererAS;
		renderer = dataGroup.getElementAt(newIndex) as StationRendererAS;
		if (!renderer)
			return;
//		var v:Number = dataGroup.verticalScrollPosition;
//		var x:int = 0;
//		var xabs:int = 0;
//		var curY:Number = 0;
//		var len:int = dataGroup.numElements-1;
//		var isSelectable:Boolean = false;
//		var delta:int = singleHeight/2;
//		
//		curY = renderer.y - v;
//		x =  curY - scaleStartingPosition;
//		xabs = (x ^ (x >> 31)) - (x >> 31);
//		isSelectable = (xabs > delta) ? false : true;
//		
//		trace("v: " + v + " - " + xabs + " - " + delta);
//		if (!isSelectable)
//			return;
		
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
			// Stop the throw effect in scroller
			//scroller.mx_internal::adjustScrollPositionAfterSoftKeyboardDeactivate();
			//moveRenderer = renderer;
			
			//startPosition = (unscaledHeight-moveRenderer.height) / 2;
			//movePadding = (moveRenderer.y-dataGroup.verticalScrollPosition > startPosition) ? -2 : 4;
			//addEventListener(Event.ENTER_FRAME, moveSelectedHandler);
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
	/*
	private var moveRenderer:StationRendererAS;
	private var startPosition:int = 0;
	private var movePadding:int = 0;
	private function moveSelectedHandler(event:Event):void
	{		
		var delta:int = ((moveRenderer.y - dataGroup.verticalScrollPosition)-(startPosition+movePadding))/4;
		if (delta > 0 && movePadding > 0)
			delta = 0;
		else if (delta < 0 && movePadding < 0)
			delta = 0;
		
		//trace("move: " + dataGroup.verticalScrollPosition + " - " + (startPosition) + " - " + moveRenderer.y + " - " + delta);
		//trace("move2: " + (moveRenderer.y-dataGroup.verticalScrollPosition));
		dataGroup.verticalScrollPosition += delta;
		
		if (delta == 0)
		{
			moveRenderer = null;
			removeEventListener(Event.ENTER_FRAME, moveSelectedHandler);
		}
	}*/
	
}
}