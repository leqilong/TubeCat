//
//  User+CoreDataProperties.swift
//  
//
//  Created by Leqi Long on 7/20/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var authToken: String?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: String?
    @NSManaged var imageData: NSData?
    @NSManaged var lastName: String?
    @NSManaged var loadedVideos: NSNumber?
    @NSManaged var pageToken: String?
    @NSManaged var videos: NSSet?

}
