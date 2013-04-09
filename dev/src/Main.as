package 
{
	import cepa.graph.GraphFunction;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite 
	{
		private var grafico:Graph_model;
		private var primitiveConstant:Number = 0;
		private var fileHandler:FileHandler;
		private var functions:Array = [];
		private var indexFunctions:int;
		
		public function Main():void 
		{
			var f:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2) -4 } );
			var F:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/3*Math.pow(x, 3)-4*x + primitiveConstant} );
			
			indexFunctions = 0;
			functions.push([f, F]);
			
			grafico = new Graph_model(functions[indexFunctions][0], functions[indexFunctions][1]);
			
			addChild(grafico);
			grafico.x = 60;
			
			fileHandler = new FileHandler("ai170");
			
			addListeners();
			
			testando();
		}
		
		private function addListeners():void 
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
		}
		
		private function keyboardHandler(e:KeyboardEvent):void 
		{
			switch (e.keyCode) {
				case Keyboard.S:
					//Salvar
					
					var state:Object = new Object();
					//state.gs = JSON.stringify(grafico.getState());
					state.gs = grafico.getState();
					state.pc = primitiveConstant;
					state.f = indexFunctions;
					
					var stringState:String = JSON.stringify(state);
					fileHandler.salvar(stringState);
					break;
				case Keyboard.R:
					//Recuperar
					fileHandler.abrir(loadComplete);
					break;
				case Keyboard.P:
					//Adiciona um ponto
					grafico.addPoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.M:
					//Adiciona uma altura
					grafico.addPointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.O:
					grafico.removePoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.N:
					grafico.removePointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				
				
			}
		}
		
		private function loadComplete(content:String):void {
			var state:Object = JSON.parse(content);
			trace(state);
			
			removeChild(grafico);
			
			primitiveConstant = state.pc;
			indexFunctions = state.f;
			grafico = new Graph_model(functions[indexFunctions][0], functions[indexFunctions][1]);
			
			grafico.restoreState(state.gs);
			
			grafico.x = 60;
			addChild(grafico);
		}
		
		private function testando():void
		{
			//grafico.addPoint( 9);
			//grafico.addPoint( -8);
			
			//grafico.addPoint( -5);
			//grafico.addPoint( 1);
			//grafico.addPoint( 5);
			//grafico.addPoint( -3);
			
			//grafico.addPointM( -7);
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
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.addEventListener(Event.RESIZE, resizeAll);
		}
		
		private function resizeAll(e:Event):void 
		{
			//trace("resize");
			//trace(stage.stageWidth, stage.stageHeight);
			grafico.graphSize = new Point(stage.stageWidth - 60, stage.stageHeight);
		}
		
		private function wheelHandler(e:MouseEvent):void 
		{
			if (e.delta > 0) {
				//Zoom in
				//grafico.zoomInPtPixel(new Point(grafico.mouseX, grafico.mouseY));
				grafico.zoomInCenter();
			}else {
				//Zoon out
				//grafico.zoomOutPtPixel(new Point(grafico.mouseX, grafico.mouseY));
				grafico.zoomOutCenter();
			}
		}
		
		private var posClick:Point = new Point();
		private function stageDown(e:MouseEvent):void 
		{
			var objClicked:Object = grafico.searchElement(new Point(grafico.mouseX, grafico.mouseY));
			
			switch (objClicked.type) {
				case Graph_model.TYPE_PRIMITIVE_C:
					posClick.y = stage.mouseY;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
					stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
					break;
				case Graph_model.TYPE_NONE:
					posClick.x = stage.mouseX;
					posClick.y = stage.mouseY;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
					stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
					break;
				case Graph_model.TYPE_DIVISOR:
					if (objClicked.label != null) {
						if (!grafico.lockAB) {
							stage.addEventListener(MouseEvent.MOUSE_MOVE, movingAB);
							stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingAB);
						}
					}
					break;
			}
		}
		
		private function movingAB(e:MouseEvent):void 
		{
			grafico.setValueToSelected(grafico.mouseX);
		}
		
		private function stopMovingAB(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingAB);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingAB);
		}
		
		private function panning(e:MouseEvent):void 
		{
			var displace:Point = new Point(stage.mouseX - posClick.x, stage.mouseY - posClick.y);
			posClick.x = stage.mouseX;
			posClick.y = stage.mouseY;
			grafico.panPixel(displace);
		}
		
		private function stopPanning(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPanning);
		}
		
		private function movingPrimitive(e:MouseEvent):void 
		{
			var diff:Number = stage.mouseY - posClick.y;
			posClick.y = stage.mouseY;
			primitiveConstant += grafico.getDistanceFromOrigin(diff).y;
			grafico.update();
		}
		
		private function stopMovingPrimitive(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
		}
		
	}
	
}