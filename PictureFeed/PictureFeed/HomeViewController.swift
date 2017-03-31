//
//  HomeViewController.swift
//  PictureFeed
//
//  Created by Sergelenbaatar Tsogtbaatar on 3/27/17.
//  Copyright © 2017 Serg Tsogtbaatar. All rights reserved.
//

import UIKit
import Social

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    let filterNames = [FilterName.vintage, FilterName.blackAndWhite, FilterName.chrome, FilterName.crystalize, FilterName.noir]
    
    let stringNames = ["Vintage", "Black & White", "Chrome", "Crystalize", "Noir"]
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButtonBottomContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        setupGalleryDelegate()
    }
    
    func setupGalleryDelegate() {
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            
            guard let galleryController = viewControllers[1] as? GalleryViewController else { return }
            
            galleryController.delegate = self
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postButtonBottomContraint.constant = 8
        filterButtonTopConstraint.constant = 8
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
        self.collectionView.reloadData()
    }

    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
        self.imagePicker.allowsEditing = true
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User Tapped Image!")
        presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            let newPost = Post(image: image, creationDate: nil)
            print(newPost)
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
        
        if self.collectionViewHeightConstraint.constant == 0 {
            self.collectionViewHeightConstraint.constant = 150
        } else {
            self.collectionViewHeightConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.5) { 
            self.view.layoutIfNeeded()
        }
        
        /*
        
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
        */
    }
    
    
    @IBAction func userLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            guard let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return
            }
            
            composeController.add(self.imageView.image)
            self.present(composeController, animated: true, completion: nil)
        }
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

        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheetController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheetController.addAction(photoAction)
        }
        
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
            actionSheetController.addAction(cancelAction)
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
}

//MARK: UICollectionView DataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: 150, height: 150)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        // Filter Label Names
        let stringName = self.stringNames[indexPath.row]
        filterCell.filterLabel.text = stringName
        
        Filters.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
}

extension HomeViewController: GalleryViewControllerDelegate {
    
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        Filters.originalImage = image
        self.tabBarController?.selectedIndex = 0
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let originalImage = Filters.originalImage else { fatalError("No Original Image for filter")}
        let filterName = self.filterNames[indexPath.row]
        Filters.filter(name: filterName, image: originalImage) { (filteredImage) in
            self.imageView.image = filteredImage
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = originalImage
            imageView.contentMode = .scaleAspectFill
            Filters.originalImage = originalImage
            self.collectionView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
        print("Info: \(info)")
    }
}
