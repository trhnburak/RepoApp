//
//  CoreDataHelper.swift
//  RepoApp
//
//  Created by Burak Turhan on 2.04.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {

    // MARK: - Properties
    static let sharedManager = CoreDataHelper()

    static let shared = CoreDataHelper()

    private let persistentContainer: NSPersistentContainer

    // MARK: - Initialization
    private init() {
        persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }

    static func addFavorite(repository: Repository, helper: CoreDataHelper = shared) {
        
        helper.persistentContainer.performBackgroundTask { context in
            do {
                    let favorite = Favorite(context: context)
                    favorite.id = UUID()
                    favorite.name = repository.name
                    favorite.full_name = repository.fullName
                    favorite.is_favorited = true
                    try context.save()
                    print("saved")

            } catch {
                print("Failed to favorite repository: \(error)")
            }
        }
    }

    static func removeFavorite(repository: Repository, helper: CoreDataHelper = shared) {
        helper.persistentContainer.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
                request.predicate = NSPredicate(format: "name = %@", repository.name!)
                let results = try context.fetch(request)

                if let favorite = results.first {
                    context.delete(favorite)
                    try context.save()
                    print("deleted")
                }
            } catch {
                print("Failed to unfavorite repository: \(error)")
            }
        }
    }

    static func fetchFavorites(helper: CoreDataHelper = shared, completion: @escaping (Result<[Favorite], Error>) -> Void) {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "is_favorited = true")
        do {
            let favorites = try helper.persistentContainer.viewContext.fetch(request)
            completion(.success(favorites))
        } catch {
            completion(.failure(error))
        }
    }



}



