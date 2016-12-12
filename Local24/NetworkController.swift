//
//  NetworkController.swift
//  Local24
//
//  Created by Local24 on 08/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import MapleBacon

class NetworkController {

    
    
    class func loadAdWith(id: Int, completion: @escaping (_ listing: Listing?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(id)/").responseJSON(completionHandler: { response in
            debugPrint(response)
            switch response.result {
            case .failure(let error):
                completion(nil, error)
            case .success:
                if let value = response.result.value as? [AnyHashable: Any] {
                    let listing = Listing(value: value)
                    completion(listing, nil)
                }
            }
        })
    }
    
    
    class func insertAdWith(values: [String:Any], images: [UIImage]?, existing: Bool, userToken: String, completion: @escaping (_ error :Error?) -> Void) {
        let method:  HTTPMethod
        if existing {
            method = .put
        } else {
            method = .post
        }
        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads?auth=\(userToken)", method: method, parameters: values, encoding: JSONEncoding.default).responseString (completionHandler: { response in
            switch response.result {
            case .success:
                Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .get, parameters: ["auth":userToken, "pagesize":1]).validate().responseJSON (completionHandler: {response in
                    switch response.result {
                    case .success:
                        let value = response.result.value  as! [[AnyHashable:Any]]
                        if let id = value[0]["Id"] as? Int {
                            Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(id)/images?auth=\(userToken)&id=\(id)", method: .delete).validate().responseJSON (completionHandler: {response in
                                if images != nil {
                                    if !images!.isEmpty {
                                        self.uploadImagesFor(adID: id, images: images!, userToken: userToken) { statusCode in
                                            if statusCode == 201 {
                                                completion(nil)
                                            } else {
                                                completion(NCError.RuntimeError("Image Upload Failed"))
                                                Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .delete, parameters: ["auth":userToken, "id":id, "finally": true]).validate().responseJSON(completionHandler: {response in
                                                    debugPrint(response)
                                                })
                                            }
                                        }
                                    } else {
                                        completion(nil)
                                    } }else {
                                    completion(nil)
                                }
                                
                            })
                        }
                    case .failure: print(response.response!)
                    }
                })
            case .failure:
                print(response.response!)
                completion(NCError.RuntimeError("Ad Upload Failed"))
            }
        })
    }
    
    
    class func uploadImagesFor(adID :Int, images: [UIImage], userToken: String, completion: @escaping (_ statusCode: Int?) -> Void) {
        let url = "https://cfw-api-11.azurewebsites.net/ads/\(adID)/images?auth=\(userToken)&id=\(adID)"
        Alamofire.upload(multipartFormData: { multipartFormData in
            for rawImage in images {
                let image = self.resizeImage(image: rawImage, newWidth: 500)!
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let randomNum:UInt32 = arc4random_uniform(1000)
                let imageName :String = String(randomNum)
                multipartFormData.append(imageData!, withName: imageName, fileName: "\(imageName).jpg", mimeType: "image/jpeg")
            }
        }, to: url, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.validate()
                upload.responseJSON { response in
                    completion((response.response?.statusCode))
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })

    }
    
    
    class func getImagePathsFor(adID :String, completion: @escaping (_ imagePaths: [String]?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(adID)/images/").responseJSON(completionHandler: { response in
           
            switch response.result {
            case .failure(let error):
                print(error)
                completion(nil, error)
            case .success:
                if let json = response.result.value as? [[AnyHashable: Any]] {
                    if json.count > 0 {
                        var imagePaths = [String]()
                        for i in 0...json.count - 1 {
                            let url = json[i]["ImagePathLarge"] as! String
                            imagePaths.append(url)
                        }
                        completion(imagePaths, nil)
                    }
                }
            }
        })
    }
    
    class func getImagesFor(adID :String, completion: @escaping (_ images: [UIImage]?) -> Void) {
        self.getImagePathsFor(adID: adID, completion: { (imagePaths, error) in
            if error == nil {
                var images = [UIImage]()
                for imagePath in imagePaths!  {
                    if let imageUrl = URL(string: imagePath) {
                        let manager = ImageManager.sharedManager
                        _ = manager.downloadImage(atUrl: imageUrl, cacheScaled: false, imageView: nil, completion: { imageDownloaderCompletion in
                            images.append((imageDownloaderCompletion.0?.image)!)
                            if imagePaths!.count == images.count {
                                completion(images)
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
}


enum NCError : Error {
    case RuntimeError(String)
}
