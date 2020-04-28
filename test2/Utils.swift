//
//  Utils.swift
//  test2
//
//  Created by user on 4/28/20.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation

class Utils {
    struct RGB {
        var r: Float = 0.0
        var g: Float = 0.0
        var b: Float = 0.0
    }
    
    struct HSV {
        var h: Float = 0.0
        var s: Float = 0.0
        var v: Float = 0.0
    }
    
    static func rgb2hsv(rgb: RGB) -> HSV{
        var hsv:HSV = HSV(h:0.0, s:0.0, v:0.0);
        var min:Float, max:Float, delta:Float;
        
        min = rgb.r < rgb.g ? rgb.r : rgb.g;
        min = min  < rgb.b ? min  : rgb.b;
        
        max = rgb.r > rgb.g ? rgb.r : rgb.g;
        max = max  > rgb.b ? max  : rgb.b;
        
        hsv.v = max/255;                                // v
        delta = max - min;
        if (delta < 0.00001)
        {
            hsv.s = 0;
            hsv.h = 0; // undefined, maybe nan?
            return hsv;
        }
        if( max > 0.0 ) { // NOTE: if Max is == 0, this divide would cause a crash
            hsv.s = (delta / max);                  // s
        } else {
            // if max is 0, then r = g = b = 0
            // s = 0, h is undefined
            hsv.s = 0.0;
            hsv.h = 0.0;                            // its now undefined
        }
        if( rgb.r >= max ){                           // > is bogus, just keeps compilor happy
            hsv.h = ( rgb.g - rgb.b ) / delta;        // between yellow & magenta
        }else if( rgb.g >= max ){
            hsv.h = 2.0 + ( rgb.b - rgb.r ) / delta;  // between cyan & yellow
        }else{
            hsv.h = 4.0 + ( rgb.r - rgb.g ) / delta;  // between magenta & cyan
        }
        
        hsv.h *= 60.0;                              // degrees
        
        if( hsv.h < 0.0 ){
            hsv.h += 360.0;
        }
        
        return hsv;
    }
}
