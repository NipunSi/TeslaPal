//
//  CarDataEntry+CoreDataProperties.swift
//  TeslaHelper
//
//  Created by Nipun Singh on 10/27/20.
//
//

import Foundation
import CoreData


extension CarDataEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CarDataEntry> {
        return NSFetchRequest<CarDataEntry>(entityName: "CarDataEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var odometer: Int32
    @NSManaged public var vehicleID: String?
    @NSManaged public var energyAdded: Int32
    @NSManaged public var batteryLevel: Int16

}

extension CarDataEntry : Identifiable {

}
