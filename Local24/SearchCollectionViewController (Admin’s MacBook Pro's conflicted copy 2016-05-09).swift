//
//  SearchCollectionViewController.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ListingsCell"

class SearchCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var listingsArray = [Listing]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        for _ in 0...20 {
        let listing = Listing()
        listing.title = "langer langer title"
        listing.price = "100.000 €"
        listing.mainImage = UIImage(named: "home_Background")
        listingsArray.append(listing)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return listingsArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchCollectionViewCell
        cell.listingTitle.text = listingsArray[indexPath.row].title
        cell.listingPrice.text = listingsArray[indexPath.row].price
        cell.listingImage.image = listingsArray[indexPath.row].mainImage
        
    
        // Configure the cell
    
        return cell
    }

    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {


        return CGSize(width: screenwidth/2 - 20, height: 200)
    }
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    
    
    func loadData() {
        let url = "https://cfw-api-11.azurewebsites.net/public/ads/"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                print("thers an error in the log")
                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    do {

                        let  json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions())
                        let array = json as! NSArray
                        if array.count > 0 {
                            for i in 0...array.count - 1 {
                                print(array[i]["Title"] as! String)
                               
                            }
                        }
                        
    
                        
                        
                    } catch {
                        let alert = UIAlertController(title: "Fehler", message: "Der Artikel konnte nicht gefunden werden.", preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    
                    
                }
            }
            
        }
        
        task.resume()
        
    }

    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
