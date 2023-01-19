package
{
	import base.*
	import flash.display.*
	import flash.events.*
	import flash.ui.*
	import flash.text.*
	
	// TODO: just copied from Brain.as
	// how is aspect ratio supposed to work? can we do 60/120 fps?
	
	[SWF(width="900",height="550",frameRate="50",backgroundColor="#000000")]
	
	public class MobileBrain extends Brain
	{
		private const TILE_COUNT:Number=10
		private const PADDING_FACTOR:Number=0.1
		private const BUTTONS_X:Array=[0,2,-1,-2,-2,0,-1]
		private const BUTTONS_Y:Array=[-2,-2,-2,-4,-2,0,0]
		private const BUTTONS_W:Array=[2,2,1,2,1,1,1]
		private const BUTTONS_H:Array=[2,2,2,2,2,1,1]
		private const BUTTONS_NAME:Array=["left","right","down","up","shift","space","return"]
		private const BUTTONS_KEY:Array=[Keyboard.LEFT,Keyboard.RIGHT,Keyboard.DOWN,Keyboard.UP,Keyboard.SHIFT,Keyboard.SPACE,Keyboard.ENTER]
		
		private var controls:Sprite
		
		private function hook_construct():void
		{
		}
		
		private function hook_init():void
		{
			stage.setAspectRatio(StageAspectRatio.LANDSCAPE)
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT
			
			// TODO: primitive!
			// adapt buttons on context
			// art
			// customizable layout?
			// hook into code instead of dispatching key events?
			// gestures?
			// pause/retry very janky, should be integrated into UI
			
			controls=new Sprite()
			
			var tileWidth:Number=stage.stageWidth/TILE_COUNT
			var tileHeight:Number=stage.stageHeight/TILE_COUNT
			var padding:Number=tileWidth*PADDING_FACTOR
			
			var format:TextFormat=new TextFormat()
			format.size=tileHeight/3
			format.font="Menlo"
			
			for(var index:int=0;index<BUTTONS_X.length;index++)
			{
				var button:Sprite=new Sprite()
				button.x=BUTTONS_X[index]>=0?BUTTONS_X[index]*tileWidth:stage.stageWidth+BUTTONS_X[index]*tileWidth
				button.y=BUTTONS_Y[index]>=0?BUTTONS_Y[index]*tileHeight:stage.stageHeight+BUTTONS_Y[index]*tileHeight
				button.graphics.beginFill(0xFFFFFF,0.3)
				button.graphics.drawRect(padding/2,padding/2,BUTTONS_W[index]*tileWidth-padding,BUTTONS_H[index]*tileHeight-padding)
				button.graphics.endFill()
				
				var text:TextField=new TextField()
				text.defaultTextFormat=format
				text.text=BUTTONS_NAME[index]
				text.x=padding
				text.y=padding
				button.addChild(text)
				button.mouseChildren=false
				
				function makeCallback(key:int,down:Boolean):Function
				{
					return function(event:Event):void
					{
						stage.dispatchEvent(new KeyboardEvent(down?KeyboardEvent.KEY_DOWN:KeyboardEvent.KEY_UP,true,false,0,key))
					}
				}
				
				button.addEventListener(TouchEvent.TOUCH_BEGIN,makeCallback(BUTTONS_KEY[index],true))
				button.addEventListener(TouchEvent.TOUCH_OVER,makeCallback(BUTTONS_KEY[index],true))
				button.addEventListener(TouchEvent.TOUCH_END,makeCallback(BUTTONS_KEY[index],false))
				button.addEventListener(TouchEvent.TOUCH_OUT,makeCallback(BUTTONS_KEY[index],false))
				
				button.addEventListener(MouseEvent.MOUSE_DOWN,makeCallback(BUTTONS_KEY[index],true))
				button.addEventListener(MouseEvent.MOUSE_UP,makeCallback(BUTTONS_KEY[index],false))
				
				controls.addChild(button)
			}
			
			addChild(controls)
		}
		
		private function hook_death():void
		{
			// TODO: not exactly ideal
			
			setChildIndex(controls,numChildren-1)
		}
		
		public function MobileBrain()
		{
			super()
			hook_construct()
		}
		
		public override function init(event:Event):*
		{
			super.init(event)
			hook_init()
		}
		
		public override function gameOver():*
		{
			super.gameOver()
			hook_death()
		}
	}
}