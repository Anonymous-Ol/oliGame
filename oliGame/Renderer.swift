//
//  Renderer.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit


class Renderer: NSObject{
    public static var currnetPipelineState: RenderPipelineStateTypes? = nil
    public static var computePipelineState: MTLComputePipelineState?  = nil
    public static var reflectionsBeingRendered: Bool = false
    public static var ScreenSize: float2 = float2(repeating: 0)
    public static var shadowRenders: [MTLTexture] =  []
    public static var currentReflectionPosition: float3 = float3(0,0,0)
    private var _baseRenderPassDescriptor:   MTLRenderPassDescriptor!
    static  var _reflectionRenderPassDescriptor: MTLRenderPassDescriptor!
    static var shadowRenderPassDescriptor: MTLRenderPassDescriptor!
    private var _firstDraw: Bool = true
    public static var AspectRation: Float{
        return ScreenSize.x/ScreenSize.y
    }
    init(_ mtkView: MTKView){
        super.init()
        updateScreenSize(view: mtkView)
        SceneManager.SetScene(.Forest)

    }
    static func createReflectionRenderPassDescriptor(_ arrayLength: Int32){
        
        let reflectionTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb,
                                                                                   width: 300,
                                                                                   height: 300,
                                                                                   mipmapped: false)
        
        
        reflectionTextureDescriptor.textureType = .typeCubeArray
        reflectionTextureDescriptor.storageMode = .private
        reflectionTextureDescriptor.usage = [.renderTarget, .shaderRead]
        reflectionTextureDescriptor.arrayLength = Int(arrayLength)
        
        let reflectionDepthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                                        width: 300,
                                                                                        height: 300,
                                                                                        mipmapped: false)
        
        
        reflectionDepthTextureDescriptor.textureType = .typeCubeArray
        reflectionDepthTextureDescriptor.storageMode = .private
        reflectionDepthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        reflectionDepthTextureDescriptor.arrayLength = Int(arrayLength)
        
        Assets.Textures.setTexture(textureType: .ReflectionRender,
                        texture:Engine.Device.makeTexture(descriptor: reflectionTextureDescriptor)!)
        let depthTexture: MTLTexture = Engine.Device.makeTexture(descriptor: reflectionDepthTextureDescriptor)!
        
        
        
        Renderer._reflectionRenderPassDescriptor = MTLRenderPassDescriptor()
        
        
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].texture = Assets.Textures[.ReflectionRender]
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].loadAction =  .clear
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].storeAction = .store
        
        Renderer._reflectionRenderPassDescriptor.depthAttachment.texture = depthTexture
        
        Renderer._reflectionRenderPassDescriptor.renderTargetArrayLength = 6*Int(arrayLength)
        
        
        
        
    }
    private func createBaseRenderPassDescriptor(view: MTKView){
    

         do {
             Renderer.computePipelineState = try Engine.Device.makeComputePipelineState(function: Engine.DefaultLibrary.makeFunction(name: "raytrace")!)
            
         }catch{
             fatalError("could not make compute pipeline state")
         }
        ///Base Color Texture 0
        let base0TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                              width: 2560,
                                                                              height: 1440,
                                                                             mipmapped: false)

        
        base0TextureDescriptor.usage = [.shaderRead, .shaderWrite]
        Assets.Textures.setTexture(textureType: .BaseColorRender_0,
                        texture: Engine.Device.makeTexture(descriptor: base0TextureDescriptor)!)
        
        
        
        ///Base Depth Texture 0
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainDethPixelFomat,
                                                                              width: 2560,
                                                                              height: 1440,
                                                                              mipmapped: false)
        

        depthTextureDescriptor.usage = [.renderTarget]
        depthTextureDescriptor.storageMode = .private

        
        Assets.Textures.setTexture(textureType: .BaseDepthRender,
                        texture: Engine.Device.makeTexture(descriptor: depthTextureDescriptor)!)
        
        
        self._baseRenderPassDescriptor = MTLRenderPassDescriptor()
        self._baseRenderPassDescriptor.colorAttachments[0].texture = Assets.Textures[.BaseColorRender_0]!
        self._baseRenderPassDescriptor.colorAttachments[0].storeAction = .store
        self._baseRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        self._baseRenderPassDescriptor.depthAttachment.texture = Assets.Textures[.BaseDepthRender]

        
    }
}

extension Renderer: MTKViewDelegate{
    func createBuffer(_ data: [float3], device: MTLDevice) -> MTLBuffer? {
        let byteLength = data.count * MemoryLayout<float3>.stride
        guard let buffer = device.makeBuffer(length: byteLength, options: []) else {
            return nil
        }
        buffer.contents().copyMemory(from: data, byteCount: byteLength)
        return buffer
    }
    public func updateScreenSize(view: MTKView){
        Renderer.ScreenSize = float2(Float(view.currentDrawable!.texture.width), Float(view.currentDrawable!.texture.height))
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

        updateScreenSize(view: view)
        createBaseRenderPassDescriptor(view: view)
    }
    func render(renderCommandEncoder: MTLRenderCommandEncoder){
        var transparentObjects: [setupRenderReturn] = []
        var opaqueObjects: [setupRenderReturn] = []
        for thing in RenderVariables.stuffToRender{
            if(thing.isTransparent){
                transparentObjects.append(thing)
            }else{
                opaqueObjects.append(thing)
            }
        }
        transparentObjects.sort { (lhs: setupRenderReturn, rhs: setupRenderReturn) -> Bool in
            // you can have additional code here
            return lhs.distanceFromCamera > rhs.distanceFromCamera
        }
        opaqueObjects.sort { (lhs: setupRenderReturn, rhs: setupRenderReturn) -> Bool in
            // you can have additional code here
            return lhs.distanceFromCamera < rhs.distanceFromCamera
        }
        renderCommandEncoder.pushDebugGroup("Rendering Opaque Objects")
        for thing in opaqueObjects{
            renderCommandEncoder.pushDebugGroup(thing.name)
            thing.doRenderFunction(renderCommandEncoder)
            renderCommandEncoder.popDebugGroup()
        }
        renderCommandEncoder.popDebugGroup()
        renderCommandEncoder.pushDebugGroup("Rendering Transparent Objects")
        for thing in transparentObjects{
            renderCommandEncoder.pushDebugGroup(thing.name)
            thing.doRenderFunction(renderCommandEncoder)
            renderCommandEncoder.popDebugGroup()
        }
        renderCommandEncoder.popDebugGroup()
        
        RenderVariables.stuffToRender = []
    }
    func copyShadowTextureData(commandBuffer: MTLCommandBuffer){
        let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()
        blitCommandEncoder?.label = "Shadow Blit COMMAND ENCODER"
        blitCommandEncoder?.pushDebugGroup("Starting Copy")
        SceneManager.CopyShadowData(blitCommandEncoder: blitCommandEncoder!)
        blitCommandEncoder?.popDebugGroup()
        blitCommandEncoder?.endEncoding()
    }
    func cubeMapRenderPass(commandBuffer: MTLCommandBuffer){
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _baseRenderPassDescriptor)
            renderCommandEncoder?.label = "Cube Map Render Command Encoder"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            //renderCommandEncoder?.setCullMode(.front)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()

        
    }
    func baseRenderPass(commandBuffer: MTLCommandBuffer){
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _baseRenderPassDescriptor)
            renderCommandEncoder?.label = "Base RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            //renderCommandEncoder?.setCullMode(.back)
            SceneManager.setupRender(renderCommandEncoder: renderCommandEncoder!)
            render(renderCommandEncoder: renderCommandEncoder!)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()

        
    }
    func finalRenderPass(view: MTKView, commandBuffer: MTLCommandBuffer){
        view.currentDrawable?.layer.allowsNextDrawableTimeout = false
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
            renderCommandEncoder?.label = "Final RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            
        renderCommandEncoder?.setRenderPipelineState(Graphics.RenderPipelineStates[.Final])
            Renderer.currnetPipelineState = .Final
            renderCommandEncoder?.setFragmentTexture(Assets.Textures[.BaseColorRender_0], index: 0)
            
            Assets.Meshes[.Quad_Custom]?.drawPrimitives(renderCommandEncoder!)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()
    }
    func draw( in view: MTKView){
        //SceneManager.Update(deltaTime:  1 / Float(view.preferredFramesPerSecond))
        if(_firstDraw){
            //createReflectionRenderPassDescriptor()
            createBaseRenderPassDescriptor(view: view)
            _firstDraw = false
        }
//        let shadowCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
//        shadowCommandBuffer?.label = "Shadow Command Buffer"
//        SceneManager.doShadowRender(commandBuffer: shadowCommandBuffer!)
//        //copyShadowTextureData(commandBuffer: shadowCommandBuffer!)
//        shadowCommandBuffer?.commit()
//        let reflectionsCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
//        reflectionsCommandBuffer?.label = "Reflections Command Buffer"
//        SceneManager.doReflectionRender()
//        SceneManager.ReflectionRender(commandBuffer: reflectionsCommandBuffer!)
//        reflectionsCommandBuffer?.commit()
        var points: [float3] = [
            float3( 0.164413, 0.081871, 0.003545),
            float3( -0.181283, 0.536302, -0.694696),
            float3( -0.377114, 0.676446, 0.315248),
            float3( -0.485988, 0.650360, -0.109615),
            float3( -0.046438, -0.718720, -0.163798),
            float3( -0.544277, 0.055575, -0.532975),
            float3( 0.216656, 0.051822, -0.476433),
            float3( 0.520625, -0.266747, -0.163950),
            float3( 0.530955, 0.067331, 0.566748),
            float3( -0.442289, -0.203033, -0.412709),
            float3( 0.651693, -0.528178, 0.059855),
            float3( 0.092863, -0.641293, -0.619994),
            float3( 0.666755, 0.255046, 0.122145),
            float3( -0.299694, -0.686118, 0.601912),
            float3( -0.681441, 0.219755, -0.338824),
            float3( 0.230046, 0.029763, 0.913829),
            float3( 0.494237, -0.110792, 0.365339),
            float3( 0.464991, 0.532899, -0.171718),
            float3( -0.797124, -0.151880, 0.428465),
            float3( -0.247718, -0.869778, -0.160232),
            float3( -0.338171, -0.305480, 0.851290),
            float3( -0.855212, -0.265215, -0.369306),
            float3( -0.619531, -0.121768, 0.091622),
            float3( 0.041630, -0.421703, 0.144284),
            float3( -0.173131, 0.178338, 0.485024),
            float3( 0.424836, -0.127764, -0.240243),
            float3( 0.467646, 0.304638, -0.332862),
            float3( -0.251703, -0.328015, -0.715077),
            float3( -0.084615, -0.118838, 0.257000),
            float3( 0.071822, 0.323414, -0.245470),
            float3( -0.332581, 0.482725, -0.421024),
            float3( 0.261241, -0.429375, 0.833710),
            float3( 0.262871, -0.036586, 0.791338),
            float3( 0.116729, 0.509968, 0.600548),
            float3( -0.621067, -0.320059, 0.323114),
            float3( -0.478934, 0.832807, 0.101750),
            float3( -0.013994, 0.885335, -0.167726),
            float3( -0.270157, -0.164296, 0.761939),
            float3( 0.583433, -0.533272, 0.502408),
            float3( -0.392621, 0.174849, -0.593922),
            float3( 0.457713, 0.538886, -0.056170),
            float3( 0.702457, -0.255835, 0.299519),
            float3( -0.129379, -0.390787, 0.725426),
            float3( 0.530749, 0.189741, -0.564165),
            float3( -0.701344, -0.333436, -0.501185),
            float3( -0.262676, 0.578669, -0.291536),
            float3( -0.183530, 0.047422, 0.561490),
            float3( 0.419425, -0.272012, -0.237997),
            float3( -0.559842, 0.305035, -0.192457),
            float3( 0.599544, 0.294396, -0.484226),
            float3( 0.756846, -0.009313, -0.267109),
            float3( 0.022293, -0.775723, -0.055005),
            float3( 0.067559, 0.231419, 0.152675),
            float3( 0.640616, -0.248335, -0.098623),
            float3( -0.245773, -0.558015, 0.535188),
            float3( -0.216157, -0.582320, 0.671965),
            float3( 0.569821, -0.322736, 0.406491),
            float3( -0.378634, -0.283488, 0.867969),
            float3( -0.030424, 0.819935, -0.015572),
            float3( -0.597336, -0.301010, -0.232343),
            float3( -0.647418, 0.029864, -0.626092),
            float3( 0.719155, 0.205716, -0.090493),
            float3( 0.196715, -0.713404, 0.032175),
            float3( 0.080334, -0.349571, 0.824163),
            float3( 0.986636, 0.111684, 0.102514),
            float3( 0.063536, -0.469379, 0.419547),
            float3( -0.088997, 0.120585, 0.408699),
            float3( -0.714690, -0.365301, 0.088925),
            float3( 0.226557, 0.558535, -0.014990),
            float3( 0.729755, 0.005093, 0.375555),
            float3( 0.098700, -0.162433, 0.663639),
            float3( 0.265575, -0.016508, 0.392292),
            float3( -0.096100, 0.335497, -0.410071),
            float3( -0.329179, -0.091382, 0.322085),
            float3( 0.452855, -0.081366, -0.672856),
            float3( -0.545622, 0.001853, 0.035997),
            float3( -0.110932, -0.187321, -0.136265),
            float3( -0.426733, -0.029512, -0.879504),
            float3( 0.537341, 0.162191, 0.668329),
            float3( -0.523932, 0.405966, 0.034614),
            float3( 0.210862, 0.056432, -0.713642),
            float3( 0.153309, -0.706887, -0.398473),
            float3( 0.611747, -0.324982, 0.241512),
            float3( 0.664883, 0.497843, 0.375651),
            float3( 0.466027, 0.381741, 0.660013),
            float3( 0.249294, 0.941308, 0.180323),
            float3( -0.629225, 0.384999, 0.235993),
            float3( -0.250616, -0.460272, 0.520818),
            float3( 0.592877, -0.549347, 0.224284),
            float3( -0.465628, -0.523768, -0.488150),
            float3( 0.241607, -0.794473, -0.017701),
            float3( 0.209550, -0.736080, -0.391409),
            float3( 0.685571, -0.275960, 0.631190),
            float3( 0.076503, 0.445535, 0.356707),
            float3( -0.115378, 0.243058, -0.410879),
            float3( 0.125453, 0.547465, 0.278505),
            float3( 0.314180, 0.072050, 0.889974),
            float3( 0.437130, 0.280029, -0.620525),
            float3( 0.100749, 0.537856, -0.220127),
            float3( -0.774147, -0.116468, 0.369462),
            float3( 0.397466, -0.291827, -0.271510),
            float3( 0.297298, -0.483930, 0.127094),
            float3( 0.135742, -0.769410, -0.356459),
            float3( 0.762327, -0.379996, -0.059444),
            float3( -0.234486, -0.162956, -0.106894),
            float3( -0.427555, 0.150543, -0.706172),
            float3( -0.391825, -0.438137, -0.210193),
            float3( -0.182395, 0.493622, 0.458790),
            float3( 0.214860, 0.336539, 0.125648),
            float3( 0.430437, -0.512653, -0.246098),
            float3( -0.576847, -0.783946, -0.062994),
            float3( -0.555948, 0.619890, -0.381146),
            float3( 0.785255, -0.355685, -0.260561),
            float3( 0.314480, -0.765546, 0.136172),
            float3( -0.576408, 0.177124, -0.789168),
            float3( -0.243688, -0.017473, 0.580138),
            float3( 0.233747, 0.343895, -0.412247),
            float3( 0.254661, -0.766082, -0.391328),
            float3( -0.884264, 0.091809, 0.164901),
            float3( -0.093047, 0.380689, 0.779088),
            float3( 0.580490, -0.374308, -0.253094),
            float3( -0.805708, -0.190670, -0.118186),
            float3( 0.055980, 0.253435, 0.056262),
            float3( -0.466876, 0.687557, 0.276311),
            float3( 0.085705, -0.015520, 0.204855),
            float3( -0.427253, 0.025881, -0.192164),
            float3( -0.390141, 0.392696, 0.636736),
            float3( 0.408178, -0.512376, -0.548790),
            float3( 0.096674, -0.103994, 0.879690),
            float3( -0.326261, 0.046411, -0.684956),
            float3( 0.240390, 0.000120, -0.094867),
            float3( -0.622359, 0.595152, 0.507570),
            float3( -0.798091, 0.167579, -0.132243),
            float3( 0.351255, 0.349570, -0.287559),
            float3( -0.007180, -0.371600, -0.202106),
            float3( 0.463918, 0.395786, -0.324805),
            float3( 0.255624, 0.835721, -0.093483),
            float3( -0.068034, 0.768214, -0.568399),
            float3( -0.478732, -0.061990, -0.673148),
            float3( 0.117357, 0.293560, -0.261494),
            float3( -0.797815, -0.071543, -0.087687),
            float3( 0.657681, -0.483091, 0.301145),
            float3( 0.406782, -0.338016, -0.755845),
            float3( 0.555832, -0.544409, 0.571581),
            float3( -0.550195, 0.004263, -0.671725),
            float3( -0.123614, 0.798318, -0.532515),
            float3( 0.095062, -0.660733, -0.038331),
            float3( -0.765542, -0.118692, -0.522155),
            float3( -0.370791, -0.070862, 0.022593),
            float3( 0.313657, -0.507582, -0.660707),
            float3( 0.037310, -0.421820, 0.604875),
            float3( 0.430949, 0.367083, 0.299638),
            float3( -0.542467, -0.210412, -0.652071),
            float3( 0.055962, 0.382980, -0.652016),
            float3( 0.518130, 0.076390, 0.447038),
            float3( -0.057094, 0.168324, -0.287985),
            float3( 0.554662, -0.401286, -0.501505),
            float3( 0.143250, 0.659459, -0.095771),
            float3( 0.189594, 0.237768, 0.208340),
            float3( 0.732541, 0.559386, 0.280208),
            float3( -0.032771, 0.477519, -0.136169),
            float3( 0.160379, -0.103732, 0.155571),
            float3( 0.071124, -0.790890, 0.390413),
            float3( 0.381463, 0.216658, -0.598242),
            float3( -0.275263, -0.058720, -0.568924),
            float3( -0.746778, 0.300050, 0.254376),
            float3( 0.331644, 0.771585, -0.468559),
            float3( 0.380220, -0.330549, 0.615905),
            float3( -0.044729, -0.090846, 0.759958),
            float3( -0.282233, 0.513357, 0.556963),
            float3( 0.267779, -0.781533, 0.132016),
            float3( -0.363755, 0.737255, -0.190649),
            float3( 0.723161, 0.284672, -0.509587),
            float3( -0.974655, 0.160712, -0.128707),
            float3( -0.026608, -0.498091, -0.592138),
            float3( 0.513725, 0.794275, -0.036274),
            float3( -0.143108, -0.928121, 0.249102),
            float3( 0.147617, -0.153635, 0.360333),
            float3( -0.614803, -0.201131, 0.750259),
            float3( -0.334279, 0.786635, -0.086292),
            float3( -0.579086, 0.448005, 0.160817),
            float3( 0.324263, -0.822074, 0.033211),
            float3( -0.353267, 0.135089, 0.394689),
            float3( 0.278269, -0.587927, -0.341693),
            float3( 0.844057, 0.242932, 0.031678),
            float3( 0.301393, -0.194032, 0.638152),
            float3( -0.498946, -0.335098, 0.056488),
            float3( -0.116667, -0.706368, -0.199806),
            float3( -0.462901, -0.071983, 0.207668),
            float3( -0.226037, -0.899223, -0.259089),
            float3( -0.168759, -0.463409, 0.620116),
            float3( -0.768714, -0.005059, 0.630819),
            float3( -0.297438, 0.318495, 0.415423),
            float3( -0.619918, -0.517504, 0.327579),
            float3( -0.245677, -0.603981, -0.231948),
            float3( 0.748477, -0.572962, -0.057789),
            float3( 0.709998, 0.217040, 0.433226),
            float3( 0.069588, 0.197158, 0.947419),
            float3( 0.688400, -0.111184, -0.679658),
            float3( 0.001567, 0.563796, -0.131325),
            float3( 0.745525, -0.230521, 0.588542),
            float3( -0.279879, 0.652092, -0.372687),
            float3( 0.316760, -0.117341, 0.481669),
            float3( -0.084582, 0.640620, -0.621437),
            float3( -0.436567, 0.197127, 0.318602),
            float3( 0.535433, 0.211474, -0.578228),
            float3( -0.347665, -0.745324, 0.334060),
            float3( 0.634043, 0.484600, 0.116269),
            float3( -0.685672, 0.346065, 0.131834),
            float3( 0.740986, 0.353237, 0.312366),
            float3( 0.485803, -0.050194, -0.784004),
            float3( 0.045793, -0.480301, 0.630064),
            float3( -0.280817, 0.391322, 0.270037),
            float3( 0.086914, 0.481153, 0.242039),
            float3( 0.046736, -0.677449, -0.447088),
            float3( -0.718324, 0.602085, -0.065729),
            float3( -0.423557, 0.568732, -0.005024),
            float3( -0.309065, 0.261034, -0.317122),
            float3( 0.834987, 0.298236, -0.258844),
            float3( -0.408074, 0.321675, -0.203756),
            float3( -0.254287, 0.534867, 0.805222),
            float3( 0.475451, 0.121836, 0.768155),
            float3( -0.639369, 0.499053, -0.114930),
            float3( -0.293631, -0.562861, 0.516422),
            float3( 0.079691, 0.133912, 0.167106),
            float3( -0.610708, 0.138280, 0.225479),
            float3( 0.226040, -0.219926, -0.702188),
            float3( -0.687259, 0.602355, 0.102272),
            float3( 0.240042, 0.121537, 0.737275),
            float3( -0.132897, 0.734187, 0.136181),
            float3( 0.071777, 0.509457, -0.637513),
            float3( 0.149634, 0.980195, -0.050410),
            float3( -0.186054, 0.156140, -0.480472),
            float3( -0.224028, 0.542329, 0.316405),
            float3( 0.314468, 0.628396, 0.020139),
            float3( 0.001979, 0.895606, -0.365008),
            float3( 0.292348, 0.371573, 0.790407),
            float3( -0.409494, -0.123523, -0.430384),
            float3( -0.523855, -0.247754, 0.561348),
            float3( -0.072657, -0.676545, 0.723517),
            float3( -0.506439, 0.047220, 0.386798),
            float3( 0.359106, 0.577402, -0.427775),
            float3( 0.712470, -0.376839, -0.524158),
            float3( -0.102248, -0.173254, 0.900217),
            float3( 0.099409, 0.272723, 0.808494),
            float3( 0.558293, 0.099994, 0.452078),
            float3( 0.142851, 0.568742, -0.085520),
            float3( 0.222784, 0.534410, 0.041088),
            float3( -0.055551, -0.540500, -0.659941),
            float3( -0.271171, 0.520228, -0.122744),
            float3( 0.206017, -0.647211, -0.228364),
            float3( 0.306449, -0.250831, 0.107390),
            float3( -0.240534, 0.197921, 0.445723),
            float3( -0.194048, -0.653731, 0.089193),
            float3( 0.557697, 0.380943, 0.638060),
            float3( -0.273301, -0.776235, -0.300821),
            float3( -0.114005, 0.769411, 0.308763),
            float3( -0.456612, -0.204591, 0.364899),
            float3( 0.066434, -0.352538, 0.249389),
            float3( -0.147030, -0.580151, 0.239929),
            float3( 0.688503, -0.360458, 0.016578),
            float3( 0.284440, 0.352768, -0.785327),
            float3( 0.871672, -0.193250, -0.047583),
            float3( 0.872855, 0.068722, 0.195251),
            float3( 0.459652, -0.666099, 0.159757),
            float3( 0.261166, -0.001710, 0.561075),
            float3( 0.683779, -0.344830, -0.454282),
            float3( -0.823237, 0.269114, 0.478963),
            float3( -0.254242, 0.575614, -0.136181),
            float3( 0.668344, 0.084102, -0.050204),
            float3( 0.591301, -0.093450, 0.215660),
            float3( -0.390046, 0.539346, 0.579154),
            float3( -0.464745, 0.449996, -0.057827),
            float3( 0.089884, 0.473019, 0.072218),
            float3( 0.219512, -0.350706, -0.583085),
            float3( -0.251400, -0.014202, -0.853768),
            float3( 0.059128, -0.081337, -0.706868),
            float3( 0.759759, 0.369626, -0.142319),
            float3( 0.457273, -0.421149, 0.277783),
            float3( -0.250417, 0.175466, -0.680491),
            float3( -0.909757, -0.124845, 0.158026),
            float3( -0.001603, 0.185896, -0.664645),
            float3( 0.587664, 0.295940, -0.350196),
            float3( -0.157111, -0.258283, -0.044449),
            float3( 0.542150, -0.266012, -0.541333),
            float3( -0.095248, 0.425107, -0.671649),
            float3( -0.025613, 0.037734, -0.055478),
            float3( -0.060415, 0.737716, -0.550968),
            float3( 0.715138, -0.371561, 0.241959),
            float3( -0.847900, -0.340799, 0.130190),
            float3( -0.034038, -0.893407, -0.192688),
            float3( 0.573284, 0.607841, 0.247826),
            float3( 0.169403, 0.441759, 0.721720),
            float3( 0.214548, -0.016865, 0.403392),
            float3( 0.051624, -0.913718, 0.300778),
            float3( 0.382127, -0.412060, 0.040255),
            float3( -0.388290, 0.631633, 0.467407),
            float3( 0.440472, -0.192488, 0.510238),
            float3( -0.686125, 0.147388, 0.474263),
            float3( -0.375451, 0.382258, 0.770303),
            float3( -0.207074, -0.275306, -0.521215),
            float3( -0.026544, -0.843714, -0.374308),
            float3( -0.585349, 0.155598, -0.675500),
            float3( 0.786054, 0.059777, 0.584742),
            float3( 0.197009, 0.134648, 0.165304),
            float3( 0.608276, 0.529034, 0.285250),
            float3( -0.126834, 0.574911, 0.469981),
            float3( 0.053604, -0.265283, 0.034753),
            float3( 0.213456, -0.164658, -0.772055),
            float3( 0.139830, -0.680755, -0.609051),
            float3( 0.595102, -0.640366, 0.484503),
            float3( -0.675929, 0.438607, 0.187021),
            float3( 0.249479, 0.421021, -0.014070),
            float3( 0.289525, 0.654565, -0.368961),
            float3( 0.744442, -0.069928, 0.535894),
            float3( 0.115637, -0.021112, -0.043446),
            float3( -0.127252, 0.315955, -0.815336),
            float3( 0.686564, 0.115906, 0.196853),
            float3( -0.538669, -0.277710, 0.355770),
            float3( 0.009912, -0.812852, -0.358970),
            float3( -0.072319, -0.669515, -0.128206),
            float3( -0.410708, 0.199829, -0.428408),
            float3( -0.319458, 0.092244, 0.465069),
            float3( 0.240581, 0.444055, 0.668060),
            float3( -0.288640, 0.637186, 0.196419),
            float3( 0.928129, -0.042537, -0.347586),
            float3( -0.752341, -0.451608, 0.160133),
            float3( 0.313172, -0.275868, 0.145454),
            float3( -0.083594, -0.416774, -0.811228),
            float3( 0.279751, -0.149943, 0.447367),
            float3( -0.212942, -0.078704, 0.656947),
            float3( -0.090242, -0.364694, 0.835085),
            float3( 0.483509, -0.748613, 0.143578),
            float3( -0.267539, 0.147453, -0.272828),
            float3( 0.421519, 0.516393, 0.128231),
            float3( -0.171555, 0.432052, 0.848778),
            float3( 0.158321, 0.053875, 0.295456),
            float3( -0.459292, 0.321057, -0.239041),
            float3( -0.623404, 0.228369, 0.033154),
            float3( -0.082373, -0.501433, -0.187905),
            float3( -0.233333, 0.696217, -0.482733),
            float3( 0.098516, 0.182041, 0.856969),
            float3( -0.327129, 0.858139, -0.273454),
            float3( -0.013979, -0.310210, -0.796104),
            float3( 0.082703, 0.501387, -0.090609),
            float3( -0.177522, -0.548328, -0.583589),
            float3( 0.606183, 0.266248, -0.378080),
            float3( 0.115189, 0.215914, 0.739940),
            float3( -0.462265, -0.169050, -0.153119),
            float3( 0.003476, 0.447659, -0.115882),
            float3( -0.317470, -0.293973, -0.866234),
            float3( -0.064409, 0.125107, 0.539897),
            float3( -0.842330, 0.115352, 0.347270),
            float3( -0.696106, -0.085152, -0.333110),
            float3( 0.340266, -0.024634, -0.719964),
            float3( 0.035526, -0.688332, 0.480774),
            float3( -0.305119, -0.647129, -0.058364),
            float3( 0.557548, 0.235771, 0.352763),
            float3( 0.040832, 0.753933, -0.571082),
            float3( -0.167861, -0.557662, 0.443264),
            float3( 0.666051, 0.576837, 0.393956),
            float3( -0.250863, -0.309245, 0.811107),
            float3( 0.601966, -0.484283, 0.041959),
            float3( -0.505364, 0.250807, -0.817541),
            float3( -0.072566, -0.086586, 0.308508),
            float3( 0.509386, 0.263006, -0.625171),
            float3( 0.349235, -0.372331, -0.603328),
            float3( -0.000808, 0.636372, -0.635733),
            float3( -0.269173, -0.445299, 0.287747),
            float3( 0.838019, 0.425024, 0.143233),
            float3( -0.417149, -0.105987, -0.122227),
            float3( 0.567862, -0.745683, -0.268290),
            float3( -0.460462, -0.571177, -0.460348),
            float3( -0.116158, 0.260158, 0.718774),
            float3( -0.238046, 0.371490, -0.441129),
            float3( 0.332783, 0.587188, 0.684470),
            float3( 0.253373, -0.073128, -0.808554),
            float3( -0.125344, -0.837052, -0.235007),
            float3( 0.369911, 0.639163, -0.606871),
            float3( 0.952740, 0.145072, 0.041672),
            float3( 0.607554, -0.367404, 0.367435),
            float3( -0.411364, 0.498902, -0.167479),
            float3( -0.131820, 0.448759, 0.764730),
            float3( -0.182577, -0.232008, -0.492157),
            float3( -0.157756, -0.424586, -0.479129),
            float3( -0.739557, -0.002657, 0.332359),
            float3( 0.164429, -0.692792, -0.271969),
            float3( 0.601452, -0.507528, -0.181763),
            float3( -0.194111, 0.092705, 0.570315),
            float3( 0.256332, 0.192227, 0.666853),
            float3( 0.547578, -0.177141, 0.219390),
            float3( -0.382390, 0.839251, 0.161170),
            float3( -0.196878, -0.716233, 0.034204),
            float3( 0.145727, -0.722907, 0.426328),
            float3( -0.859058, -0.162624, 0.126088),
            float3( -0.585742, 0.528641, 0.445831),
            float3( 0.251732, -0.732800, 0.304390),
            float3( -0.738200, -0.335037, -0.042713),
            float3( 0.895697, -0.131455, 0.276102),
            float3( 0.554174, -0.650318, -0.080685),
            float3( 0.658686, 0.662132, 0.255317),
            float3( 0.641245, 0.530153, -0.313142),
            float3( 0.598376, -0.128672, 0.276972),
            float3( 0.388434, -0.400075, 0.491023),
            float3( -0.315268, 0.599920, -0.035941),
            float3( -0.840913, -0.209677, -0.099312),
            float3( -0.199529, -0.318808, -0.672246),
            float3( -0.079246, 0.335594, -0.695162),
            float3( 0.303465, 0.663585, -0.439852),
            float3( -0.045409, 0.113436, -0.404906),
            float3( -0.328342, -0.427475, 0.224718),
            float3( 0.710417, -0.389500, -0.535008),
            float3( 0.753327, 0.095840, -0.371395),
            float3( -0.247645, 0.799429, 0.093307),
            float3( -0.571008, -0.640227, 0.381938),
            float3( 0.403757, -0.096559, -0.576769),
            float3( 0.376893, -0.388005, 0.637846),
            float3( -0.362883, 0.586539, -0.430669),
            float3( -0.493981, 0.227290, -0.044627),
            float3( -0.567347, -0.418910, 0.441667),
            float3( -0.018805, 0.574764, -0.229575),
            float3( -0.077389, -0.590589, 0.315596),
            float3( 0.368941, -0.123220, 0.380387),
            float3( -0.333138, -0.055206, -0.288488),
            float3( 0.408032, 0.501973, -0.413906),
            float3( -0.239437, -0.595341, -0.348074),
            float3( -0.150259, 0.303437, 0.024866),
            float3( 0.422438, 0.058830, 0.573122),
            float3( -0.012822, -0.879830, 0.041316),
            float3( -0.258148, 0.055243, 0.521024),
            float3( -0.873876, 0.447304, 0.036493),
            float3( 0.314479, 0.374904, -0.777378),
            float3( -0.315455, 0.512150, -0.186128),
            float3( 0.089152, 0.939468, -0.323894),
            float3( -0.278980, 0.328441, 0.622198),
            float3( 0.795240, -0.202857, 0.058106),
            float3( -0.054294, 0.941852, -0.038200),
            float3( 0.274270, 0.732037, 0.498810),
            float3( -0.576580, 0.693501, -0.037864),
            float3( -0.761776, 0.516353, -0.097720),
            float3( -0.371005, -0.498488, -0.753284),
            float3( 0.198393, 0.509208, 0.350663),
            float3( -0.580023, 0.348196, 0.635425),
            float3( 0.160410, -0.125483, -0.758902),
            float3( -0.067756, 0.018216, 0.295720),
            float3( 0.550317, 0.105899, 0.789481),
            float3( 0.011221, -0.424116, -0.197224),
            float3( 0.026712, 0.777697, 0.348047),
            float3( 0.577843, -0.296872, 0.034163),
            float3( 0.046904, 0.470502, -0.448200),
            float3( -0.704689, -0.102331, -0.103117),
            float3( -0.200584, 0.379392, -0.006582),
            float3( 0.224281, -0.273463, -0.475004),
            float3( 0.444549, -0.357922, 0.084915),
            float3( 0.749914, 0.357481, 0.249532),
            float3( 0.707755, 0.517092, 0.098265),
            float3( 0.332548, -0.581853, -0.246210),
            float3( -0.157229, -0.390394, -0.702989),
            float3( 0.013245, 0.090121, -0.217728),
            float3( 0.700807, 0.013809, 0.461688),
            float3( -0.528516, 0.003292, -0.463486),
            float3( 0.601668, -0.061191, 0.505342),
            float3( -0.016182, 0.767496, -0.105964),
            float3( -0.144588, 0.000682, -0.520349),
            float3( -0.291515, 0.719871, -0.417255),
            float3( 0.641160, -0.014209, -0.072065),
            float3( 0.516285, -0.446013, 0.508829),
            float3( -0.134923, -0.647677, -0.249698),
            float3( -0.425723, 0.012622, -0.105574),
            float3( 0.389300, -0.523853, 0.482922),
            float3( 0.017950, 0.098197, -0.259493),
            float3( -0.003605, -0.470430, 0.426964),
            float3( -0.331271, -0.662144, 0.243965),
            float3( 0.373246, 0.258895, -0.557495),
            float3( -0.388750, -0.045141, -0.788086),
            float3( -0.089087, 0.432501, 0.519968),
            float3( -0.096415, -0.365933, -0.780903),
            float3( 0.077354, 0.705831, -0.141038),
            float3( -0.147216, -0.406445, 0.576517),
            float3( -0.022125, -0.460521, -0.311240),
            float3( -0.009970, 0.040024, 0.035670),
            float3( 0.329489, 0.200242, 0.526389),
            float3( -0.353028, -0.475726, 0.748912),
            float3( 0.739790, -0.013916, -0.309365),
            float3( -0.298004, 0.308169, 0.419432),
            float3( -0.348584, 0.497335, -0.160469),
            float3( -0.776673, 0.245279, -0.534744),
            float3( 0.284798, -0.596356, 0.163646),
            float3( 0.087738, 0.755591, 0.013243),
            float3( -0.109546, 0.272324, 0.398862),
            float3( -0.062685, -0.026245, -0.465984),
            float3( 0.530384, -0.160748, 0.169592),
            float3( 0.199206, 0.303837, 0.609687),
            float3( -0.731638, -0.529317, -0.311863),
            float3( -0.300916, 0.048877, -0.067808),
            float3( 0.197824, -0.471694, -0.294723),
            float3( 0.794440, -0.075542, 0.141161),
            float3( -0.065151, -0.303369, -0.137397),
            float3( 0.380496, 0.299822, 0.079036),
            float3( 0.678947, -0.519516, 0.262802),
        ]
        var seed = Int.random(in: 1..<10000)
        let pointsBuffer = createBuffer(points, device: Engine.Device)
        let rayTracingCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
        let rayTracingEncoder       = rayTracingCommandBuffer?.makeComputeCommandEncoder()
        rayTracingEncoder?.setComputePipelineState(Renderer.computePipelineState!)
        rayTracingEncoder?.setBuffer(pointsBuffer, offset: 0, index: 1)
        rayTracingEncoder?.setBytes(&seed, length: MemoryLayout<Int>.stride, index: 2)
        rayTracingEncoder?.setTexture(Assets.Textures[.BaseColorRender_0], index: 1)
        let gridSize: MTLSize = MTLSize(width: 2560, height: 1440, depth: 1)
        let threadWidth = Renderer.computePipelineState!.threadExecutionWidth
        let threadHeight = Renderer.computePipelineState!.maxTotalThreadsPerThreadgroup / threadWidth
        let threadsForThreadgroup = MTLSize(width: threadWidth, height: threadHeight, depth: 1)
        rayTracingEncoder?.dispatchThreads(gridSize, threadsPerThreadgroup: threadsForThreadgroup)
        rayTracingEncoder?.endEncoding()
        rayTracingCommandBuffer?.commit()

        
        let baseCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
        baseCommandBuffer?.label = "Base Command Buffer"
        rayTracingCommandBuffer?.waitUntilCompleted()

//        baseRenderPass(commandBuffer: baseCommandBuffer!)
        finalRenderPass(view: view, commandBuffer: baseCommandBuffer!)
        
        baseCommandBuffer?.present(view.currentDrawable!)
        baseCommandBuffer?.commit()
    }
}
