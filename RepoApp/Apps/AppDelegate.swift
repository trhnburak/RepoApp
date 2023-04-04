//
//  AppDelegate.swift
//  RepoApp
//
//  Created by Burak Turhan on 30.03.2023.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Set the root view controller
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create a RepositoryListViewController
        let repositoryListVC = RepositoryListViewController()

        // Create a UINavigationController and set the repositoryListVC as the rootViewController
        let navigationController = UINavigationController(rootViewController: repositoryListVC)

        // Create a TabBarController
        let tabBarController = UITabBarController()
        // Create a RepositoryListViewController

        let favoritesViewController = FavoritesViewController()

        // Set titles and icons for each tab
        repositoryListVC.title = "Home"
        if #available(iOS 13.0, *) {
            repositoryListVC.tabBarItem.image = UIImage(systemName: "house")
        } else {
            // Fallback on earlier versions
        }

        favoritesViewController.title = "Favorites"
        if #available(iOS 13.0, *) {
            favoritesViewController.tabBarItem.image = UIImage(systemName: "heart.fill")
        } else {
            // Fallback on earlier versions
        }

        // Set the navigationController as one of the view controllers of the tabBarController
        tabBarController.viewControllers = [navigationController, favoritesViewController]

        // Set the tabBarController as the rootViewController for the window
        window?.rootViewController = tabBarController

        // Make the window visible
        window?.makeKeyAndVisible()

        return true
    }


    
}

