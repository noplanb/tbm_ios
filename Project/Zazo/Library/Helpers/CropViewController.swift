//
//  CropViewController.swift
//  Zazo
//
//  Created by Rinat on 07/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit


protocol CropViewControllerDelegate: class {
    func cropViewControllerDidTapCancel(controller: CropViewController);
    func cropViewControllerDidComplete(controller: CropViewController, with cropRect: CGRect);
}

class CropViewController: UIViewController {
    
    weak var delegate: CropViewControllerDelegate?
    
    private(set) lazy var contentView = CropView()
    
    var faceRect: CGRect?
    
    var image: UIImage? {
        didSet {
            updateImage(image)
        }
    }
    
    var neededImageSize = CGSize(width: 480, height: 640)
    
    var cropSize: CGSize = {
        let screenSize = UIScreen.mainScreen().bounds.size
        let width = screenSize.width * 3/4
        let height = width * 4/3
        return CGSize(width: width, height: height)
    }()
    
    override func loadView() {
        self.view = contentView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentView.cropSize = cropSize
        
        let isPad2 = UIScreen.mainScreen().scale == 1 && UIScreen.mainScreen().bounds.size.width == 768
        let maxScale: CGFloat = isPad2 ? 1.2 : 1
        
        let scale = neededImageSize.width/cropSize.width
        contentView.scrollView.maximumZoomScale = scale > maxScale ? scale : maxScale
    }
    
    func configureNavigationBar() {
        contentView.navigationBar.items = [navigationItem]
        navigationItem.title = "Crop"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didTapDone))
    }
    
    override func viewDidLoad() {
        updateScrollView()
        configureNavigationBar()
    }
    
    func updateImage(image: UIImage?) {
        contentView.imageView.image = image
        faceRect = image != nil ? detectFace(image!) : nil
        updateScrollView()
    }
    
    override func viewDidAppear(animated: Bool) {
        centerToFaceIfPossible()
    }
    
    func updateScrollView() {

        guard let image = self.contentView.imageView.image else {
            return
        }
        
        let minimalVerticalScale = cropSize.height / image.size.height
        let minimalHorizontalScale = cropSize.width / image.size.width
        let scale = max(minimalVerticalScale, minimalHorizontalScale)
        
        contentView.scrollView.minimumZoomScale = scale
        contentView.scrollView.zoomScale = scale

        let imageSize = CGSize(width: image.size.width * scale,
                               height: image.size.height * scale)
        
        let centerOffset = CGPoint(x: (imageSize.width - cropSize.width)/2,
                             y: (imageSize.height - cropSize.height)/2)
        
        contentView.scrollView.contentOffset = centerOffset
        centerToFaceIfPossible()
    }
    
    func centerToFaceIfPossible() {
        
        guard let faceRect = faceRect else {
            return
        }
        
        GCDBlock.after(.Main, delay: 0.1) {
            let rect = self.extendRectToCropSize(faceRect)
            self.contentView.scrollView.scrollRectToVisible(rect, animated: false)
        }
    }
    
    func extendRectToCropSize(rect: CGRect) -> CGRect {
        var extendedRect = CGRect(origin: CGPoint.zero, size: cropSize)
        extendedRect.center = rect.center
        return extendedRect
    }

    func detectFace(image: UIImage) -> CGRect? {
        
        let context = CIContext()
        let opts = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: opts) else {
            return nil
        }
        
        let _image = image.CGImage != nil ? CIImage(CGImage: image.CGImage!) : image.CIImage
        
        guard let coreImage = _image else {
            return nil
        }
        
        let features = detector.featuresInImage(coreImage)
        
        let faces: [CIFaceFeature] = features.filter({ $0 is CIFaceFeature }).map({ $0 as! CIFaceFeature })
        
        guard let face = faces.first else {
            return nil
        }
        
        var bounds = face.bounds
        bounds.origin.y = image.size.height - bounds.origin.y - bounds.height
        return bounds
    }
}

extension CropViewController {
    func didTapCancel() {
        self.delegate?.cropViewControllerDidTapCancel(self)
    }
    
    func didTapDone() {
        let scrollView = self.contentView.scrollView
        let result = scrollView.convertRect(scrollView.bounds, toView: self.contentView.imageView)
        self.delegate?.cropViewControllerDidComplete(self, with: result)
    }
}
