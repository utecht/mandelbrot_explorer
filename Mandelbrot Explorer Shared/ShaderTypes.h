//
//  ShaderTypes.h
//  Mandelbrot Explorer Shared
//
//  Created by Joseph Utecht on 8/23/18.
//  Copyright © 2018 Joseph Utecht. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

struct Vertex {
    vector_float2 pos;
};

#endif /* ShaderTypes_h */

