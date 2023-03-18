//
//  RenderUtilities.swift
//  oliGame
//
//  Created by Oliver Crumrine on 3/17/23.
//

import Metal
class RenderUtilities{
    public static var currentPipelineState: RenderPipelineStateTypes? = nil
    static func advancedSetRenderPipelineState(pipelineState: RenderPipelineStateTypes, commandEncoder: MTLRenderCommandEncoder){
        if(currentPipelineState != pipelineState){
            commandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[pipelineState])
        }
        
    }
    
}
