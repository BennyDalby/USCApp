//
//  imageModel.swift
//  USC Visual Supply
//
//  Created by benny dalby on 12/11/21.
//

import Foundation
import UIKit



struct ImageModel {
    
    var image : UIImage
    var depthImage : UIImage
    var rgbImage : UIImage
    var rgbData : CVPixelBuffer?
    var sceneDepthData : CVPixelBuffer?
    var rgbImageData : Data?
    var depthData : Data?
    var rgbMeta : String?
    var depthMeta : String?
    var filePathRGB : String?
    var filePathDepth : String?
    var filePathRGBMeta : String?
    var filePathDepthMeta : String?
    
    
}

struct RGBDataImage: Codable {
    
    var red : CGFloat
    var green : CGFloat
    var blue : CGFloat
    var alpha : CGFloat
    
    
}

struct DepthDataImage: Codable {
    
    var distance : Double
    
    
}

struct DeviceData :  Codable {
    
    var ipAddress : String?
    var latitute : String?
    var longitude : String?
    
}
