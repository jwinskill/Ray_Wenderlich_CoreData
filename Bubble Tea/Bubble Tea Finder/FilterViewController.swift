//
//  FilterViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/27/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
  
  //FilterViewController Delegate section
  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?
  
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
  lazy var offeringDealPredicate: NSPredicate = {
    var predicate = NSPredicate(format: "specialCount > 0")
    return predicate!
  }()
  lazy var walkingDistancePredicate: NSPredicate = {
    var predicate = NSPredicate(format: "location.distance < 500")
    return predicate!
  }()
  lazy var hasUserTipsPredicate: NSPredicate = {
    var predicate = NSPredicate(format: "stats.tipCount > 0")
    return predicate!
  }()
  
  //Sort Descriptor section
  lazy var nameSortDescriptor: NSSortDescriptor = {
    var sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: "localizedStandardCompare:")
    return sortDescriptor
  }()
  lazy var distanceSortDescriptor: NSSortDescriptor = {
    var sortDescriptor = NSSortDescriptor(key: "location.distance", ascending: true)
    return sortDescriptor
  }()
  lazy var priceSortDescriptor: NSSortDescriptor = {
    var sortDescriptor = NSSortDescriptor(key: "priceInfo.priceCategroy", ascending: true)
    return sortDescriptor
  }()
  
  //MARK - overridden view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    populateCheapMenuCountLabel()
    populateModerateMenuCountLabel()
    populateExpensiveMenuCountLabel()
    populateDealsCountLabel()
  }

  //MARK - UITableViewDelegate methods
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
    
    switch cell {
      // price section
    case cheapVenueCell:
      selectedPredicate = self.cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = self.moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = self.expensiveVenuePredicate
    case offeringDealCell:
      selectedPredicate = self.offeringDealPredicate
    case walkingDistanceCell:
      selectedPredicate = self.walkingDistancePredicate
    case userTipsCell:
      selectedPredicate = self.hasUserTipsPredicate
    case nameAZSortCell:
        selectedSortDescriptor = self.nameSortDescriptor
    case nameZASortCell:
        selectedSortDescriptor = self.nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
    case distanceSortCell:
        selectedSortDescriptor = self.distanceSortDescriptor
    case priceSortCell:
        selectedSortDescriptor = self.priceSortDescriptor
    default:
      println("default case")
    }
    
    cell.accessoryType = .Checkmark
  }
  
  // MARK - UIButton target action
  
  @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
    
    self.delegate!.filterViewController(self, didSelectPredicate: self.selectedPredicate, sortDescriptor: self.selectedSortDescriptor)
    
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
  
  func populateDealsCountLabel() {
    // 1. Create a fetch request, and set its result type to DictionaryResultType
    var fetchRequest = NSFetchRequest(entityName: "Venue")
    fetchRequest.resultType = .DictionaryResultType
    
    // 2. create a NSExpressionDescription to request the sum, give it a name so its result can be read
    let sumExpressionDesc = NSExpressionDescription()
    sumExpressionDesc.name = "sumDeals"
    
    // 3. Specify the function used (sum) and proptery to sum (specialCount), and set return type
    sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "specialCount")])
    sumExpressionDesc.expressionResultType = .Integer32AttributeType
    
    // 4. Tell the fetch request to fetch the expression we just created
    fetchRequest.propertiesToFetch = [sumExpressionDesc]
    
    // 5. Execute the fetch request
    var error: NSError?
    let result = self.coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as? [NSDictionary]
    
    if let resultArray = result {
      let resultDict = resultArray[0]
      let numDeals: AnyObject? = resultDict["sumDeals"]
      self.numDealsLabel.text = "\(numDeals!) total deals"
    } else {
      println("Error: \(error?.localizedDescription)")
    }
  }
  
}
