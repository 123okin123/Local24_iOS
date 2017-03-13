//
//  DetailImageViewController.swift
//  Local24
//
//  Created by Local24 on 09/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class DetailImageViewController: UIViewController, UIScrollViewDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var closeButton: UIButton! {didSet {
        closeButton.layer.cornerRadius = 5
        closeButton.layer.borderColor = UIColor.white.cgColor
        closeButton.layer.borderWidth = 1
        }}
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: Variables
    
    var images = [UIImage]()
    var touchedImageTag = Int()
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        var imageViewFrameOriginX :CGFloat = 0
        if images.count > 0 {
        for i in 0...images.count - 1 {
        let image = images[i]
        let imageView = UIImageView(image: image)
        imageView.frame.origin = CGPoint(x: imageViewFrameOriginX, y: 0)
        imageView.frame.size.height = screenheight
        imageView.frame.size.width = screenwidth
        imageViewFrameOriginX = imageViewFrameOriginX + screenwidth
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        }
        }

        scrollView.contentSize = CGSize(width: imageViewFrameOriginX, height: screenheight)

        let xoffSet = screenwidth * CGFloat(touchedImageTag)
        scrollView.contentOffset = CGPoint(x: xoffSet, y: 0)
        
        pageControl.numberOfPages = images.count
        
        

        pageControl.currentPage = touchedImageTag
        pageControl.updateCurrentPageDisplay()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("DetailImage")
    }
    
    
    
    override var prefersStatusBarHidden : Bool {
       return true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage  = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(currentPage)
        pageControl.updateCurrentPageDisplay()
    }
    
}
