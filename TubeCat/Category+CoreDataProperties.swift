//
//  Category+CoreDataProperties.swift
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

extension Category {

    @NSManaged var boxIndex: NSNumber?
    @NSManaged var currentPageToken: String?
    @NSManaged var id: String?
    @NSManaged var imageUrl: String?
    @NSManaged var loadedVideos: NSNumber?
    @NSManaged var name: String?
    @NSManaged var nextPageToken: String?
    @NSManaged var prePageToken: String?
    @NSManaged var videos: NSSet?

}
