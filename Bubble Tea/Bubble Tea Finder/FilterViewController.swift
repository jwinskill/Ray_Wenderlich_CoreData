//
//  FilterViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/27/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UITableViewController {
  
  
  //Outlets section
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!
  
  //Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!
  
  //Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  //Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!
  
  //CoreData section
  var coreDataStack: CoreDataStack!
  lazy var cheapVenuePredicate: NSPredicate = {
    var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$")
    return predicate!
  }()
  lazy var moderateVenuePredicate: NSPredicate = {
    var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$")
    return predicate!
  }()
  lazy var expensiveVenuePredicate: NSPredicate = {
    var predicate = NSPredicate(format: "priceInfo.priceCategory == %@", "$$$")
    return predicate!
  }()
  
  //MARK - overridden view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    populateCheapMenuCountLabel()
    populateModerateMenuCountLabel()
    populateExpensiveMenuCountLabel()
  }

  //MARK - UITableViewDelegate methods
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  // MARK - UIButton target action
  
  @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion:nil)
  }
  
  // MARK - Label methods
  
  func populateCheapMenuCountLabel() {
    
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.resultType = .CountResultType
    fetchRequest.predicate = self.cheapVenuePredicate
    
    var error: NSError?
    
    let result = self.coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as? [NSNumber]
    
    if let countArray = result {
      self.firstPriceCategoryLabel.text = "\(countArray[0].integerValue) bubble tea places"
    } else {
      println("Error: \(error?.localizedDescription)")
    }
  }
  
  func populateModerateMenuCountLabel() {
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.resultType = .CountResultType
    fetchRequest.predicate = self.moderateVenuePredicate
    
    var error: NSError?
    
    let result = self.coreDataStack.context.executeFetchRequest(fetchRequest, error: &error)
    
    if let countArray = result {
      self.secondPriceCategoryLabel.text = "\(countArray[0].integerValue) bubble tea places"
    } else {
      println("Error: \(error!.localizedDescription)")
    }
  }
  
  func populateExpensiveMenuCountLabel() {
    let fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.predicate = self.expensiveVenuePredicate
    
    var error: NSError?
    
    let count = self.coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
    
    if count == NSNotFound {
      println("Could not fetch, error: \(error?.localizedDescription)")
    }
    
    self.thirdPriceCategoryLabel.text = "\(count) bubble tea places"
  }
  
}
