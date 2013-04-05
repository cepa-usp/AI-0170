package 
{
	import cepa.graph.GraphFunction;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite 
	{
		private var grafico:Graph_model;
		private var primitiveConstant:Number = 0;
		
		public function Main():void 
		{
			var f:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x } );
			var F:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.cos(x) + 5 + primitiveConstant } );
			
			grafico = new Graph_model(f, F, primitiveConstant);
			
			addChild(grafico);
			grafico.x = 60;
			
			testando();
		}
		
		private function testando():void
		{
			grafico.addPoint( 9);
			grafico.addPoint( -8);
			
			grafico.addPoint( -5);
			//grafico.addPoint( 1);
			grafico.addPoint( 5);
			grafico.addPoint( -3);
			
			grafico.addPointM( -7);
			//grafico.addPointM( -4);
			//grafico.addPointM( -1);
			//grafico.addPointM( 3);
			//grafico.addPointM( 8);
			//
			//grafico.select("rectangle", 2, NaN);
			//grafico.select("divisor", 2, NaN);
			//grafico.select("altura", 2, NaN);
			
			//grafico.searchElement(new Point(115, 115), 20);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
		}
		
		private var posYclick:Number;
		private function stageDown(e:MouseEvent):void 
		{
			var objClicked:Object = grafico.searchElement(new Point(grafico.mouseX, grafico.mouseY));
			if (objClicked.type == Graph_model.TYPE_PRIMITIVE_C) {
				posYclick = stage.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
			}
		}
		
		private function movingPrimitive(e:MouseEvent):void 
		{
			var diff:Number = stage.mouseY - posYclick;
			posYclick = stage.mouseY;
			primitiveConstant += grafico.getDifference(diff);
			grafico.update();
		}
		
		private function stopMovingPrimitive(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
		}
		
	}
	
}