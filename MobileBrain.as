package
{
	import base.*
	import flash.display.*
	import flash.events.*
	import flash.ui.*
	import flash.utils.*
	import flash.text.*
	
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
		private var hasGameButtons:Boolean
		private var prevBoost:Boolean
		
		private function clearButtons():void
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
				x=0
				trace("Amy: screen is wide, scale: "+scaleX+", y: "+y)
			}
			else
			{
				scaleX=heightRatio
				scaleY=heightRatio
				var extraWidth:Number=heightRatio*NORMAL_WIDTH-stage.stageWidth
				x=extraWidth/-2
				y=0
				trace("Amy: screen is tall, scale: "+scaleX+", x: "+x)
			}
		}
		
		private function resizeCallback(event:Event):void
		{
			trace("Amy: resized width: "+stage.stageWidth+", height: "+stage.stageHeight)
			fixLayout()
		}
		
		private function debugViewToStringRecursive(view:DisplayObjectContainer,depth:int=1):String
		{
			var output:String=""
			for(var index:int=0;index<view.numChildren;index++)
			{
				var child:*=view.getChildAt(index)
				for(var pad:int=0;pad<depth;pad++)
				{
					output+=" "
				}
				output+=child
				if(child is DisplayObject)
				{
					output+=" (name: "+child.name+", x: "+child.x+", y: "+child.y+", w: "+child.width+", h: "+child.height+")"
				}
				if(child is TextField)
				{
					output+=" (text: "+child.text.replace("\r","\\r")+")"
				}
				if(child is MovieClip)
				{
					output+=" (label: "+child.currentLabel+")"
				}
				output+="\n"
				if(child is DisplayObjectContainer)
				{
					output+=debugViewToStringRecursive(child,depth+1)
				}
			}
			return output
		}
		
		private function debugPrintViewHierarchy():void
		{
			trace("Amy: view hierarchy: \n"+debugViewToStringRecursive(stage,1))
		}
		
		private function debugPrintFonts():void
		{
			var fonts:Array=Font.enumerateFonts()
			var fontString:String=""
			for(var index:int in fonts)
			{
				fontString+=fonts[index].fontName+", "
			}
			trace("Amy: available fonts: "+fontString)
		}
		
		private function frameCallback(event:Event):void
		{
			var state:String=gState
			var view:String=interF.current
			if(state!=prevState||view!=prevView)
			{
				trace("Amy: state changed, brain: "+state+", ui: "+view)
				
				// TODO: debugging
				
				debugPrintViewHierarchy()
				
				prevState=state
				prevView=view
				
				clearButtons()
				hasGameButtons=false
				
				if(view=="Race"||view=="")
				{
					if(state=="game")
					{
						hasGameButtons=true
						refreshGameButtons()
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
						hasGameButtons=true
						refreshGameButtons()
					}
					else if(state=="endLevel")
					{
						addButton(3.5,0,3,2,"continue",Keyboard.SPACE)
					}
				}
			}
			
			if(hasGameButtons)
			{
				if(prevBoost&&dino.adren<1000)
				{
					trace("Amy: hide boost")
					prevBoost=false
					refreshGameButtons()
				}
				if(!prevBoost&&dino.adren>=1000)
				{
					trace("Amy: show boost")
					prevBoost=true
					refreshGameButtons()
				}
			}
			
			// TODO: not exactly efficient
			
			function refreshGameButtons():void
			{
				clearButtons()
				addButton(0,-2,2,2,"left",Keyboard.LEFT)
				addButton(2,-2,2,2,"right",Keyboard.RIGHT)
				addButton(-2,-2,2,2,"duck",Keyboard.DOWN)
				addButton(-2,-4,2,2,"jump",Keyboard.UP)
				if(dino.adren>=1000)
				{
					addButton(-3,-2,1,2,"boost",Keyboard.SHIFT)
				}
				if(state=="game")
				{
					addButton(0,0,1,2,"pause",Keyboard.SPACE)
				}
				if(state=="win")
				{
					addButton(4,0,2,2,"quit",Keyboard.ENTER)
				}
			}
		}
		
		public function MobileBrain()
		{
			trace("Amy: constructor hook")
			
			super()
			
			Config.STEAM=false
			
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT
			
			stage.scaleMode=StageScaleMode.NO_SCALE
			stage.align=StageAlign.TOP_LEFT
			stage.color=NORMAL_COLOR
			stage.frameRate=NORMAL_FPS
			
			stage.addEventListener(Event.RESIZE,resizeCallback)
			fixLayout()
			
			controls=new Sprite()
			stage.addChild(controls)
			
			stage.addEventListener(Event.ENTER_FRAME,frameCallback)
		}
	}
}