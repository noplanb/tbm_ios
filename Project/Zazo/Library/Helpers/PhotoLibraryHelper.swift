//
//  PhotoLibraryPickerHelper.swift
//  Zazo
//
//  Created by Rinat on 07/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class PhotoLibraryHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    typealias Completion = (UIImage?)->()
    
    lazy var pickerController = UIImagePickerController()
    lazy var cropViewController = CropViewController(nibName: nil, bundle: nil)
    
    var completion: Completion
    
    override init() {
        completion = { (image) in
            logError("default completion called")
        }
        super.init()
        pickerController.allowsEditing = false
        pickerController.delegate = self
    }
    
    @objc func presentLibrary(from VC: UIViewController, with completion: Completion)
    {
        self.completion = completion
        pickerController.sourceType = .PhotoLibrary
        VC.presentViewController(pickerController, animated: true) {
            
        }
    }
    
    @objc func presentCamera(from VC: UIViewController, with completion: Completion)
    {
        self.completion = completion
        pickerController.sourceType = .Camera
        VC.presentViewController(pickerController, animated: true) { 
            
        }
    }
    
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
        imagePickerControllerDidCancel(picker)
    }
    
    func cropImage(image: UIImage) {

    }
}