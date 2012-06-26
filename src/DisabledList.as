package 
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.events.ScrollEventDirection;
	
	public class DisabledList extends List
	{
		// disable all mouse events on disabled items
		override protected function mouseOverHandler(event:MouseEvent):void
		{
			var item:IListItemRenderer = mouseEventToItemRenderer(event);
			if (mouseItemDisabled(event)) {
			} else {
				super.mouseOverHandler(event);
			}
		}
		    
		override protected function mouseDownHandler(event:MouseEvent):void {
			if (mouseItemDisabled(event)) {
				return;
			} else {
				super.mouseDownHandler(event);
			}              
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			if (mouseItemDisabled(event)) {
				return;
			} else {
				super.mouseUpHandler(event);
			}        
		}

		override protected function mouseClickHandler(event:MouseEvent):void {
			if (mouseItemDisabled(event)) {
				return;
			} else {
				super.mouseClickHandler(event);
			}
		}
		
		override protected function mouseDoubleClickHandler(event:MouseEvent):void {
			if (mouseItemDisabled(event)) {
				event.preventDefault();
			} else {
				super.mouseDoubleClickHandler(event);
			}
		}
		
		private function mouseItemDisabled(event:MouseEvent):Boolean {
			var item:IListItemRenderer = mouseEventToItemRenderer(event);
			if(itemDisabled(item))
			{
				return true;
			}else{
				return false;
			}
		}

		protected function rowItemDisabled(index:int):Boolean
		{
			var rowItems:Array = listItems[index] as Array;
			var item:IListItemRenderer = rowItems[0]; 
			if(itemDisabled(item))
			{
				return true;
			}
			return false;
		}
		
		private function itemDisabled(item:IListItemRenderer):Boolean
		{
			if (item != null && item.data != null && 
				((item.data is XML && item.data.@enabled == 'false') || item.data.enabled === false || item.data.enabled == 'false'))
			{
				return true;
			}
			return false;
		}
		
		// adjust keyboard behaviour to prevent selecting disabled items
		override protected function moveSelectionVertically(code:uint, shiftKey:Boolean,
												   ctrlKey:Boolean):void
		{
			
			var rowCount:int = listItems.length;
			var onscreenRowCount:int = listItems.length - offscreenExtraRowsTop - offscreenExtraRowsBottom;
			var partialRow:int = (rowInfo[rowCount - offscreenExtraRowsBottom - 1].y + 
				rowInfo[rowCount - offscreenExtraRowsBottom - 1].height >
				listContent.heightExcludingOffsets - listContent.topOffset) ? 1 : 0;
			
			var newIndex:int = caretIndex;
				
			switch (code)
			{
				case Keyboard.UP:
				{
					// check if there is any enabled element above selected element
					for(var i:int=caretIndex-1; i >= 0; i--)
					{
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					break;
				}

				case Keyboard.DOWN:
				{
					for(var i:int=caretIndex+1; i < rowCount; i++)
					{
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					break;
				}
					
				case Keyboard.PAGE_UP:
				{
					var expectedNewIndex:int;
					if (caretIndex > verticalScrollPosition &&
						caretIndex < verticalScrollPosition + onscreenRowCount)
					{
						expectedNewIndex = verticalScrollPosition;
					}
					else
					{
						// paging up is really hard because we don't know how many
						// rows to move because of variable row height.  We would have
						// to double-buffer a previous screen in order to get this exact
						// so we just guess for now based on current rowCount
						expectedNewIndex = Math.max(caretIndex - Math.max(onscreenRowCount - partialRow, 1), 0);
					}
					// check if this row is enabled. if not, try next row below that until it reaches the current row
					for(var i:int=expectedNewIndex; i < caretIndex; i++){
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					// if there is no enabled below the expected index
					if(newIndex == caretIndex)
					{
						// try to see if there is any enabled row above that
						for(var i:int=expectedNewIndex-1; i >= 0; i--)
						{
							if(!rowItemDisabled(i))
							{
								newIndex = i;
								break;
							}
						}
					}
					
					break;
				}
					
				case Keyboard.PAGE_DOWN:
				{
					var expectedNewIndex:int;
					
					// if the caret is on-screen, but not at the bottom row
					// just move the caret to the bottom row (not partial row)
					if (caretIndex >= verticalScrollPosition &&
						caretIndex < verticalScrollPosition + onscreenRowCount - partialRow - 1)
					{
						expectedNewIndex = verticalScrollPosition + onscreenRowCount - partialRow - 1;
					}
					
					// move up it the expected row is disabled
					for(var i:int=expectedNewIndex; i > caretIndex; i--){
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					
					// move down if there is still no enabled row
					if(newIndex == caretIndex)
					{
						for(var i:int=expectedNewIndex+1; i < rowCount; i++)
						{
							if(!rowItemDisabled(i))
							{
								newIndex = i;
								break;
							}
						}
					}
					
					break;
				}
					
				case Keyboard.HOME:
				{
					for(var i:int=0; i < caretIndex; i++){
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					break;
				}
					
				case Keyboard.END:
				{
					for(var i:int=collection.length - 1; i > caretIndex; i--)
					{
						if(!rowItemDisabled(i))
						{
							newIndex = i;
							break;
						}
					}
					break;
				}
			}
			
			// now move it
			if(newIndex > caretIndex)
			{
				var distance:int = newIndex-caretIndex;
				for(var i:int=0; i<distance; i++)
				{
					super.moveSelectionVertically(Keyboard.DOWN, shiftKey, ctrlKey);
				}
			}else
			{
				var distance:int = caretIndex-newIndex;
				for(var i:int=0; i<distance; i++)
				{
					super.moveSelectionVertically(Keyboard.UP, shiftKey, ctrlKey);
				}
			}
			
		}
		
		// disable finding an item in the list based on a String
		override public function findString(str:String):Boolean
		{
			return false;
		}
		
	}
}