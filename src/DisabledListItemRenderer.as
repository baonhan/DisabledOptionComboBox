package  {
	import mx.controls.Alert;
	import mx.controls.listClasses.ListItemRenderer;
	
	public class DisabledListItemRenderer extends ListItemRenderer {
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if ((data.enabled != null) && (data.enabled == false)) {
				enabled = false;
				setStyle('disabledColor', '0x888888');
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}
