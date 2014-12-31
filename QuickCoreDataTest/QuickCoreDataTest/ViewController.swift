//
//  ViewController.swift
//  QuickCoreDataTest
//
//  Created by Joshua Winskill on 12/27/14.
//  Copyright (c) 2014 Joshua Winskill. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData(name: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        person.setValue(name, forKey: "name")
        var error: NSError?
        
        if !managedContext.save(&error) {
            println("You've got an error, son.")
        }
        self.people.append(person)
    }

    @IBAction func save(sender: AnyObject) {
        if self.textField.text != "" {
            self.saveData(self.textField.text)
        }
    }
    @IBAction func display(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        var error: NSError?
        
        let fetchResults = appDelegate.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchResults {
            self.people = results
            for person in self.people {
                var name = person.valueForKey("name") as? String
                if let nameToPrint = name {
                    println(name)
                }
            }
        } else {
            println("\(error?.localizedDescription)")
        }
    }

}

