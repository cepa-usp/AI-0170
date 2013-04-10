package  
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.AxisX;
	import cepa.graph.rectangular.AxisY;
	import cepa.graph.rectangular.SimpleGraph;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Graph_model extends Sprite
	{
		public static const TYPE_DIVISOR:String = "divisor";
		public static const TYPE_ALTURA:String = "altura";
		public static const TYPE_FUNCTION:String = "function";
		public static const TYPE_PRIMITIVE:String = "primitive";
		public static const TYPE_PRIMITIVE_C:String = "primitive_c";
		public static const TYPE_RECTANGLE:String = "rectangle";
		public static const TYPE_NONE:String = "none";
		
		private var layerGraph:Sprite;
		private var layerRects:Sprite;
		private var layerFunctions:Sprite;
		private var layerPoints:Sprite;
		private var layerTextos:Sprite;
		
		private var graph:SimpleGraph;
		private var f:GraphFunction;
		private var F:GraphFunction;
		private var points:Vector.<Object>;
		
		private var selectedType:String;
		private var selectedIndex:int;
		private var selectedValue:Number;
		//private var primitiveConstante:Number;
		private var showPrimitive:Boolean = false;
		private var showHpoints:Boolean = false;
		
		private var _graphSize:Point = new Point(740, 480);
		
		private var txtSomaDTF:TextFormat = new TextFormat("arial", 12, 0x000000);
		private var txtSoma:TextField;
		private var txtNDTF:TextFormat = new TextFormat("arial", 12, 0x000000);
		private var txtN:TextField;
		
		private var _lockAB:Boolean = false;
		private var _defineAB:Boolean = false;
		private var _abDefined:Boolean = false;
		
		public function Graph_model(f:GraphFunction, F:GraphFunction, points:Vector.<Object> = null) 
		{
			this.f = f;
			this.F = F;
			//this.primitiveConstante = primitive;
			
			if (points == null) this.points = new Vector.<Object>();
			else this.points = points;
			
			createLayers();
			createGraph();
			createTexts();
			
			addFuntcion();
			//addPrimitive();
			
			select(TYPE_NONE, NaN, NaN);
			
			draw();
		}
		
		private function createTexts():void 
		{
			txtSoma = new TextField();
			txtSomaDTF.align = TextFormatAlign.RIGHT;
			txtSoma.defaultTextFormat = txtSomaDTF;
			txtSoma.width = 200;
			txtSoma.height = 25;
			txtSoma.x = 800 - 60 - 205;
			txtSoma.y = 5;
			txtSoma.selectable = false;
			//txtSoma.border = true;
			layerTextos.addChild(txtSoma);
			
			txtN = new TextField();
			txtNDTF.align = TextFormatAlign.RIGHT;
			txtN.defaultTextFormat = txtNDTF;
			txtN.width = 200;
			txtN.height = 25;
			txtN.x = 800-60-205;
			txtN.y = 30;
			txtN.selectable = false;
			//txtN.border = true;
			layerTextos.addChild(txtN);
			
			hideSum();
			
		}
		
		/**
		 * Adiciona a função ao gráfico.
		 * @param	selected Indica se a função está selecionada ou não.
		 */
		private function addFuntcion(selected:Boolean = false):void 
		{
			var style:DataStyle = new DataStyle();
			if (selected) {
				style.color = 0xFF0000;
				style.stroke = 5;
			}else{
				style.color = 0x004000;
				style.stroke = 2;
			}
			graph.addFunction(f, style);
			graph.draw();
		}
		
		/**
		 * Remove a função do gráfico.
		 */
		private function removeFunction():void
		{
			graph.removeFunction(f);
		}
		
		/**
		 * Adiciona a primitiva da função ao gráfico.
		 */
		private function addPrimitive(selected:Boolean = false ):void 
		{
			var style2:DataStyle = new DataStyle();
			if (selected) {
				style2.color = 0xFF0000;
				style2.stroke = 5;
			}else{
				style2.color = 0x0000A0;
				style2.stroke = 2;
			}
			graph.addFunction(F, style2);
			graph.draw();
		}
		
		/**
		 * Remove a função primitiva do gráfico.
		 */
		private function removePrimitive():void
		{
			graph.removeFunction(F);
		}
		
		/**
		 * Cria as camadas do gráfico.
		 */
		private function createLayers():void 
		{
			layerFunctions = new Sprite();
			layerGraph = new Sprite();
			layerPoints = new Sprite();
			layerRects = new Sprite();
			layerTextos = new Sprite();
			
			addChild(layerTextos);
			addChild(layerGraph);
			addChild(layerRects);
			addChild(layerFunctions);
			addChild(layerPoints);
		}
		
		/**
		 * Cria o gráfico com a configuração padrão.
		 */
		private function createGraph():void 
		{
			graph = new SimpleGraph( -10, 10, graphSize.x, -8, 8, graphSize.y);
			graph.setTicksDistance(SimpleGraph.AXIS_X, 5);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, 5);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
			graph.setAxisColor(0x808080);
			graph.setTickAlignment(SimpleGraph.AXIS_X, AxisX.TICKS_CENTER);
			graph.setTickAlignment(SimpleGraph.AXIS_Y, AxisY.TICKS_CENTER);
			graph.resolution = 2;
			
			graph.grid = false;
			
			graph.setAxisName(SimpleGraph.AXIS_X, "x");
			graph.setAxisName(SimpleGraph.AXIS_Y, "y");
			
			layerGraph.addChild(graph);
		}
		
		/**
		 * Adiciona um ponto ao eixo x. Esse ponto é uma divisão da área do gráfico que será integrada.
		 * @param	n Valor x do ponto a ser inserido.
		 * @return Retorna o id do objeto inserido.
		 */
		public function addPoint(n:Number):void
		{
			if (points.length == 2 && _defineAB) return;
			
			if (points.length >= 2) {
				if (points[0].x < points[points.length - 1].x) {
					if (n < points[0].x || n > points[points.length - 1].x) return;
				}else {
					if (n > points[0].x || n < points[points.length - 1].x) return;
				}
			}
			
			var newObj:Object = new Object();
			newObj.x = n;
			newObj.h = null;
			
			if (points.length == 0) {
				points.push(newObj);
				newObj.label = "a";
			}else {
				if (points.length == 1) {
					newObj.label = "b";
					_abDefined = true;
				}
				if (points.length == 2 && !lockAB) lockAB = true;
				lookAdd: for (var i:int = 0; i < points.length; i++) 
				{
					if (n < points[i].x) {
						if(i > 0){
							var oldPoint:Object = points[i-1];
							if (oldPoint.h != null) {
								if (newObj.x < oldPoint.h) {
									newObj.h = oldPoint.h;
									oldPoint.h = null;
								}
							}
						}
						points.splice(i, 0, newObj);
						break lookAdd;
					}else if (i == points.length - 1) {
						points.push(newObj);
						break lookAdd;
					}
				}
			}
			draw();
			calculateSum();
		}
		
		/**
		 * Remove o ponto com a coordenada x = n do eixo, ou seja, remove uma divisão da área do gráfico que será integrada.
		 * @param	n Valor x do ponto a ser removido.
		 * @return Retorna o id do ponto removido.
		 */
		public function removePoint(n:Number):void
		{
			lookRemove: for (var i:int = 0; i < points.length; i++) 
			{
				if (n == points[i].x && points[i].label == null) {
					var point:Object = points.splice(i, 1)[0];
					break lookRemove;
				}
			}
			draw();
			calculateSum();
		}
		
		/**
		 * Adiciona um ponto que representa a altura de uma divisão da área a ser integrada.
		 * @param	m Valor x do ponto a ser inserido. O valor y é calculado de acordo com a função.
		 * @return Retorna o id do ponto inserido.
		 */
		public function addPointM(h:Number):void
		{
			if (points.length < 2) return;
			if (points.length == 2 && _defineAB) return;
			
			lookAdd: for (var i:int = 1; i < points.length; i++) 
			{
				if (h < points[i].x) {
					if (i == 1) {
						if (h < points[0].x) return;
					}else if (i == points.length - 1) {
						if (h > points[points.length - 1].x) return;
					}
					points[i - 1].h = h;
					break lookAdd;
				}
			}
			draw();
			calculateSum();
		}
		
		/**
		 * Remove o ponto com a coordenada x = n do eixo, ou seja, remove a altura da área do gráfico que será integrada.
		 * @param	m Valor x do ponto a ser removido.
		 * @return Retorna o id do ponto removido.
		 */
		public function removePointM(h:Number):void
		{
			lookAdd: for (var i:int = 1; i < points.length; i++) 
			{
				if (h < points[i].x) {
					points[i - 1].h = null;
					break lookAdd;
				}
			}
			draw();
			calculateSum();
		}
		
		public function divideIn(nPartitions:int):void
		{
			if (nPartitions < 2) return;
			
			if (points.length > 2) {
				for (var j:int = points.length - 1; j >= 0 ; j--) 
				{
					if (points[j].label == null) removePoint(points[j].x);
					else points[j].h = null;
				}
			}
			
			var ptA:Number = getPtByLabel("a");
			var ptB:Number = getPtByLabel("b");
			var gap:Number;
			if (ptB > ptA) gap = (ptB - ptA) / nPartitions;
			else gap = (ptA - ptB) / nPartitions;
			
			for (var i:int = 1; i < nPartitions; i++) 
			{
				addPoint(points[0].x + i * gap);
			}
		}
		
		private function getPtByLabel(label:String):Number
		{
			for (var i:int = 0; i < points.length; i++) 
			{
				if(points[i].label != null)
					if (points[i].label == label) return points[i].x;
			}
			
			return NaN;
		}
		
		private function calculateSum():void
		{
			if (points.length < 2) return;
			
			var sum:Number = 0;
			var ptA:Number;
			var ptB:Number;
			
			for (var i:int = 0; i < points.length; i++) 
			{
				if (points[i].label == "a") ptA = points[i].x;
				else if (points[i].label == "b") ptB = points[i].x;
				
				if (points[i].h != null) {
					sum += (points[i + 1].x - points[i].x) * f.value(points[i].h);
				}
			}
			
			if (ptA > ptB) sum *= -1;
			
			txtSoma.text = "soma = " + sum.toPrecision(2);
			txtN.text = "n = " + (points.length - 1);
		}
		
		public function get n():int
		{
			return points.length - 1;
		}
		
		public function showSum():void
		{
			txtSoma.visible = true;
			txtN.visible = true;
		}
		
		public function hideSum():void
		{
			txtSoma.visible = false;
			txtN.visible = false;
		}
		
		/**
		 * Salva o estado atual em um Object.
		 * @return Estado atual do gráfico.
		 */
		public function getState():Object
		{
			var state:Object = new Object();
			
			state.n = points.length;
			
			for (var i:int = 0; i < points.length; i++) 
			{
				state[i] = { x: points[i].x, h: points[i].h };
			}
			
			state.xmin = graph.xmin;
			state.xmax = graph.xmax;
			state.ymin = graph.ymin;
			state.ymax = graph.ymax;
			
			return state;
		}
		
		/**
		 * Restaura o estado do gráfico.
		 * @param	state Estado salvo a ser recuperado.
		 */
		public function restoreState(state:Object):void
		{
			points = new Vector.<Object>();
			
			for (var i:int = 0; i < state.n; i++) 
			{
				var obj:Object = new Object();
				obj.x = state[i].x;
				obj.h = state[i].h;
				
				points.push(obj);
			}
			
			graph.xmin = state.xmin;
			graph.xmax = state.xmax;
			graph.ymin = state.ymin;
			graph.ymax = state.ymax;
			
			draw();
		}
		
		/**
		 * Busca um elemento próximo a um ponto. A ordem de busca é: pontos de divisão, pontos de altura, f, F, retângulos.
		 * @param	clickPoint Ponto onde se quer buscar um elemento próximo
		 * @param	minDist Distância em pixel para a busca. Padrão = 5.
		 * @return Retorna um Object com as informações do objeto próximo ao ponto dado.
		 */
		public function searchElement(clickPoint:Point, minDist:Number = 5):Object
		{
			//layerFunctions.graphics.beginFill(0xFFFF00);
			//layerFunctions.graphics.drawCircle(clickPoint.x, clickPoint.y, 2);
			//layerFunctions.graphics.endFill();
			
			var i:int;
			var j:Number;
			var posStage:Point;
			var objReturn:Object;
			
			//Busca nos divisores
			for (i = 0; i < points.length; i++) 
			{
				posStage = getStageCoords(points[i].x, 0);
				if (Point.distance(clickPoint, posStage) < minDist) {
					objReturn = new Object();
					objReturn.type = TYPE_DIVISOR;
					objReturn.index = i;
					objReturn.value = points[i].x;
					objReturn.label = points[i].label;
					
					select(TYPE_DIVISOR, i, points[i].x);
					
					return objReturn;
				}
			}
			
			//Busca nos pontos de altura
			for (i = 0; i < points.length; i++) 
			{
				posStage = getStageCoords(points[i].h, f.value(points[i].h));
				if (Point.distance(clickPoint, posStage) < minDist) {
					objReturn = new Object();
					objReturn.type = TYPE_ALTURA;
					objReturn.index = i;
					objReturn.value = points[i].h;
					
					select(TYPE_ALTURA, i, points[i].h);
					
					return objReturn;
				}
			}
			
			//Busca no f
			for (j = graph.xmin; j < graph.xmax; j+=(graph.xmax - graph.xmin)/100) 
			{
				posStage = getStageCoords(j, f.value(j));
				if (Point.distance(clickPoint, posStage) < minDist * 2) {
					objReturn = new Object();
					objReturn.type = TYPE_FUNCTION;
					//objReturn.index = NaN;
					//objReturn.value = NaN;
					
					select(TYPE_FUNCTION, NaN, NaN);
					
					return objReturn;
				}
			}
			
			//Busca no F(0)
			posStage = getStageCoords(0, F.value(0));
			if (Point.distance(clickPoint, posStage) < minDist) {
				objReturn = new Object();
				objReturn.type = TYPE_PRIMITIVE_C;
				//objReturn.index = NaN;
				//objReturn.value = NaN;
				
				select(TYPE_PRIMITIVE_C, NaN, NaN);
				
				return objReturn;
			}
			
			
			//Busca no F
			for (j = graph.xmin; j < graph.xmax; j+=(graph.xmax - graph.xmin)/100) 
			{
				posStage = getStageCoords(j, F.value(j));
				if (Point.distance(clickPoint, posStage) < minDist * 2) {
					objReturn = new Object();
					objReturn.type = TYPE_PRIMITIVE;
					//objReturn.index = NaN;
					//objReturn.value = NaN;
					
					select(TYPE_PRIMITIVE, NaN, NaN);
					
					return objReturn;
				}
			}
			
			//Busca retângulos
			if(points.length >= 2){
				var pta:Point = getStageCoords(points[0].x, 0);
				var ptb:Point = getStageCoords(points[points.length - 1].x, 0);
				if (clickPoint.x > pta.x && clickPoint.x < ptb.x) {
					var clickOnGraph:Point = getGraphCoords(clickPoint.x, clickPoint.y);
					//var valueClickOnFunction:Number = f.value(clickOnGraph.x);
					//if (clickOnGraph.y < valueClickOnFunction) {
						lookRect: for (i = 1; i < points.length; i++) 
						{
							if (clickOnGraph.x < points[i].x) {
								if(points[i-1].h != null){
									var altura:Number = f.value(points[i - 1].h);
									if (altura < 0) {
										if (clickOnGraph.y > altura && clickOnGraph.y < 0) {
											objReturn = new Object();
											objReturn.type = TYPE_RECTANGLE;
											objReturn.index = i-1;
											//objReturn.value = NaN;
											
											select(TYPE_RECTANGLE, i - 1, NaN);
											
											return objReturn;
										}else {
											break lookRect;
										}
									}else {
										if (clickOnGraph.y < altura && clickOnGraph.y > 0) {
											objReturn = new Object();
											objReturn.type = TYPE_RECTANGLE;
											objReturn.index = i-1;
											//objReturn.value = NaN;
											
											select(TYPE_RECTANGLE, i - 1, NaN);
											
											return objReturn;
										}else {
											break lookRect;
										}
									}
									
								}else {
									break lookRect;
								}
								
							}
						}
					//}
				}
			}
			
			select(TYPE_NONE, NaN, NaN);
			
			objReturn = new Object();
			objReturn.type = TYPE_NONE;
			
			return objReturn;
		}
		
		/**
		 * Seleciona o objeto de acordo com os parâmetros.
		 * @param	type Tipo do objeto
		 * @param	index Indice do objeto no vetor (caso seja uma função = NaN)
		 * @param	value Valor do objeto selecionado (caso não haja valor = NaN)
		 */
		public function select(type:String, index:int, value:Number):void
		{
			selectedIndex = index;
			selectedType = type;
			selectedValue = value;
			
			draw();
		}
		
		public function deleteSelected():void
		{
			if (selectedType == TYPE_NONE) return;
			if (selectedType == TYPE_FUNCTION) return;
			if (selectedType == TYPE_PRIMITIVE) return;
			if (selectedType == TYPE_PRIMITIVE_C) return;
			
			if (selectedType == TYPE_DIVISOR) {
				removePoint(selectedValue);
				select(TYPE_NONE, NaN, NaN);
			}
			
			if (selectedType == TYPE_ALTURA) {
				removePointM(selectedValue);
				select(TYPE_NONE, NaN, NaN);
			}
			
			if (selectedType == TYPE_RECTANGLE) {
				removePointM(points[selectedIndex].h);
				select(TYPE_NONE, NaN, NaN);
			}
			
		}
		
		public function setValueToSelected(value:Number):void
		{
			points[selectedIndex].x = getGraphCoords(value, 0).x;
			selectedValue = points[selectedIndex].x;
			
			draw();
		}
		
		/**
		 * Transforma as coordenadas do gráfico em coordenadas do palco.
		 * @param	graphPointX Coordenada x no gráfico.
		 * @param	graphPointY Coordenada y no gráfico.
		 * @return Retorna um point com as coordenadas do palco.
		 */
		private function getStageCoords(graphPointX:Number, graphPointY:Number):Point
		{
			var posX:Number = graph.x2pixel(graphPointX) + graph.x;
			var posY:Number = graph.y2pixel(graphPointY) + graph.y;
			
			return new Point(posX, posY);
		}
		
		/**
		 * Transforma as coordenadas do palco em coordenadas do gráfico.
		 * @param	mouseX Coordenada x do palco
		 * @param	mouseY Coordenada y do palco.
		 * @return Retorna um point com as coordenadas do gráfico.
		 */
		public function getGraphCoords(mouseX:Number, mouseY:Number):Point
		{
			var posX:Number = graph.pixel2x(mouseX - graph.x);
			var posY:Number = graph.pixel2y(mouseY - graph.y);
			
			return new Point(posX, posY);
		}
		
		/**
		 * Calcula a distância de um número à origem.
		 * @param	dist Número em coordenadas do gráfico 
		 * @return Retorna um ponto contendo a distância do número dado à origem nos eixo x e y.
		 */
		public function getDistanceFromOrigin(dist:Number):Point
		{
			var ptStage:Point = getStageCoords(0, 0);
			ptStage.x += dist;
			ptStage.y += dist;
			var ptOnGraph:Point = getGraphCoords(ptStage.x, ptStage.y);
			
			return ptOnGraph;
		}
		
		/**
		 * Função pública utilizada para redesenhar o gráfico.
		 */
		public function update():void
		{
			draw();
		}
		
		/**
		 * Desloca o gráfico de acordo com o ponto recebido (deslocamento em pixels).
		 * @param	displacement Ponto com o valor em pixels a ser deslocado no eixo x e y.
		 */
		public function panPixel(displacement:Point):void
		{
			//graph.panX = displacement.x;
			//graph.panY = displacement.y;
			var distX:Number = getDistanceFromOrigin(displacement.x).x;
			var distY:Number = getDistanceFromOrigin(displacement.y).y;
			
			graph.setRange(graph.xmin - distX, graph.xmax - distX, graph.ymin - distY, graph.ymax - distY);
			
			updateFunctionsRange();
			
			draw();
		}
		
		public function zoomInCenter():void
		{
			zoomInPtPixel(new Point(graphSize.x / 2, graphSize.y/ 2));
		}
		
		public function zoomOutCenter():void
		{
			zoomOutPtPixel(new Point(graphSize.x / 2, graphSize.y/ 2));
		}
		
		private var zoomRangePercent:Number = 10;
		public function zoomInPtPixel(pt:Point):void
		{
			var zoomRangeX:Number = (graph.xmax - graph.xmin) * zoomRangePercent / 100;
			var zoomRangeY:Number = (graph.ymax - graph.ymin) * zoomRangePercent / 100;
			
			var ptGraph:Point = getGraphCoords(pt.x, pt.y);
			var graphCenter:Point = new Point((graph.xmax - graph.xmin) / 2, (graph.ymax - graph.ymin) / 2);
			
			var pX:Number = (ptGraph.x - graph.xmin) / (graph.xmax - graph.xmin);
			var pY:Number = (ptGraph.y - graph.ymin) / (graph.ymax - graph.ymin);
			
			graph.setRange(graph.xmin + zoomRangeX * pX, graph.xmax - zoomRangeX * (1 - pX), graph.ymin + zoomRangeY * pY, graph.ymax - zoomRangeY * (1 - pY));
			
			updateFunctionsRange();
			
			draw();
		}
		
		public function zoomOutPtPixel(pt:Point):void
		{
			var zoomRangeX:Number = (graph.xmax - graph.xmin) * zoomRangePercent / 100;
			var zoomRangeY:Number = (graph.ymax - graph.ymin) * zoomRangePercent / 100;
			
			var ptGraph:Point = getGraphCoords(pt.x, pt.y);
			var graphCenter:Point = new Point((graph.xmax - graph.xmin) / 2, (graph.ymax - graph.ymin) / 2);
			
			var pX:Number = (ptGraph.x - graph.xmin) / (graph.xmax - graph.xmin);
			var pY:Number = (ptGraph.y - graph.ymin) / (graph.ymax - graph.ymin);
			
			graph.setRange(graph.xmin - zoomRangeX * pX, graph.xmax + zoomRangeX * (1 - pX), graph.ymin - zoomRangeY * pY, graph.ymax + zoomRangeY * (1 - pY));
			
			updateFunctionsRange();
			
			draw();
		}
		
		private function updateFunctionsRange():void
		{
			f.setRange(graph.xmin, graph.xmax);
			F.setRange(graph.xmin, graph.xmax);
		}
		
		/**
		 * Redesenha todo o gráfico da atividade.
		 * Função chamada sempre que algum mobjeto é modificado.
		 */
		private function draw():void 
		{
			graph.draw();
			
			var i:int;
			var pt1:Point;
			var pt2:Point;
			var altura:Point;
			
			layerRects.graphics.clear();
			layerPoints.graphics.clear();
			
			for (i = 0; i < points.length; i++) 
			{
				//Desenha o ponto
				pt1 = getStageCoords(points[i].x, 0);
				drawPoint(pt1, (selectedIndex == i && selectedType == TYPE_DIVISOR));
				if (points[i].label != null) drawChar(points[i].label, pt1);
				
				if (points[i].h != null) {
					
					//Desenha o ponto na função
					altura = getStageCoords(points[i].h, f.value(points[i].h));
					if (showHpoints) drawFunctionPoint(altura, (selectedIndex == i && selectedType == TYPE_ALTURA));
					else if(selectedIndex == i && selectedType == TYPE_ALTURA) drawFunctionPoint(altura, false);
					
					//Desenha os retângulos:
					pt2 = getStageCoords(points[i + 1].x, 0);
					drawRectangle(pt1, pt2, altura, (selectedIndex == i && selectedType == TYPE_RECTANGLE));
					
				}
			}
			
			if (selectedType == TYPE_FUNCTION) {
				removeFunction();
				addFuntcion(true);
			}else {
				removeFunction();
				addFuntcion();
			}
			
			if(showPrimitive){
				if (selectedType == TYPE_PRIMITIVE) {
					removePrimitive();
					addPrimitive(true);
				}else {
					removePrimitive();
					addPrimitive();
				}
			}
			
			
			if (graph.hasFunction(F)) {
				pt1 = getStageCoords(0, F.value(0));
				drawPoint(pt1, selectedType == TYPE_PRIMITIVE_C);
			}
			
		}
		
		/**
		 * Desenha um ponto nas coordenadas dadas.
		 * @param	pt1 Ponto onde será desenhado o ponto.
		 * @param	selected Indica se o ponto está selecionado ou não.
		 */
		private function drawPoint(pt1:Point, selected:Boolean):void
		{
			layerPoints.graphics.lineStyle(1, 0x000000);
			if (selected) {
				layerPoints.graphics.beginFill(0xFF0000);
				layerPoints.graphics.drawCircle(pt1.x, pt1.y, 5);
			}else{
				layerPoints.graphics.beginFill(0x804000);
				layerPoints.graphics.drawCircle(pt1.x, pt1.y, 3);
			}
			layerPoints.graphics.endFill();
		}
		
		/**
		 * Desenha um ponto nas coordenadas dadas.
		 * @param	ptf Ponto onde será desenhado o ponto.
		 * @param	selected Indica se o ponto está selecionado ou não.
		 */
		private function drawFunctionPoint(ptf:Point, selected:Boolean):void
		{
			layerPoints.graphics.lineStyle(1, 0x000000);
			if (selected) {
				layerPoints.graphics.beginFill(0xFF0000);
				layerPoints.graphics.drawCircle(ptf.x, ptf.y, 5);
			}else{
				layerPoints.graphics.beginFill(0x00FF00);
				layerPoints.graphics.drawCircle(ptf.x, ptf.y, 3);
			}
			layerPoints.graphics.endFill();
		}
		
		/**
		 * Desenha o caractere do ponto (label);
		 * @param	char Caractere a ser desenhado.
		 * @param	pt Ponto onde o caractere será desenhado.
		 */
		private function drawChar(char:String, pt:Point):void
		{
			var altura:Number = 10;
			var largura:Number = 8;
			var distancia:Number = 6;
			
			layerPoints.graphics.lineStyle(2, 0x000000);
			if (char == "a" || char == "A") {
				layerPoints.graphics.moveTo(pt.x, pt.y + distancia);
				layerPoints.graphics.lineTo(pt.x - largura/2, pt.y + distancia + altura);
				layerPoints.graphics.moveTo(pt.x, pt.y + distancia);
				layerPoints.graphics.lineTo(pt.x + largura/2, pt.y + distancia + altura);
				layerPoints.graphics.moveTo(pt.x - largura/3, pt.y + distancia + altura/2);
				layerPoints.graphics.lineTo(pt.x + largura/3, pt.y + distancia + altura/2);
			}else if (char == "b" || char == "B") {
				layerPoints.graphics.moveTo(pt.x - largura/2, pt.y + distancia);
				layerPoints.graphics.lineTo(pt.x - largura/2, pt.y + distancia + altura);
				layerPoints.graphics.curveTo(pt.x + largura, pt.y + distancia + altura/2 + altura/4, pt.x - largura/2, pt.y + distancia + altura/2);
				layerPoints.graphics.curveTo(pt.x + largura, pt.y + distancia + altura/4, pt.x - largura/2, pt.y + distancia);
			}
		}
		
		/**
		 * Desenha um retângulo utilizando 3 pontos.
		 * @param	pt1 Primeiro ponto.
		 * @param	pt2 Segundo ponto.
		 * @param	altura Terceiro ponto, utilizado para a altura do retângulo.
		 * @param	selected Indica se o retângulo está selecionado.
		 */
		private function drawRectangle(pt1:Point, pt2:Point, altura:Point, selected:Boolean):void
		{
			if (selected) {
				layerRects.graphics.lineStyle(1, 0xC0C0C0);
				layerRects.graphics.moveTo(pt1.x, pt1.y);
				layerRects.graphics.lineTo(pt1.x, 0);
				layerRects.graphics.moveTo(pt1.x, pt1.y);
				layerRects.graphics.lineTo(pt1.x, stage.stageHeight);
				layerRects.graphics.moveTo(pt2.x, pt2.y);
				layerRects.graphics.lineTo(pt2.x, 0);
				layerRects.graphics.moveTo(pt2.x, pt2.y);
				layerRects.graphics.lineTo(pt2.x, stage.stageHeight);
				
				layerRects.graphics.lineStyle(2, 0x000000);
				layerRects.graphics.beginFill(0x800000, 0.6);
			}else{
				layerRects.graphics.lineStyle(1, 0x000000);
				layerRects.graphics.beginFill(0xFF8000, 0.6);
			}
			layerRects.graphics.moveTo(pt1.x, pt1.y);
			layerRects.graphics.lineTo(pt1.x, altura.y);
			layerRects.graphics.lineTo(pt2.x, altura.y);
			layerRects.graphics.lineTo(pt2.x, pt2.y);
			layerRects.graphics.lineTo(pt1.x, pt1.y);
			layerRects.graphics.endFill();
		}
		
		public function get graphSize():Point 
		{
			return _graphSize;
		}
		
		public function set graphSize(value:Point):void 
		{
			_graphSize.x = value.x;
			_graphSize.y = value.y;
			
			graph.setSize(value.x, value.y);
			
			draw();
		}
		
		public function get lockAB():Boolean 
		{
			return _lockAB;
		}
		
		public function set lockAB(value:Boolean):void 
		{
			_lockAB = value;
		}
		
		public function get defineAB():Boolean 
		{
			return _defineAB;
		}
		
		public function set defineAB(value:Boolean):void 
		{
			if (lockAB) _defineAB = false;
			else _defineAB = value;
		}
		
		public function get abDefined():Boolean 
		{
			return _abDefined;
		}
		
	}

}