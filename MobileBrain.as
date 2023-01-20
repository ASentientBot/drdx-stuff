package
{
	import base.*
	import flash.display.*
	import flash.events.*
	import flash.ui.*
	import flash.utils.*
	
	public class MobileBrain extends Brain
	{
		// TODO: seems like various stuff is hardcoded to expect these (from Brain.as)
		// how feasible will it be to increase resolution (without scaling) or framerate?
		
		private const NORMAL_WIDTH:int=900
		private const NORMAL_HEIGHT:int=550
		private const NORMAL_FPS:int=50
		private const NORMAL_COLOR:int=0x000000
		
		private const TILE_COUNT:Number=10
		private const PADDING_FACTOR:Number=0.1
		
		private var controls:Sprite
		
		private function hideButtons()
		{
			controls.removeChildren()
		}
		
		// TODO: would make more sense to just add one at a time...
		
		private function showButtons(xs:Array,ys:Array,ws:Array,hs:Array,names:Array,keys:Array)
		{
			hideButtons()
			
			// TODO: art/font/integration into UI
			// TODO: customizable layout?
			// TODO: hook into code instead of dispatching key events?
			// TODO: gestures?
			// TODO: ability to lock/toggle buttons down?
			
			var tileWidth:Number=stage.stageWidth/TILE_COUNT
			var tileHeight:Number=stage.stageHeight/TILE_COUNT
			var padding:Number=tileWidth*PADDING_FACTOR
			
			for(var index:int=0;index<xs.length;index++)
			{
				var button:Button=new Button(ws[index]*tileWidth,hs[index]*tileHeight,padding,names[index],buttonCallback,keys[index])
				button.x=xs[index]>=0?xs[index]*tileWidth:stage.stageWidth+xs[index]*tileWidth
				button.y=ys[index]>=0?ys[index]*tileHeight:stage.stageHeight+ys[index]*tileHeight
				
				function buttonCallback(down:Boolean,key:int):void
				{
					stage.dispatchEvent(new KeyboardEvent(down?KeyboardEvent.KEY_DOWN:KeyboardEvent.KEY_UP,true,false,0,key))
				}
				
				controls.addChild(button)
			}
		}
		
		private function fixLayout():void
		{
			var widthRatio:Number=stage.stageWidth/NORMAL_WIDTH
			var heightRatio:Number=stage.stageHeight/NORMAL_HEIGHT
			if(widthRatio>heightRatio)
			{
				scaleX=widthRatio
				scaleY=widthRatio
				var extraHeight:Number=widthRatio*NORMAL_HEIGHT-stage.stageHeight
				y=extraHeight/-2
				trace("Amy: wide, scale: "+scaleX+", y: "+y)
			}
			else
			{
				scaleX=heightRatio
				scaleY=heightRatio
				var extraWidth:Number=heightRatio*NORMAL_WIDTH-stage.stageWidth
				x=extraWidth/-2
				trace("Amy: tall, scale: "+scaleX+", x: "+x)
			}
		}
		
		private function hookConstruct():void
		{
			trace("Amy: constructor hook")
			
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT
			
			stage.scaleMode=StageScaleMode.NO_SCALE
			stage.align=StageAlign.TOP_LEFT
			stage.color=NORMAL_COLOR
			stage.frameRate=NORMAL_FPS
			
			function resizeCallback(event:Event):void
			{
				trace("Amy: resized width: "+stage.stageWidth+", height: "+stage.stageHeight)
				fixLayout()
			}
			
			stage.addEventListener(Event.RESIZE,resizeCallback)
			fixLayout()
			
			// TODO: on iPhone SE, intermittently opens shifted left?
			
			controls=new Sprite()
			stage.addChild(controls)
			
			var state:String=null
			var view:String=null
			function frameCallback(event:Event):void
			{
				if(gState==state&&interF.current==view)
				{
					return
				}
				state=gState
				view=interF.current
				
				trace("Amy: state changed, brain: "+state+", ui: "+view)
				
				// TODO: cleanup
				
				switch(state)
				{
					case "game":
						showButtons([0,2,-2,-2,-3,0],[-2,-2,-2,-4,-2,0],[2,2,2,2,1,1],[2,2,2,2,2,2],["left","right","duck","jump","boost","pause"],[Keyboard.LEFT,Keyboard.RIGHT,Keyboard.DOWN,Keyboard.UP,Keyboard.SHIFT,Keyboard.SPACE])
						break
					
					// TODO: more specific
					
					case "pause":
						if(view=="Main")
						{
							hideButtons()
							break
						}
					case "extinct":
					case "endLevel":
					case "win":
						showButtons([0,5],[-2,-2],[5,5],[2,2],["continue","quit"],[Keyboard.SPACE,Keyboard.ENTER])
						break
					
					default:
						hideButtons()
				}
			}
			
			stage.addEventListener(Event.ENTER_FRAME,frameCallback)
		}
		
		public function MobileBrain()
		{
			super()
			hookConstruct()
		}
		
		// TODO: remove unused hooks
		
		public override function newLevel(retry:*,level:*):*
		{
			super.newLevel(retry,level)
			trace("Amy: start game hook")
		}
		
		public override function gameOver():*
		{
			super.gameOver()
			trace("Amy: death hook")
		}
		
		public override function restart():*
		{
			super.restart()
			trace("Amy: end game hook")
		}
	}
}