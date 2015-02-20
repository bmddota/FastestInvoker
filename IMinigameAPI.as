package  {
	
	public interface IMinigameAPI {

		// Interface methods:
		function getData() : Object;
		function saveData() : void;
		
		function resizeGameWindow(wid:Number = -1, hei:Number = -1) : void;
		function repositionGameWindow(xpos:Number = -1000, ypos:Number = -1000) : void;
		function closeMinigame() : void;
		function updateTitle() : void;
		function updateLeaderboard(leaderboard:String, value:Number) : void;
		function getLeaderboardTop(leaderboard:String, callback:Function) : void;
		function getUserID() : String;
	 	function translate(str:String) : String;
		
		function log(obj:Object) : void;
	}
}
