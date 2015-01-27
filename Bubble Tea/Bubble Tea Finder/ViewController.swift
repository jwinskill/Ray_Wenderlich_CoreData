//
//  ViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/24/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coreDataStack: CoreDataStack!
  var fetchRequest: NSFetchRequest!
  var venues: [Venue]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.fetchRequest = self.coreDataStack.model.fetchRequestTemplateForName("FetchRequest")
    
    self.fetchAndReload()

  }
  
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

