//
//  ViewController.swift
//  HitList
//
//  Created by Joshua Winskill on 12/9/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\"The List\""
      //  self.tableView.registerClass(UITableViewCell.self, forHeaderFooterViewReuseIdentifier: "CELL")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Workflow for fetching Core Data to populate Tableview
        
        // 1. Get a reference to the managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // 2. Create a fetch request object that will grab all Person Entities
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        // 3. Hand off the fetch request to the Managed Context to execute
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        if let results = fetchedResults {
            self.people = results
        } else {
            println("\(error!.description)")
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        let person = people[indexPath.row]
        cell?.textLabel.text = person.valueForKey("name") as? String
        return cell!
    }
    
    @IBAction func addName(sender: AnyObject) {
        var alert = UIAlertController(title: "New name", message: "Add a new name", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action : UIAlertAction!) -> Void in
            
            let textField = alert.textFields![0] as UITextField
            self.saveName(textField.text)
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action : UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveName(name: String) {
        
        // Workflow for saving data using CoreData:
        
        // 1. Get a reference to appDelegate's Managed Object Context
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // 2. Create a new managed object and insert it into the Managed Object Context
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext!)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // 3. Set the attributes for the managed object
        person.setValue(name, forKey: "name")
        
        // 4. Save the Managed Object Context with the added Managed Object and check for errors
        var error: NSError?
        if !managedContext!.save(&error) {
            println("could not save \(error), \(error!.userInfo)")
        }
        
        // 5. Append our data to the data source array for the table view
        people.append(person)
    }
}

