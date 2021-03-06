
Namespace mojo.graphics

Using std.resource

#rem monkeydoc The Image class.

An image is a rectangular array of pixels that can be drawn to a canvas using one of the [[Canvas.DrawImage]] methods.

Images are similar to pixmap's, except that they are optimized for rendering, and typically live in GPU memory. 

To load an image from a file, use one of the [[Load]], [[LoadBump]] or [[LoadLight]] functions.

To create an image from an existing pixmap, use the New( pixmap,... ) constructor.

To create an image that is a 'window' into an existing image, use the New( image,rect... ) constructor. This allows you to use images as 'atlases',

To create an 'empty' image, use the New( width,height ) constructor. You can then render to this image by creating a canvas with this image as its render target.

Images also have several properties that affect how they are rendered, including:

* Handle - the relative position of the image's centre (or 'pivot point') for rendering, where (0.0,0.0) means the top-left of the image while (1.0,1.0) means the bottom-right.
* Scale - a fixed scale factor for the image.
* BlendMode - controls how the image is blended with the contents of the canvas. If this is null, this property is ignored and the current canvas blendmode is used to render the image instead.
* Color - when rendering an image to a canvas, this property is multiplied by the current canvas color and the result is multiplied by actual image pixel colors to achieve the final color to be rendered.
* TextureFilter - controls how image texels are sampled. Set to TextureFilter.None for coolio retro style graphics, or TextureFilter.Mipmap for fullon super smoothing.


#end
Class Image Extends Resource

	#rem monkeydoc Creates a new Image.
	
	New( pixmap,... ) Creates an image from an existing pixmap.
	
	New( width,height,... ) Creates an image that can be rendered to using a canvas.
	
	New( image,... ) Creates an image from within an 'atlas' image.
	
	Note: `textureFlags` should be null for static images or TextureFlags.Dynamic for dynamic images.

	@param pixmap Source image.
	
	@param textureFlags Image texture flags. 
	
	@param shader Image shader.
	
	@param image Source pixmap.
	
	@param rect Source rect.
	
	@param x,y,width,height Source rect
	
	@param width,height Image size.
	
	#end	
	Method New( pixmap:Pixmap,textureFlags:TextureFlags=Null,shader:Shader=Null )
	
		Local texture:=New Texture( pixmap,textureFlags )
		
		Init( texture,texture.Rect,shader )
		
		AddDependancy( texture )
	End

	Method New( width:Int,height:Int,textureFlags:TextureFlags=Null,shader:Shader=Null )
	
		Local texture:=New Texture( width,height,PixelFormat.RGBA32,textureFlags )
		
		Init( texture,texture.Rect,shader )
		
		AddDependancy( texture )
	End

	Method New( width:Int,height:Int,format:PixelFormat,textureFlags:TextureFlags=Null,shader:Shader=Null )
	
		Local texture:=New Texture( width,height,format,textureFlags )
		
		Init( texture,texture.Rect,shader )
		
		AddDependancy( texture )
	End

	Method New( image:Image )
	
		Init( image._textures[0],image._rect,image._shader )
		
		image.AddDependancy( Self )
		
		For Local i:=1 Until 4
			SetTexture( i,image.GetTexture( i ) )
		Next
		
		BlendMode=image.BlendMode
		TextureFilter=image.TextureFilter
		LightDepth=image.LightDepth
		Handle=image.Handle
		Scale=image.Scale
		Color=image.Color
	End
	
	Method New( image:Image,rect:Recti )
	
		Init( image._textures[0],rect+image._rect.Origin,image._shader )
		
		image.AddDependancy( Self )
		
		For Local i:=1 Until 4
			SetTexture( i,image.GetTexture( i ) )
		Next
		
		BlendMode=image.BlendMode
		TextureFilter=image.TextureFilter
		LightDepth=image.LightDepth
		Handle=image.Handle
		Scale=image.Scale
		Color=image.Color
	End
	
	Method New( image:Image,x:Int,y:Int,width:Int,height:Int )
	
		Self.New( image,New Recti( x,y,x+width,y+height ) )
	End
	
	#rem monkeydoc @hidden
	#end
	Method New( texture:Texture,shader:Shader=Null )

		Init( texture,texture.Rect,shader )
	End
	
	#rem monkeydoc @hidden
	#end
	Method New( texture:Texture,rect:Recti,shader:Shader=Null )

		Init( texture,rect,shader )
	End
	
	#rem monkeydoc The image's primary texture.
	#end	
	Property Texture:Texture()
	
		Return _textures[0]
	
	Setter( texture:Texture )
	
		SetTexture( 0,texture )
	End

	#rem monkeydoc The image's texture rect.
	
	Describes the rect the image occupies within its primary texture.
	
	#end
	Property Rect:Recti()
	
		Return _rect
	End
	
	#rem monkeydoc The image handle.
	
	Image handle values are fractional, where 0,0 is the top-left of the image and 1,1 is the bottom-right.

	#end
	Property Handle:Vec2f()
	
		Return _handle
		
	Setter( handle:Vec2f )
	
		_handle=handle
		
		UpdateVertices()
	End

	#rem monkeydoc The image scale.
	
	The scale property provides a simple way to 'pre-scale' an image.
	
	For images with a constant scale, Scaling an image this way is faster than using one of the 'scale' parameters of [[Canvas.DrawImage]].
	
	#end
	Property Scale:Vec2f()
	
		Return _scale
	
	Setter( scale:Vec2f )
	
		_scale=scale
		
		UpdateVertices()
	End

	#rem monkeydoc The image blend mode.
	
	The blend mode used to draw the image.
	
	If set to BlendMode.None, the canvas blend mode is used instead.
	
	Defaults to BlendMode.None.
	
	#end	
	Property BlendMode:BlendMode()
	
		Return _blendMode
		
	Setter( blendMode:BlendMode )
	
		_blendMode=blendMode
	End
	
	#rem monkeydoc The image texture filter.
	
	The texture flags used to draw the image.
	
	If set to TextureFilter.None, the canvas texture filter is used instead.
	
	Defaults to TextureFilter.None
	
	#end	
	Property TextureFilter:TextureFilter()
	
		Return _textureFilter
		
	Setter( filter:TextureFilter )
	
		_textureFilter=filter
	End
	
	#rem monkeydoc The image color.
	
	The color used to draw the image.
	
	Image color is multiplied by canvas color to achieve the final rendering color.
	
	Defaults to white.
	
	#end	
	Property Color:Color()
	
		Return _color
	
	Setter( color:Color )
	
		_color=color
		
		_material.SetVector( "mx2_ImageColor",_color )
	End

	#rem monkeydoc The image light depth.
	#end
	Property LightDepth:Float()
	
		Return _lightDepth
	
	Setter( depth:Float )
	
		_lightDepth=depth
		
		_material.SetScalar( "mx2_LightDepth",_lightDepth )
	End

	#rem monkeydoc Shadow caster attached to image.
	#end	
	Property ShadowCaster:ShadowCaster()
	
		Return _shadowCaster
		
	Setter( shadowCaster:ShadowCaster )
	
		_shadowCaster=shadowCaster
	End

	#rem monkeydoc The image bounds.
	
	The bounds rect represents the actual image vertices used when the image is drawn.
	
	Image bounds are affected by [[Scale]] and [[Handle]], and can be used for simple collision detection.
	
	#end
	Property Bounds:Rectf()
	
		Return _bounds
	End

	#rem monkeydoc Image bounds width.
	#end	
	Property Width:Float()
	
		Return _bounds.Width
	End
	
	#rem monkeydoc Image bounds height.
	#end	
	Property Height:Float()
	
		Return _bounds.Height
	End

	#rem monkeydoc Image bounds radius.
	#end
	Property Radius:Float()
	
		Return _radius
	End

	#rem monkeydoc Image shader.
	#end
	Property Shader:Shader()
	
		Return _shader
	End
	
	#rem monkeydoc Image material.
	#end
	Property Material:UniformBlock()
	
		Return _material
	End

	#rem monkeydoc @hidden Image vertices.
	#end	
	Property Vertices:Rectf()
	
		Return _vertices
	End
	
	#rem monkeydoc @hidden Image texture coorinates.
	#end	
	Property TexCoords:Rectf()
	
		Return _texCoords
	End

	#rem monkeydoc @hidden Sets an image texture.
	#end	
	Method SetTexture( index:Int,texture:Texture )
	
		_textures[index]=texture
		
		_material.SetTexture( "mx2_ImageTexture"+index,texture )
	End
	
	#rem monkeydoc @hidden gets an image texture.
	#end	
	Method GetTexture:Texture( index:Int )
	
		Return _textures[index]
	End
	
	#rem monkeydoc Loads an image from file.
	#end
	Function Load:Image( path:String,shader:Shader=Null )
	
		Local pixmap:=Pixmap.Load( path,Null,True )
		If Not pixmap Return Null

		If Not shader shader=mojo.graphics.Shader.GetShader( "sprite" )
		
		Local image:=New Image( pixmap,Null,shader )
			
		image.OnDiscarded+=Lambda()
			pixmap.Discard()
		End
		
		Return image
	End
	
	#rem monkeydoc Loads a bump image from file(s).
	
	`diffuse`, `normal` and `specular` are filepaths of the diffuse, normal and specular image files respectively.
	
	`specular` can be null, in which case `specularScale` is used for the specular component. Otherwise, `specularScale` is used to modulate the red component of the specular texture.
	
	#end
	Function LoadBump:Image( diffuse:String,normal:String,specular:String,specularScale:Float=1,flipNormalY:Bool=True,shader:Shader=Null )
	
		Local texture1:=graphics.Texture.LoadNormal( normal,Null,specular,specularScale,flipNormalY )
		If Not texture1 Return Null
		
		Local texture0:=graphics.Texture.Load( diffuse,Null )
		
		If Not texture0
			Local pdiff:=New Pixmap( texture1.Width,texture1.Height,PixelFormat.I8 )
			pdiff.Clear( std.graphics.Color.White )
			texture0=New graphics.Texture( pdiff,Null )
		Endif
		
		If Not shader shader=graphics.Shader.GetShader( "bump" )
		
		Local image:=New Image( texture0,texture0.Rect,shader )
		image.SetTexture( 1,texture1 )
		
		image.OnDiscarded+=Lambda()
			If texture0 texture0.Discard()
			If texture1 texture1.Discard()
		End
		
		Return image
	End

	#rem monkeydoc Loads a light image from file.
	#end
	Function LoadLight:Image( path:String,shader:Shader=Null )
	
		Local pixmap:=Pixmap.Load( path )
		If Not pixmap Return Null
		
		If Not shader shader=mojo.graphics.Shader.GetShader( "light" )
	
		Select pixmap.Format
		Case PixelFormat.IA16,PixelFormat.RGBA32
		
			pixmap.PremultiplyAlpha()
			
		Case PixelFormat.A8

			Local tpixmap:=pixmap
			pixmap=pixmap.Convert( PixelFormat.IA16 )
			tpixmap.Discard()

			'Copy A->I
			For Local y:=0 Until pixmap.Height
				Local p:=pixmap.PixelPtr( 0,y )
				For Local x:=0 Until pixmap.Width
					p[0]=p[1]
					p+=2
				Next
			Next

		Case PixelFormat.I8
		
			Local tpixmap:=pixmap
			pixmap=pixmap.Convert( PixelFormat.IA16 )
			tpixmap.Discard()
			
			'Copy I->A
			For Local y:=0 Until pixmap.Height
				Local p:=pixmap.PixelPtr( 0,y )
				For Local x:=0 Until pixmap.Width
					p[1]=p[0]
					p+=2
				Next
			Next

		Case PixelFormat.RGB24
		
			Local tpixmap:=pixmap
			pixmap=pixmap.Convert( PixelFormat.RGBA32 )
			tpixmap.Discard()
			
			'Copy Max(R,G,B)->A
			For Local y:=0 Until pixmap.Height
				Local p:=pixmap.PixelPtr( 0,y )
				For Local x:=0 Until pixmap.Width
					p[3]=Max( Max( p[0],p[1] ),p[2] )
					p+=4
				Next
			Next
		
		End
		
		Local texture:=New Texture( pixmap,Null )
		
		Local image:=New Image( texture,shader )
		
		image.OnDiscarded+=Lambda()
			pixmap.Discard()
		End
		
		Return image
	End

	Private
	
	Field _shader:Shader
	Field _material:UniformBlock

	Field _textures:=New Texture[4]
	Field _blendMode:BlendMode
	Field _textureFilter:TextureFilter
	Field _color:Color
	Field _lightDepth:Float
	Field _shadowCaster:ShadowCaster
	
	Field _rect:Recti
	Field _handle:Vec2f
	Field _scale:Vec2f
	
	Field _vertices:Rectf
	Field _texCoords:Rectf
	Field _bounds:Rectf
	Field _radius:Float
	
	Method Init( texture:Texture,rect:Recti,shader:Shader )
	
		If Not shader shader=Shader.GetShader( "sprite" )
	
		_rect=rect
		_shader=shader
		_material=New UniformBlock
		
		AddDependancy( _material )
		
		SetTexture( 0,texture )
		
		BlendMode=BlendMode.None
		TextureFilter=TextureFilter.None
		Color=Color.White
		LightDepth=100
		Handle=New Vec2f( 0 )
		Scale=New Vec2f( 1 )
		
		UpdateVertices()
		UpdateTexCoords()
	End
	
	Method UpdateVertices()
		_vertices.min.x=Float(_rect.Width)*(0-_handle.x)*_scale.x
		_vertices.min.y=Float(_rect.Height)*(0-_handle.y)*_scale.y
		_vertices.max.x=Float(_rect.Width)*(1-_handle.x)*_scale.x
		_vertices.max.y=Float(_rect.Height)*(1-_handle.y)*_scale.y
		_bounds.min.x=Min( _vertices.min.x,_vertices.max.x )
		_bounds.max.x=Max( _vertices.min.x,_vertices.max.x )
		_bounds.min.y=Min( _vertices.min.y,_vertices.max.y )
		_bounds.max.y=Max( _vertices.min.y,_vertices.max.y )
		_radius=_bounds.min.x*_bounds.min.x+_bounds.min.y*_bounds.min.y
		_radius=Max( _radius,_bounds.max.x*_bounds.max.x+_bounds.min.y*_bounds.min.y )
		_radius=Max( _radius,_bounds.max.x*_bounds.max.x+_bounds.max.y*_bounds.max.y )
		_radius=Max( _radius,_bounds.min.x*_bounds.min.x+_bounds.max.y*_bounds.max.y )
		_radius=Sqrt( _radius )
	End
	
	Method UpdateTexCoords()
		_texCoords.min.x=Float(_rect.min.x)/_textures[0].Width
		_texCoords.min.y=Float(_rect.min.y)/_textures[0].Height
		_texCoords.max.x=Float(_rect.max.x)/_textures[0].Width
		_texCoords.max.y=Float(_rect.max.y)/_textures[0].Height
	End
	
End

Class ResourceManager Extension

	Method OpenImage:Image( path:String,shader:Shader=Null )

		Local slug:="Image:name="+StripDir( StripExt( path ) )+"&shader="+(shader ? shader.Name Else "null")
		
		Local image:=Cast<Image>( OpenResource( slug ) )
		If image Return image

		Local texture:=OpenTexture( path,Null )
		If texture image=New Image( texture,shader )
		
		AddResource( slug,image )
		Return image
	End

End
