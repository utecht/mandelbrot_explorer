//
//  Shaders.metal
//  Mandelbrot Explorer Shared
//
//  Created by Joseph Utecht on 8/23/18.
//  Copyright © 2018 Joseph Utecht. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <metal_math>
#include "ShaderTypes.h"
using namespace metal;

struct VertexOut {
    float4 pos [[position]];
};

vertex VertexOut vertexShader(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){
    Vertex in = vertexArray[vid];
    VertexOut out;
    out.pos = float4(in.pos.x, in.pos.y, 0, 1);
    return out;
}

fragment float4 mandelbrotSet(VertexOut interpolated [[stage_in]],
                              const device float4 *palette [[buffer(0)]],
                              const device float *window [[buffer(1)]],
                              const device float2 *scaling [[buffer(2)]],
                              const device int *rotation [[buffer(3)]]){
    float x0 = ((interpolated.pos.x / window[0]) * scaling[0][0]) + scaling[1][0];
    float y0 = ((interpolated.pos.y / window[1]) * scaling[0][1]) + scaling[1][1];
    float x = 0.0;
    float y = 0.0;
    int iteration = 0;
    int max_iteration = 1000;
    while(x*x + y*y < 4 && iteration < max_iteration){
        float xtemp = x*x - y*y + x0;
        y = 2*x*y + y0;
        x = xtemp;
        iteration += 1;
    }
    if(iteration != max_iteration) {
        iteration = (iteration + rotation[0]) % 1000;
    }
    float r = palette[iteration][0];
    float b = palette[iteration][1];
    float g = palette[iteration][2];
    return float4(r, b, g, 1.0);
}

fragment float4 juliaSet(VertexOut interpolated [[stage_in]],
                         const device float4 *palette [[buffer(0)]],
                         const device float *window [[buffer(1)]],
                         const device float2 *scaling [[buffer(2)]],
                         const device int *rotation [[buffer(3)]]){
    float zx = ((interpolated.pos.x / window[0]) * scaling[0][0]) + scaling[1][0];
    float zy = ((interpolated.pos.y / window[1]) * scaling[0][1]) + scaling[1][1];
    
    float x = 0.0;
    float y = 0.0;
    float n = 4;
    int iteration = 0;
    int max_iteration = 1000;
    while(x*x + y*y < 4 && iteration < max_iteration){
        float xtemp = pow(x*x + y*y, n/2) * cos(n * atan2(y, x)) + zx;
        y = pow(x*x + y*y, n/2) * sin(n * atan2(y, x)) + zy;
        x = xtemp;
        iteration += 1;
    }
    if(iteration != max_iteration) {
        iteration = (iteration + rotation[0]) % 1000;
    }
    float r = palette[iteration][0];
    float b = palette[iteration][1];
    float g = palette[iteration][2];
    return float4(r, b, g, 1.0);
}
