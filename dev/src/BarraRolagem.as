package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class BarraRolagem extends Sprite
	{
		private var content:MovieClip;
		private var maskContent:Sprite;
		private var widthContent:Number;
		private var maxHeight:Number;
		private var rollBar:Sprite
		
		public function BarraRolagem(content:MovieClip, maxHeight:Number, rollBarSpr:Sprite) 
		{
			this.content = content;
			this.content.x = 0;
			this.content.y = 0;
			this.maxHeight = maxHeight;
			this.rollBar = rollBarSpr;
			this.widthContent = content.width;
			
			if (stage) makeRollBar();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			makeRollBar();
		}
		
		private function makeRollBar():void 
		{
			maskContent = new Sprite();
			maskContent.graphics.beginFill(0xFF8080, 1);
			maskContent.graphics.drawRect(0, 0, widthContent, maxHeight);
			maskContent.graphics.endFill();
			
			addChild(maskContent);
			content.mask = maskContent;
			
			addChild(content);
			
			if (content.height > maxHeight) {
				rollBar.x = widthContent + 15;
				rollBar.y = rollBar.height / 2;
				rollBar.buttonMode = true;
				addChild(rollBar);
				rollBar.addEventListener(MouseEvent.MOUSE_DOWN, initScroll, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelScroll, false, 0, true);
			}
		}
		
		private function wheelScroll(e:MouseEvent):void 
		{
			var dY:Number = (e.delta > 0 ? -1 : 1) * 15;
			rollBar.y = Math.max(rollBar.height / 2, Math.min(maxHeight - rollBar.height / 2, rollBar.y + dY));
			content.y = getYposition(rollBar.y);
		}
		
		private var rollCkickY:Number;
		private function initScroll(e:MouseEvent):void 
		{
			e.stopImmediatePropagation();
			rollCkickY = rollBar.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scrollingBar, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScrollBar, false, 0, true);
			
			//if(e.target == rollBar){
				//stage.addEventListener(MouseEvent.MOUSE_MOVE, scrollingBar, false, 0, true);
				//stage.addEventListener(MouseEvent.MOUSE_UP, stopScrollBar, false, 0, true);
			//}else {
				//clickPos.x = this.mouseX;
				//clickPos.y = this.mouseY;
				//stage.addEventListener(MouseEvent.MOUSE_MOVE, scrolling);
				//stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			//}
		}
		
		private function scrollingBar(e:MouseEvent):void 
		{
			rollBar.y = Math.max(rollBar.height / 2, Math.min(maxHeight - rollBar.height / 2, this.mouseY - rollCkickY));
			content.y = getYposition(rollBar.y);
			
			//clickPos.x = this.mouseX;
			//clickPos.y = this.mouseY;
		}
		
		private function stopScrollBar(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrollingBar);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScrollBar);
		}
		
		private function getYposition(posY:Number, rollingBar:Boolean = true):Number 
		{
			var x0:Number = rollBar.height / 2;
			var x1:Number = maxHeight - rollBar.height / 2;
			var y0:Number = 0;
			var y1:Number = -content.height + maxHeight;
			
			var newY:Number;
			if(rollingBar){
				newY = y0 + (y1 - y0) / (x1 - x0) * (posY - x0);
			}else {
				newY = x0 + (x1 - x0) / (y1 - y0) * (posY - y0); 
			}
			return newY;
		}
		
	}

}