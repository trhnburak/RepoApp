import UIKit
import Alamofire

class RepositoryListViewModel {

    var apiClient: APIClient?

   

    var totalPages = 10
    var isFetchingData = false

    var repositories = [Repository]()
    var filteredRepositories = [Repository]()
    var favoriteRepositories = [Repository]()
    var errorMessage: String = ""

    var didUpdateRepositories: (() -> Void)?
    var didFailToUpdateRepositories: ((String) -> Void)?
    var repositoriesDidChange: (([Repository]) -> Void)?

    var currentPage: Int = 1 {
        didSet {
            // Notify any observers of the change
            currentPageDidChange?(currentPage)
        }
    }

    var currentPageDidChange: ((Int) -> Void)?

    var numberOfRepositories: Int {
        return filteredRepositories.count
    }

    enum FilterOption: String {
        case organization = "Organization"
        case other1 = "Other1"
        case other2 = "Other2"
    }

    //MARK: - Fetch
    func fetchRepositories(page: Int, type: RepositoryListViewController.FilterOption? = nil) {
        // Check if we've already fetched all the repositories
        guard currentPage <= totalPages else {
            return
        }

        // Check if we're already fetching data
        guard !isFetchingData else {
            return
        }

        // Set isFetchingData to true to prevent multiple fetches
        isFetchingData = true

        var endpoint: Endpoint
        if let type = type {
            endpoint = Endpoint.googleRepositories(page: currentPage, type: type)
        } else {
            endpoint = Endpoint.googleRepositories(page: currentPage)
        }

        APIClient.get(endpoint: endpoint) { [weak self] result in
            // Handle the result
            switch result {
                case let .success(response):
                    //self?.totalPages = response.totalPages
                    self?.repositories += response
                    self?.sortRepositories(by: .createdDescending)
                    self?.didUpdateRepositories?()
                    self?.repositoriesDidChange?(self?.filteredRepositories ?? [Repository]())
                case let .failure(error):
                    self?.didFailToUpdateRepositories?(error.localizedDescription)
            }

            // Set isFetchingData to false to allow another fetch
            self?.isFetchingData = false
        }
    }

    
    //MARK: - Pagination
    func loadNextPage() {
        guard currentPage < totalPages else {
            return
        }
        repositories = []
        self.currentPage += 1
        fetchRepositories(page: currentPage)

    }

    func loadFirstPage() {
        currentPage = 1
        repositories = []
        fetchRepositories(page: 1)
    }

    func loadPreviousPage() {
        guard currentPage > 0 else {
            return
        }
        repositories = []
        self.currentPage -= 1
        fetchRepositories(page: currentPage)

    }

    func loadLastPage() {
        guard totalPages > 0 else {
            return
        }
        repositories = []
        self.currentPage = totalPages
        fetchRepositories(page: currentPage)
    }

    //MARK: - Search
    func searchRepositories(with searchQuery: String) {
        if searchQuery.isEmpty {
            // Reset the filteredRepositories array
            filteredRepositories = []

            // Fetch repositories for the current page number
            fetchRepositories(page: currentPage)

        } else {
            // Filter the repositories based on the search query
            filteredRepositories = repositories.filter { repository in
                repository.name?.lowercased().contains(searchQuery.lowercased()) ?? false
            }
        }

        // Update repositories and numberOfRepositories properties
        self.repositories = filteredRepositories

        // Call repositoriesDidChange closure with filteredRepositories array
        repositoriesDidChange?(filteredRepositories)
    }

    // MARK: - Filter and Sort
    func filterRepositories(with predicate: (Repository) -> Bool) {
        filteredRepositories = repositories.filter(predicate)
        repositoriesDidChange?(filteredRepositories)
    }

    func sortRepositories(by sortOption: RepositoryListViewController.RepositorySortOption) {
        switch sortOption {
            case .createdAscending:
                repositories.sort(by: { $0.createdAt ?? "" < $1.createdAt ?? "" })
            case .createdDescending:
                repositories.sort(by: { $0.createdAt ?? "" > $1.createdAt ?? "" })
        }

        repositoriesDidChange?(repositories)
    }


    // MARK: - Core Data
    func addFavorite(repository: Repository){
        CoreDataHelper.addFavorite(repository: repository)
    }

    func removeFavorite(repository: Repository){
        CoreDataHelper.removeFavorite(repository: repository)
    }




    func getFavorites(completion: @escaping (Result<[Favorite], Error>) -> Void) {
        CoreDataHelper.fetchFavorites(completion: completion)
    }


}
