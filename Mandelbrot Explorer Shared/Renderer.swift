//
//  Renderer.swift
//  Mandelbrot Explorer Shared
//
//  Created by Joseph Utecht on 8/23/18.
//  Copyright © 2018 Joseph Utecht. All rights reserved.
//

import Metal
import MetalKit
import Foundation

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    let paletteBuffer: MTLBuffer
    var origin: float2 = [-2.5, -1.0]
    var scale: float2 = [3.5, 2.0]
    var rotation = 0
    var should_rotate = true
    
    init?(mtkView: MTKView){
        device = mtkView.device!
        commandQueue = device.makeCommandQueue()!
        do {
            pipelineState = try Renderer.buildRenderPipelineWith(device: device, metalKitView: mtkView)
        } catch {
            print("unable to compile render pipeline state \(error)")
            return nil
        }
        var palette: Array<float4> = []
        
        func rgb(h: Float, s: Float, v: Float) -> float4 {
            let h = h / 60
            let s = s / 100
            let v = v / 100
            
            let index = Int(h) % 6
            
            let f = h - floor(h)
            let p = v * (1 - s)
            let q = v * (1 - (s * f))
            let t = v * (1 - (s * (1 - f)))
            
            let values = [
                [v, t, p],
                [q, v, p],
                [p, v, t],
                [p, q, v],
                [t, p, v],
                [v, p, q]
                ][index]
            
            return float4(values[0], values[1], values[2], 1.0)
        }
        
        for index in 0..<1000{
            let h: Float = (sqrt((Float(index) / 1000.0)) * 360.0)
            let s: Float = 76.0
            let v: Float = 76.0
            palette.append(rgb(h: h, s: s, v: v))
        }
        let vertices = [Vertex(pos: [-1, -1]),
                        Vertex(pos: [-1, 1]),
                        Vertex(pos: [1, -1]),
                        Vertex(pos: [1, 1]),
                        Vertex(pos: [1, -1]),
                        Vertex(pos: [-1, 1])]
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        paletteBuffer = device.makeBuffer(bytes: palette, length: palette.count * MemoryLayout<float4>.stride, options: [])!
    }
    
    func zoom(center: float2, speed: Float){
        let old_scale_x = scale[0]
        let old_scale_y = scale[1]
        scale[0] *= (1 - speed)
        scale[1] *= (1 - speed)
        origin[0] -= (scale[0] - old_scale_x) * center[0]
        origin[1] -= (scale[1] - old_scale_y) * center[1]
    }
    
    func pan(pan_x: CGFloat, pan_y: CGFloat){
        origin[0] += Float(pan_x / 100) * scale[0]
        origin[1] += Float(pan_y / 100) * scale[1]
    }
    
    func draw(in view: MTKView){
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(paletteBuffer, offset: 0, index: 0)
        let window_size = [Float(view.drawableSize.width), Float(view.drawableSize.height)]
        renderEncoder.setFragmentBytes(window_size, length: window_size.count * MemoryLayout<Float>.stride, index: 1)
        renderEncoder.setFragmentBytes([scale, origin], length: 2 * MemoryLayout<float2>.stride, index: 2)
        if should_rotate {
            rotation = (rotation + 1) % 1000
        }
        renderEncoder.setFragmentBytes([rotation], length: MemoryLayout<int4>.stride, index: 3)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize){
        
    }
    
    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "mandelbrotSet")
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
