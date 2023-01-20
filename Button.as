package
{
	import flash.display.*
	import flash.text.*
	import flash.events.*
	
	public class Button extends Sprite
	{
		private var w:Number
		private var h:Number
		private var padding:Number
		private var callback:Function
		private var context:*
		private var down:Boolean
		
		public function Button(w:Number,h:Number,padding:Number,name:String,fontSize:Number,callback:Function,context:*)
		{
			super()
			
			this.w=w
			this.h=h
			this.padding=padding
			this.context=context
			this.callback=callback
			
			var format:TextFormat=new TextFormat()
			format.font="DinoRunInfoText02_8pt Regular_16pt_st"
			format.size=fontSize
			format.color=0x000000
			
			var text:TextField=new TextField()
			text.autoSize=TextFieldAutoSize.LEFT
			text.embedFonts=true
			text.defaultTextFormat=format
			text.text=name
			text.x=(w-text.width)/2
			text.y=(h-text.height)/2
			text.alpha=0.2
			addChild(text)
			mouseChildren=false
			
			trace("Amy: button w: "+w+", h: "+h+", padding: "+padding+", name: "+name+", size: "+fontSize)
			
			// TODO: does destroying the sprite remove these?
			
			addEventListener(TouchEvent.TOUCH_BEGIN,downCallback)
			addEventListener(TouchEvent.TOUCH_OVER,downCallback)
			addEventListener(TouchEvent.TOUCH_END,upCallback)
			addEventListener(TouchEvent.TOUCH_OUT,upCallback)
			
			addEventListener(MouseEvent.MOUSE_DOWN,downCallback)
			addEventListener(MouseEvent.MOUSE_UP,upCallback)
			
			down=false
			draw()
		}
		
		private function downCallback(event:Event):void
		{
			if(!down)
			{
				down=true
				draw()
				callback(true,context)
			}
		}
		
		private function upCallback(event:Event):void
		{
			if(down)
			{
				down=false
				draw()
				callback(false,context)
			}
		}
		
		private function draw():void
		{
			graphics.clear()
			graphics.beginFill(0xffffff,down?0.6:0.2)
			graphics.drawRoundRect(padding/2,padding/2,w-padding,h-padding,padding*4)
			graphics.endFill()
		}
	}
}