package
{
	import com.larrio.flow.ITaskKernel;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class AnimalKernal extends EventDispatcher implements ITaskKernel
	{
		private var _url:String;
		private var _result:Loader;
		
		private var _name:String;
		
		public function AnimalKernal()
		{
			
		}

		public function execute(data:Object):void
		{			
			_url = data as String;
			_name = String(_url.split("?").shift()).match(/\w+\.\w+$/)[0];
			
			_result = null;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			var request:URLRequest = new URLRequest(_url);
			request.requestHeaders.push(new URLRequestHeader("Referer", "http://user.qzone.qq.com/"));
			loader.addEventListener(Event.COMPLETE, assetHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, assetHandler);
			
			loader.load(request);
		}
		
		protected function assetHandler(e:Event):void
		{
			var target:URLLoader = e.currentTarget as URLLoader;
			target.removeEventListener(Event.COMPLETE, arguments.callee);
			target.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);			
			
			if (e.type != Event.COMPLETE)
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				return;
			}
			
			var file:File = new File(URL.DOWNLOADS.url + "/" + _name);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(target.data);
			stream.close();
			
			var bytes:ByteArray = new ByteArray();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
			
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.loadBytes(bytes, context);
		}
		
		protected function completeHandler(e:Event):void
		{
			var target:LoaderInfo = e.currentTarget as LoaderInfo;
			target.removeEventListener(e.type, arguments.callee);
			
			_result = target.loader;
			dispatchEvent(new Event(Event.COMPLETE));
			
			target.loader.unloadAndStop(true);
		}
		
		public function get data():Object
		{
			return _url;
		}
		
		public function get result():Object
		{
			return _result;
		}

		public function get name():String
		{
			return _name;
		}
	}
}