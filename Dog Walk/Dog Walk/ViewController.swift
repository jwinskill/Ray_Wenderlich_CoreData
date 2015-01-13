//
//  ViewController.swift
//  Dog Walk
//
//  Created by Pietro Rea on 7/10/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
  
  @IBOutlet var tableView: UITableView!
  var currentDog: Dog!
  var context: NSManagedObjectContext!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.registerClass(UITableViewCell.self,
      forCellReuseIdentifier: "Cell")
    
    // Insert Dog entity
    let dogEntity = NSEntityDescription.entityForName("Dog", inManagedObjectContext: self.context)
    
    let dogName = "Fido"
    let dogFetch = NSFetchRequest(entityName: "Dog")
    dogFetch.predicate = NSPredicate(format: "name == %@", dogName)
    
    var error: NSError?
    
    let result = self.context.executeFetchRequest(dogFetch, error: &error) as? [Dog]
    
    if let dogs = result {
        if dogs.count == 0 {
            self.currentDog = Dog(entity: dogEntity!, insertIntoManagedObjectContext: self.context)
            self.currentDog.name = dogName
            
            if !self.context.save(&error) {
                println("Could not save: \(error)")
            }
        } else {
            currentDog = dogs[0]
        }
    } else {
        println("Could not fetch: \(error)")
    }
  }
    
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
  }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 1. Get a reference to the walk in the cell for editing
            let walkToRemove = self.currentDog.walks[indexPath.row] as Walk
            
            // 2. Remove the core data object by first creating a copy and then removing the walk
            let walks = self.currentDog.walks.mutableCopy() as NSMutableOrderedSet
            walks.removeObjectAtIndex(indexPath.row)
            currentDog.walks = walks.copy() as NSOrderedSet
            
            // 3. Remove the object with the managed context
            self.context.deleteObject(walkToRemove)
            
            // 4. Finally save the changes with the managed context
            var error: NSError?
            if !self.context.save(&error) {
                println("Could not save \(error)")
            }
            
            // 5. Animate the table view to inform the user of the deletion
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
  
  func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
        
        var numRows = 0
        
        if let dog = self.currentDog? {
            numRows = dog.walks.count
        }
        
        return numRows
  }
  
  func tableView(tableView: UITableView,
    titleForHeaderInSection section: Int) -> String? {
      return "List of Walks";
  }
  
  func tableView(tableView: UITableView,
    cellForRowAtIndexPath
    indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell =
      tableView.dequeueReusableCellWithIdentifier("Cell",
      forIndexPath: indexPath) as UITableViewCell
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .ShortStyle
    dateFormatter.timeStyle = .MediumStyle
    
    let walk = self.currentDog.walks[indexPath.row] as Walk
        
    cell.textLabel.text = dateFormatter.stringFromDate(walk.date)
    
    return cell
  }
  
  @IBAction func add(sender: AnyObject) {

    // insert a new walk entity into core data
    let walkEntity = NSEntityDescription.entityForName("Walk", inManagedObjectContext: self.context)
    
    let walk = Walk(entity: walkEntity!, insertIntoManagedObjectContext: self.context)
    
    walk.date = NSDate()
    
    // Insert the new walk into the dog's walks set
    var walks = self.currentDog.walks.mutableCopy() as NSMutableOrderedSet
    
    walks.addObject(walk)
    
    currentDog.walks = walks.copy() as NSOrderedSet
    
    // Save the managed object context
    var error: NSError?
    if !self.context!.save(&error) {
        println("Could not save: \(error)")
    }
    
    
    tableView.reloadData()
  }
  
}

