//
//  Conversion.swift
//  
//
//  Created by Mayank Kumar on 7/28/15.
//
//

import Foundation
import CoreData

@objc(Conversion)

class Conversion: NSManagedObject {

    @NSManaged var association: String
    @NSManaged var baseValue: NSNumber
    @NSManaged var eurValue: NSNumber
    @NSManaged var gbpValue: NSNumber
    @NSManaged var inrValue: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Conversion", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        association = dictionary["association"] as! String
        baseValue = dictionary["baseVal"] as! NSNumber
        eurValue = dictionary["eurVal"] as! NSNumber
        gbpValue = dictionary["gbpVal"] as! NSNumber
        inrValue = dictionary["inrVal"] as! NSNumber
    }

}
