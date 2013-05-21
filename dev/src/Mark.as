package  
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Mark extends Sprite 
	{
		private var lenX:Number = 5;
		private var lenY:Number = 5;
		private var pos:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat("arial", 12, 0x000000);
		
		public function Mark() 
		{
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.moveTo( -lenX, -lenY);
			this.graphics.lineTo(lenX, lenY);
			this.graphics.moveTo( -lenX, lenY);
			this.graphics.lineTo(lenX, -lenY);
			
			pos.defaultTextFormat = textFormat;
			pos.height = 10;
			pos.height = 10;
			pos.autoSize = TextFieldAutoSize.CENTER;
			pos.selectable = false;
			pos.y = 8;
			addChild(pos);
		}
		
		public function setPosition(pt:Point):void
		{
			pos.text = "(" + pt.x.toFixed(2) + ", " + pt.y.toFixed(2) + ")";
			pos.x = -pos.width / 2;
		}
		
	}

}