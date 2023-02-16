//
//  CubeMapLoader.swift
//  oliGame
//
//  Created by Oliver Crumrine on 2/13/23.
//

import MetalKit


class CubeMapLoader{
    init(){
        
    }
    static func loadCubeMap(_ name: String, _ fileExtension: String) -> MTLTexture? {
        
        let loader  = MTKTextureLoader(device: Engine.Device)
        let options: [MTKTextureLoader.Option : Any] = [
            MTKTextureLoader.Option.origin : .topLeft as MTKTextureLoader.Origin,
            MTKTextureLoader.Option.generateMipmaps : true,
            MTKTextureLoader.Option.cubeLayout : .vertical as MTKTextureLoader.CubeLayout
        ]
        let url = Bundle.main.url(forResource: name, withExtension: fileExtension)!
        
        do{
            return try loader.newTexture(URL: url, options: options)
        }catch{
            print(error)
        }
        
        return nil
    }
}
