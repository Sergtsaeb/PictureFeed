//
//  Filters.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/28/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import UIKit

enum FilterName: String {
    case vintage = "CIPhotoEffectTransfer"
    case blackAndWhite = "CIPhotoEffectMono"
    case noir = "CIPhotoEffectNoir"
    case chrome = "CIPhotoEffectChrome"
    case crystalize = "CICrystallize"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    static var originalImage = UIImage()
    
    class func filter(name: FilterName, image: UIImage, completion: @escaping FilterCompletion) {
        OperationQueue().addOperation {
            
            guard let filter = CIFilter(name: name.rawValue) else { fatalError("Failed to create CIFilter") }
            
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
            //GPU Context
            let options = [kCIContextWorkingColorSpace: NSNull()]
            guard let eaglContext = EAGLContext(api: .openGLES2) else {fatalError("Failed to create EAGLContext.") }
            
            let ciContext = CIContext(eaglContext: eaglContext, options: options)
            
            //Get final image from using GPU
            guard let outputImage = filter.outputImage else {fatalError("Failed to get output image from Filter.") }
            
            if let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                
                OperationQueue.main.addOperation {
                    completion(finalImage)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
            
        }
    }
    
}