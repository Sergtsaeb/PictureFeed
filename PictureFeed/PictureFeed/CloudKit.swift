//
//  CloudKit.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/27/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import UIKit
import CloudKit

typealias SuccessCompletion = (Bool) -> ()
typealias PostsCompletion = ([Post]?) -> ()

class CloudKit {
    
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    
    var privateDatabase: CKDatabase {
        return self.container.privateCloudDatabase
    }
    
    func save(post: Post, completion: @escaping SuccessCompletion) {
        do {
            if let record = try Post.recordFor(post: post) { // try creating a CKrecord from post
                
                privateDatabase.save(record, completionHandler: { (record, error) in //save that CKRecord of Post record type to the CKDatabase
                    
                    if error != nil {
                        completion(false)
                        return
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
    
    func getPosts(completion: @escaping PostsCompletion) {
        
        let postQuery = CKQuery(recordType: "Post", predicate: NSPredicate(value: true))
        
        self.privateDatabase.perform(postQuery, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
            
            if let records = records {
                
                var posts = [Post]()
                for record in records {
                    
                    let date = record.creationDate
                    
                    if let asset = record["image"] as? CKAsset {
                        let path = asset.fileURL.path
                        if let image = UIImage(contentsOfFile: path) {
                            let newPost = Post(image: image, creationDate: date)
                            posts.append(newPost)
                        }
                    }
                }
                
                OperationQueue.main.addOperation {
                    completion(posts)
                }
            }
        }
    }
}
