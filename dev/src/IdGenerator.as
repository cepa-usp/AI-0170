package  
{
	/**
	 * ...
	 * @author Alexandre
	 */
	public final class IdGenerator 
	{
		
		public function IdGenerator() 
		{
			
		}
		
		private static var id:int = 0;
		public static function getId():int
		{
			return id++;
		}
		
	}

}