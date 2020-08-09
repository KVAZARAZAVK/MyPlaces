//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Anatoly Valkov on 6/10/20.
//  Copyright © 2020 Anatoly Valkov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
