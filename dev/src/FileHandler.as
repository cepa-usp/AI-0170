package  
{
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public interface FileHandler 
	{
		function save(content:String):void;
		function saveAs(content:String):void;
		function abrir(returnFunction:Function):void;
		function get content():String;
		
	}
	
}