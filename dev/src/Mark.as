package  
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Mark extends Sprite 
	{
		private var lenX:Number = 5;
		private var lenY:Number = 5;
		
		public function Mark() 
		{
			this.graphics.lineStyle(2, 0x808000);
			this.graphics.moveTo( -lenX, -lenY);
			this.graphics.lineTo(lenX, lenY);
			this.graphics.moveTo( -lenX, lenY);
			this.graphics.lineTo(lenX, -lenY);
		}
		
	}

}