/**
 *	资源管理器
 * 	负责加载和维护所有的资源 
 */
package blade3d.resource
{
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	import blade3d.effect.BlEffectManager;
	import blade3d.filesystem.BlFileSystem;
	import blade3d.filesystem.BlFlashFileSystem;
	import blade3d.loader.BlResourceLoaderManager;
	
	import flash.utils.Dictionary;

	public class BlResourceManager extends BlManager
	{
		// 资源类型
		static public var TYPE_NONE : int = 0;
		static public var TYPE_BYTEARRAY : int = 1;			// binary数据
		static public var TYPE_STRING : int = 2;				// 文本字符串
		static public var TYPE_IMAGE : int = 3;				// 图片
		static public var TYPE_MESH : int = 4;				// 模型
		static public var TYPE_COUNT : int = 5;				// 资源类型数
		
		public var allResCount : Vector.<uint> = new Vector.<uint>(TYPE_COUNT, false);			// 所以资源计数
		public var loadedResCount : Vector.<uint> = new Vector.<uint>(TYPE_COUNT, false);		// 加载过的资源计数
		
		// 资源列表
		private var _ResourceMap : Dictionary = null;		// 资源列表
		private var _firstLoadCount : int = 0;
		
		// 文件访问器
		private var _fileSystem : BlFileSystem;
		
		static private var _instance : BlResourceManager;
		
		private var _loaderManager : BlResourceLoaderManager;
		public function get loaderManager() : BlResourceLoaderManager {return _loaderManager;}
		
		public function BlResourceManager()
		{
			if(_instance)
				Debug.error("BlResourceManager error");
			
			_fileSystem = new BlFlashFileSystem;
		}
		
		static public function instance() : BlResourceManager
		{
			if(!_instance)
				_instance = new BlResourceManager();
			return _instance;
		}
		
		public function get ResourceMap() : Dictionary {return _ResourceMap;}
		
		public function init(callBack:Function):Boolean
		{
			_initCallBack = callBack;
			_loaderManager = new BlResourceLoaderManager;
			// 配置资源路径
			initUrl();
			
			var i:int;
			for(i=0;i<allResCount.length;i++)
				allResCount[i] = 0;
			for(i=0;i<loadedResCount.length;i++)
				loadedResCount[i] = 0;
			// 读取资源文件列表
			loadResource(BlResourceConfig.root_url + "filelist.txt", TYPE_STRING, onLoadFileList);
			
			return true;
		}
		
		private function initUrl():void
		{
			BlResourceConfig.scene_url = BlResourceConfig.root_url + BlResourceConfig.scene_dir;
			BlResourceConfig.avatar_url = BlResourceConfig.root_url + BlResourceConfig.avatar_dir;
		}
		// 添加资源
		public function addResource(res:BlResource, url:String):Boolean
		{
			// 确认url不重复
			if(findResource(url))
				return false;
			
			saveResource(res, url);
			return true;
		}
		// 保存资源
		public function saveResource(res:BlResource, url:String = null):Boolean
		{
			if(url)
				_ResourceMap[url] = res;
			else
				url = res.url; 
			
			_fileSystem.saveFile(res, url);
			return true;
		}
		
		// 寻找可用路径
		static public function findValidPath(url:String, path:String):String
		{
			var testUrl : String = url;
			if( instance().findResource(testUrl) )
				return testUrl;
			
			testUrl = path + url;
			if( instance().findResource(testUrl) )
				return testUrl;
			
			testUrl = path + url.substr(url.lastIndexOf('/')+1);
			if( instance().findResource(testUrl) )
				return testUrl;
			
			Debug.assert(false, "url not exist!");
			return url;
		}
		
		public function findResource(url:String):BlResource
		{
			return _ResourceMap[url];
		}
		
		public function findBinaryResource(url:String):BlBinaryResource
		{
			if(_ResourceMap[url] && _ResourceMap[url] is BlBinaryResource)
				return _ResourceMap[url];
			else
				return null;
		}
		
		public function findImageResource(url:String):BlImageResource
		{
			if(_ResourceMap[url] && _ResourceMap[url] is BlImageResource)
				return _ResourceMap[url];
			else
				return null;
		}
		
		public function findStringResource(url:String):BlStringResource
		{
			if(_ResourceMap[url] && _ResourceMap[url] is BlStringResource)
				return _ResourceMap[url];
			else
				return null;
		}
		
		public function findModelResource(url:String):BlModelResource
		{
			if(_ResourceMap[url] && _ResourceMap[url] is BlModelResource)
				return _ResourceMap[url];
			else
				return null;
		}
		
		private function loadString(url:String, callBack : Function):void
		{
			loadResource(url, TYPE_STRING, callBack);
		}
		
		private function loadResource(url:String, type:int, callback:Function):void
		{
			_loaderManager.loadResource(url, type, callback);
		}
		
		private function onLoadFileList(str:String):void
		{
			Debug.assert(!_ResourceMap);
			_ResourceMap = new Dictionary;
			
			// 创建资源列表
			var strArray : Array = str.split(/\s/);
			var filterStrArray : Array = strArray.filter(
				function(element:*, index:int, arr:Array):Boolean 
				{
					return (element.length != 0 && element.charAt(0) != '#'); 
				}
			);
			
			// 创建资源对象
			var allFileName : String;
			var fileName : String;
			var extName : String;
			var pathName : String;
			for(var i:int=0; i<filterStrArray.length; i++)
			{
				// 解析文件名
				allFileName = filterStrArray[i];
				var pPos:int = allFileName.lastIndexOf('.');
				extName = allFileName.substr(pPos);
				fileName = allFileName.substr(0, pPos);
				var slashPos:int = fileName.lastIndexOf('/') + 1;
				pathName = fileName.substr(0, slashPos);
				fileName = fileName.substr(slashPos);
				
				// 创建资源对象
				var newResource:BlResource;
				if(extName == ".3ds")
				{	// 静态模型
					newResource = new BlModelResource(allFileName);
				}
				else if(extName == ".dds" || extName == ".png" || extName == ".bmp" || extName == ".jpeg" || extName == ".jpg" || extName == "gif")
				{	// 贴图
					newResource = new BlImageResource(allFileName);
				}
				else if(extName == ".txt" || extName == ".xml" || extName == ".eff")
				{	// 文本
					newResource = new BlStringResource(allFileName);
				}
				else
				{	// 2进制数据
					newResource = new BlBinaryResource(allFileName);
				}
				
				// 设置资源加载类型 
				newResource.loadType = BlResource.LOAD_TYPE_DELAY;
				
				allResCount[newResource.resType]++;
					
				// 记录资源
				_ResourceMap[allFileName] = newResource;
				
				// 记录特效资源
				if(extName == ".eff")
				{
					BlEffectManager.instance().recordEffectResource(newResource);
				}
			}
			
			// 加载资源列表中，必须加载的资源
			_firstLoadCount++;
			for each(var res:BlResource in _ResourceMap)
			{
				if(res.loadType == BlResource.LOAD_TYPE_MUST)
				{
					_firstLoadCount++;
					res.load();
				}
			}
			
			onResourceLoaded(null);
//			dispatchEvent(new BlResourceEvent(BlResourceEvent.RESOURCE_LIST, null));
		}
		
		public function onResourceLoaded(res:BlResource):void
		{
			_firstLoadCount--;
			if(_firstLoadCount==0)
			{
				_initCallBack(this);
			}
			
			if(res)
			{
				Debug.log("load res:"+res.url);
				dispatchEvent(new BlResourceEvent(BlResourceEvent.RESOURCE_COMPLETE, res));
				loadedResCount[res.resType]++;
			}
		}
	}
}