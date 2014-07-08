//
//  TMImageViewExtensions.swift
//  SampleApiCall
//
//  Created by Thahir Maheen on 7/7/14.
//  Copyright (c) 2014 Thahir Maheen. All rights reserved.
//

import UIKit

let SharedImageCache = ImageCache()

class ImageCache: NSObject {
    
    var currentCache : NSMutableDictionary? = [:] as NSMutableDictionary
    
    class var sharedCache : ImageCache {
        return SharedImageCache
    }
    
    func imageForKey(key : NSString) -> UIImage? {
        return currentCache![key] as? UIImage
    }
    
    func setImageForKey(image : UIImage, key : NSString) {
        currentCache![key] = image
    }
}

extension UIView {
    
    func disableAutoresizingMask() {
        setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    func centerHorizontallyInSuperview() {
        disableAutoresizingMask()
        var constraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.superview.addConstraint(constraints)
    }
    
    func centerVerticallyInSuperview() {
        disableAutoresizingMask()
        var constraints = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.superview.addConstraint(constraints)
    }
}

extension UIImageView {
    
    func setImageWithUrlString(urlString : NSString, placeHolderImage : UIImage) {
        setImageWithUrl(NSURL.URLWithString(urlString), placeHolderImage: placeHolderImage)
    }
    
    func setImageWithUrl(url : NSURL, placeHolderImage : UIImage) {
        
        // set the placeholder image
        self.image = placeHolderImage
        
        func configureActivityIndicatorView() -> UIActivityIndicatorView {
            let _activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            _activityIndicatorView.hidesWhenStopped = true
            _activityIndicatorView.startAnimating()
            
            return _activityIndicatorView
        }
        
        // set activity indicator view
        let activityIndicatorView = configureActivityIndicatorView()
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerHorizontallyInSuperview()
        activityIndicatorView.centerVerticallyInSuperview()
        
        // do everything in a background thread
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // try to get the image from the SharedImageCache
            var image: UIImage? = ImageCache.sharedCache.imageForKey(url.absoluteString) as? UIImage
            
            // function which sets image with a fade animation
            func setImageWithAnimation() {
                
                // set the image to the imageview
                self.alpha = 0
                self.image = image
                activityIndicatorView.stopAnimating()
                
                // animate images on loading
                UIView.animateWithDuration(1.5, animations: { self.alpha = 1 }) { finished in
                    
                    // hide the activity indicator
                    activityIndicatorView.stopAnimating()
                }
            }
            
            if !image? {
                
                // if the image does not exist, we need to download it
                // Download an NSData representation of the image at the URL
                var request: NSURLRequest = NSURLRequest(URL: url)
                var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!,data: NSData!,error: NSError!) in
                    
                    if !error? {
                        
                        // save the image
                        image = UIImage(data: data)
                        
                        // Store the image in to our cache
                        ImageCache.sharedCache.setImageForKey(image!, key: url.absoluteString)
                        
                        // set image with a fade animation
                        setImageWithAnimation()
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                    })
                
            }
            else {
                
                // set image with a fade animation
                setImageWithAnimation()
            }
            })
    }
}
