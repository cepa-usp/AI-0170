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
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import tutorial.CaixaTextoNova;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite 
	{
		private var menu:Menu;
		private var subMenu:SubMenu;
		private var primitiveConstant:Number = 1;
		private var fileHandler:FileHandler;
		private var functions:Array;
		private var mcFunctions:Array;
		private var indexFunction:int = -1;
		
		//Camadas:
		private var layer_graph:Sprite;
		private var layer_screen:Sprite;
		private var layer_menu:Sprite;
		private var layer_info:Sprite;
		private var layer_mark:Sprite;
		private var layer_borda:Sprite;
		private var layer_help:Sprite;
		
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
		
		//private var informacoes:CaixaTextoNova;
		private var informacoes:InfoBar;
		private var airVersion:Boolean = true;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
			
			this.scrollRect = new Rectangle(0, 0, 800, 480);
			//informacoes = new CaixaTextoNova();
			//informacoes.nextButton.visible = false;
			//informacoes.closeButton.addEventListener(MouseEvent.CLICK, closeInfo);
			informacoes = new InfoBar();
			informacoes.info.embedFonts = true;
			informacoes.info.autoSize = TextFieldAutoSize.LEFT
			informacoes.info.width = 330;
			informacoes.x = 62;
			informacoes.y = 161;
			informacoes.alpha = 0;
			
			if (airVersion) fileHandler = new FileHandlerAIR("ai170");
			else fileHandler = new FileHandlerFlash(stage);
			
			currentScreen = INICIAL;
			
			createLayers();
			createMenu();
			createFunctions();
			createScreens();
			//createGraph();
			
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
			layer_borda = new Sprite();
			layer_help = new Sprite();
			
			addChild(layer_graph);
			addChild(layer_mark);
			addChild(layer_screen);
			addChild(layer_menu);
			addChild(layer_info);
			addChild(layer_help);
			layer_help.x = 60;
			addChild(layer_borda);
			
			layer_borda.graphics.lineStyle(4, 0xCCCCCC);
			layer_borda.graphics.lineTo(800, 0);
			layer_borda.graphics.lineTo(800, 480);
			layer_borda.graphics.lineTo(0, 480);
			layer_borda.graphics.lineTo(0, 0);
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
			//makeButton(menu.currentScreen, loadInfo);
			menu.cs.addEventListener(MouseEvent.CLICK, loadInfo);
			menu.cs.mouseChildren = false;
			menu.cs.buttonMode = true;
			menu.help.addEventListener(MouseEvent.CLICK, showHelp);
			
			subMenu = new SubMenu();
			subMenu.x = -subMenu.width + 60;
			makeButton(subMenu.newEx, createNew);
			makeButton(subMenu.open, openFile);
			makeButton(subMenu.save, save);
			makeButton(subMenu.saveAs, saveAs);
			//makeButton(subMenu.language, null);
			makeButton(subMenu.about, openAbout);
			
			if(!airVersion){
				subMenu.saveAs.visible = false;
				subMenu.saveAs.mouseEnabled = false;
				subMenu.about.y = subMenu.saveAs.y;
			}
		}
		
		private var about:Sobre = new Sobre();
		private function openAbout(e:MouseEvent):void 
		{
			e.stopImmediatePropagation();
			if (layer_help.contains(about)) layer_help.removeChild(about);
			else layer_help.addChild(about);
			
			if (subMenuOpen) closeSubMenu();
		}
		
		private var help:Ajuda = new Ajuda();
		private var helpFormat:TextFormat = new TextFormat("arial", 14, 0x333333);
		private function showHelp(e:MouseEvent):void 
		{
			if (layer_help.contains(help)) {
				layer_help.removeChild(help);
				return;
			}
			if (subMenuOpen) closeSubMenu();
			help = new Ajuda();
			if (grafico != null) {
				var gPt:Point;
				switch(grafico.getSelectedType()) {
					case Graph_model.TYPE_ALTURA:
						help.gotoAndStop(19);
						gPt = grafico.getSelectedGraphPos();
						//help.dinamico.defaultTextFormat = helpFormat;
						help.dinamico.embedFonts = true;
						help.dinamico.text = "(" + gPt.x.toFixed(2) + ", " + gPt.y.toFixed(2) + ")";
						break;
					case Graph_model.TYPE_ALTURA_Y:
						help.gotoAndStop(18);
						gPt = grafico.getSelectedGraphPos();
						//help.dinamico.embedFonts = true;
						//help.dinamico.defaultTextFormat = helpFormat;
						help.dinamico.embedFonts = true;
						help.dinamico.text = gPt.y.toFixed(2);
						break;
					case Graph_model.TYPE_ALTURA_X:
						help.gotoAndStop(17);
						gPt = grafico.getSelectedGraphPos();
						//help.dinamico.embedFonts = true;
						//help.dinamico.defaultTextFormat = helpFormat;
						help.dinamico.embedFonts = true;
						help.dinamico.text = gPt.x.toFixed(2);
						break;
					case Graph_model.TYPE_DIVISOR:
						gPt = grafico.getSelectedGraphPos();
						if (grafico.getSelectedLabel() == "a" || grafico.getSelectedLabel() == "A") {
							help.gotoAndStop(14);
						}else if (grafico.getSelectedLabel() == "b" || grafico.getSelectedLabel() == "B") {
							help.gotoAndStop(15);
						}else {
							help.gotoAndStop(16);
						}
						//help.dinamico.embedFonts = true;
						//help.dinamico.defaultTextFormat = helpFormat;
						help.dinamico.embedFonts = true;
						help.dinamico.text = gPt.x.toFixed(2);
						break;
					case Graph_model.TYPE_FUNCTION:
						help.gotoAndStop(23);
						//TO DO: Mandar o movieclip das funções para o indice da funcao selecionada.
						help.expressao.gotoAndStop(indexFunction);
						break;
					case Graph_model.TYPE_PRIMITIVE:
						help.gotoAndStop(24);
						//TO DO: Mandar o movieclip das primitivas para o indice da funcao selecionada.
						help.expressao.gotoAndStop(indexFunction);
						help.cValue.embedFonts = true;
						help.cValue.x = help.expressao.x + help.expressao.width;
						help.cValue.text = primitiveConstant.toFixed(2);
						break;
					case Graph_model.TYPE_SOMA:
						help.gotoAndStop(25);
						help.dinamico.embedFonts = true;
						help.dinamico.text = grafico.getSelectedValue().toPrecision(2);
						break;
					case Graph_model.TYPE_N:
						help.gotoAndStop(26);
						help.dinamico.embedFonts = true;
						help.dinamico.text = String(grafico.getSelectedValue());
						break;
					case Graph_model.TYPE_PRIMITIVE_C:
						help.gotoAndStop(22);
						//TO DO: Indicar o valor da constante de integracao
						help.dinamico.embedFonts = true;
						help.dinamico.text = primitiveConstant.toFixed(2);
						break;
					case Graph_model.TYPE_PRIMITIVE_A:
						help.gotoAndStop(27);
						help.dinamico.embedFonts = true;
						help.dinamico.text = grafico.getSelectedValue().toFixed(2);
						break;
					case Graph_model.TYPE_PRIMITIVE_B:
						help.gotoAndStop(28);
						help.dinamico.embedFonts = true;
						help.dinamico.text = grafico.getSelectedValue().toFixed(2);
						break;
					case Graph_model.TYPE_RECTANGLE:
						help.gotoAndStop(21);
						help.dinamico.embedFonts = true;
						help.dinamico.text = grafico.getSelectedValue().toFixed(2);
						break;
					case Graph_model.TYPE_INTERVAL:
						help.gotoAndStop(20);
						help.dinamico.embedFonts = true;
						help.dinamico.text = grafico.getSelectedValue().toFixed(2);
						break;
					case Graph_model.TYPE_NONE:
						openAboutNone();
						break;
				}
			}else {
				openAboutNone();
			}
			
			if (!layer_help.contains(help)) {
				layer_help.addChild(help);
			}
		}
		
		private function openAboutNone():void 
		{
			switch(currentScreen) {
				case CHOOSE_F:
					help.gotoAndStop(4);
					break;
				case CHOOSE_AB:
					help.gotoAndStop(5);
					break;
				case CHOOSE_SUM:
					help.gotoAndStop(6);
					var roll:BarraRolagem = new BarraRolagem(help.content, 400, new RollBar());
					roll.x = 65;
					roll.y = 45;
					help.addChild(roll);
					break;
				case PARTITION:
					help.gotoAndStop(7);
					break;
				case RESULT:
					help.gotoAndStop(8);
					break;
				case FINAL:
					help.gotoAndStop(9);
					break;
			}
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
		
		private var tela1Accord:Accordion;
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
			tela1.x = 60;
			tela1Accord = new Accordion();
			tela1Accord.addEventListener("accordionClick", accClick);
			//var f0:F0 = new F0();
			//var f1:F1 = new F1();
			//var f2:F2 = new F2();
			//var f3:F3 = new F3();
			//var f4:F4 = new F4();
			
			mcFunctions = [];
			//mcFunctions.push(f0, f1, f2, f3, f4);
			
			var classe:Class;
			for (var i:int = 0; i <= 41; i++) 
			{
				classe = getClass(i);
				//classe = Class(getDefinitionByName("F" + String(i)));
				mcFunctions.push(new classe());
				mcFunctions[i].mouseChildren = false;
				mcFunctions[i].name = "f" + String(i);
				mcFunctions[i].buttonMode = true;
				mcFunctions[i].gotoAndStop(1);
				mcFunctions[i].addEventListener(MouseEvent.CLICK, chooseFunction);
			}
			
			tela1Accord.addAba(new MF1(), mcFunctions.slice(0, 10));
			tela1Accord.addAba(new MF2(), mcFunctions.slice(10, 20));
			//tela1Accord.addAba(new MF3(), mcFunctions.slice(20, 26));
			tela1Accord.addAba(new MF4(), mcFunctions.slice(26, 35));
			tela1Accord.addAba(new MF5(), mcFunctions.slice(35, 42));

			tela1.addChild(tela1Accord);
			
			//tela1.addEventListener(MouseEvent.CLICK, chooseFunction);
			
			tela3 = new Tela3();
			tela3.x = 60;
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
		
		private function getClass(n:int):Class 
		{
			switch(n) {
				case 0:
					return F0;
					break;
				case 1:
					return F1;
					break;
				case 2:
					return F2;
					break;
				case 3:
					return F3;
					break;
				case 4:
					return F4;
					break;
				case 5:
					return F5;
					break;
				case 6:
					return F6;
					break;
				case 7:
					return F7;
					break;
				case 8:
					return F8;
					break;
				case 9:
					return F9;
					break;
				case 10:
					return F10;
					break;
				case 11:
					return F11;
					break;
				case 12:
					return F12;
					break;
				case 13:
					return F13;
					break;
				case 14:
					return F14;
					break;
				case 15:
					return F15;
					break;
				case 16:
					return F16;
					break;
				case 17:
					return F17;
					break;
				case 18:
					return F18;
					break;
				case 19:
					return F19;
					break;
				case 20:
					return F20;
					break;
				case 21:
					return F21;
					break;
				case 22:
					return F22;
					break;
				case 23:
					return F23;
					break;
				case 24:
					return F24;
					break;
				case 25:
					return F25;
					break;
				case 26:
					return F26;
					break;
				case 27:
					return F27;
					break;
				case 28:
					return F28;
					break;
				case 29:
					return F29;
					break;
				case 30:
					return F30;
					break;
				case 31:
					return F31;
					break;
				case 32:
					return F32;
					break;
				case 33:
					return F33;
					break;
				case 34:
					return F34;
					break;
				case 35:
					return F35;
					break;
				case 36:
					return F36;
					break;
				case 37:
					return F37;
					break;
				case 38:
					return F38;
					break;
				case 39:
					return F39;
					break;
				case 40:
					return F40;
					break;
				case 41:
					return F41;
					break;
				
			}
			return null;
		}
		
		private function accClick(e:Event):void 
		{
			if(indexFunction != -1){
				fSelected.gotoAndStop(1);
				fSelected = null;
				indexFunction = -1;
			}
			verificaAvancar();
		}
		
		private function choseStrategy(e:MouseEvent):void 
		{
			tela3.inferior.gotoAndStop(1);
			tela3.superior.gotoAndStop(1);
			tela3.personal.gotoAndStop(1);
			//switch(MovieClip(e.target).name) {
			trace(e.target.name);
			switch(e.target.name) {
				case "inferior":
				case "inf":
					currentStrategy = INFERIOR;
					tela3.inferior.gotoAndStop(2);
					break;
				case "superior":
				case "sup":
					currentStrategy = SUPERIOR;
					tela3.superior.gotoAndStop(2);
					break;
				case "personal":
				case "per":
					currentStrategy = PERSONAL;
					tela3.personal.gotoAndStop(2);
					break;
				default:
					currentStrategy = -1;
					break;
			}
			verificaAvancar();
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
			//----------------------- Funções polinomiais --------------------------------
			
			var f0:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return 1 } );
			var pF0:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return x + primitiveConstant } );
			
			var f1:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -1 } );
			var pF1:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -x + primitiveConstant } );
			
			var f2:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x } );
			var pF2:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 2) / 2 + primitiveConstant } );
			
			var f3:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -x } );
			var pF3:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.pow(x, 2) / 2 + primitiveConstant } );
			
			var f4:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x+1 } );
			var pF4:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 2)/2 + x + primitiveConstant } );
			
			var f5:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return 2*x + 1 } );
			var pF5:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 2) + x + primitiveConstant } );
			
			var f6:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2) } );
			var pF6:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 3) / 3 + primitiveConstant } );
			
			var f7:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2) + 1 } );
			var pF7:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 3) / 3 + x + primitiveConstant } );
			
			var f8:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2) + x} );
			var pF8:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 3) / 3 + Math.pow(x, 2) + primitiveConstant } );
			
			var f9:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2) + x + 1 } );
			var pF9:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(x, 3) / 3 + Math.pow(x, 2) + x + primitiveConstant } );
			
			//---------------------- Funções exponenciais ---------------
			
			var f10:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.exp(x) } );
			var pF10:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.exp(x) + primitiveConstant } );
			
			var f11:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.exp(-x) } );
			var pF11:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.exp(-x) + primitiveConstant } );
			
			var f12:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -Math.exp(x) } );
			var pF12:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.exp(x) + primitiveConstant } );
			
			var f13:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -Math.exp(-x) } );
			var pF13:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.exp(-x) + primitiveConstant } );
			
			var f14:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.exp(x) + 1 } );
			var pF14:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.exp(x) + x + primitiveConstant } );
			
			var f15:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.exp(-x)+1 } );
			var pF15:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.exp(-x) + x + primitiveConstant } );
			
			var f16:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -Math.exp(x)+1 } );
			var pF16:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.exp(x) + x + primitiveConstant } );
			
			var f17:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return -Math.exp(-x) + 1 } );
			var pF17:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.exp(-x) + x + primitiveConstant } );
			
			var f18:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.exp(x) - 1} );
			var pF18:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.exp(x) - x + primitiveConstant } );
			
			var f19:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(2, x) } );
			var pF19:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(2, x) / Math.LN2 + primitiveConstant } );
			
			//---------------------- Funções logarítmicas ---------------
			
			var f20:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.log(x) } );
			var pF20:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/(x*Math.LN10*Math.log(x)) + primitiveConstant } );
			
			var f21:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.LN10*Math.log(x) } );
			var pF21:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/x + primitiveConstant } );
			
			var f22:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.log(x)+1 } );
			var pF22:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/(x*Math.LN10*Math.log(x)) + x + primitiveConstant } );
			
			var f23:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.LN10*Math.log(x) + 1 } );
			var pF23:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/x + x + primitiveConstant } );
			
			var f24:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.log(x) - 1 } );
			var pF24:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1/(x*Math.LN10*Math.log(x)) - x + primitiveConstant } );
			
			var f25:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.LN10*Math.log(x)-1 } );
			var pF25:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1 / x - x + primitiveConstant } );
			
			//---------------------- Funções trigonométricas ---------------
			
			var f26:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.sin(x) } );
			var pF26:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.cos(x) + primitiveConstant } );
			
			var f27:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.cos(x) } );
			var pF27:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.sin(x) + primitiveConstant } );
			
			var f28:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(Math.sin(x), 2) } );
			var pF28:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return x / 2 - Math.sin(2 * x) / 4 + primitiveConstant } );
			
			var f29:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(Math.cos(x), 2) } );
			var pF29:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return x / 2 + Math.sin(2 * x) / 4 + primitiveConstant } );
			
			var f30:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.sin(x)*Math.cos(x) } );
			var pF30:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return -Math.cos(2*x)/4 + primitiveConstant } );
			
			var f31:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return  Math.pow(Math.sin(x), 2)*Math.cos(x)} );
			var pF31:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(Math.sin(x), 3)/3 + primitiveConstant } );
			
			var f32:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return  Math.pow(Math.tan(x), 2)} );
			var pF32:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.tan(x) - x + primitiveConstant } );
			
			var f33:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return  Math.pow(1/Math.cos(x), 2)} );
			var pF33:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.tan(x) + primitiveConstant } );
			
			var f34:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return 1/Math.cos(x) * Math.tan(x) } );
			var pF34:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return 1 / Math.cos(x) + primitiveConstant } );
			
			//---------------------- Mistas ---------------
			
			var f35:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x * Math.cos(x) } );
			var pF35:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.cos(x) + x*Math.sin(x) + primitiveConstant } );
			
			var f36:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return x * Math.sin(x) } );
			var pF36:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.sin(x) - x*Math.cos(x) + primitiveConstant } );
			
			var f37:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(x, 2)*Math.sin(x) } );
			var pF37:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return (2-Math.pow(x, 2))*Math.cos(x)+2*x*Math.sin(x) + primitiveConstant } );
			
			var f38:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(Math.E, x)*Math.sin(x) } );
			var pF38:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(Math.E, x)*(Math.sin(x)-Math.cos(x))/2 + primitiveConstant } );
			
			var f39:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return Math.pow(Math.E, x)*Math.cos(x) } );
			var pF39:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return Math.pow(Math.E, x)*(Math.sin(x)+Math.cos(x))/2 + primitiveConstant } );
			
			var f40:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return  (Math.pow(Math.E, x) + Math.pow(Math.E, -x))/2} );
			var pF40:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return (Math.pow(Math.E, x) - Math.pow(Math.E, -x))/2 + primitiveConstant } );
			
			var f41:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number {return  (Math.pow(Math.E, x) - Math.pow(Math.E, -x))/2} );
			var pF41:GraphFunction = new GraphFunction( -10, 10, function(x:Number):Number { return (Math.pow(Math.E, x) + Math.pow(Math.E, -x))/2 + primitiveConstant } );
			
			
			functions = new Array();
			functions.push([f0, pF0]);
			functions.push([f1, pF1]);
			functions.push([f2, pF2]);
			functions.push([f3, pF3]);
			functions.push([f4, pF4]);
			functions.push([f5, pF5]);
			functions.push([f6, pF6]);
			functions.push([f7, pF7]);
			functions.push([f8, pF8]);
			functions.push([f9, pF9]);
			functions.push([f10, pF10]);
			functions.push([f11, pF11]);
			functions.push([f12, pF12]);
			functions.push([f13, pF13]);
			functions.push([f14, pF14]);
			functions.push([f15, pF15]);
			functions.push([f16, pF16]);
			functions.push([f17, pF17]);
			functions.push([f18, pF18]);
			functions.push([f19, pF19]);
			functions.push([f20, pF20]);
			functions.push([f21, pF21]);
			functions.push([f22, pF22]);
			functions.push([f23, pF23]);
			functions.push([f24, pF24]);
			functions.push([f25, pF25]);
			functions.push([f26, pF26]);
			functions.push([f27, pF27]);
			functions.push([f28, pF28]);
			functions.push([f29, pF29]);
			functions.push([f30, pF30]);
			functions.push([f31, pF31]);
			functions.push([f32, pF32]);
			functions.push([f33, pF33]);
			functions.push([f34, pF34]);
			functions.push([f35, pF35]);
			functions.push([f36, pF36]);
			functions.push([f37, pF37]);
			functions.push([f38, pF38]);
			functions.push([f39, pF39]);
			functions.push([f40, pF40]);
			functions.push([f41, pF41]);
		}
		
		private function plusHandler(e:MouseEvent):void 
		{
			switch (currentScreen) {
				case PARTITION:
					if (currentStrategy == PERSONAL) {
						if (layer_mark.contains(mark)) {
							var yOrigin:Number = grafico.getStageCoords(0, 0).y;
							trace(yOrigin, mark.y);
							if(Math.abs(yOrigin - mark.y) < 0.1){
								var posOnGraph:Point = grafico.globalToLocal(new Point(mark.x, mark.y));
								grafico.addPoint(grafico.getGraphCoords(posOnGraph.x, posOnGraph.y).x);
								unlock(menu.minus);
							}
						}
						lock(menu.plus);
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
							if (Point.distance(posOnGraph, ptFunc) < 1) {
								grafico.addPointM(graphCoords.x);
								unlock(menu.minus);
							}
							
							verificaAvancar();
						}
						lock(menu.plus);
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
						unlock(menu.plus);
						lock(menu.minus);
					}else{
						grafico.divideIn(grafico.n - 1);
					}
					break;
				case RESULT:
					if(currentStrategy == PERSONAL){
						grafico.deleteSelected([Graph_model.TYPE_ALTURA, Graph_model.TYPE_RECTANGLE]);
						lock(menu.minus);
					}
					verificaAvancar();
					break;
			}
		}
		
		private var fSelected:MovieClip;
		private function chooseFunction(e:MouseEvent):void 
		{
			var fClicked:MovieClip = MovieClip(e.target);
			var newIndex:int = int(fClicked.name.replace("f", ""));
			if (!isNaN(newIndex)) {
				if(indexFunction != -1){
					if (newIndex != indexFunction) {
						fSelected.gotoAndStop(1);
						fSelected = null;
					}
				}
				indexFunction = newIndex;
				fSelected = fClicked;
				fClicked.gotoAndStop(2);
				if (grafico != null) grafico = null;
				//next();
			}
			verificaAvancar();
		}
		
		private function openFile(e:MouseEvent):void 
		{
			fileHandler.abrir(loadComplete);
		}
		
		private var confirmScreen:ConfirmNew = new ConfirmNew();
		private function createNew(e:MouseEvent):void 
		{
			if(currentScreen > 1){
				confirmScreen.ok.addEventListener(MouseEvent.CLICK, confirmNew);
				confirmScreen.cancel.addEventListener(MouseEvent.CLICK, cancelNew);
				stage.addChild(confirmScreen);
			}else {
				confirmNew(null);
			}
			//currentStrategy = -1;
			//indexFunction = -1;
			//fSelected = null;
			//tela1Accord.close();
			//primitiveConstant = 1;
			//unloadScreen(currentScreen);
			//currentScreen = 1;
			//loadScreen(currentScreen);
			//menu.currentScreen.text = currentScreen.toString();
		}
		
		private function confirmNew(e:MouseEvent):void
		{
			if(e != null) cancelNew(null);
			
			currentStrategy = -1;
			indexFunction = -1;
			fSelected = null;
			tela1Accord.close();
			primitiveConstant = 1;
			unloadScreen(currentScreen);
			currentScreen = 1;
			loadScreen(currentScreen);
			menu.cs.currentScreen.text = currentScreen.toString();
		}
		
		private function cancelNew(e:MouseEvent):void
		{
			confirmScreen.ok.removeEventListener(MouseEvent.CLICK, confirmNew);
			confirmScreen.cancel.removeEventListener(MouseEvent.CLICK, cancelNew);
			stage.removeChild(confirmScreen);
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
		
		private function verificaAvancar():void
		{
			switch (currentScreen) {
				case CHOOSE_F:
					if (indexFunction > -1) {
						unlock(menu.next);
					}else {
						lock(menu.next);
					}
					break;
				case CHOOSE_SUM:
					if (currentStrategy > -1) {
						unlock(menu.next);
					}else {
						lock(menu.next);
					}
					break;
				case RESULT:
					if(currentStrategy == PERSONAL){
						if (grafico.allElements) unlock(menu.next);
						else lock(menu.next);
					}
					break;
				case FINAL:
					lock(menu.next);
					break;
				default:
					unlock(menu.next);
					break;
			}
		}
		
		private function lock(bt:*):void
		{
			bt.mouseEnabled = false;
			bt.alpha = 0.5;
		}
		
		private function unlock(bt:*):void
		{
			bt.mouseEnabled = true;
			bt.alpha = 1;
		}
		
		private function getFb():Number
		{
			var oldPrimitiveConstanta:Number = primitiveConstant;
			primitiveConstant = 0;
			var fb:Number = -GraphFunction(functions[indexFunction][1]).value(grafico.getPtByLabel("a"));
			primitiveConstant = oldPrimitiveConstanta;
			return fb;
		}
		
		/**
		 * Carrega uma tela de acordo com a indicação.
		 * @param	screen Tela a ser carregada.
		 */
		private function loadScreen(screen:int, state:Object = null):void 
		{
			menu.cs.currentScreen.text = screen.toString();
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
					unlock(menu.next);
					menu.plus.visible = false;
					menu.minus.visible = false;
					layer_screen.addChild(tela1);
					if (indexFunction == -1) {
						for (var i:int = 0; i < mcFunctions.length; i++) 
						{
							mcFunctions[i].gotoAndStop(1);
						}
					}
					menu.next.visible = true;
					break;
				case CHOOSE_AB:
					if (layer_menu.numChildren == 0) {
						layer_menu.addChild(subMenu);
						layer_menu.addChild(menu);
					}
					unlock(menu.next);
					removeMark();
					menu.plus.visible = false;
					menu.minus.visible = false;
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					if(grafico.n == -1){
						grafico.addPoint( -5);
						grafico.addPoint( 5);
						//grafico.setFb(getFb());
					}
					grafico.showhRects = false;
					grafico.defineAB = true;
					grafico.showPrimitive = false;
					grafico.searchInterval = false;
					grafico.x = 60;
					grafico.gColor = 0x808080;
					grafico.gStroke = 1;
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
					unlock(menu.next);
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
					unlock(menu.next);
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.hideSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.showPrimitive = false;
					grafico.showhRects = false;
					grafico.searchInterval = false;
					grafico.x = 60;
					grafico.gColor = 0x000000;
					grafico.gStroke = 2;
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					removeMark();
					menu.plus.visible = true;
					menu.minus.visible = true;
					switch (currentStrategy) {
						case INFERIOR:
						case SUPERIOR:
							if (grafico.n == 1) grafico.divideIn(defaultN);
							else grafico.divideIn(grafico.n);
							unlock(menu.plus);
							unlock(menu.minus);
							break;
						case PERSONAL:
							lock(menu.plus);
							lock(menu.minus);
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
					//menu.next.visible = true;
					unlock(menu.next);
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.showSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.showPrimitive = false;
					grafico.showhRects = true;
					grafico.searchInterval = true;
					grafico.x = 60;
					grafico.gColor = 0x000000;
					grafico.gStroke = 2;
					removeMark();
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
							lock(menu.plus);
							lock(menu.minus);
							if (grafico.allElements) unlock(menu.next);
							else lock(menu.next);
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
					//menu.next.visible = false;
					lock(menu.next);
					menu.plus.visible = false;
					menu.minus.visible = false;
					if (grafico == null) grafico = new Graph_model(functions[indexFunction][0], functions[indexFunction][1]);
					grafico.showSum();
					grafico.defineAB = false;
					grafico.lockAB = true;
					grafico.x = 60;
					grafico.gColor = 0x808080;
					grafico.gStroke = 1;
					grafico.showPrimitive = true;
					grafico.searchInterval = true;
					if (state != null) grafico.restoreState(state);
					layer_graph.addChild(grafico);
					//stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
					break;
				
			}
			loadInfo();
			verificaAvancar();
		}
		
		private var infosShowed:Object = new Object();
		private const maxDias:Number = 15 * 24 * 60 * 60 * 1000;//15 dias
		private function loadInfo(e:MouseEvent = null):void 
		{
			switch(currentScreen) {
				case INICIAL:
					break;
				case CHOOSE_F:
					verifyDate(e, currentScreen, "Escolha da função");
					break;
				case CHOOSE_AB:
					verifyDate(e, currentScreen, "Escolha o intervalo de integração");
					break;
				case CHOOSE_SUM:
					verifyDate(e, currentScreen, "Escolha da estratégia");
					break;
				case PARTITION:
					verifyDate(e, currentScreen, "Escolha da partição");
					break;
				case RESULT:
					verifyDate(e, currentScreen, "Escolha dos elementos de área");
					break;
				case FINAL:
					verifyDate(e, currentScreen, "Ajuste da constante de integração");
					break;
				
			}
		}
		
		private function verifyDate(event:MouseEvent, screen:int, info:String):void {
			var date:Date = new Date();
			var showedDate:Date;
			
			if (event != null) {
				if (infoTimer.running) closeInfoText();
				else {
					setInfoText(info);
					infosShowed[screen] = String(date.fullYear) + "," + String(date.month) + "," + String(date.date) + "," + String(date.hours);
				}
			}else{
				if (infosShowed[screen] == null) {
					setInfoText(info);
					infosShowed[screen] = String(date.fullYear) + "," + String(date.month) + "," + String(date.date) + "," + String(date.hours);
				}else {
					var oldDate:Array = String(infosShowed[screen]).split(",");
					showedDate = new Date(Number(oldDate[0]), Number(oldDate[1]), Number(oldDate[2]), Number(oldDate[3]));
					if (date.valueOf() - showedDate.valueOf() > maxDias) {
						setInfoText(info);
						infosShowed[screen] = String(date.fullYear) + "," + String(date.month) + "," + String(date.date) + "," + String(date.hours);
					}
				}
			}
		}
		
		private var infoTimer:Timer = new Timer(10 * 1000, 1);
		private function setInfoText(text:String):void
		{
			//informacoes.setText(text, CaixaTextoNova.LEFT, CaixaTextoNova.CENTER);
			//informacoes.setPosition(50, 180);
			//informacoes.nextButton.visible = false;
			informacoes.info.text = text;
			informacoes.info.y = -informacoes.info.height / 2;
			informacoes.background.height = informacoes.info.height + 30;
			informacoes.background.width = informacoes.info.textWidth + 20;
			layer_info.addChild(informacoes);
			if (infoTimer.running) {
				infoTimer.stop();
				infoTimer.reset();
			}
			Actuate.tween(informacoes, 0.5, { alpha:1 } );
			infoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCloseInfo);
			infoTimer.start();
		}
		
		private function timerCloseInfo(e:TimerEvent):void 
		{
			if (infoTimer.running) {
				infoTimer.stop();
			}
			infoTimer.reset();
			infoTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCloseInfo);
			closeInfoText();
		}
		
		private function closeInfoText():void
		{
			if (infoTimer.running) {
				infoTimer.stop();
				infoTimer.reset();
			}
			infoTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCloseInfo);
			Actuate.tween(informacoes, 0.5, { alpha:0 } ).onComplete(removeInfo);
		}
		
		private function removeInfo():void 
		{
			if(layer_info.contains(informacoes)) layer_info.removeChild(informacoes);
		}
		
		/**
		 * Descarrega a tela atual para uma nova tela ser carregada.
		 * @param	screen Tela a ser carregada.
		 */
		private function unloadScreen(screen:int):void 
		{
			removeMark();
			closeInfoText();
			if (grafico != null) grafico.removeSelection();
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
		
		private function makeButton(bt:*, func:Function):void
		{
			if (bt is MovieClip) {
				bt.gotoAndStop(1);
				bt.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
				bt.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
				bt.mouseChildren = false;
				bt.buttonMode = true;
			}
			
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
					if (currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.addPoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					else if (currentScreen == RESULT && currentStrategy == PERSONAL) {
						grafico.addPointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
						verificaAvancar();
					}
					break;
				case Keyboard.A:
					if (grafico != null) {
						grafico.zoomInPtPixel(new Point(grafico.mouseX, grafico.mouseY));
						updateMarkPosition();
					}
					break;
				case Keyboard.D:
					if(grafico != null){
						grafico.zoomOutPtPixel(new Point(grafico.mouseX, grafico.mouseY));
						updateMarkPosition();
					}
					break;
				/*case Keyboard.M:
					//Adiciona uma altura
					if (currentScreen == RESULT && currentStrategy == PERSONAL) {
						grafico.addPointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
						verificaAvancar();
					}
					break;
				case Keyboard.O:
					if(currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.removePoint(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
					break;
				case Keyboard.N:
					if (currentScreen == RESULT && currentStrategy == PERSONAL) {
						grafico.removePointM(grafico.getGraphCoords(grafico.mouseX, grafico.mouseY).x);
						verificaAvancar();
					}
					break;*/
				case Keyboard.DELETE:
					if(currentScreen == PARTITION && currentStrategy == PERSONAL) grafico.deleteSelected([Graph_model.TYPE_DIVISOR]);
					else if (currentScreen == RESULT && currentStrategy == PERSONAL) {
						grafico.deleteSelected([Graph_model.TYPE_ALTURA, Graph_model.TYPE_RECTANGLE]);
						verificaAvancar();
					}
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
			if (content == null || content == "") return;
			
			unloadScreen(currentScreen);
			
			var state:Object = JSON.parse(content);
			primitiveConstant = state.pc;
			indexFunction = state.f;
			currentScreen = state.sc;
			currentStrategy = state.st;
			grafico = null;
			
			loadScreen(currentScreen, state.gs);
			verificaAvancar();
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
				updateMarkPosition();
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
			if (e.target is RollBar) return;
			
			if (e.target == menu.help) {
				if (layer_info.contains(informacoes)) closeInfoText();
				if (layer_help.contains(about)) layer_help.removeChild(about);
				e.stopImmediatePropagation();
				return;
			}
			
			if (layer_help.contains(help)) {
				layer_help.removeChild(help);
				if (layer_info.contains(informacoes)) closeInfoText();
				if (layer_help.contains(about)) layer_help.removeChild(about);
				e.stopImmediatePropagation();
				return;
			}
			
			if (e.target != menu.openMenu) {
				if (subMenuOpen) closeSubMenu();
			}else {
				if (layer_info.contains(informacoes)) closeInfoText();
			}
			
			if (layer_help.contains(about)) layer_help.removeChild(about);
			
			if (menu.hitTestPoint(stage.mouseX, stage.mouseY)) return;
			if (subMenu.hitTestPoint(stage.mouseX, stage.mouseY)) return;
			
			if (layer_info.contains(informacoes)) closeInfoText();
			
			if (grafico == null) return;
			
			if(layer_graph.contains(grafico)){
				var objClicked:Object = grafico.searchElement(new Point(grafico.mouseX, grafico.mouseY));
				//trace(objClicked.label);
				
				switch (objClicked.type) {
					case Graph_model.TYPE_PRIMITIVE_C:
					case Graph_model.TYPE_PRIMITIVE:
						posClick.x = stage.mouseX;
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
								//pos.x += grafico.x;
								//setMark(pos, false);
								posClick.x = stage.mouseX;
								posClick.y = stage.mouseY;
								stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
							}
						}else {
							//pos = grafico.getSelectedPosition();
							//pos.x += grafico.x;
							//setMark(pos, false);
							posClick.x = stage.mouseX;
							posClick.y = stage.mouseY;
							stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						}
						break;
					case Graph_model.TYPE_FUNCTION:
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						break;
					case Graph_model.TYPE_ALTURA:
					case Graph_model.TYPE_ALTURA_X:
					case Graph_model.TYPE_ALTURA_Y:
					case Graph_model.TYPE_PRIMITIVE_A:
					case Graph_model.TYPE_PRIMITIVE_B:
						//pos = grafico.getSelectedPosition();
						//pos.x += grafico.x;
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						//setMark(pos, false);
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						break;
					case Graph_model.TYPE_RECTANGLE:
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
						//setMark(posClick, false);
						break;
					default:
						//removeMark();
						posClick.x = stage.mouseX;
						posClick.y = stage.mouseY;
						stage.addEventListener(MouseEvent.MOUSE_UP, stopPanning);
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
			//grafico.setFb(getFb());
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
		private var markTimer:Timer = new Timer(5 * 1000, 1);
		private function setMark(position:Point, snap:Boolean = true):void
		{
			if (currentScreen == CHOOSE_AB) {
				if (layer_mark.contains(mark)) layer_mark.removeChild(mark);
				return;
			}
			
			if (snap) {
				var nearPos:Point = grafico.getNearPos(position.x - grafico.x, position.y);
				mark.x = nearPos.x + grafico.x;
				mark.y = nearPos.y;
			}else {
				mark.x = position.x;
				mark.y = position.y;
			}
			var markGrafico:Point = grafico.globalToLocal(new Point(mark.x, mark.y));
			var markGraph:Point = grafico.getGraphCoords(markGrafico.x, markGrafico.y);
			posMarkGraph.x = markGraph.x;
			posMarkGraph.y = markGraph.y;
			
			if (markTimer.running) {
				markTimer.stop();
				markTimer.reset();
				markTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeMark);
			}
			markTimer.addEventListener(TimerEvent.TIMER_COMPLETE, removeMark);
			markTimer.start();
			
			mark.setPosition(grafico.getGraphCoords(mark.x - grafico.x, mark.y));
			
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
		
		private function removeMark(e:TimerEvent = null):void
		{
			markTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeMark);
			markTimer.stop();
			markTimer.reset();
			
			if (layer_mark.contains(mark)) layer_mark.removeChild(mark);
			//if (grafico != null) grafico.removeSelection();
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
						if (currentStrategy == PERSONAL) {
							if(grafico.betweenAB(graphCoordsOfMouse.x)){
								if (grafico.getSelectedType() == Graph_model.TYPE_DIVISOR) {
									unlock(menu.minus);
									lock(menu.plus);
								}else {
									unlock(menu.plus);
									lock(menu.minus);
								}
							}else {
								lock(menu.plus);
								lock(menu.minus);
							}
						}
					}else {
						//setMark(posClick);
						addMark();
						if(currentStrategy == PERSONAL){
							lock(menu.plus);
							lock(menu.minus);
						}
					}
				}else if (currentScreen == RESULT) {
					//Adiciona a marcação X da altura
					var stageCoordsOfMouseFunc:Point = grafico.getStageCoords(graphCoordsOfMouse.x, functions[indexFunction][0].value(graphCoordsOfMouse.x));
					
					if (Point.distance(posMouse, stageCoordsOfMouseFunc) < 5) {
						if(grafico.getSelectedType() == Graph_model.TYPE_FUNCTION) setMark(new Point(posClick.x, stageCoordsOfMouseFunc.y));
						else addMark();
						if(currentStrategy == PERSONAL){
							if(grafico.betweenAB(graphCoordsOfMouse.x)){
								if (grafico.getSelectedType() == Graph_model.TYPE_ALTURA || grafico.getSelectedType() == Graph_model.TYPE_RECTANGLE) {
									unlock(menu.minus);
									lock(menu.plus);
								}else {
									unlock(menu.plus);
									lock(menu.minus);
								}
							}else {
								lock(menu.plus);
								lock(menu.minus);
							}
						}
					}else {
						//setMark(posClick);
						addMark();
						if(currentStrategy == PERSONAL){
							lock(menu.plus);
							if (grafico.getSelectedType() == Graph_model.TYPE_ALTURA || grafico.getSelectedType() == Graph_model.TYPE_RECTANGLE) unlock(menu.minus);
							else lock(menu.minus);
						}
					}
				}else if (currentScreen == CHOOSE_AB || currentScreen == FINAL) {
					addMark();
				}
			}
		}
		
		private function addMark():void
		{
			switch(grafico.getSelectedType()) {
				case Graph_model.TYPE_ALTURA_X:
				case Graph_model.TYPE_ALTURA_Y:
				case Graph_model.TYPE_ALTURA:
				case Graph_model.TYPE_DIVISOR:
				case Graph_model.TYPE_PRIMITIVE_C:
				case Graph_model.TYPE_PRIMITIVE_A:
				case Graph_model.TYPE_PRIMITIVE_B:
					var markPos:Point = grafico.getSelectedPosition(true);
					markPos.x += grafico.x;
					setMark(markPos);
					break;
				case Graph_model.TYPE_N:
				case Graph_model.TYPE_SOMA:
					removeMark();
					break;
				default:
					setMark(posClick);
					break;
			}
		}
		
		private function movingPrimitive(e:MouseEvent):void 
		{
			var diff:Number = stage.mouseY - posClick.y;
			posClick.y = stage.mouseY;
			primitiveConstant += grafico.getDistanceFromOrigin(diff).y;
			//if (Math.abs(primitiveConstant - grafico.getFb()) < 0.15) grafico.showFB = true;
			//else grafico.showFB = false;
			grafico.update();
		}
		
		private function stopMovingPrimitive(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPrimitive);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingPrimitive);
			setMark(new Point(stage.mouseX, stage.mouseY));
		}
		
	}
	
}