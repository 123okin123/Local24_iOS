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
import MapKit
import Fuzi


class NetworkController {

    
    // MARK: Inserate
    
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
        let url :URLConvertible
        if existing {
            method = .put
            url = "https://cfw-api-11.azurewebsites.net/ads/\(values["ID"]!)?auth=\(userToken)"
        } else {
            method = .post
            url = "https://cfw-api-11.azurewebsites.net/ads?auth=\(userToken)"
        }
        Alamofire.request(url, method: method, parameters: values, encoding: JSONEncoding.default).responseString (completionHandler: { response in
            debugPrint(response)
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
    class func changeAdWith(adID: Int, to state: String, userToken: String, completion: @escaping (_ error: Error?) -> Void) {
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
    
    class func deleteAdWith(adID: Int, userToken :String, completion: @escaping (_ error: Error?) -> Void) {
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
    
    
    
    // MARK: Forms
    
    
    class func getValuesForDepending(field: String, of independendField: String, with value: String, entityType: String, completion: (_ values: [String]?, _ error: Error?) -> Void) {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/forms/\(entityType)/options", method: .get, parameters: ["name": entityType,"dependson": independendField, "value": value]).responseJSON(completionHandler: { response in
        debugPrint(response)
        })
    }
    

    class func getCustomFieldsFor(entityType: String, completion: @escaping (_ fields:[(String,[String])]?, _ error: Error?) -> Void) {
        let customFieldNamesCar = [
            ("Make", "Marke"),
            ("Model", "Modell"),
            ("Condition", "Zustand"),
            ("BodyColor", "Außenfarbe"),
            ("BodyForm", "Karosserieform"),
            ("GearType", "Getriebeart"),
            ("FuelType", "Kraftstoffart"),
            ("InitialRegistration", "Erstzulassung"),
            ("Mileage", "Kilometerstand"),
            ("Power", "Leistung")
        ]
        
        
        Alamofire.request("https://cfw-api-11.azurewebsites.net/forms/\(entityType)/schema", method: .get).responseJSON(completionHandler: { response in
            
            if response.result.isSuccess {
                if let responseString = response.result.value as? String {
                    do {
                        let doc = try XMLDocument(string: responseString)
                        if let properties = doc.root?.firstChild(tag: "Properties") {
                            var fields = [(String,[String])]()
                            for property in properties.children {
                                if let propertyName = property.attr("name") {
                                    if customFieldNamesCar.contains(where: {(string0, string1) in
                                        return string0 == propertyName
                                    }) {
                                        if let options = property.firstChild(tag: "Constraints")?.firstChild(tag: "OptionsOnly") {
                                            if let optionsArray = options.attr("options")?.components(separatedBy: ",") {
                                            fields.append((propertyName, optionsArray))
                                            }
                                        }
                                    }
                                }
                            }
                            switch entityType {
                            case "AdCar":
                                var initialRegistration = [String]()
                                let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
                                for i in 1960...2050 {
                                    for month in months {
                                    initialRegistration.append(month+"/"+String(i))
                                    }
                                }
                                fields.append(("InitialRegistration", initialRegistration))
                                var mileAge = [String]()
                                for i in 0...100 {
                                    mileAge.append(String(i*5000))
                                }
                                fields.append(("Mileage", mileAge))
                                var power = [String]()
                                for i in 0...500 {
                                    power.append(String(i))
                                }
                                fields.append(("Power", power))
                            default: break
                            }
                            debugPrint(fields)
                            completion(fields,nil)
                        }
                    } catch let error {
                        print(error)
                        completion(nil,error)
                    }
                
                }
            } else {
            completion(nil, response.result.error)
            }
        })
    }

    
    // MARK: Images
    
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

    
    
    // MARK: User
    

    class func registerUserWith(values :[String: Any], completion: @escaping (_ error:Error?) -> Void) {
        Alamofire.request("https://www.local24.de/registrieren/", method: .post, parameters: values).responseString { responseResult in
        debugPrint(responseResult)
            if responseResult.result.isSuccess {
            completion(nil)
            } else {
            completion(responseResult.result.error)
            }
        }
    }
    
    
    
    class func getUserProfile(userToken :String, completion: @escaping (_ user: User?, _ statusCode :Int) -> Void) {
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
    
    
    class func getPlacemarkFor(user: User, completion: @escaping (_ placemark :CLPlacemark?, _ error :Error?)-> Void) {
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

        print(addressDict)
        
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
    



}


enum NCError : Error {
    case RuntimeError(String)
}
