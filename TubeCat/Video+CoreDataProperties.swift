//
//  Video+CoreDataProperties.swift
//  
//
//  Created by Leqi Long on 7/26/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var id: String?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var playlistItemId: String?
    @NSManaged var text: String?
    @NSManaged var thumbnail: NSData?
    @NSManaged var thumbnailURL: String?
    @NSManaged var title: String?
    @NSManaged var category: Category?
    @NSManaged var user: User?

}
