//
//  Graphics.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//
class Graphics{
    private static var _ShaderLibrary: ShaderLibrary!
    public static var Shaders: ShaderLibrary { return _ShaderLibrary }
    
    
    private static var _vertexDescriptorLibrary: VertexDescriptoryLibrary!
    public static var VertexDescriptors: VertexDescriptoryLibrary { return _vertexDescriptorLibrary }

    
    private static var _renderPipelineStateLibrary: RenderPipelineStateLibrary!
    public static var RenderPipelineStates: RenderPipelineStateLibrary{ return _renderPipelineStateLibrary}
    
    private static var _depthStencilStateLibrary: DepthStencilStateLibrary!
    public static var DepthStencilStates: DepthStencilStateLibrary{ return _depthStencilStateLibrary}
    
    private static var _samplerStateLibrary: SamplerStateLibrary!
    public static var SamplerStates: SamplerStateLibrary{ return _samplerStateLibrary}
    
    public static func initialize(){
        self._ShaderLibrary = ShaderLibrary()
        self._vertexDescriptorLibrary = VertexDescriptoryLibrary()
        self._renderPipelineStateLibrary = RenderPipelineStateLibrary()
        self._depthStencilStateLibrary = DepthStencilStateLibrary()
        self._samplerStateLibrary = SamplerStateLibrary()
    }


}
