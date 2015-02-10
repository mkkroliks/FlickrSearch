//
//  FlickrHelper.swift
//  FlickrAPI
//
//  Created by Maciej Krolikowski on 10/02/15.
//  Copyright (c) 2015 Maciej Krolikowski. All rights reserved.
//

import UIKit

class FlickrHelper: NSObject {
   
    class var sharedInstance:FlickrHelper {
        struct Singleton {
            static let instance = FlickrHelper()
        }
        return Singleton.instance
    }
    
    func URLForSearchString(searchString:String) -> String {
        let apiKey = "32400bdb252ffe7dafc8b07239c2a1ee"
        let search = searchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(search)&per_page=5&format=json&nojsoncallback=1"
    }
    
    func URLForFlickrPhoto(photo:FlickrPhoto, size:String?) -> String {
        let size:String! = (size == nil) ? "m" : size
        return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg"
    }
    
    func searchFlickrForString(searchString:String, complition:(flickrPhotos:[FlickrPhoto]?, error:NSError?)->()) {
        let searchURL = URLForSearchString(searchString)
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(queue, {
            var error:NSError?
            let searchResultString = String(contentsOfURL: NSURL(string:searchURL)!, encoding: NSUTF8StringEncoding, error: &error)
            
            if error != nil {
                complition(flickrPhotos: nil, error: error!)
            } else {
                //PARSE JSON
                var jsonData:NSData! = searchResultString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                let resultDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                
                if error != nil {
                    complition(flickrPhotos: nil, error: error!)
                } else {
                    let resultArray:NSArray = resultDict.objectForKey("photos")?.objectForKey("photo") as NSArray
                    var photos:[FlickrPhoto] = []
                    
                    for photoObj in resultArray {
                        let photoDict:NSDictionary = photoObj as NSDictionary
                        var flickrPhoto:FlickrPhoto = FlickrPhoto()
                        flickrPhoto.farm = photoDict.objectForKey("farm") as Int
                        flickrPhoto.server = photoDict.objectForKey("server") as String
                        flickrPhoto.secret = photoDict.objectForKey("secret") as String
                        flickrPhoto.id = photoDict.objectForKey("id") as String
                        
                        let searchURL:String = self.URLForFlickrPhoto(flickrPhoto, size: "m")
                        let imageData:NSData = NSData(contentsOfURL: NSURL(string: searchURL)!, options:nil, error: &error)!
                        
                        let image:UIImage = UIImage(data: imageData)!
                        
                        flickrPhoto.thumbnail = image
                        
                        photos.append(flickrPhoto)
                        
                    }
                    complition(flickrPhotos: photos, error: nil)
                }
            }
            
        })
    }
    
    
    

}
