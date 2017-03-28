//
//  CloudKit.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/27/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import Foundation
import CloudKit

typealias PostCompletion = (Bool) -> ()

class CloudKit {
    
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    
    var privateDatabase: CKDatabase {
        return self.container.privateCloudDatabase
    }
    
    func save(post: Post, completion: @escaping PostCompletion) {
        do {
            if let record = try Post.recordFor(post: post) { // try creating a CKrecord from post
                
                privateDatabase.save(record, completionHandler: { (record, error) in //save that CKRecord of Post record type to the CKDatabase
                    
                    if error != nil {
                        completion(false)
                    }
                    
                    if let record = record {
                        print(record)
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        } catch {
            print(error)
        }
        
    }
    
    
}
