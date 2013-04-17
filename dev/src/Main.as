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
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import tutorial.CaixaTextoNova;
	
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
		private var layer_mark:Sprite;
		
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
		
		private var informacoes:CaixaTextoNova;
		
		public function Main():void 
		{
			
			//indexFunction = 0;
			//grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
			
			//addChild(grafico);
			//grafico.x = 60;
			
			//addListeners();
			
			//testando();
			
			this.scrollRect = new Rectangle(0, 0, 800, 480);
			informacoes = new CaixaTextoNova();
			informacoes.nextButton.visible = false;
			informacoes.closeButton.addEventListener(MouseEvent.CLICK, closeInfo);
			
			currentScreen = INICIAL;
			
			createLayers();
			createMenu();
			createScreens();
			createFunctions();
			//createGraph();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
			
			loadScreen(currentScreen);
		}
		
		private function closeInfo(e:MouseEvent):void 
		{
			if (layer_info.contains(informacoes)) layer_info.removeChild(informacoes);
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
			layer_mark = new Sprite();
			
			addChild(layer_graph);
			addChild(layer_mark);
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
			makeButton(menu.openMenu, openMenuClick)//.addEventListener(MouseEvent.CLICK, );
			makeButton(menu.next, next);// .addEventListener(MouseEvent.CLICK, next);
			makeButton(menu.previous, previous);// .addEventListener(MouseEvent.CLICK, previous);
			makeButton(menu.help, null);
			makeButton(menu.plus, null);
			makeButton(menu.minus, null);
			//menu.help.addEventListener(MouseEvent.CLICK, showHelp);
			
			subMenu = new SubMenu();
			subMenu.x = -subMenu.width + 60;
			makeButton(subMenu.newEx, createNew);
			makeButton(subMenu.open, openFile);
			makeButton(subMenu.save, save);
			makeButton(subMenu.saveAs, saveAs);
			makeButton(subMenu.language, null);
			makeButton(subMenu.about, null);
			
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
			tela1.f1.mouseChildren = false;
			tela1.f2.mouseChildren = false;
			tela1.f3.mouseChildren = false;
			tela1.f4.mouseChildren = false;
			
			tela1.f0.buttonMode = true;
			tela1.f1.buttonMode = true;
			tela1.f2.buttonMode = true;
			tela1.f3.buttonMode = true;
			tela1.f4.buttonMode = true;
			
			tela1.f0.gotoAndStop(1);
			tela1.f1.gotoAndStop(1);
			tela1.f2.gotoAndStop(1);
			tela1.f3.gotoAndStop(1);
			tela1.f4.gotoAndStop(1);
			
			tela1.addEventListener(MouseEvent.CLICK, chooseFunction);
			
			tela3 = new Tela3();
			tela3.inferior.buttonMode = true;
			tela3.superior.buttonMode = true;
			tela3.personal.buttonMode = true;
			
			tela3.inferior.mouseChildren = false;
			tela3.superior.mouseChildren = false;
			tela3.personal.mouseChildren = false;
			
			tela3.inferior.gotoAndStop(1);
			tela3.superior.gotoAndStop(1);
			tela3.personal.gotoAndStop(1);
			
			tela3.addEventListener(MouseEvent.CLICK, choseStrategy);
		}
		
		private function choseStrategy(e:MouseEvent):void 
		{
			tela3.inferior.gotoAndStop(1);
			tela3.superior.gotoAndStop(1);
			tela3.personal.gotoAndStop(1);
			switch(MovieClip(e.target).name) {
				case "inferior":
					currentStrategy = INFERIOR;
					tela3.inferior.gotoAndStop(2);
					break;
				case "superior":
					currentStrategy = SUPERIOR;
					tela3.superior.gotoAndStop(2);
					break;
				case "personal":
					currentStrategy = PERSONAL;
					tela3.personal.gotoAndStop(2);
					break;
				default:
					currentStrategy = -1;
					break;
			}
			
			/*
			if (currentStrategy >= 0) {
				next();
			}
			*/
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
		
		private function plusHandler(e:MouseEvent):void 
		{
			switch (currentScreen) {
				case PARTITION:
					if (currentStrategy == PERSONAL) {
						if (layer_mark.contains(mark)) {
							var yOrigin:Number = grafico.getStageCoords(0, 0).y;
							if(yOrigin == mark.y){
								var posOnGraph:Point = grafico.globalToLocal(new Point(mark.x, mark.y));
								grafico.addPoint(grafico.getGraphCoords(posOnGraph.x, posOnGraph.y).x);
							}
						}
					}else{
						grafico.divideIn(grafico.n + 1);
					}
					break;
				case RESULT:
					if (currentStrategy == PERSONAL) {
						if (layer_mark.contains(mark)) {
							posOnGraph = grafico.globalToLocal(new Point(mark.x, mark.y));
							var graphCoords:Point = grafico.getGraphCoords(posOnGraph.x, posOnGraph.y);
							var ptFunc:Point = grafico.getStageCoords(graphCoords.x, functions[indexFunction][0].value(graphCoords.x));
							if(Point.distance(posOnGraph, ptFunc) < 1) grafico.addPointM(graphCoords.x);
						}
					}
					break;
			}
		}
		
		private function minusHandler(e:MouseEvent):void 
		{
			switch (currentScreen) {
				case PARTITION:
					if (currentStrategy == PERSONAL) {
						grafico.deleteSelected([Graph_model.TYPE_DIVISOR]);
					}else{
						grafico.divideIn(grafico.n - 1);
					}
					break;
				case RESULT:
					grafico.deleteSelected([Graph_model.TYPE_ALTURA]);
					break;
			}
		}
		
		private function chooseFunction(e:MouseEvent):void 
		{
			//trace(int("a"));
			var newIndex:int = int(MovieClip(e.target).name.replace("f", ""));
			if (!isNaN(newIndex)) {
				if(indexFunction != -1){
					if (newIndex != indexFunction) {
						MovieClip(tela1.getChildByName("f" + indexFunction)).gotoAndStop(1);
					}
				}
				indexFunction = newIndex;
				MovieClip(tela1.getChildByName("f" + indexFunction)).gotoAndStop(2);
				if (grafico != null) grafico = null;
				//next();
			}
		}
		
		private function openFile(e:MouseEvent):void 
		{
			fileHandler.abrir(loadComplete);
		}
		
		private function createNew(e:MouseEvent):void 
		{
			currentStrategy = -1;
			indexFunction = -1;
			primitiveConstant = 0;
			unloadScreen(currentScreen);
			currentScreen = 1;
			loadScreen(currentScreen);
			menu.currentScreen.text = currentScreen.toString();
			//next();
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
		}
		
		private function previous(e:MouseEvent = null):void
		{
			unloadScreen(currentScreen);
			currentScreen--;
			loadScreen(currentScreen);
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
					
					//TODO: condição pra passar.
					
					return true;
					break;
				case FINAL:
					
					break;
				
			}
			
			return false;
		}
		
		/**
		 * Carrega uma tela de acordo com a indicação.
		 * @param	screen Tela a ser carregada.
		 */
		private function loadScreen(screen:int, state:Object = null):void 
		{
			menu.currentScreen.text = screen.toString();
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
					menu.plus.visible = false;
					menu.minus.visible = false;
					layer_screen.addChild(tela1);
					if (indexFunction == -1) {
						tela1.f0.gotoAndStop(1);
						tela1.f1.gotoAndStop(1);
						tela1.f2.gotoAndStop(1);
						tela1.f3.gotoAndStop(1);
						tela1.f4.gotoAndStop(1);
					}
					break;
				case CHOOSE_AB:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					menu.plus.visible = false;
					menu.minus.visible = false;
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					if(grafico.n == -1){
						grafico.addPoint( -5);
						grafico.addPoint( 5);
					}
					grafico.showhRects = false;
					grafico.defineAB = true;
					grafico.showPrimitive = false;
					grafico.x = 60;
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case CHOOSE_SUM:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					menu.plus.visible = false;
					menu.minus.visible = false;
					layer_screen.addChild(tela3);
					if (currentStrategy == -1) {
						tela3.inferior.gotoAndStop(1);
						tela3.superior.gotoAndStop(1);
						tela3.personal.gotoAndStop(1);
					}
					break;
				case PARTITION:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					menu.plus.visible = true;
					menu.minus.visible = true;
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.showPrimitive = false;
					grafico.showhRects = false;
					grafico.x = 60;
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					switch (currentStrategy) {
						case INFERIOR:
						case SUPERIOR:
							if (grafico.n == 1) grafico.divideIn(defaultN);
							else grafico.divideIn(grafico.n);
							break;
						case PERSONAL:
							
							break;
					}
					menu.plus.addEventListener(MouseEvent.CLICK, plusHandler);
					menu.minus.addEventListener(MouseEvent.CLICK, minusHandler);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case RESULT:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.showSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.showPrimitive = false;
					grafico.showhRects = true;
					grafico.x = 60;
					switch (currentStrategy) {
						case INFERIOR:
							menu.plus.visible = false;
							menu.minus.visible = false;
							grafico.lowerSum();
							break;
						case SUPERIOR:
							menu.plus.visible = false;
							menu.minus.visible = false;
							grafico.upperSum();
							break;
						case PERSONAL:
							menu.plus.visible = true;
							menu.minus.visible = true;
							menu.plus.addEventListener(MouseEvent.CLICK, plusHandler);
							menu.minus.addEventListener(MouseEvent.CLICK, minusHandler);
							break;
					}
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case FINAL:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					menu.plus.visible = false;
					menu.minus.visible = false;
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.x = 60;
					grafico.showPrimitive = true;
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					//stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				
			}
			loadInfo(screen);
		}
		
		private function loadInfo(screen:int):void 
		{
			switch(screen) {
				case INICIAL:
					break;
				case CHOOSE_F:
					//setInfoText("Escolha a função para iniciar o exercício");
					break;
				case CHOOSE_AB:
					break;
				case CHOOSE_SUM:
					break;
				case PARTITION:
					break;
				case RESULT:
					break;
				case FINAL:
					break;
				
			}
		}
		
		private function setInfoText(text:String):void
		{
			informacoes.setText(text, CaixaTextoNova.LEFT, CaixaTextoNova.CENTER);
			informacoes.setPosition(50, 180);
			informacoes.nextButton.visible = false;
			layer_info.addChild(informacoes);
		}
		
		/**
		 * Descarrega a tela atual para uma nova tela ser carregada.
		 * @param	screen Tela a ser carregada.
		 */
		private function unloadScreen(screen:int):void 
		{
			removeMark();
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
					//stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case CHOOSE_SUM:
					layer_screen.removeChild(tela3);
					break;
				case PARTITION:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					menu.plus.removeEventListener(MouseEvent.CLICK, plusHandler);
					menu.minus.removeEventListener(MouseEvent.CLICK, minusHandler);
					break;
				case RESULT:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				case FINAL:
					layer_graph.removeChild(grafico);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					//stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				
			}
		}
		
		private function makeButton(bt:MovieClip, func:Function):void
		{
			bt.gotoAndStop(1);
			bt.mouseChildren = false;
			bt.buttonMode = true;
			bt.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			bt.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
			if (func != null) bt.addEventListener(MouseEvent.MOUSE_DOWN, func);
		}
		
		private function overBtn(e:MouseEvent):void 
		{
			MovieClip(e.target).gotoAndStop(2);
		}
		
		private function outBtn(e:MouseEvent):void 
		{
			MovieClip(e.target).gotoAndStop(1);
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
					//salvar(e.ctrlKey);
					
					break;
				case Keyboard.R:
					//Recuperar
					//fileHandler.abrir(loadComplete);
					break;
				case Keyboard.P:
					//Adiciona um ponto
					if(currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.addPoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.M:
					//Adiciona uma altura
					if(currentScreen == RESULT && currentStrategy == PERSONAL) grafico.addPointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.O:
					if(currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.removePoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.N:
					if(currentScreen == RESULT && currentStrategy == PERSONAL) grafico.removePointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.DELETE:
					if(currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.deleteSelected([Graph_model.TYPE_DIVISOR]);
					if(currentScreen == RESULT && currentStrategy == PERSONAL) grafico.deleteSelected([Graph_model.TYPE_ALTURA, Graph_model.TYPE_RECTANGLE]);
					break;
				
			}
		}
		
		private function save(e:MouseEvent = null):void
		{
			var stringState:String = JSON.stringify(getState());
			fileHandler.save(stringState);
		}
		
		private function saveAs(e:MouseEvent = null):void
		{
			var stringState:String = JSON.stringify(getState());
			fileHandler.saveAs(stringState);
		}
		
		private function getState():Object
		{
			var state:Object = new Object();
			if(grafico != null) state.gs = grafico.getState();
			state.pc = primitiveConstant;
			state.f = indexFunction;
			state.sc = currentScreen;
			state.st = currentStrategy;
			
			return state;
		}
		
		private function loadComplete(content:String):void {
			
			unloadScreen(currentScreen);
			
			var state:Object = JSON.parse(content);
			
			primitiveConstant = state.pc;
			indexFunction = state.f;
			currentScreen = state.sc;
			currentStrategy = state.st;
			//grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
			
			//grafico.restoreState(state.gs);
			
			//grafico.x = 60;
			//addChild(grafico);
			
			loadScreen(currentScreen, state.gs);
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
				updateMarkPosition()
				//grafico.zoomInCenter();
			}else {
				//Zoon out
				grafico.zoomOutPtPixel(new Point(grafico.mouseX, grafico.mouseY));
				updateMarkPosition();
				//grafico.zoomOutCenter();
			}
		}
		
		private var posClick:Point = new Point();
		private function stageDown(e:MouseEvent):void 
		{
			if (e.target != menu.openMenu) {
				if (subMenuOpen) closeSubMenu();
			}
			
			if (stage.mouseX < 60) return;
			if (grafico == null) return;
			
			if(layer_graph.contains(grafico)){
				var objClicked:Object = grafico.searchElement(new Point(grafico.mouseX, grafico.mouseY));
				trace(objClicked.type);
				
				switch (objClicked.type) {
					case Graph_model.TYPE_PRIMITIVE_C:
						posClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
						stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
						break;
					case Graph_model.TYPE_NONE:
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						panClick.x = stage.mouseX;
						panClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						break;
					case Graph_model.TYPE_DIVISOR:
						if (objClicked.label != null) {
							if (!grafico.lockAB) {
								removeMark();
								stage.addEventListener(MouseEvent.MOUSE_MOVE, movingAB);
								stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingAB);
							}else {
								var pos:Point = grafico.getSelectedPosition();
								pos.x += grafico.x;
								setMark(pos, false);
							}
						}else {
							pos = grafico.getSelectedPosition();
							pos.x += grafico.x;
							setMark(pos, false);
						}
						break;
					case Graph_model.TYPE_FUNCTION:
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						break;
					case Graph_model.TYPE_ALTURA:
						pos = grafico.getSelectedPosition();
						pos.x += grafico.x;
						setMark(pos, false);
						break;
					case Graph_model.TYPE_RECTANGLE:
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						setMark(posClick, false);
						break;
					default:
						//removeMark();
						break;
				}
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
			var positionSelected:Point = grafico.getSelectedPosition();
			if (positionSelected != null) {
				positionSelected.x += grafico.x;
				setMark(positionSelected, false);
			}
		}
		
		private var panClick:Point = new Point();
		private function panning(e:MouseEvent):void 
		{
			var displace:Point = new Point(stage.mouseX - panClick.x, stage.mouseY - panClick.y);
			panClick.x = stage.mouseX;
			panClick.y = stage.mouseY;
			grafico.panPixel(displace);
			
			updateMarkPosition();
		}
		
		//------------------------- Marcação no palco --------------------------------
		
		private var mark:Mark = new Mark();
		private var posMarkGraph:Point = new Point();
		private function setMark(position:Point, snap:Boolean = true):void
		{
			if (snap) {
				var nearPos:Point = grafico.getNearPos(position.x - grafico.x, position.y);
				mark.x = nearPos.x + grafico.x;
				mark.y = nearPos.y;
			}else{
				mark.x = position.x;
				mark.y = position.y;
			}
			var markGrafico:Point = grafico.globalToLocal(new Point(mark.x, mark.y));
			var markGraph:Point = grafico.getGraphCoords(markGrafico.x, markGrafico.y);
			posMarkGraph.x = markGraph.x;
			posMarkGraph.y = markGraph.y;
			
			if (!layer_mark.contains(mark)) layer_mark.addChild(mark);
		}
		
		private function updateMarkPosition():void
		{
			if(layer_mark.contains(mark)){
				var markStage:Point = grafico.getStageCoords(posMarkGraph.x, posMarkGraph.y);
				mark.x = markStage.x + grafico.x;
				mark.y = markStage.y + grafico.y;
			}
		}
		
		private function removeMark():void
		{
			if (layer_mark.contains(mark)) layer_mark.removeChild(mark);
		}
		
		//------------------------- Fim marcação palco ----------------------------------
		
		private function stopPanning(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPanning);
			
			if (Point.distance(posClick, new Point(stage.mouseX, stage.mouseY)) < 1) {
				var posMouse:Point = new Point(grafico.mouseX, grafico.mouseY);
				var graphCoordsOfMouse:Point = grafico.getGraphCoords(posMouse.x, posMouse.y);
				
				if(currentScreen == PARTITION){
					//Adiciona a marcação X do ponto no eixo x
					var stageCoordsOfMouseX:Point = grafico.getStageCoords(graphCoordsOfMouse.x, 0);
					
					if (Point.distance(posMouse, stageCoordsOfMouseX) < 5) {
						setMark(new Point(posClick.x, stageCoordsOfMouseX.y));
					}else {
						setMark(posClick);
					}
				}else if (currentScreen == RESULT) {
					//Adiciona a marcação X da altura
					var stageCoordsOfMouseFunc:Point = grafico.getStageCoords(graphCoordsOfMouse.x, functions[indexFunction][0].value(graphCoordsOfMouse.x));
					
					if (Point.distance(posMouse, stageCoordsOfMouseFunc) < 5) {
						setMark(new Point(posClick.x, stageCoordsOfMouseFunc.y));
					}else {
						setMark(posClick);
					}
				}else if (currentScreen == CHOOSE_AB) {
					setMark(posClick);
				}
			}
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