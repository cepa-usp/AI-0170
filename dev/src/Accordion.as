package  
{
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
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
		
		public function Accordion() 
		{
			
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
			
			addChild(aba);
		}
		
		private function openCloseAba(e:MouseEvent):void 
		{
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