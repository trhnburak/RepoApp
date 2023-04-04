//
//  FavoritesViewModel.swift
//  RepoApp
//
//  Created by Burak Turhan on 2.04.2023.
//

import UIKit


class FavoritesViewModel {

    // MARK: - Properties
    var repositories: [Repository] = []
    var errorMessage: String = ""

    var favorites = [Favorite]()

    // MARK: - Methods

    func fetchFavorites() {
        CoreDataHelper.fetchFavorites { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let favorites):
                    self.favorites = favorites
                case .failure(let error):
                    print("Failed to fetch favorites: \(error)")
            }
        }
    }

    func fetchRepositoriesByOwner(owner:String?, repo:String?, completion: @escaping () -> Void) {
        APIClient.get(endpoint: Endpoint.repositoryDetails(owner: owner ?? "", repo: repo ?? "")) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let repositories):
                    self.repositories = repositories
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
            }

            completion()
        }
    }

}


