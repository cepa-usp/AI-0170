package 
{
	import cepa.graph.GraphFunction;
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.MovieClip;
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
		private var menu:Menu;
		private var subMenu:SubMenu;
		private var primitiveConstant:Number = 0;
		private var fileHandler:FileHandler;
		private var functions:Array;
		private var indexFunction:int = -1;
		
		//Camadas:
		private var layer_graph:Sprite;
		private var layer_screen:Sprite;
		private var layer_menu:Sprite;
		private var layer_info:Sprite;
		
		//Indice telas:
		private const INICIAL:int = 0;
		private const CHOOSE_F:int = 1;
		private const CHOOSE_AB:int = 2;
		private const CHOOSE_SUM:int = 3;
		private const PARTITION:int = 4;
		private const RESULT:int = 5;
		private const FINAL:int = 6;
		
		//Telas:
		private var tela0:Tela0;
		private var tela1:Tela1;
		private var tela3:Tela3;
		private var grafico:Graph_model;
		
		//Estratégias:
		private const PERSONAL:int = 0;
		private const SUPERIOR:int = 1;
		private const INFERIOR:int = 2;
		
		private var currentScreen:int;
		private var currentStrategy:int = -1;
		private const defaultN:int = 5;
		
		public function Main():void 
		{
			
			//indexFunction = 0;
			//grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
			
			//addChild(grafico);
			//grafico.x = 60;
			
			//addListeners();
			
			//testando();
			
			
			currentScreen = INICIAL;
			
			createLayers();
			createMenu();
			createScreens();
			createFunctions();
			//createGraph();
			
			loadScreen(currentScreen);
		}
		
		/**
		 * Cria as camadas da aplicação.
		 */
		private function createLayers():void 
		{
			layer_graph = new Sprite();
			layer_info = new Sprite();
			layer_menu = new Sprite();
			layer_screen = new Sprite();
			
			addChild(layer_graph);
			addChild(layer_screen);
			addChild(layer_menu);
			addChild(layer_info);
		}
		
		/**
		 * Cria o menu.
		 */
		private function createMenu():void 
		{
			menu = new Menu();
			menu.openMenu.buttonMode = true;
			menu.next.buttonMode = true;
			menu.previous.buttonMode = true;
			menu.help.buttonMode = true;
			menu.openMenu.addEventListener(MouseEvent.CLICK, openMenuClick);
			menu.next.addEventListener(MouseEvent.CLICK, next);
			menu.previous.addEventListener(MouseEvent.CLICK, previous);
			//menu.help.addEventListener(MouseEvent.CLICK, showHelp);
			
			subMenu = new SubMenu();
			subMenu.x = -subMenu.width + 60;
			fileHandler = new FileHandler("ai170");
		}
		
		private var subMenuOpen:Boolean = false;
		private function openMenuClick(e:MouseEvent):void 
		{
			if (subMenuOpen) closeSubMenu();
			else openSubMenu();
		}
		
		private function openSubMenu():void
		{
			Actuate.tween(subMenu, 0.5, { x:60 } );
			subMenuOpen = true;
		}
		
		private function closeSubMenu():void
		{
			Actuate.tween(subMenu, 0.5, { x: -subMenu.width + 60 } );
			subMenuOpen = false;
		}
		
		/**
		 * Cria as telas que serão utilizadas.
		 */
		private function createScreens():void 
		{
			tela0 = new Tela0();
			tela0.newFile.buttonMode = true;
			tela0.openFile.buttonMode = true;
			tela0.openFile.addEventListener(MouseEvent.CLICK, openFile);
			tela0.newFile.addEventListener(MouseEvent.CLICK, createNew);
			
			tela1 = new Tela1();
			tela1.f0.mouseChildren = false;
			tela1.f0.buttonMode = true;
			tela1.f1.mouseChildren = false;
			tela1.f1.buttonMode = true;
			tela1.f2.mouseChildren = false;
			tela1.f2.buttonMode = true;
			tela1.f3.mouseChildren = false;
			tela1.f3.buttonMode = true;
			tela1.f4.mouseChildren = false;
			tela1.f4.buttonMode = true;
			tela1.addEventListener(MouseEvent.CLICK, chooseFunction);
			
			tela3 = new Tela3();
			tela3.inferior.buttonMode = true;
			tela3.superior.buttonMode = true;
			tela3.personal.buttonMode = true;
			tela3.inferior.mouseChildren = false;
			tela3.superior.mouseChildren = false;
			tela3.personal.mouseChildren = false;
			tela3.addEventListener(MouseEvent.CLICK, choseStrategy);
		}
		
		private function choseStrategy(e:MouseEvent):void 
		{
			switch(MovieClip(e.target).name) {
				case "inferior":
					currentStrategy = INFERIOR;
					break;
				case "superior":
					currentStrategy = SUPERIOR;
					break;
				case "personal":
					currentStrategy = PERSONAL;
					break;
				default:
					currentStrategy = -1;
					break;
			}
			
			if (currentStrategy >= 0) {
				next();
			}
		}
		
		/**
		 * Cria as funções que podem ser utilizadas.
		 */
		private function createFunctions():void 
		{
			var f0:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return 3 * x + 2 } );
			var F0:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 3/2 * Math.pow(x, 2) + 2 * x + primitiveConstant } );
			
			var f1:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x } );
			var F1:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1 / 2 * Math.pow(x, 2) + primitiveConstant } );
			
			var f2:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return 5 * Math.pow(x, 2) + 3 * x + 1 } );
			var F2:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 5 / 3 * Math.pow(x, 3) + 3/2 * Math.pow(x, 2) + x + primitiveConstant } );
			
			var f3:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.log(x) } );
			var F3:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return x * Math.log(x) + primitiveConstant } );
			
			var f4:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.sin(x) } );
			var F4:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.cos(x) + primitiveConstant} );
			
			functions = new Array();
			functions.push([f0, F0]);
			functions.push([f1, F1]);
			functions.push([f2, F2]);
			functions.push([f3, F3]);
			functions.push([f4, F4]);
		}
		
		/**
		 * Carrega uma tela de acordo com a indicação.
		 * @param	screen Tela a ser carregada.
		 */
		private function loadScreen(screen:int):void 
		{
			switch (screen) {
				case INICIAL:
					if (layer_menu.numChildren > 0){
						layer_menu.removeChild(subMenu);
						layer_menu.removeChild(menu);
					}
					layer_screen.addChild(tela0);
					break;
				case CHOOSE_F:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					layer_screen.addChild(tela1);
					break;
				case CHOOSE_AB:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					grafico.defineAB = true;
					grafico.x = 60;
					layer_graph.addChild(grafico);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case CHOOSE_SUM:
					layer_screen.addChild(tela3);
					break;
				case PARTITION:
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.x = 60;
					layer_graph.addChild(grafico);
					switch (currentStrategy) {
						case INFERIOR:
						case SUPERIOR:
							if (grafico.n == 1) grafico.divideIn(defaultN);
							menu.plus.addEventListener(MouseEvent.CLICK, plusHandler);
							menu.minus.addEventListener(MouseEvent.CLICK, minusHandler);
							break;
						case PERSONAL:
							
							break;
					}
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case RESULT:
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.showSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.x = 60;
					layer_graph.addChild(grafico);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case FINAL:
					
					break;
				
			}
		}
		
		private function plusHandler(e:MouseEvent):void 
		{
			switch (currentScreen) {
				case PARTITION:
					grafico.divideIn(grafico.n + 1);
					break;
			}
		}
		
		private function minusHandler(e:MouseEvent):void 
		{
			switch (currentScreen) {
				case PARTITION:
					grafico.divideIn(grafico.n - 1);
					break;
			}
		}
		
		private function chooseFunction(e:MouseEvent):void 
		{
			trace(int("a"));
			indexFunction = int(MovieClip(e.target).name.replace("f", ""));
			if (!isNaN(indexFunction)) {
				if (grafico != null) grafico = null;
				next();
			}
		}
		
		private function openFile(e:MouseEvent):void 
		{
			fileHandler.abrir(loadComplete);
		}
		
		private function createNew(e:MouseEvent):void 
		{
			next();
		}
		
		private function next(e:MouseEvent = null):void
		{
			if (!alowNext(currentScreen)) {
				//TODO: mostrar tela de erro.
				
				return;
			}
			unloadScreen(currentScreen);
			currentScreen++;
			loadScreen(currentScreen);
			menu.currentScreen.text = currentScreen.toString();
		}
		
		private function alowNext(screen:int):Boolean
		{
			switch (screen) {
				case INICIAL:
					return true;
					break;
				case CHOOSE_F:
					return (indexFunction >= 0);
					break;
				case CHOOSE_AB:
					return grafico.abDefined;
					break;
				case CHOOSE_SUM:
					return (currentStrategy >= 0);
					break;
				case PARTITION:
					
					//TODO: condição para passar.
					
					return true;
					break;
				case RESULT:
					
					break;
				case FINAL:
					
					break;
				
			}
			
			return false;
		}
		
		private function previous(e:MouseEvent = null):void
		{
			unloadScreen(currentScreen);
			currentScreen--;
			loadScreen(currentScreen);
			menu.currentScreen.text = currentScreen.toString();
		}
		
		/**
		 * Descarrega a tela atual para uma nova tela ser carregada.
		 * @param	screen Tela a ser carregada.
		 */
		private function unloadScreen(screen:int):void 
		{
			switch (screen) {
				case INICIAL:
					layer_screen.removeChild(tela0);
					break;
				case CHOOSE_F:
					layer_screen.removeChild(tela1);
					break;
				case CHOOSE_AB:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case CHOOSE_SUM:
					layer_screen.removeChild(tela3);
					break;
				case PARTITION:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					menu.plus.removeEventListener(MouseEvent.CLICK, plusHandler);
					menu.minus.removeEventListener(MouseEvent.CLICK, minusHandler);
					break;
				case RESULT:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case FINAL:
					
					break;
				
			}
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
					state.f = indexFunction;
					
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
				case Keyboard.DELETE:
					grafico.deleteSelected();
					break;
				
			}
		}
		
		private function loadComplete(content:String):void {
			var state:Object = JSON.parse(content);
			trace(state);
			
			removeChild(grafico);
			
			primitiveConstant = state.pc;
			indexFunction = state.f;
			grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
			
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
				grafico.zoomInPtPixel(new Point(grafico.mouseX, grafico.mouseY));
				//grafico.zoomInCenter();
			}else {
				//Zoon out
				grafico.zoomOutPtPixel(new Point(grafico.mouseX, grafico.mouseY));
				//grafico.zoomOutCenter();
			}
		}
		
		private var posClick:Point = new Point();
		private function stageDown(e:MouseEvent):void 
		{
			if (subMenuOpen) closeSubMenu();
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