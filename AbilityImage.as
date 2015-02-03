package  {
	
	import flash.display.MovieClip;
	import fl.transitions.TweenEvent;
	import fl.transitions.Tween;
	
	
	public class AbilityImage extends MovieClip {
		
		
		public function AbilityImage(imageName:String, globals) {
			globals.LoadAbilityImage(imageName,this.image); this.image.width = 64; this.image.height = 64;
			green.visible = false;
			currentClip.visible = false;
			stop();
		}
		
		public function pulse(){
			var cursx = scaleX;
			var cursy = scaleY;
			var tween:Tween = new Tween(this, "scaleX", null, 1.2 * cursx, cursx, .2, true);
			tween.start();
			var tween2:Tween = new Tween(this, "scaleY", null, 1.2 * cursy, cursy, .2, true);
			tween2.start();
		}
		
		public function current(b:Boolean){
			currentClip.visible = b;
		}
		
		public function done(b:Boolean){
			green.visible = b;
			
		}
	}
	
}
