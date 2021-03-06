//
//  ViewController.swift
//  Bow Ties
//
//  Created by Pietro Rea on 6/25/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    var managedContext: NSManagedObjectContext!
    var currentBowtie: Bowtie!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 1. call insertSampleData
    self.insertSampleData()
    
    // 2. fetch the newly inserted bowtie entities
    let request = NSFetchRequest(entityName: "Bowtie")
    let firstTitle = self.segmentedControl.titleForSegmentAtIndex(0)
    
    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle!)
    
    // 3. The MOC executes fetch request and returns a Bowtie array
    var error: NSError?
    
    var results = managedContext.executeFetchRequest(request, error: &error) as? [Bowtie]
    
    // 4. Populate the UI with the first bow tie in the results array
    if let bowties = results {
        currentBowtie = bowties[0]
        populate(currentBowtie)
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
    }
  }
  
  @IBAction func segmentedControl(control: UISegmentedControl) {
    
    let selectedValue = control.titleForSegmentAtIndex(control.selectedSegmentIndex)
    let fetchRequest = NSFetchRequest(entityName: "Bowtie")
    
    fetchRequest.predicate = NSPredicate(format: "searchKey == %@", selectedValue!)
    
    var error: NSError?
    
    let results = self.managedContext.executeFetchRequest(fetchRequest, error: &error) as? [Bowtie]
    
    if let bowties = results {
        currentBowtie = bowties.last!
        populate(currentBowtie)
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
    }
  }

  @IBAction func wear(sender: AnyObject) {
    let times = self.currentBowtie.timesWorn.integerValue
    currentBowtie.timesWorn = NSNumber(integer: (times + 1))
    
    currentBowtie.lastWorn = NSDate()
    
    var error: NSError?
    if !self.managedContext.save(&error) {
        println("Could not save \(error), \(error!.userInfo)")
    }
    self.populate(currentBowtie)
  }
  
  @IBAction func rate(sender: AnyObject) {
    let alert = UIAlertController(title: "New Rating", message: "Rate this bowtie", preferredStyle: UIAlertControllerStyle.Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
    }
    
    let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action) -> Void in
        let textField = alert.textFields![0] as UITextField
        self.updateRating(textField.text)
    }
    
    alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
    }
    
    alert.addAction(cancelAction)
    alert.addAction(saveAction)
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
    
    func populate(bowtie: Bowtie) {
        imageView.image = UIImage(data: bowtie.photoData)
        self.nameLabel.text = bowtie.name
        ratingLabel.text = "Rating: \(bowtie.rating.doubleValue)/5"
        
        timesWornLabel.text = "# times worn: \(bowtie.timesWorn.integerValue)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        lastWornLabel.text = "Last worn: " + dateFormatter.stringFromDate(bowtie.lastWorn)
        favoriteLabel.hidden = !bowtie.isFavorite.boolValue
        
        view.tintColor = bowtie.tintColor as UIColor
    }
    
    func updateRating(numericString: String) {
        
        let rating = (numericString as NSString).doubleValue
        self.currentBowtie.rating = NSNumber(double: rating)
        
        var error: NSError?
        if !self.managedContext.save(&error) {
            if error!.code == NSValidationNumberTooSmallError || error!.code == NSValidationNumberTooLargeError {
                rate(currentBowtie)
            }
        } else {
            populate(currentBowtie)
        }
    }
    
    // MARK: - CoreData Sample propogation
    
    func insertSampleData() {
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
        let count = managedContext.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            return
        }
        
        let path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        
        let dataArray = NSArray(contentsOfFile: path!)
        
        for dict in dataArray! {
            let entity = NSEntityDescription.entityForName("Bowtie", inManagedObjectContext: managedContext)
            
            let bowtie = Bowtie(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            let btDict = dict as NSDictionary
            
            bowtie.name = btDict["name"] as NSString
            bowtie.searchKey = btDict["searchKey"] as NSString
            bowtie.rating = btDict["rating"] as NSNumber
            let tintColorDict = btDict["tintColor"] as NSDictionary
            bowtie.tintColor = colorFromDict(tintColorDict)
            
            let imageName = btDict["imageName"] as NSString
            let image = UIImage(named: imageName)
            let photoData = UIImagePNGRepresentation(image)
            bowtie.photoData = photoData
            
            bowtie.lastWorn = btDict["lastWorn"] as NSDate
            bowtie.timesWorn = btDict["timesWorn"] as NSNumber
            bowtie.isFavorite = btDict["isFavorite"] as NSNumber
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error!.userInfo)")
        }
    }
    
    func colorFromDict(dict: NSDictionary) -> UIColor {
        let red = dict["red"] as NSNumber
        let green = dict["green"] as NSNumber
        let blue = dict["blue"] as NSNumber
        
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        
        return color
    }
}

