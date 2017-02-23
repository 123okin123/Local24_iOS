//
//  NetworkManager.swift
//  Local24
//
//  Created by Local24 on 08/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import MapleBacon
import MapKit
import Fuzi
import SwiftyJSON

public class NetworkManager  {

    private var request :Request?
    
    init() {}
    
    // MARK: Inserate
    
    
    
    func getAdsSatisfying(filterArray :[Filter]?, page: Int, completion: @escaping (_ listings :[Listing]?,_ error :Error?) -> Void) ->  DataRequest {
        var parameters = [String:Any]()
        if filterArray != nil {
            parameters["source"] = FilterManager.shared.getJSONFromfilterArray(filterArray: filterArray!, size: 20, from: (page * 20))
        }
        
        let request = Alamofire.request(searchIndexURL, method: .get, parameters: parameters).responseJSON (completionHandler: { responseData in
           // debugPrint(responseData)
            
            switch responseData.result {
            case .failure(let error):
                completion(nil, error)
            case .success:
                var listings = [Listing]()
                if let value = responseData.result.value as? [AnyHashable: Any] {
                    if let firstHits = value["hits"] as? [AnyHashable: Any] {
                        if let hits = firstHits["hits"] as? NSArray {
                            for hit in hits {
                                if let hitvalues = hit as? [AnyHashable: Any] {
                                    let listing = Listing(searchIndexValue: hitvalues)
                                    listings.append(listing)
                                }
                            }
                        }
                    }
                }
                completion(listings, nil)
            }
        })
        return request
        
    }
    
    
     func loadAdWith(id: Int, completion: @escaping (_ listing: Listing?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(id)/").responseJSON(completionHandler: { response in
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
    
     func insertAdWith(values: [String:Any], images: [UIImage]?, existing: Bool, userToken: String, completion: @escaping (_ errorString :String?) -> Void)  {
        let method:  HTTPMethod
        let url :URLConvertible
        if existing {
            method = .put
            url = "https://cfw-api-11.azurewebsites.net/ads/\(values["ID"]!)?auth=\(userToken)"
        } else {
            method = .post
            url = "https://cfw-api-11.azurewebsites.net/ads?auth=\(userToken)"
        }
        
        request = Alamofire.request(url, method: method, parameters: values, encoding: JSONEncoding.default).responseJSON (completionHandler: { responseData in
            debugPrint(responseData)
            if let response = responseData.response {
                switch response.statusCode {
                case 201, 200:
                    if let location = response.allHeaderFields["Location"] as? String {
                        if let id = location.components(separatedBy: "/").last {
                            if images != nil {
                                if !images!.isEmpty {
                                    self.uploadImagesFor(adID: id, images: images!, userToken: userToken) { statusCode in
                                        if statusCode == 201 {
                                            completion(nil)
                                        } else {
                                            completion("Image Upload Failed")
                                            Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .delete, parameters: ["auth":userToken, "id":id, "finally": true]).validate().responseJSON(completionHandler: {response in
                                            })
                                        }
                                    }
                                } else {
                                    completion(nil)
                                }
                            }else {
                                completion(nil)
                            }
                            
                        }
                    }
                default:
                    if responseData.result.isSuccess {
                        let values = responseData.result.value as! [String : String]
                        var errorString = ""
                        for (_,value) in values {
                            errorString = errorString + value + "\n"
                        }
                        completion(errorString)
                    } else {
                        completion(responseData.result.error!.localizedDescription)
                    }
                }
            }
        })
    }
    
    
     func changeAdWith(adID: Int, to state: String, userToken: String, completion: @escaping (_ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(adID)", method: .get, parameters: ["auth": userToken, "id": adID]).validate().responseJSON { response in
            if response.result.error == nil {
                var values = response.result.value as! [String:Any]
                values["AdState"] = state
                let url = "https://cfw-api-11.azurewebsites.net/ads/\(adID)/?auth=\(userToken)&id=\(adID)"
                Alamofire.request(url, method: HTTPMethod.put, parameters: values, encoding: JSONEncoding.default).responseString(completionHandler: {response  in
                completion(response.result.error)
                })
            } else {
            completion(response.result.error)
            }
        }

    }
    
     func deleteAdWith(adID: Int, userToken :String, completion: @escaping (_ error: Error?) -> Void) {
            Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(adID)", method: .delete,
                              parameters:
                ["auth": userToken,
                 "id": adID as Any,
                 "finally": "true"
                ]).response {response in
                    if response.error == nil {
                        completion(nil)
                    } else {
                        completion(response.error)
                    }
            }
    }
    
    
     func cancelCurrentRequest() {
        request?.cancel()
        request = nil
    }
    
    
    // MARK: Forms
    
    
    class func getValuesForDepending(field: String, independendField: String, value: String, entityType: String, completion: @escaping (_ values: [String]?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/forms/\(entityType)/options", method: .get, parameters: ["name": entityType,"dependson": independendField, "value": value]).responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                if let json = response.result.value as? [[AnyHashable: Any]] {
               
                    if json.count > 0 {
                        var values = [String]()
                        for i in 0...json.count - 1 {
                            let value = json[i]["OptionValue"] as! String
                            values.append(value)
                        }
                        completion(values, nil)
                    } else {
                    completion(nil, NCError.RuntimeError("no values"))
                    }
                }
            } else {
            completion(nil, response.result.error)
            }
        })
    }
    

    
    


    
    // MARK: Images
    
     func uploadImagesFor(adID :String, images: [UIImage], userToken: String, completion: @escaping (_ statusCode: Int?) -> Void) {
        request = Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(adID)/images?auth=\(userToken)&id=\(adID)", method: .delete).validate().responseJSON (completionHandler: {response in
            let url = "https://cfw-api-11.azurewebsites.net/ads/\(adID)/images?auth=\(userToken)&id=\(adID)"
            Alamofire.upload(multipartFormData: { multipartFormData in
                for rawImage in images {
                    let image = self.resizeImage(image: rawImage, newWidth: 1000)!
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    let randomNum:UInt32 = arc4random_uniform(1000)
                    let imageName :String = String(randomNum)
                    multipartFormData.append(imageData!, withName: imageName, fileName: "\(imageName).jpg", mimeType: "image/jpeg")
                }
            }, to: url, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    self.request = upload
                    upload.validate()
                    upload.responseJSON { response in
                        self.request = nil
                        completion((response.response?.statusCode))
                    }
                case .failure: break
                }
            })
        })
    }
    
     func getImagePathsFor(adID :Int, completion: @escaping (_ imagePaths: [String]?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(adID)/images/").responseJSON(completionHandler: { response in
           
            switch response.result {
            case .failure(let error):
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
    
     func getImagesFor(adID :Int, completion: @escaping (_ images: [UIImage]?) -> Void) {
        self.getImagePathsFor(adID: adID, completion: { (imagePaths, error) in
            if error == nil {
                var images = [UIImage]()
                for imagePath in imagePaths!  {
                    if let imageUrl = URL(string: imagePath) {
                        let manager = ImageManager.sharedManager
                        _ = manager.downloadImage(atUrl: imageUrl, cacheScaled: false, imageView: nil, completion: { imageDownloaderCompletion in
                            if let image = imageDownloaderCompletion.0?.image {
                                images.append(image)
                            }
                            if imagePaths!.count == images.count {
                                completion(images)
                            }
                        })
                    }
                }
            }
        })
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getImageFor(paths: [String], completion: @escaping (_ images:[UIImage]?,_ error :Error?) -> Void) {
        var images = [UIImage]()
        for path in paths  {
            if let imageUrl = URL(string: path) {
                let manager = ImageManager.sharedManager
                _ = manager.downloadImage(atUrl: imageUrl, cacheScaled: false, imageView: nil, completion: { imageDownloaderCompletion in
                    if imageDownloaderCompletion.1 == nil {
                    if let image = imageDownloaderCompletion.0?.image {
                        images.append(image)
                    }
                    if paths.count == images.count {
                        completion(images, nil)
                    }
                    } else {
                    completion(nil, imageDownloaderCompletion.1)
                    }
                })
            }
        }

    }

    
    
    // MARK: User
    

     func registerUserWith(values :[String: Any], completion: @escaping (_ error:Error?) -> Void) {
        Alamofire.request("https://www.local24.de/registrieren/", method: .post, parameters: values).responseString { responseResult in
            if responseResult.result.isSuccess {
                if let string = responseResult.result.value {
                    if string.contains("successBox") {
                        completion(nil)
                    } else {
                        completion(NCError.RuntimeError("Fehler"))
                    }
                } else {
                    completion(NCError.RuntimeError("Fehler"))
                }
            } else {
            completion(responseResult.result.error)
            }
        }
    }
    
    
    
     func getUserProfile(userToken :String, completion: @escaping (_ user: User?, _ statusCode :Int) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/me", method: .get, parameters: ["auth": userToken]).validate().responseJSON (completionHandler: {response in
            if let statusCode = response.response?.statusCode {
                switch response.result {
                case .success:
                    tokenValid = true
                    let user = User(value: response.result.value as! [AnyHashable:Any])
                    self.getPlacemarkFor(user: user, completion: { (placemark, error) in
                        if error == nil {
                            user.placemark = placemark
                        }
                        completion(user, statusCode)
                    })
                    
                case .failure:
                    tokenValid = false
                    completion(nil, statusCode)
                }
            }
        })
    }
    
    
     func getPlacemarkFor(user: User, completion: @escaping (_ placemark :CLPlacemark?, _ error :Error?)-> Void) {
        guard let zipCode = user.zipCode else {
            completion(nil, NCError.RuntimeError("missing User Data"))
            return
        }
        guard let city = user.city else {
            completion(nil, NCError.RuntimeError("missing User Data"))
            return
        }
        guard let houseNumber = user.houseNumber else {
            completion(nil, NCError.RuntimeError("missing User Data"))
            return
        }
        guard let street = user.street else {
            completion(nil, NCError.RuntimeError("missing User Data"))
            return
        }
        let addressDict = ["City": city, "PostalCode": zipCode, "SubThoroughfare" : houseNumber, "Thoroughfare": street]

        let geocoder = CLGeocoder()

        
        geocoder.geocodeAddressDictionary(addressDict, completionHandler: { (placemarks, error) in
            if error == nil {
                let placemark = placemarks?[0]
                if placemark?.addressDictionary?["City"] != nil &&
                    placemark?.addressDictionary?["ZIP"] != nil {
                    completion(placemark, nil)
                } else {
                    completion(nil, NCError.RuntimeError("No City or PostalCode"))
                }
            } else {
                completion(nil, error)
            }
        })
    }
    

    
    func editUserInfos(user: User, userToken: String, completion: @escaping (_ error: Error?) -> Void) {
        
        guard let values = user.userToJSON() as? [String: Any] else {
            completion(NCError.RuntimeError("userToJSON failed"))
            return
        }
        let url :URLConvertible = "https://cfw-api-11.azurewebsites.net/me/account?auth=\(userToken)"
        Alamofire.request(url, method: .put, parameters: values, encoding: JSONEncoding.default, headers: nil).validate().responseJSON(completionHandler: { response in
            if let statusCode = response.response?.statusCode {
                if statusCode == 200 {
                completion(nil)
                } else {
                completion(NCError.RuntimeError("no statusCode 200"))
                }
            } else {
            completion(NCError.RuntimeError("no statusCode"))
            }
        })
    }
}


enum NCError : Error {
    case RuntimeError(String)
}






