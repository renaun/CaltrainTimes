package com.renaun.caltrain.renderers
{
	
	import spark.components.LabelItemRenderer;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class AlertListItemRenderer extends LabelItemRenderer
	{
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			super.createChildren();
			// create any additional children for your item renderer here
			this.labelDisplay.multiline = true;
			this.labelDisplay.wordWrap = true;
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
			if (!labelDisplay)
				return;
			
			var paddingLeft:Number   = getStyle("paddingLeft"); 
			var paddingRight:Number  = getStyle("paddingRight");
			var paddingTop:Number    = getStyle("paddingTop");
			var paddingBottom:Number = 0;//getStyle("paddingBottom")/2;
			var verticalAlign:String = getStyle("verticalAlign");
			
			var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
			
			var vAlign:Number;
			if (verticalAlign == "top")
				vAlign = 0;
			else if (verticalAlign == "bottom")
				vAlign = 1;
			else // if (verticalAlign == "middle")
				vAlign = 0.5;
			
			// measure the label component
			// text should take up the rest of the space width-wise, but only let it take up
			// its measured textHeight so we can position it later based on verticalAlign
			var labelWidth:Number = Math.max(viewWidth, 0); 
			var labelHeight:Number = 0;
			
			if (label != "")
			{
				labelDisplay.commitStyles();
				
				// reset text if it was truncated before.
				if (labelDisplay.isTruncated)
					labelDisplay.text = label;
				
				labelHeight = getElementPreferredHeight(labelDisplay);
			}
			
			setElementSize(labelDisplay, labelWidth, labelHeight);    
			
			// We want to center using the "real" ascent
			var labelY:Number = Math.round(vAlign * (viewHeight - labelHeight))  + paddingTop;
			setElementPosition(labelDisplay, paddingLeft, labelY);
			
		}
		
	}
}