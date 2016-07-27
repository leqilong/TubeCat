//
//  Video.swift
//  
//
//  Created by Leqi Long on 7/26/16.
//
//

import Foundation
import CoreData


class Video: NSManagedObject {

    convenience init(id: String, title: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Video", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.title = title
        }else{
            fatalError("Unable to find entity name!")
        }
    }
    


}
