package  
{
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.Graph;
	import cepa.graph.rectangular.SimpleGraph;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Grafico 
	{
		private var graph:Graph_view;
		private var model:Graph_model;
		
		public function Grafico(f:GraphFunction, F:GraphFunction, points:Vector.<Object> = null) 
		{
			model = new Graph_model(f, F, points);
		}
		
	}

}