//
//  Post.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/28/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    let image: UIImage
    let creationDate: Date?
    
    init(image: UIImage, creationDate: Date?) {
        self.image = image
        self.creationDate = creationDate
    }
}

enum PostError: Error {
    case writingImageToData
    case writingDataToDisk
}

extension Post {
    
    class func recordFor(post: Post) throws -> CKRecord? {
        guard let data = UIImageJPEGRepresentation(post.image, 0.7) else { throw PostError.writingImageToData }
        do {
            try data.write(to: post.image.path)
            let asset = CKAsset(fileURL: post.image.path)
            
            let record = CKRecord(recordType: "Post")
            record.setValue(asset, forKey: "image")
            
            return record
            
        } catch {
            throw PostError.writingDataToDisk
        }
     
    }
    
}
