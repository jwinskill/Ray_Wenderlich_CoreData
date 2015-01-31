//
//  ViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/24/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, FilterViewControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var coreDataStack: CoreDataStack!
  var asyncFetchRequest: NSAsynchronousFetchRequest!
  var fetchRequest: NSFetchRequest!
  var venues: [Venue] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
    batchUpdate.propertiesToUpdate = ["favorite": NSNumber(bool: true)]
    batchUpdate.affectedStores = self.coreDataStack.psc.persistentStores
    batchUpdate.resultType = NSBatchUpdateRequestResultType.UpdatedObjectsCountResultType
    
    var batchError: NSError?
    let batchResult = self.coreDataStack.context.executeRequest(batchUpdate, error: &batchError) as NSBatchUpdateResult?
    
    if let result = batchResult {
      println("Records updated \(result.result!)")
    } else {
      println("Could not update \(batchError), \(batchError!.userInfo)")
    }
    
    // 1. Create a fetch request to be wrapped by an asynchronous fetch request
    var fetchRequest = NSFetchRequest(entityName: "Venue")
    
    // 2. Create an asyncfetchrequest with the previous fetch request. Set results and reload table view in completion block
    self.asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest)
      { [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
      
      self.venues = result.finalResult as [Venue]
      self.tableView.reloadData()
    }
    
    // 3. use the coreData context to call executeRequest (instead of executeFetchRequest) to fetch data
    var error: NSError?
    let results = self.coreDataStack.context.executeRequest(self.asyncFetchRequest, error: &error)
    
    if let persistentStoreResults = results {
      
    } else {
      println("Could not fetch \(error), \(error!.localizedDescription)")
    }
  }
  
  // MARK: - FilterViewController Methods
  
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
    
    fetchRequest.predicate = nil
    fetchRequest.sortDescriptors = nil
    
    if let fetchPredicate = predicate {
      fetchRequest.predicate = fetchPredicate
    }
    
    if let fetchSortDescriptor = sortDescriptor {
      fetchRequest.sortDescriptors = [fetchSortDescriptor]
    }
    
    fetchAndReload()
  }
  
  // MARK: - TableView Methods
  
  func tableView(tableView: UITableView?,
    numberOfRowsInSection section: Int) -> Int {
      return self.venues.count
  }
  
  func tableView(tableView: UITableView!,
    cellForRowAtIndexPath
    indexPath: NSIndexPath!) -> UITableViewCell! {
      
      var cell = tableView.dequeueReusableCellWithIdentifier("VenueCell") as UITableViewCell
      let venue = venues[indexPath.row]
      
      
      cell.textLabel.text = venue.name
      cell.detailTextLabel!.text = venue.priceInfo.priceCategory
      
      return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "toFilterViewController" {
      
      let navController = segue.destinationViewController as UINavigationController
      let filterVC = navController.topViewController as FilterViewController
      filterVC.coreDataStack = self.coreDataStack
      filterVC.delegate = self
    }
  }
    
  func fetchAndReload() {
    var error: NSError?
    let results = self.coreDataStack.context.executeFetchRequest(self.fetchRequest, error: &error) as? [Venue]
    if let fetchedResults = results {
      self.venues = fetchedResults
    } else {
      println("Error, could not save: \(error?.description)")
    }
    
    self.tableView.reloadData()
  }
  
  @IBAction func unwindToVenuListViewController(segue: UIStoryboardSegue) {
    
  }
}

