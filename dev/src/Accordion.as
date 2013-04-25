package  
{
	import cepa.utils.MouseMotionData;
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Accordion extends Sprite
	{
		private var distAbas:Number = 5;
		private var distItens:Number = 5;
		
		private var abaOpen:Sprite;
		private var abas:Vector.<Sprite> = new Vector.<Sprite>();
		private var containers:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var rollBar:RollBar = new RollBar();
		
		private var layerAbas:Sprite = new Sprite();
		private var alowOpenClose:Boolean = true;
		
		private var clickPos:Point = new Point();
		private var mouseMotion:MouseMotionData = MouseMotionData.instance;
		
		public function Accordion() 
		{
			addChild(layerAbas);
		}
		
		public function addAba(mc:MovieClip, buttons:Array):void
		{
			var aba:Sprite = new Sprite();
			var maskAba:Sprite = new Sprite();
			maskAba.name = "mask";
			maskAba.graphics.beginFill(0xFF0000);
			maskAba.graphics.drawRect(0, 0, mc.width, mc.height);
			maskAba.graphics.endFill();
			aba.addChild(maskAba);
			aba.mask = maskAba;
			
			mc.mouseChildren = false;
			mc.buttonMode = true;
			if (mc.getChildByName("openClose") != null) {
				mc.openClose.gotoAndStop("OPEN");
			}
			mc.name = "aba";
			aba.addChild(mc);
			
			var container:Sprite = new Sprite();
			container.name = "container";
			var posY:Number = mc.height + distItens;
			for (var i:int = 0; i < buttons.length; i++) 
			{
				buttons[i].y = posY;
				buttons[i].gotoAndStop(1);
				container.addChild(buttons[i]);
				posY += buttons[i].height + distItens;
			}
			//container.y = -container.height + mc.height;
			aba.addChild(container);
			aba.setChildIndex(container, 0);
			mc.addEventListener(MouseEvent.CLICK, openCloseAba);
			
			posY = 0;
			for (i = 0; i < abas.length; i++) 
			{
				posY += abas[i].getChildByName("aba").height + distAbas;
				//posY += abas[i].height + distAbas;
			}
			aba.y = posY;
			abas.push(aba);
			
			layerAbas.addChild(aba);
			
			verifyForRollBar();
		}
		
		private function verifyForRollBar():void
		{
			var lastAba:Sprite = abas[abas.length - 1];
			var mask:Sprite = Sprite(lastAba.getChildByName("mask"));
			var altura:Number = lastAba.y + mask.height + distAbas;
			
			if (altura > 480) {
				addRollBar();
			}else {
				removeRollBar();
			}
		}
		
		private function addRollBar():void 
		{
			if (!this.contains(rollBar)) {
				rollBar.x = layerAbas.width + 10;
				rollBar.y = rollBar.height / 2;
				
				this.addEventListener(MouseEvent.MOUSE_DOWN, initScroll);
				if (stage) stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelScroll);
				else addEventListener(Event.ADDED_TO_STAGE, addWheelHandler);
				
				addChild(rollBar);
			}
		}
		
		private function removeRollBar():void
		{
			if (this.contains(rollBar)) {
				removeChild(rollBar);
			}
			layerAbas.y = 0;
			this.removeEventListener(MouseEvent.MOUSE_DOWN, initScroll);
			if(stage) stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelScroll);
		}
		
		private function addWheelHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addWheelHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelScroll);
		}
		
		private function wheelScroll(e:MouseEvent):void 
		{
			var dY:Number = (e.delta > 0 ? -1 : 1) * 15;
			rollBar.y = Math.max(rollBar.height / 2, Math.min(480 - rollBar.height / 2, rollBar.y + dY));
			layerAbas.y = getYposition(rollBar.y);
		}
		
		
		private function initScroll(e:MouseEvent):void 
		{
			if(e.target == rollBar){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, scrollingBar);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopScrollBar);
			}else {
				clickPos.x = this.mouseX;
				clickPos.y = this.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, scrolling);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			}
		}
		
		private function scrolling(e:MouseEvent):void 
		{
			if (Point.distance(clickPos, new Point(this.mouseX, this.mouseY)) >= 1) alowOpenClose = false;
			
			var lastAba:Sprite = abas[abas.length - 1];
			var mask:Sprite = Sprite(lastAba.getChildByName("mask"));
			var yMin:Number = 480 - (lastAba.y + mask.height + distAbas);
			
			layerAbas.y = Math.max(yMin, Math.min(0, layerAbas.y + this.mouseY - clickPos.y));
			rollBar.y = getYposition(layerAbas.y, false);
			
			clickPos.x = this.mouseX;
			clickPos.y = this.mouseY;
		}
		
		private function stopScroll(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrolling);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			setTimeout(alowOC, 10);
		}
		
		private function alowOC():void
		{
			alowOpenClose = true;
		}
		
		private function scrollingBar(e:MouseEvent):void 
		{
			rollBar.y = Math.max(rollBar.height / 2, Math.min(480 - rollBar.height / 2, this.mouseY));
			layerAbas.y = getYposition(rollBar.y);
		}
		
		private function getYposition(posY:Number, rollingBar:Boolean = true):Number 
		{
			var x0:Number = rollBar.height / 2;
			var x1:Number = 480 - rollBar.height / 2;
			var y0:Number = 0;
			
			var lastAba:Sprite = abas[abas.length - 1];
			var mask:Sprite = Sprite(lastAba.getChildByName("mask"));
			var y1:Number = 480 - (lastAba.y + mask.height + distAbas);
			
			var newY:Number;
			if(rollingBar){
				newY = y0 + (y1 - y0) / (x1 - x0) * (posY - x0);
			}else {
				newY = x0 + (x1 - x0) / (y1 - y0) * (posY - y0); 
			}
			return newY;
		}
		
		private function stopScrollBar(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrollingBar);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScrollBar);
		}
		
		private function openCloseAba(e:MouseEvent):void 
		{
			if (this.contains(rollBar)) {
				if (!alowOpenClose) return;
			}
			
			var abaClicked:Sprite = Sprite(e.target.parent);
			if (abaOpen == null) {
				openAba(abaClicked);
			}else {
				if (abaOpen == abaClicked) {
					closeAba(abaClicked, true);
				}else {
					closeAba(abaOpen);
					openAba(abaClicked);
				}
			}
			dispatchEvent(new Event("accordionClick", true));
		}
		
		private function openAba(aba:Sprite):void
		{
			abaOpen = aba;
			MovieClip(MovieClip(aba.getChildByName("aba")).getChildByName("openClose")).gotoAndStop("CLOSE");
			var container:Sprite = Sprite(aba.getChildByName("container"));
			var mask:Sprite = Sprite(aba.getChildByName("mask"));
			//Actuate.tween(container, 0.5, { y: 0 } );
			Actuate.tween(mask, 0.5, { height: container.height + aba.getChildByName("aba").height } ).onUpdate(updateAccordion).onComplete(finishActuate);
		}
		
		private function closeAba(aba:Sprite, same:Boolean = false):void
		{
			MovieClip(MovieClip(aba.getChildByName("aba")).getChildByName("openClose")).gotoAndStop("OPEN");
			var container:Sprite = Sprite(aba.getChildByName("container"));
			var mask:Sprite = Sprite(aba.getChildByName("mask"));
			//Actuate.tween(container, 0.5, { y: -container.height + aba.getChildByName("aba").height} );
			Actuate.tween(mask, 0.5, { height: aba.getChildByName("aba").height } ).onUpdate(updateAccordion).onComplete(finishActuate, same);
		}
		
		private function updateAccordion():void 
		{
			var mask:Sprite;
			for (var i:int = 1; i < abas.length; i++) 
			{
				mask = Sprite(abas[i-1].getChildByName("mask"));
				abas[i].y = abas[i-1].y + mask.height + distAbas;
			}
			verifyForRollBar();
			if(this.contains(rollBar)) layerAbas.y = getYposition(rollBar.y);
		}
		
		private function finishActuate(closing:Boolean = false):void 
		{
			if (closing) {
				abaOpen = null;
			}
		}
		
		public function close():void
		{
			if (abaOpen != null) {
				closeAba(abaOpen, true);
			}
		}
		
		public function open(abaNumber:int):void
		{
			if (abaNumber >= 0 && abaNumber < abas.length) {
				openAba(abas[abaNumber]);
			}
		}
		
	}

}