/**
 */
package away3d.filters.tasks
{
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.errors.AbstractMethodError;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;

	public class Filter3DTaskBase
	{
		protected var _mainInputTexture : Texture;

		protected var _scaledTextureWidth : int = -1;
		protected var _scaledTextureHeight : int = -1;
		protected var _textureWidth : int = -1;
		protected var _textureHeight : int = -1;
		private var _textureDimensionsInvalid : Boolean = true;
		private var _program3DInvalid : Boolean = true;
		private var _program3D : Program3D;
		private var _target : Texture;
		private var _requireDepthRender : Boolean;
		protected var _textureScale : int = 0;
		
		private var _context3D : Context3D;		// 设备对象

		public function Filter3DTaskBase(requireDepthRender : Boolean = false)
		{
			_requireDepthRender = requireDepthRender;
		}
		
		private function checkContext3D(stage : Stage3DProxy):void
		{
			if(_context3D == stage.context3D)
				return;
			
			_context3D = stage.context3D;
			
			_textureDimensionsInvalid = true;
			invalidateProgram3D();
		}

		public function get textureScale() : int
		{
			return _textureScale;
		}

		public function set textureScale(value : int) : void
		{
			if (_textureScale == value) return;
			_textureScale = value;
			_scaledTextureWidth = _textureWidth >> _textureScale;
			_scaledTextureHeight = _textureHeight >> _textureScale;
			_textureDimensionsInvalid = true;
		}

		public function get target() : Texture
		{
			return _target;
		}

		public function set target(value : Texture) : void
		{
			_target = value;
		}

		public function get textureWidth() : int
		{
			return _textureWidth;
		}

		public function set textureWidth(value : int) : void
		{
			if (_textureWidth == value) return;
			_textureWidth = value;
			_scaledTextureWidth = _textureWidth >> _textureScale;
			_textureDimensionsInvalid = true;
		}

		public function get textureHeight() : int
		{
			return _textureHeight;
		}

		public function set textureHeight(value : int) : void
		{
			if (_textureHeight == value) return;
			_textureHeight = value;
			_scaledTextureHeight = _textureHeight >> _textureScale;
			_textureDimensionsInvalid = true;
		}

		public function getMainInputTexture(stage : Stage3DProxy) : Texture
		{
			checkContext3D(stage);
			
			if (_textureDimensionsInvalid) 
				updateTextures(stage);

			return _mainInputTexture;
		}

		public function dispose() : void
		{
			if (_mainInputTexture)
				Context3DProxy.disposeTexture(_mainInputTexture); // _mainInputTexture.dispose();
			if (_program3D) 
				Context3DProxy.disposeProgram(_program3D); //  _program3D.dispose();
		}

		protected function invalidateProgram3D() : void
		{
			_program3DInvalid = true;
		}

		protected function updateProgram3D(stage : Stage3DProxy) : void
		{
			if (_program3D) 
				_program3D.dispose();
			
			_program3D = Context3DProxy.createProgram(); //  stage.context3D.createProgram();
			_program3D.upload(	new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.VERTEX, getVertexCode(), Debug.active),
								new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.FRAGMENT, getFragmentCode(), Debug.active));
			_program3DInvalid = false;
		}

		protected function getVertexCode() : String
		{
			return 	"mov op, va0\n"+
					"mov v0, va1";
		}

		protected function getFragmentCode() : String
		{
			throw new AbstractMethodError();
			return null;
		}

		protected function updateTextures(stage : Stage3DProxy) : void
		{
			if (_mainInputTexture)
				Context3DProxy.disposeTexture(_mainInputTexture); // _mainInputTexture.dispose();

			_mainInputTexture = Context3DProxy.createTexture(_scaledTextureWidth, _scaledTextureHeight, Context3DTextureFormat.BGRA, true);

			_textureDimensionsInvalid = false;
		}

		public function getProgram3D(stage3DProxy : Stage3DProxy) : Program3D
		{
			checkContext3D(stage3DProxy);
			
			if (_program3DInvalid)
				updateProgram3D(stage3DProxy);
			return _program3D;
		}

		public function activate(stage3DProxy : Stage3DProxy, camera : Camera3D, depthTexture : Texture) : void
		{
		}

		public function deactivate(stage3DProxy : Stage3DProxy) : void
		{
		}

		public function get requireDepthRender() : Boolean
		{
			return _requireDepthRender;
		}
	}
}
