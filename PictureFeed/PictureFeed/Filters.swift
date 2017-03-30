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
    var context: CIContext
    
    static let shared = Filters()
    private init() {
        //GPU Context
        let options = [kCIContextWorkingColorSpace: NSNull()]
        guard let eaglContext = EAGLContext(api: .openGLES2) else {fatalError("Failed to create EAGLContext.") }
        
        self.context = CIContext(eaglContext: eaglContext, options: options)
    }
    
    /*
    func filterAccessor(name: String, image: UIImage) {
        
       // var names: [String:]
        
        
        filter(name: name, image: image) { (filteredImage) in
            image
        }
    }
    
    func blackAndWhite(image: UIImage, completion: FilterCompletion)
    
        self.filter(name: .blackAndWhite, image: image, completion: completion)
    }
 
    
    
    func filterName(name: String, image: String) {
        switch name {
            case "Vintage":
            return FilterName.vintage
            case "BlackAndWhite":
            return FilterName.vintage
            case "Noir":
            return FilterName.noir
            case "Chrome":
            return FilterName.chrome
            case "Crystalize":
            return 
        }
        
        //self.filter(name: <#T##FilterName#>, image: <#T##UIImage#>, completion: <#T##FilterCompletion##FilterCompletion##(UIImage?) -> ()#>)
    }
 
 */
    
     class func filter(name: FilterName, image: UIImage, completion: @escaping FilterCompletion) {
        OperationQueue().addOperation {
            
            guard let filter = CIFilter(name: name.rawValue) else { fatalError("Failed to create CIFilter") }
            
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
   
            
            //Get final image from using GPU
            guard let outputImage = filter.outputImage else {fatalError("Failed to get output image from Filter.") }
            
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
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
