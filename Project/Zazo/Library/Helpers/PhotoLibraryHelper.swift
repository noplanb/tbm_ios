//
//  PhotoLibraryPickerHelper.swift
//  Zazo
//
//  Created by Rinat on 07/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class PhotoLibraryHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    typealias Completion = (UIImage?)->()
    
    lazy var pickerController = UIImagePickerController()
    lazy var cropViewController = CropViewController(nibName: nil, bundle: nil)
    
    var completion: Completion
    
    override init() {
        completion = { (image) in
            logError("default completion called")
        }
        super.init()
    }

    func configurePickerController() {
        pickerController.allowsEditing = false
        pickerController.delegate = self
    }
    
    func configureCropViewController() {
        cropViewController.delegate = self
    }
    
    @objc func presentLibrary(from VC: UIViewController, with completion: Completion)
    {
        configurePickerController()
        self.completion = completion
        pickerController.sourceType = .PhotoLibrary
        
        VC.presentViewController(pickerController, animated: true) {
//            self.cropImage(UIImage(named: "ceo.jpg", inBundle: nil, compatibleWithTraitCollection: nil)!)
        }
    }
    
    @objc func presentCamera(from VC: UIViewController, with completion: Completion)
    {
        configurePickerController()
        self.completion = completion
        pickerController.sourceType = .Camera
        
        VC.presentViewController(pickerController, animated: true) { 
            
        }
    }
   
    func cropImage(image: UIImage) {
        guard let vc = pickerController.presentingViewController else {
            logError("internal inconsistency")
            return
        }
        configureCropViewController()
        
        pickerController.dismissViewControllerAnimated(true) {
            vc.presentViewController(self.cropViewController, animated: true, completion: {
                self.cropViewController.image = image
            })
        }
    }
    
    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { 
            self.completion(nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            logError("no image, cancelling")
            imagePickerControllerDidCancel(picker)
            return
        }
        
        cropImage(image)
    }
    
    // MARK: CropViewControllerDelegate
    
    func cropViewControllerDidComplete(controller: CropViewController) {
        
    }
    
    func cropViewControllerDidTapCancel(controller: CropViewController) {
        controller.dismissViewControllerAnimated(true) {
            self.completion(nil)
        }
    }
}