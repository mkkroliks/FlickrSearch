//
//  ViewController.swift
//  FlickrAPI
//
//  Created by Maciej Krolikowski on 10/02/15.
//  Copyright (c) 2015 Maciej Krolikowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activity.hidden = true
        self.activity.startAnimating()
    }
    @IBAction func searchForImage(sender: AnyObject) {
        
        searchTextField.resignFirstResponder()
        self.activity.hidden = false
        
        FlickrHelper.sharedInstance.searchFlickrForString(searchTextField.text, complition: { (flickrPhotos:[FlickrPhoto]?, error:NSError?) -> () in
            if (error == nil) {
                let flickrPhoto:FlickrPhoto = flickrPhotos![Int(arc4random_uniform(UInt32(flickrPhotos!.count)))] as FlickrPhoto
                let image:UIImage = flickrPhoto.thumbnail
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.searchImageView.image = image
                    self.activity.hidden = true
                })
                
            } else {
                //error occured
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

