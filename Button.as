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
		
		public function Button(w:Number,h:Number,padding:Number,name:String,callback:Function,context:*)
		{
			super()
			
			this.w=w
			this.h=h
			this.padding=padding
			this.context=context
			this.callback=callback
			
			var text:TextField=new TextField()
			text.autoSize=TextFieldAutoSize.LEFT
			text.text=name
			
			// TODO: cursed
			
			var format:TextFormat=new TextFormat()
			format.font="sans-serif"
			format.size=0
			format.color=0x000000
			while(text.width<w-padding*2&&text.height<h-padding*2)
			{
				format.size=(format.size as Number)+1
				text.setTextFormat(format)
			}
			text.x=(w-text.width)/2
			text.y=(h-text.height)/2
			text.alpha=0.2
			addChild(text)
			mouseChildren=false
			
			trace("Amy: button w: "+w+", h: "+h+", padding: "+padding+", name: "+name+", size: "+format.size)
			
			// TODO: does destroying the sprite remove these?
			
			addEventListener(TouchEvent.TOUCH_BEGIN,downCallback)
			addEventListener(TouchEvent.TOUCH_OVER,downCallback)
			addEventListener(TouchEvent.TOUCH_END,upCallback)
			addEventListener(TouchEvent.TOUCH_OUT,upCallback)
			
			addEventListener(MouseEvent.MOUSE_DOWN,downCallback)
			addEventListener(MouseEvent.MOUSE_UP,upCallback)
			
			draw(false)
		}
		
		private function downCallback(event:Event):void
		{
			draw(true)
			callback(true,context)
		}
		
		private function upCallback(event:Event):void
		{
			draw(false)
			callback(false,context)
		}
		
		private function draw(down:Boolean):void
		{
			graphics.clear()
			graphics.beginFill(0xffffff,down?0.7:0.2)
			graphics.drawRoundRect(padding/2,padding/2,w-padding,h-padding,padding*4)
			graphics.endFill()
		}
	}
}