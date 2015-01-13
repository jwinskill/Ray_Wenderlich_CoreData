//
//  Walk.swift
//  Dog Walk
//
//  Created by Joshua Winskill on 1/11/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import Foundation
import CoreData

class Walk: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var dog: Dog

}
