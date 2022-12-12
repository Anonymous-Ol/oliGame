//
//  Assets.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

class Assets{
    private static var _meshLibrary: MeshLibrary!
    public static var Meshes: MeshLibrary {return _meshLibrary}
    
    private static var _textureLibrary: TextureLibrary!
    public static var Textures: TextureLibrary {return _textureLibrary}

    public static func initialize(){
        self._meshLibrary = MeshLibrary()
        self._textureLibrary = TextureLibrary()
    }
}
