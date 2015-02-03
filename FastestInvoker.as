package  {
	
	import flash.display.MovieClip;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.sampler.NewObjectSample;
	import flash.media.SoundChannel;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	
	public class FastestInvoker extends Minigame {
		private static const _ZEROS:String = "0000000000000000000000000000000000000000"; // 40 zeros, shorten/expand as you wish
		private static const TENINVOKES:int = 1;
		private static const FIVECOMBOS:int = 2;
		
		private static const QUAS:int = 1;
		private static const WEX:int = 2;
		private static const EXORT:int = 3;
		
		private var leaderboard:String = "Ten Invokes";
		private var gameMode:int = TENINVOKES;
		
		private var startTime:Number = 0;
		private var score:Number = 0;
		private var gameTimer:Timer;
		private var countdownTimer:Timer;
		private var invokeCooldownTimer:Timer;
		private var consumingInput:Boolean = false;
		
		private var currentOrbs:Vector.<Object> = new Vector.<Object>();
		private var usedSpells = new Object();
		private var refreshUsed:Boolean = false;
		private var invokeCooldown:Boolean = false;
		private var fadeClipHeight:Number = 0;
		private var fadeClipY:Number = 0;
		private var currentSpell:String = "invoker_empty1";
		private var invokeList:Vector.<String> = new Vector.<String>();
		private var invokeClipList:Vector.<AbilityImage> = new Vector.<AbilityImage>();
		private var invokeArrowList:Vector.<ArrowClip> = new Vector.<ArrowClip>();
		private var invokesToGo:int = 10;
		private var totalInvokes:int = 10;
		private var toInvoke:int;
		
		private var gameData:Object;
		
		
		private var combosSize:Array = new Array(6,5,4,3,2);
		private var spellNames:Array = new Array("invoker_sun_strike",
										"invoker_chaos_meteor",
										"invoker_alacrity",
										"invoker_emp",
										"invoker_forge_spirit",
										"invoker_deafening_blast",
										"invoker_tornado",
										"invoker_ice_wall",
										"invoker_ghost_walk",
										"invoker_cold_snap");
		
		private var spells:Object = {0:{0:{3:"invoker_sun_strike"},
									    1:{2:"invoker_chaos_meteor"},
									    2:{1:"invoker_alacrity"},
									    3:{0:"invoker_emp"}},
									 1:{0:{2:"invoker_forge_spirit"},
 									    1:{1:"invoker_deafening_blast"},
 									    2:{0:"invoker_tornado"}},
									 2:{0:{1:"invoker_ice_wall"},
									    1:{0:"invoker_ghost_walk"}},
									 3:{0:{0:"invoker_cold_snap"}}};
									 
		private var soundStartup:String = "Tutorial.TaskCompleted";
		private var soundCountdown:String = "ui.click_forward";
		private var soundCountdownDone:String = "ui.click_back";
		private var soundQWE:String = "General.ButtonClick";
		private var soundInvoke:String = "Creep_Good_Melee.PreAttack";
		private var soundCastSuccess:String = "Item.PickUpGemShop";
		private var soundCastFailure:String = "General.CastFail_NoMana";
		private var soundRefresher:String = "DOTA_Item.Refresher.Activate";
		private var soundNextInvoke:String = "Shop.PanelUp";
		private var soundInvokeCooldown:String = "General.CastFail_ItemInCooldown";
		private var soundEnd:String = "crowd.lv_01";
		private var soundEndNewBest:String = "crowd.lv_04";
		
		public function FastestInvoker() {
			this.title = "FASTEST INVOKER";
			this.minigameID = "112871c41019e5cbb2fc0e0d08e7d518";
			//gotoAndStop(2);
			stop();
		}
		
		public override function initialize() : void {
			precacheIcons();
			trace(1);
			//globals.LoadMiniHeroImage("invoker",this.invokerIcon);  //this.invokerIcon.width = 64; this.invokerIcon.height = 64;
			globals.LoadImageWithCallback("images/miniheroes/invoker.png",this.invokerIcon,true, null); //this.invokerIcon.width = 64; this.invokerIcon.height = 64;
			//Globals.instance.LoadImageWithCallback("images/miniheroes/invoker.png",this.qwe1,true, null);
			trace(2);
			globals.LoadAbilityImage("invoker_quas",gameClip.qclip); this.gameClip.qclip.width = 40; gameClip.qclip.height = 40;
			globals.LoadAbilityImage("invoker_wex",gameClip.wclip); this.gameClip.wclip.width = 40; gameClip.wclip.height = 40;
			globals.LoadAbilityImage("invoker_exort",gameClip.eclip); this.gameClip.eclip.width = 40; gameClip.eclip.height = 40;
			globals.LoadAbilityImage("invoker_empty1",gameClip.dclip); this.gameClip.dclip.width = 40; gameClip.dclip.height = 40;
			globals.LoadAbilityImage("invoker_invoke",gameClip.rclip); this.gameClip.rclip.width = 40; gameClip.rclip.height = 40;
			trace(3);
			//globals.LoadItemImage("refresher",this.refresherclip); //this.refresherclip.width = 40; this.refresherclip.height = 40;
			//Globals.instance.LoadImageWithCallback("images/items/refresher.png",this.refresherclip,true, null); //this.refresherclip.width = 40; this.refresherclip.height = 40;
			
			//globals.LoadAbilityImage("invoker_quas",gameClip.qwe1); gameClip.qwe1.width = 64; gameClip.qwe1.height = 64;
			//globals.LoadAbilityImage("invoker_quas",gameClip.qwe2); gameClip.qwe2.width = 64; gameClip.qwe2.height = 64;
			//globals.LoadAbilityImage("invoker_quas",gameClip.qwe3); gameClip.qwe3.width = 64; gameClip.qwe3.height = 64;
			
			trace(4);
			
			menuClip.mode1Button.textField.text = "10 INVOKES";
			menuClip.mode1Button.addEventListener(MouseEvent.CLICK, mode1Click);
			menuClip.mode2Button.textField.text = "5 COMBOS";
			menuClip.mode2Button.addEventListener(MouseEvent.CLICK, mode2Click);
			
			gameClip.retryButton.textField.text = "RETRY";
			gameClip.retryButton.addEventListener(MouseEvent.CLICK, retryClick);
			gameClip.mainmenuButton.textField.text = "MAIN MENU";
			gameClip.mainmenuButton.addEventListener(MouseEvent.CLICK, mainmenuClick);
			
			trace(5);
			retryClip.submitButton.textField.text = "SUBMIT";
			retryClip.retryButton.textField.text = "RETRY";
			retryClip.retryButton.addEventListener(MouseEvent.CLICK, retryClick);
			retryClip.mainmenuButton.textField.text = "MAIN MENU";
			retryClip.mainmenuButton.addEventListener(MouseEvent.CLICK, mainmenuClick);
			
			menuClip.visible = true;
			gameClip.visible = false;
			retryClip.visible = false;
			countdown.visible = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
			
			gameData = minigameAPI.getData();
			fadeClipHeight = gameClip.fadeClip.height;
			fadeClipY = gameClip.fadeClip.y;
			
			globals.GameInterface.PlaySound(soundStartup);
		}
		
		public function precacheIcons(){
			globals.PrecacheImage("images/spellicons/invoker_empty1.png");
			globals.PrecacheImage("images/spellicons/invoker_alacrity.png");
			globals.PrecacheImage("images/spellicons/invoker_cold_snap.png");
			globals.PrecacheImage("images/spellicons/invoker_ghost_walk.png");
			globals.PrecacheImage("images/spellicons/invoker_tornado.png");
			globals.PrecacheImage("images/spellicons/invoker_emp.png");
			globals.PrecacheImage("images/spellicons/invoker_alacrity.png");
			globals.PrecacheImage("images/spellicons/invoker_chaos_meteor.png");
			globals.PrecacheImage("images/spellicons/invoker_sun_strike.png");
			globals.PrecacheImage("images/spellicons/invoker_forge_spirit.png");
			globals.PrecacheImage("images/spellicons/invoker_ice_wall.png");
			globals.PrecacheImage("images/spellicons/invoker_deafening_blast.png");
		}
		
		public override function close() : Boolean{
			return true;
		}
		
		public override function resize(stageWidth:int, stageHeight:int, scaleRatio:Number) : Boolean{
			return true;
		}
		
		private function beginGame(){
			if (gameTimer != null)
				gameTimer.stop();
			if (countdownTimer != null)
				countdownTimer.stop();
			
			for (var index:int=0; index < currentOrbs.length; index++){
				var orb = currentOrbs[index];
				gameClip.removeChild(orb.clip);
			}
			
			for (var j:int=0; j<invokeClipList.length; j++){
				gameClip.spellPanel.removeChild(invokeClipList[j]);
			}
			
			for (var l:int=0; l<invokeArrowList.length; l++){
				gameClip.spellPanel.removeChild(invokeArrowList[l]);
			}
			
			invokeClipList = new Vector.<AbilityImage>();
			invokeArrowList = new Vector.<ArrowClip>();
			
			gameClip.abilityMask.visible = false;
			gameClip.fadeClip.visible = false;
			gameClip.refresherMask.visible = false;
			usedSpells = new Object();
			refreshUsed = false;
			invokeCooldown = false;
			currentSpell = "invoker_empty1";
			globals.LoadAbilityImage(currentSpell,gameClip.dclip); this.gameClip.dclip.width = 40; gameClip.dclip.height = 40;
			
			invokesToGo = totalInvokes;
			gameClip.countToGo.text = invokesToGo;
			currentOrbs = new Vector.<Object>();
				
			countdownTimer = new Timer(1000,3);
			countdownTimer.addEventListener(TimerEvent.TIMER, countdownTime);
			countdownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, countdownDone);
			countdownTimer.start();
			
			globals.GameInterface.PlaySound(soundCountdown);
			
			this.countdown.text = "3";
			gameClip.clockTime.text = "0.000";
			
			menuClip.visible = false;
			gameClip.visible = true;
			retryClip.visible = false;
			countdown.visible = true;
		}
		
		private function startGame(){
			startTime = new Date().time;
			trace(startTime);
			
			gameTimer = new Timer(5,0);
			gameTimer.addEventListener(TimerEvent.TIMER, timeUpdate);
			gameTimer.start();
			
			if (!consumingInput){
				globals.GameInterface.AddKeyInputConsumer();
				consumingInput = true;
			}
			
			nextInvoke();
		}
		
		private function nextInvoke(){
			gameClip.countToGo.text = invokesToGo;
			if (invokesToGo == 0){
				endGame();
				return;
			}
			invokesToGo--;
			
			for (var j:int=0; j<invokeClipList.length; j++){
				gameClip.spellPanel.removeChild(invokeClipList[j]);
			}
			
			for (var l:int=0; l<invokeArrowList.length; l++){
				gameClip.spellPanel.removeChild(invokeArrowList[l]);
			}
			
			gameClip.abilityMask.visible = false;
			gameClip.refresherMask.visible = false;
			gameClip.fadeClip.visible = false;
			invokeCooldown = false;
			usedSpells = new Object();
			refreshUsed = false;
			var prevSpell:String = currentSpell;
			currentSpell = "invoker_empty1";
			globals.LoadAbilityImage(currentSpell,gameClip.dclip); this.gameClip.dclip.width = 40; gameClip.dclip.height = 40;
			
			toInvoke = 0;
			invokeList = new Vector.<String>();
			invokeClipList = new Vector.<AbilityImage>();
			invokeArrowList = new Vector.<ArrowClip>();
			var spell:String;
			
			if (gameMode == TENINVOKES){
				spell = prevSpell;
				while (spell == prevSpell){
					spell = spellNames[Math.floor(Math.random() * 10)];
				}
				invokeList.push(spell);
			}
			else if (gameMode == FIVECOMBOS){
				var size:int = combosSize[invokesToGo];
				
				var used:Object = new Object();
				var refreshNeeded:Boolean = false;
				
				for (var i:int=0; i<size; i++){
					spell = spellNames[Math.floor(Math.random() * 10)];
					
					if (used[spell]){
						if (!refreshNeeded){
							refreshNeeded = true;
							used = new Object();
						}
						else{
							i--;
							continue;
						}
					}
					
					used[spell] = true;
					invokeList.push(spell);
				}
			}
			
			var mid:Number = 260;
			var gap:Number = 10;
			var clip:Number = 64;
			var arrow:Number = 32;
			var maxWidth:Number = 500;
			
			
			var pixels:Number = invokeList.length * clip + (invokeList.length - 1) * (gap*2 + arrow);
			var scale:Number = 1;
			if (pixels > 500){
				scale = 500 / pixels;
			}
			
			var curX:Number = mid - ((clip / 2 + gap + arrow / 2) * (invokeList.length - 1)) * scale
			
			for (var k:int=0; k<invokeList.length; k++){
				var sp:String = invokeList[k];
				var ai:AbilityImage = new AbilityImage(sp, globals);
				
				ai.scaleX = scale;
				ai.scaleY = scale;
				ai.y = 108;
				ai.x = curX;
				
				curX += (clip/2 + gap + arrow/2) * scale;
				
				invokeClipList.push(ai);
				gameClip.spellPanel.addChild(ai);
				
				if (k != invokeList.length - 1){
					// add an arrow
					var arr:ArrowClip = new ArrowClip();
					var arrScale:Number = (32 / arr.width);
					arr.scaleX = scale * arrScale;
					arr.scaleY = scale * arrScale;
					arr.y = 108;
					arr.x = curX;
					
					curX += (clip/2 + gap + arrow/2) * scale;
					
					invokeArrowList.push(arr);
					gameClip.spellPanel.addChild(arr);
				}
			}
			
			invokeClipList[0].current(true);
			invokeClipList[0].pulse();
		}
		
		private function keyHit(e:KeyboardEvent){
			if (!consumingInput)
				return;
			if (e.keyCode == Keyboard.Q){
				pushAndMove(QUAS, new AbilityImage("invoker_quas", globals));
			}
			else if(e.keyCode == Keyboard.W){
				pushAndMove(WEX, new AbilityImage("invoker_wex", globals));
			}
			else if(e.keyCode == Keyboard.E){
				pushAndMove(EXORT, new AbilityImage("invoker_exort", globals));
			}
			else if(e.keyCode == Keyboard.R){
				if (invokeCooldown){
					globals.GameInterface.PlaySound(soundInvokeCooldown);
					return;
				}
				if (currentOrbs.length == 3){
					var q:int = 0;
					var w:int = 0;
					var ex:int = 0;
					for (var i:int = 0; i<currentOrbs.length; i++){
						var orb = currentOrbs[i];
						if (orb.type == QUAS){
							q++;
						}
						else if (orb.type == WEX){
							w++;
						}
						else if (orb.type == EXORT){
							ex++
						}
					}
					
					currentSpell = spells[q][w][ex];
					trace(currentSpell);
					globals.LoadAbilityImage(currentSpell,gameClip.dclip); this.gameClip.dclip.width = 40; gameClip.dclip.height = 40;
					invokeCooldown = true;
					
					gameClip.fadeClip.height = fadeClipHeight;
					gameClip.fadeClip.y = fadeClipY;
					gameClip.fadeClip.visible = true;
					invokeCooldown = true;
					globals.GameInterface.PlaySound(soundInvoke);
					
					invokeCooldownTimer = new Timer(50,20);
					invokeCooldownTimer.addEventListener(TimerEvent.TIMER, invokeCooldownCallback);
					invokeCooldownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, invokeCooldownComplete);
					invokeCooldownTimer.start();
					
					gameClip.abilityMask.visible = false;
					if (usedSpells[currentSpell] == true){
						gameClip.abilityMask.visible = true;
					}
				}
			}
			else if(e.keyCode == Keyboard.D){
				if (currentSpell == "invoker_empty1" || usedSpells[currentSpell])
					return;
				
				// check spell against current toInvoke
				var sp:String = invokeList[toInvoke];
				if (currentSpell != sp){
					// failed
					if (toInvoke != 0){
						toInvoke = 0;
						for (var j:int=0; j<invokeClipList.length; j++){
							invokeClipList[j].current(false);
							invokeClipList[j].done(false);
						}
						invokeClipList[0].current(true);
						invokeClipList[0].pulse();
					}
					gameClip.refresherMask.visible = false;
					gameClip.abilityMask.visible = false;
					usedSpells = new Object();
					refreshUsed = false;
					globals.GameInterface.PlaySound(soundCastFailure);
					return;
				}
				
				invokeClipList[toInvoke].current(false);
				invokeClipList[toInvoke].done(true);
				toInvoke++;
				
				globals.GameInterface.PlaySound(soundCastSuccess);
				
				if (toInvoke == invokeClipList.length){
					// Successful combo
					globals.GameInterface.PlaySound(soundNextInvoke);
					nextInvoke();
					return;
				}
				
				invokeCooldown = false;
				gameClip.fadeClip.visible = false;
				invokeClipList[toInvoke].current(true);
				invokeClipList[toInvoke].pulse();
				usedSpells[currentSpell] = true;
				gameClip.abilityMask.visible = true;
			}
			else if(e.keyCode == Keyboard.NUMBER_1){
				trace('key 1')
				if (refreshUsed)
					return;
					
				globals.GameInterface.PlaySound(soundRefresher);
				usedSpells = new Object();
				refreshUsed = true;
				gameClip.refresherMask.visible = true;
				gameClip.abilityMask.visible = false;
				gameClip.fadeClip.visible = false;
				invokeCooldown = false;
			}
		}
		
		private function invokeCooldownCallback(e:TimerEvent){
			if (!invokeCooldown){
				invokeCooldownTimer.stop();
				gameClip.fadeClip.visible = false;
				return;
			}
			
			gameClip.fadeClip.height -= fadeClipHeight / 20;
			gameClip.fadeClip.y += fadeClipHeight / 20;
		}
		
		private function invokeCooldownComplete(e:TimerEvent){
			invokeCooldown = false;
			gameClip.fadeClip.visible = false;
		}
		
		private function pushAndMove(type:int, ai:AbilityImage){
			var orb;
			globals.GameInterface.PlaySound(soundQWE);
			if (currentOrbs.length >= 3){
				orb = currentOrbs.shift();
				gameClip.removeChild(orb.clip);
			}
			
			for (var i:int = currentOrbs.length - 1; i >= 0; i--){
				orb = currentOrbs[i];
				orb.clip.x += 75;
			}
			
			ai.x = 34.25;
			ai.y = 346.25;
			ai.pulse();
			gameClip.addChild(ai);
			currentOrbs.push({type:type, clip:ai});
		}
		
		private function endGame(){
			gameTimer.stop();
			score = new Date().time - startTime;
			var sec:String = String(Math.floor(score / 1000));
			var ms:String = uint_Zeropadded(score % 1000, 3);
			
			trace("END GAME");
			trace(score);
			var best:Number = gameData[leaderboard];
			trace(best);
			if (score < best){
				best = score;
				gameData[leaderboard] = best;
				minigameAPI.saveData();
				trace("SAVED");
				globals.GameInterface.PlaySound(soundEndNewBest);
			}
			else{
				globals.GameInterface.PlaySound(soundEnd);
			}
			var sec2:String = String(Math.floor(best / 1000));
			var ms2:String = uint_Zeropadded(best % 1000, 3);
			
			retryClip.clockTime.text = sec + "." + ms;
			retryClip.bestTime.text = sec2 + "." + ms2;
			
			retryClip.submitButton.textField.text = "SUBMIT";
			retryClip.submitButton.addEventListener(MouseEvent.CLICK, submitClick);
			
			menuClip.visible = false;
			gameClip.visible = false;
			retryClip.visible = true;
			countdown.visible = false;
			
			if (consumingInput){
				globals.GameInterface.RemoveKeyInputConsumer();
				consumingInput = false;
			}
		}
		
		private function countdownTime(e:TimerEvent){
			this.countdown.text = String(Number(this.countdown.text) - 1);
			if (this.countdown.text != "0")
				globals.GameInterface.PlaySound(soundCountdown);
		}
		
		private function countdownDone(e:TimerEvent){
			countdown.visible = false;
			startGame();
			globals.GameInterface.PlaySound(soundCountdownDone);
		}
		
		private function timeUpdate(e:TimerEvent){
			score = new Date().time - startTime;
			var sec:String = String(Math.floor(score / 1000));
			var ms:String = uint_Zeropadded(score % 1000, 3);
			
			
			gameClip.clockTime.text = sec + "." + ms;
			
			if (score > 10 * 60000) {
				endGame();
				gameTimer.stop();
			}
		}
		
		private function mode1Click(e:MouseEvent){
			gameMode = TENINVOKES;
			totalInvokes = 10;
			leaderboard = "Ten Invokes";
			if (gameData["Ten Invokes"] == null){
				gameData["Ten Invokes"] = 600000;
			}
			beginGame();
		}
		
		private function mode2Click(e:MouseEvent){
			gameMode = FIVECOMBOS;
			totalInvokes = 5;
			leaderboard = "Five Combos";
			if (gameData["Five Combos"] == null){
				gameData["Five Combos"] = 600000;
			}
			
			beginGame();
		}
		
		private function submitClick(e:MouseEvent){
			this.minigameAPI.updateLeaderboard(leaderboard, score);
			retryClip.submitButton.textField.text = "SUBMITTED!";
			retryClip.submitButton.enabled = false;
			retryClip.submitButton.removeEventListener(MouseEvent.CLICK, submitClick);
		}
		
		private function retryClick(e:MouseEvent){
			beginGame();
		}
		
		private function mainmenuClick(e:MouseEvent){
			menuClip.visible = true;
			gameClip.visible = false;
			retryClip.visible = false;
			countdown.visible = false;
		}

        /*
         * f: positive integer value
         * z: maximum number of leading zeros of the numeric part (sign takes one extra digit)
         */
        public static function uint_Zeropadded(f:uint, z:int = 0):String {
            var result:String = f.toString();
            while (result.length < z)
                result = _ZEROS.substr(0, z - result.length) + result;
            return result;
        }
	}
	
}
