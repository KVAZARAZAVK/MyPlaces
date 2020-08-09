//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Anatoly Valkov on 6/8/20.
//  Copyright © 2020 Anatoly Valkov. All rights reserved.
//

 import RealmSwift
 import CloudKit

class Place: Object {
    
    @objc dynamic var placeID    = UUID().uuidString
    @objc dynamic var recordID   = ""
    @objc dynamic var date       = Date()
    @objc dynamic var imageData  : Data?
    @objc dynamic var location   : String?
    @objc dynamic var name       = ""
    @objc dynamic var rating     = 0.0
    @objc dynamic var type       : String?
    
    convenience init (name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.imageData  = imageData
        self.location   = location
        self.name       = name
        self.rating     = rating
        self.type       = type
    }
    
    convenience init(record: CKRecord) {
        self.init()
        
        let image = #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image.pngData()
        
        self.placeID    = record.value(forKey: "placeID") as! String
        self.recordID   = record.recordID.recordName
        self.name       = record.value(forKey: "name") as! String
        self.location   = record.value(forKey: "location") as? String
        self.type       = record.value(forKey: "type") as? String
        self.imageData  = imageData
        guard let rating = record.value(forKey: "rating") as? Double else { return }
        self.rating     = rating
    }
    
    override static func primaryKey() -> String? {
        return "placeID"
    }
}

