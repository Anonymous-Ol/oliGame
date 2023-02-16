//
//  TextureLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit
enum TextureTypes{
    case None
    case PartyPirateParrot
    case Cruiser
    case Clouds
    
    case BaseColorRender_0
    case BaseColorRender_1
    case BaseColorRender_2
    case ShadowRender
    case ShadowDepth
    case BaseDepthRender
    case ReflectionRender
}

class TextureLibrary: Library<TextureTypes, MTLTexture>{
    private var _library: [TextureTypes : Texture] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Texture("PartyPirateParot", ext: "jpg"), forKey: .PartyPirateParrot)
        _library.updateValue(Texture("cruiser", ext: "bmp", origin: .BottomLeft), forKey: .Cruiser)
        _library.updateValue(Texture("clouds", origin: .BottomLeft), forKey: .Clouds)
    }
    func setTexture(textureType: TextureTypes, texture: MTLTexture){
        _library.updateValue(Texture(texture: texture), forKey: textureType)
    }
    override subscript(type: TextureTypes) -> MTLTexture? {
        return _library[type]?.texture
    }
}
class Texture{
    var texture: MTLTexture!
    init(texture: MTLTexture){
        self.texture = texture
    }
    init(_ textureName: String, ext: String = "png", origin: TextureOrigin = TextureOrigin.TopLeft){
        let textureLoader = TextureLoader(textureName: textureName, textureExtension: ext, origin: origin)
        let texture: MTLTexture = textureLoader.loadTextureFromBundle()
        setTexture(texture)
    }
    func setTexture(_ texture: MTLTexture){
        self.texture = texture
    }
}

public enum TextureOrigin{
    case TopLeft
    case BottomLeft
}
class TextureLoader{
    private var _textureName: String!
    private var _textureExtension: String!
    private var _origin: MTKTextureLoader.Origin!
    
    init(textureName: String, textureExtension: String = "png", origin: TextureOrigin = TextureOrigin.TopLeft){
        self._textureName = textureName
        self._textureExtension = textureExtension
        self.setTextureOrigin(origin)
    }
    
    private func setTextureOrigin(_ textureOrigin: TextureOrigin){
        switch textureOrigin{
        case .TopLeft:
            self._origin = MTKTextureLoader.Origin.topLeft
        case .BottomLeft:
            self._origin = MTKTextureLoader.Origin.bottomLeft
        }
    }
    public func loadTextureFromBundle()->MTLTexture{
        var result: MTLTexture!
        
        if let url = Bundle.main.url(forResource: _textureName, withExtension: self._textureExtension){
            print(self._textureExtension)
            let textureLoader = MTKTextureLoader(device: Engine.Device)
            
            let options: [MTKTextureLoader.Option : Any] = [
                MTKTextureLoader.Option.origin: _origin as Any,
                MTKTextureLoader.Option.generateMipmaps: true]
            do{
                result = try textureLoader.newTexture(URL: url, options: options)
                result.label = _textureName
            }catch{
                print("error loading textures")
            }
        }else{
            print("error loading textures")
        }
        return result
    }
}
