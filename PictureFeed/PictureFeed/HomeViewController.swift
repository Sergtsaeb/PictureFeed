//
//  HomeViewController.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/27/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postButtonBottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postButtonBottomContraint.constant = 8
        filterButtonTopConstraint.constant = 8
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }

    }

    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = originalImage
            imageView.contentMode = .scaleAspectFill
            Filters.originalImage = originalImage
        }
        
        dismiss(animated: true, completion: nil)
        print("Info: \(info)")
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User Tapped Image!")
        presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            let newPost = Post(image: image)
            CloudKit.shared.save(post: newPost, completion: { (success) in
                
                if success {
                    print("Saved post successfully to CloudKit!")
                } else {
                    print("We did not successfully save to CloudKit..")
                }
                
                
            })
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        
        guard let image = self.imageView.image else { return }
        
        let alertController = UIAlertController(title: "Filter", message: "Please select a filter", preferredStyle: .alert)
        
        let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
            Filters.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
                self.imageView.image = filteredImage
            })
        }
        
        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
            Filters.filter(name: .vintage, image: image, completion: { (filteredImage) in
                self.imageView.image = filteredImage
            })
        }
        
        let noirAction = UIAlertAction(title: "Noir", style: .default) { (action) in
            Filters.filter(name: .noir, image: image, completion: { (filteredImage) in
                self.imageView.image = filteredImage
            })
        }
        
        let chromeAction = UIAlertAction(title: "Chrome", style: .default) { (action) in
            Filters.filter(name: .chrome, image: image, completion: { (filteredImage) in
                self.imageView.image = filteredImage
            })
        }
        
        let crystalizeAction = UIAlertAction(title: "Crystalize", style: .default) { (action) in
            Filters.filter(name: .crystalize, image: image, completion: { (filteredImage) in
                self.imageView.image = filteredImage
            })
        }
        
        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
            self.imageView.image = Filters.originalImage
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(blackAndWhiteAction)
        alertController.addAction(vintageAction)
        alertController.addAction(noirAction)
        alertController.addAction(chromeAction)
        alertController.addAction(crystalizeAction)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentActionSheet() {
        let actionSheetController = UIAlertController(title: "Source", message: "Please Select Source Type", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
        }
        
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        
        actionSheetController.addAction(cameraAction)
        
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    
}
