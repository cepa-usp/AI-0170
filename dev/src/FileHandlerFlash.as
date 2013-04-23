package  
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FileHandlerFlash implements FileHandler
	{
		private var _content:String;
		private var returnFunction:Function;
		private var telaPaste:LoadStringScreen = new LoadStringScreen();
		private var stage:Stage;
		
		public function FileHandlerFlash(stage:Stage) 
		{
			this.stage = stage;
		}
		
		public function save(content:String):void
		{
			if (encrypt) System.setClipboard(compress(content));
			else System.setClipboard(content);
		}
		
		public function saveAs(content:String):void{
			save(content);
		}
		
		public function abrir(returnFunction:Function):void {
			this.returnFunction = returnFunction;
			telaPaste.pasteText.text = "";
			telaPaste.ok.addEventListener(MouseEvent.CLICK, carregado);
			telaPaste.cancel.addEventListener(MouseEvent.CLICK, cancel);
			stage.addChild(telaPaste);
		}
		
		private function cancel(e:MouseEvent):void 
		{
			telaPaste.ok.removeEventListener(MouseEvent.CLICK, carregado);
			telaPaste.cancel.removeEventListener(MouseEvent.CLICK, cancel);
			stage.removeChild(telaPaste);
		}
		
		public function get content():String 
		{
			return _content;
		}
		
		private function carregado(e:MouseEvent):void {
			telaPaste.ok.removeEventListener(MouseEvent.CLICK, carregado);
			telaPaste.cancel.removeEventListener(MouseEvent.CLICK, cancel);
			
			try{
				if (encrypt) _content = uncompress(telaPaste.pasteText.text);
				else _content = telaPaste.pasteText.text;
				if (returnFunction != null) returnFunction(_content);
			}catch (err:Error){
				
			}
			stage.removeChild(telaPaste);
		}
		
		private var encrypt:Boolean = true;
		private static function compress( str:String ) :String
		{
		   var b:ByteArray = new ByteArray();
		   b.writeObject( str );
		   b.compress();
		   return Base64.Encode( b );
		}

		private static function uncompress( str:String ) :String
		{
		   var b:ByteArray = Base64.Decode( str );
		   b.uncompress();
		   var strB:String = b.toString();
		   var index:int = strB.indexOf("{");
		   return strB.substring(index);
		}
		
	}

}