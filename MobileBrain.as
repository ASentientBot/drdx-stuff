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
		private var prevState:String
		private var prevView:String
		
		private function clearButtons()
		{
			controls.removeChildren()
		}
		
		// TODO: clean up size calculations...
		
		private function addButton(x:Number,y:Number,w:Number,h:Number,name:String,key:int):void
		{
			var tileWidth:Number=stage.stageWidth/TILE_COUNT
			var tileHeight:Number=stage.stageHeight/TILE_COUNT
			var padding:Number=tileWidth*PADDING_FACTOR
			
			var fontSize:Number=w>1?padding*5:padding*2
			
			var button:Button=new Button(w*tileWidth,h*tileHeight,padding,name,fontSize,callback,key)
			button.x=x>=0?x*tileWidth:stage.stageWidth+x*tileWidth
			button.y=y>=0?y*tileHeight:stage.stageHeight+y*tileHeight
			
			function callback(down:Boolean,key:int):void
			{
				stage.dispatchEvent(new KeyboardEvent(down?KeyboardEvent.KEY_DOWN:KeyboardEvent.KEY_UP,true,false,0,key))
			}
			
			controls.addChild(button)
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
		
		private function resizeCallback(event:Event):void
		{
			trace("Amy: resized width: "+stage.stageWidth+", height: "+stage.stageHeight)
			fixLayout()
		}
		
		function frameCallback(event:Event):void
		{
			var state:String=gState
			var view:String=interF.current
			if(state!=prevState||view!=prevView)
			{
				trace("Amy: state changed, brain: "+state+", ui: "+view)
				
				prevState=state
				prevView=view
				
				clearButtons()
				
				if(view=="Race")
				{
					if(state=="game")
					{
						addButton(0,-2,2,2,"left",Keyboard.LEFT)
						addButton(2,-2,2,2,"right",Keyboard.RIGHT)
						addButton(-2,-2,2,2,"duck",Keyboard.DOWN)
						addButton(-2,-4,2,2,"jump",Keyboard.UP)
						addButton(-3,-2,1,2,"boost",Keyboard.SHIFT)
						addButton(0,0,1,2,"pause",Keyboard.SPACE)
					}
					else if(state=="pause")
					{
						addButton(0,0,3,2,"resume",Keyboard.SPACE)
						addButton(-2,0,2,2,"quit",Keyboard.ENTER)
					}
					else if(state=="extinct")
					{
						if(sys2.stats.cont>0)
						{
							addButton(0,0,3,2,"retry",Keyboard.SPACE)
							addButton(-2,0,2,2,"quit",Keyboard.ENTER)
						}
						else
						{
							addButton(4,0,2,2,"quit",Keyboard.ENTER)
						}
					}
					else if(state=="win")
					{
						addButton(4,0,2,2,"quit",Keyboard.ENTER)
					}
				}
			}
		}
		
		public function MobileBrain()
		{
			trace("Amy: constructor hook")
			
			super()
			
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT
			
			stage.scaleMode=StageScaleMode.NO_SCALE
			stage.align=StageAlign.TOP_LEFT
			stage.color=NORMAL_COLOR
			stage.frameRate=NORMAL_FPS
			
			stage.addEventListener(Event.RESIZE,resizeCallback)
			fixLayout()
			
			// TODO: on iPhone SE, intermittently opens shifted left?
			
			controls=new Sprite()
			stage.addChild(controls)
			
			stage.addEventListener(Event.ENTER_FRAME,frameCallback)
		}
	}
}