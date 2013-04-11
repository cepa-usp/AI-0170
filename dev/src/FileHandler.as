package  
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import fl.data.DataProvider;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FileHandler 
	{
		private var arquivo:File = File.desktopDirectory;
		private var formato:String;
		private var loader:URLLoader = new URLLoader();
		
		private var _content:String;
		private var returnFunction:Function;
		
		private var currentPath:String = "";
		
		public function FileHandler(formato:String) 
		{
			this.formato = formato;
		}
		
		public function save(content:String):void
		{
			if (currentPath == "") saveAs(content);
			else {
				var confFile:File = new File(currentPath);
				var FSt:FileStream = new FileStream();
				FSt.open(confFile, FileMode.WRITE);
				if (encrypt) FSt.writeUTFBytes(compress(content));
				else FSt.writeUTFBytes(content);
				FSt.close();
			}
		}
		
		public function saveAs(content:String):void{
			this._content = content;
			arquivo.browseForSave("Salvar configuração");
			arquivo.addEventListener(Event.SELECT, salvarArquivo);
		}
		
		public function abrir(returnFunction:Function):void{
			this.returnFunction = returnFunction;
			selecionar();
		}
		
		private function selecionar():void{
			var fileFilter:FileFilter = new FileFilter("Arquivo de configuração (." + formato + ")","*." + formato + ";");
			arquivo.browseForOpen("Abrir Arquivo de Configuração", [fileFilter]);
			arquivo.addEventListener(Event.SELECT, abrirArquivo);
		}
		
		private function salvarArquivo(e:Event):void {
			arquivo.removeEventListener(Event.SELECT, salvarArquivo);
			var tArr:Array = File(e.target).nativePath.split(File.separator);
			var nome:String = tArr.pop();
			var confFileDef:String = confExt(nome);
			tArr.push(confFileDef);
			currentPath = tArr.join(File.separator)
			var confFile:File = new File(currentPath);
			var FSt:FileStream = new FileStream();
			FSt.open(confFile, FileMode.WRITE);
			if (encrypt) FSt.writeUTFBytes(compress(content));
			else FSt.writeUTFBytes(content);
			FSt.close();
		}
		
		private function confExt(fileDef:String):String{
			/*var fileExt:String = fileDef.split(".")[1];
			for each (var i:String in Formato){
				if (fileExt == i){
					return fileDef;
				}
			}*/
			return fileDef.split(".")[0] + "." + formato;
		}
		
		private function abrirArquivo(e:Event):void {
			arquivo.removeEventListener(Event.SELECT, abrirArquivo);
			//var Load:URLLoader = new URLLoader();
			currentPath = arquivo.nativePath;
			loader.load(new URLRequest(arquivo.nativePath));
			loader.addEventListener(Event.COMPLETE, carregado);
		}
		
		private function carregado(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, carregado);
			if (encrypt) _content = uncompress(e.target.data);
			else _content = e.target.data;
			if (returnFunction != null) returnFunction(_content);
			//texto.text = e.target.data;
			//nome_ar.text = arquivo.name;
		}
		
		public function get content():String 
		{
			return _content;
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