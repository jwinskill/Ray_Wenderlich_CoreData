//
//  AppDelegate.swift
//  Dog Walk
//
//  Created by Pietro Rea on 7/10/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()
    
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    let navigationController = self.window!.rootViewController as UINavigationController
    
    let viewController = navigationController.topViewController as ViewController
    
    viewController.context = self.coreDataStack.context
    
    return true
  }
    
  func applicationDidEnterBackground(application: UIApplication) {
        self.coreDataStack.saveContext()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.coreDataStack.saveContext()
    }

}

