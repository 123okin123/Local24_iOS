//
//  Categories.swift
//  Local24
//
//  Created by Locla24 on 27/01/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation


class Categories {


    var categoriesAPI = [CategoryModel]()
    var mainCategoriesAPI = [CategoryModel]()
    var subCategoriesAPI = [CategoryModel]()
    
    func getCategories() {
    let url = "https://cfw-api-11.azurewebsites.net/public/categories"
    var request = URLRequest(url: URL(string: url)!)
    let session = URLSession.shared
    request.httpMethod = "GET"
    let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
        if error != nil {
            print("thers an error in the log")
        } else {
            DispatchQueue.main.async {
                do {
                    let  json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions())
                    let array = json as! [[AnyHashable: Any]]
                    if array.count > 0 {
                        for i in 0...array.count - 1 {
                            let categoryModel = CategoryModel()
                            if let adclass = array[i]["AdClass"] as? String {
                                categoryModel.adclass = adclass
                            }
                            if let id = array[i]["ID"] as? Int {
                                categoryModel.id = id
                            }
                            if let idParentCategory = array[i]["ID_ParentCategory"] as? Int {
                                categoryModel.idParentCategory = idParentCategory
                                categoryModel.isParentCat = false
                            } else {
                                categoryModel.isParentCat = true
                            }
                            if let level = array[i]["Level"] as? Int {
                                categoryModel.level = level
                            }
                            if let name = array[i]["Name"] as? String {
                                categoryModel.name = name
                            }
                            self.categoriesAPI.append(categoryModel)
                            if categoryModel.isParentCat! {
                            self.mainCategoriesAPI.append(categoryModel)
                            } else {
                            self.subCategoriesAPI.append(categoryModel)
                            }
                        }
                    }
                } catch {
                }
            }
        }
    }) 
    task.resume()
    }





    let mainCatsStrings = [
        "Autos, Fahrzeuge",
        "Immobilien",
        "Tiere",
        "Haushalt, Möbel",
        "Jobs, Stellenangebote",
        "Dienstleistungen, Service",
        "Partnersuche",
        "Kontaktanzeigen",
        "Baby, Kind",
        "Fahrrad",
        "Sport, Freizeit, Hobby",
        "Gewerbe",
        "Bauen, Renovieren",
        "Garten, Pflanzen",
        "Musik, Film, Bücher",
        "Antiquitäten, Kunst",
        "Flirt & Abenteuer"
        
]
    let cats = [
        ["Alles in Autos, Fahrzeuge", "Auto", "Motorrad", "Reifen", "LKW"],
        ["Alles in Immobilien", "Wohnung", "Haus", "Ferienwohnungen"],
        ["Alles in Tiere", "Tierzubehör", "Hunde", "Katzen", "Pferde", "Reitbeteiligung & Pferdebox", "Fische"],
        ["Alles in Haushalt, Möbel", "Haushaltsgeräte", "Sofas, Sessel, Couch", "Möbel", "Schrank", "Lampen & Licht", "Wohnzimmer", "Schlafzimmer", "Küchenmöbel"],
        ["Alles in Jobs, Stellenangebote", "Bau", "Haushaltshilfe", "Selbstständige", "Informationstechnologie", "Gesundheit & Medizin"],
        ["Alles in Dienstleistungen, Service", "Haushaltsauflösung", "Alles Mögliche"],
        ["Alles in Partnersuche", "Frau sucht Mann", "Mann sucht Frau"],
        ["Alle Kontaktanzeigen", "Er sucht sie", "Sie sucht ihn", "Sie sucht sie", "Er sucht ihn", "Freundschaft"],
        ["Alles in Baby, Kind", "Kinderwagen", "Babykleidung", "Spielzeug"],
        ["Alles in Fahrrad", "Mountainbike", "Kinderfahrrad", "Fahrradzubehör", "Damenfahrrad"],
        ["Alles in Sport, Freizeit, Hobby", "Modellbau","Wintersport","Gesellschaftsspiele","Fitnessgeräte","Inliner & Rollschuhe","Angeln"],
        ["Alles in Gewerbe", "Restposten", "Gastronomiebedarf"],
        ["Alles in Bauen, Renovieren", "Werkzeug", "Baumaschinen"],
        ["Alles in Garten, Pflanzen", "Diverses", "Gartengeräte", "Blumen, Samen, Pflanzen", "Gartenmöbel", "Grill, Barbecue", "Blumentopf, Blumenkübel"],
        ["Alles in Musik, Film, Bücher", "Musikinstrumente", "Sachbücher, Fachbücher", "Belletristik, Literatur", "Kinderbücher, Jugenbücher", "Zeitschriften, Magazine", "Diverses"],
        ["Alles in Antiquitätem", "Diverses", "Glas, Porzellan", "Antike Möbel", "Bilder, Gemälde"],
        ["Alles in Flirt & Abenteuer", "Fetisch und Lust", "Paare und Mehr", "Er sucht sie Erotik", "Sie sucht ihn Erotik", "Er sucht ihn Erotik", "Sie sucht sie Erotik"]
        
    ]

    
    func getURLFromMainCatID(_ id :Int?) -> String {
    
        var url = ""
    if id != nil {
    switch id! {
    case 0: url = "autos-fahrzeuge/"
    case 1: url = "immobilien/"
    case 2: url = "tiere/"
    case 3: url = "haushalt-moebel/"
    case 4: url = "job/"
    case 5: url = "dienstleistungen-service/"
    case 6: url = "partnersuche/"
    case 7: url = "kontaktanzeigen/"
    case 8: url = "baby-kind/"
    case 9: url = "fahrrad/"
    case 10: url = "sport-freizeit-hobby/"
    case 11: url = "gewerbe-existenzgruendung/"
    case 12: url = "bauen-renovieren/"
    case 13: url = "garten-pflanzen/"
    case 14: url = "musik-film-buecher/"
    case 15: url = "antiquitaeten-kunst/"
    case 16: url = "flirt-abenteuer/"
    default: break
    }
    } 
     return url
    }
    
    
    func getSubCatURLFromID(_ mainId :Int?, subId :Int?) -> String {
        
        var url = ""
        if mainId != nil && subId != nil {
            switch mainId! {
            case 0:
                switch subId! {
                case 0: url = "auto/"
                case 1: url = "motorrad/"
                case 2: url = "reifen-felgen/"
                case 3: url = "lkw-nutzfahrzeuge/"
                default: break
                }
            case 1:
                switch subId! {
                case 0: url = "wohnung/"
                case 1: url = "haus/"
                case 2: url = "ferienwohnungen-ferienhaeuser/"
                default: break
                }
            case 2:
                switch subId! {
                case 0: url = "tierzubehoer/"
                case 1: url = "hunde/"
                case 2: url = "katzen/"
                case 3: url =  "pferde/"
                case 4: url = "reitbeteiligung-pferdebox/"
                case 5: url = "fische/"
                default: break
                }
            case 3:
                switch subId! {
                case 0: url = "haushaltsgeraete/"
                case 1: url = "sofa-sessel-couch/"
                case 2: url = "moebel/"
                case 3: url = "schrank/"
                case 4: url = "lampen-licht/"
                case 5: url = "wohnzimmer/"
                case 6: url = "schlafzimmer-betten-matratzen/"
                case 7: url = "kuechenmoebel/"
                default: break
                }
            case 4:
                switch subId! {
                case 0: url = "bau-handwerk-produktion/"
                case 1: url = "reinigungskraft-haushaltshilfe-au-pair/"
                case 2: url = "selbststaendigkeit/"
                case 3: url = "informationstechnologie/"
                case 4: url = "gesundheit-medizin/"
                default: break
                }
            case 5:
                switch subId! {
                case 0: url = "haushaltsaufloesung/"
                case 1: url = "diverses/"
                default: break
                }
            case 6:
                switch subId! {
                case 0: url =  "frau-sucht-mann/"
                case 1: url = "mann-sucht-frau/"
                default: break
                }
            case 7:
                switch subId! {
                case 0: url =  "er-sucht-sie/"
                case 1: url = "sie-sucht-ihn/"
                case 2: url = "sie-sucht-sie/"
                case 3: url = "er-sucht-ihn/"
                case 4: url = "freundschaft/"
                default: break
                }
            case 8:
                switch subId! {
                case 0: url =  "kinderwagen-buggys/"
                case 1: url = "bekleidung-schuhe/"
                case 2: url = "spielzeug-spielsachen/"
                default: break
                }
            case 9:
                switch subId! {
                case 0: url = "mountainbike/"
                case 1: url = "kinderfahrrad-jugendfahrrad/"
                case 2: url = "fahrradzubehoer-fahrradteile/"
                case 3: url = "damenfahrrad/"
                default: break
                }
            case 10:
                switch subId! {
                case 0: url = "modellbau-technik/"
                case 1: url = "wintersport/"
                case 2: url = "gesellschaftsspiele-kartenspiele/"
                case 3: url = "fitnessgeraete-heimtrainer/"
                case 4: url = "inliner-rollschuhe/"
                case 5: url = "angeln-angelzubehoer/"
                default: break
                }
            case 11:
                switch subId! {
                case 0: url = "restposten-insolvenzen/"
                case 1: url = "gastronomiebedarf/"
                default: break
                }
            case 12:
                switch subId! {
                case 0: url = "werkzeug/"
                case 1: url = "baugeraete-baumaschinen/"
                default: break
                }
            case 13:
                switch subId! {
                case 0: url = "diverses/"
                case 1: url = "gartengeraete/"
                case 2: url = "blumen-samen-pflanzen/"
                case 3: url = "gartenmoebel/"
                case 4: url = "grill-barbecue/"
                case 5: url = "blumentopf-blumenkuebel/"
                default: break
                }
            case 14:
                switch subId! {
                case 0: url = "musikinstrumente/"
                case 1: url = "sachbuecher-fachbuecher/"
                case 2: url = "belletristik-literatur/"
                case 3: url = "kinderbuecher-jugendbuecher/"
                case 4: url = "zeitschriften-magazine/"
                case 5: url = "diverses/"
                default: break
                }
            case 15:
                switch subId! {
                case 0: url = "diverses/"
                case 1: url = "glas-porzellan/"
                case 2: url = "antike-moebel/"
                case 3: url = "bilder-gemaelde/"
                default: break
                }
            case 16:
                switch subId! {
                case 0: url = "fetisch-und-lust/"
                case 1: url = "paare-und-mehr/"
                case 2: url = "er-sucht-sie-erotik/"
                case 3: url = "sie-sucht-ihn-erotik/"
                case 4: url = "er-sucht-ihn-erotik/"
                case 5: url = "sie-sucht-sie-erotik/"
                default: break
                }
            default: break
        }
    }
        return url
    }
    
    
}



class CategoryModel {
    var id :Int?
    var idParentCategory :Int?
    var name :String?
    var level :Int?
    var adclass :String?
    var isParentCat :Bool?
}




