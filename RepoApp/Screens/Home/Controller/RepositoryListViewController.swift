
import UIKit


class RepositoryListViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties

    var viewModel: RepositoryListViewModel?


    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Repositories"
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    private let firstPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("First", for: .normal)
        return button
    }()

    private let previousPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Previous", for: .normal)
        return button
    }()

    private let nextPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        return button
    }()

    private let lastPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Last", for: .normal)
        return button
    }()

    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filter", for: .normal)
        return button
    }()

    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sort", for: .normal)
        return button
    }()

    private let sortOptions: [RepositorySortOption] = [.createdAscending, .createdDescending]


    enum RepositorySortOption: String, CaseIterable {
        case createdAscending = "Created (Oldest First)"
        case createdDescending = "Created (Newest First)"

        var title: String {
            return self.rawValue
        }
    }


    enum FilterOption: String, CaseIterable {
        case organization = "Organization"
        case other1 = "Other1"
        case other2 = "Other2"

        var title: String {
            switch self {
                case .organization:
                    return "Organization"
                case .other1:
                    return "Other 1"
                case .other2:
                    return "Other 2"
            }
        }
    }

    var selectedFilterOption: FilterOption = .organization
    var selectedSortOption: RepositorySortOption = .createdDescending


    // MARK: - View Lifecycle



    override func viewDidLoad() {
        super.viewDidLoad()


        // Initialize viewModel
        viewModel = RepositoryListViewModel()

        // Set the view background color to white
        view.backgroundColor = .white

        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(firstPageButton)
        view.addSubview(previousPageButton)
        view.addSubview(nextPageButton)
        view.addSubview(lastPageButton)
        view.addSubview(filterButton)
        view.addSubview(sortButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: firstPageButton.topAnchor),

            firstPageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            firstPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            previousPageButton.leadingAnchor.constraint(equalTo: firstPageButton.trailingAnchor, constant: 16),
            previousPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            nextPageButton.trailingAnchor.constraint(equalTo: lastPageButton.leadingAnchor, constant: -16),
            nextPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            lastPageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lastPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            filterButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            sortButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            sortButton.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8)
        ])

        if viewModel?.currentPage == 1 {
            previousPageButton.isEnabled = false
            firstPageButton.isEnabled = false
        }else if viewModel?.currentPage == viewModel?.totalPages{
            nextPageButton.isEnabled = false
            lastPageButton.isEnabled = false
        } else {
            previousPageButton.isEnabled = true
            nextPageButton.isEnabled = true
            firstPageButton.isEnabled = true
            lastPageButton.isEnabled = true
        }

        nextPageButton.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)
        previousPageButton.addTarget(self, action: #selector(previousPageButtonTapped), for: .touchUpInside)
        firstPageButton.addTarget(self, action: #selector(firstPageButtonTapped), for: .touchUpInside)
        lastPageButton.addTarget(self, action: #selector(lastPageButtonTapped), for: .touchUpInside)

        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)


        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "Cell")

        // Set searchBar delegate
        searchBar.delegate = self

        // Bind to ViewModel
        viewModel?.repositoriesDidChange = { [weak self] repositories in
            if let tableView = self?.tableView {
                if let window = tableView.window, window.isKeyWindow {
                    tableView.reloadData()
                } else {
                    tableView.dataSource = self

                    tableView.dataSource = self
                    tableView.reloadData()
                }
            }
        }
        viewModel?.fetchRepositories(page: 1)
    }

    // MARK: - Actions

    @objc private func firstPageButtonTapped() {
        buttonDisabler()
        viewModel?.loadFirstPage()
        tableView.reloadData()
    }

    @objc private func previousPageButtonTapped() {
        buttonDisabler()
        viewModel?.loadPreviousPage()
        tableView.reloadData()
    }

    @objc private func nextPageButtonTapped() {
        buttonDisabler()
        viewModel?.loadNextPage()
        tableView.reloadData()
    }

    @objc private func lastPageButtonTapped() {
        buttonDisabler()
        viewModel?.loadLastPage()
        tableView.reloadData()
    }

    @objc private func showSortOptions() {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)

        for sortOption in sortOptions {
            let action = UIAlertAction(title: sortOption.title, style: .default) { [weak self] _ in
                self?.selectedSortOption = sortOption
                self?.viewModel?.sortRepositories(by: sortOption)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc func showFilterOptions() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        for option in FilterOption.allCases {
            alert.addAction(UIAlertAction(title: option.rawValue, style: .default, handler: { _ in
                self.selectedFilterOption = option
                // Call your method to update the repository list based on the selected filter option
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }



    func buttonDisabler(){
        viewModel?.currentPageDidChange = { [weak self] currentPage in
            if currentPage == 1 {
                self?.previousPageButton.isEnabled = false
                self?.firstPageButton.isEnabled = false
                self?.nextPageButton.isEnabled = true
                self?.lastPageButton.isEnabled = true
            }else if currentPage == self?.viewModel?.totalPages{
                self?.nextPageButton.isEnabled = false
                self?.lastPageButton.isEnabled = false
                self?.previousPageButton.isEnabled = true
                self?.firstPageButton.isEnabled = true
            } else {
                self?.previousPageButton.isEnabled = true
                self?.nextPageButton.isEnabled = true
                self?.firstPageButton.isEnabled = true
                self?.lastPageButton.isEnabled = true

            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel?.searchRepositories(with: searchText)
        }
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            // Search bar is empty
            viewModel?.fetchRepositories(page: viewModel?.currentPage ?? 1)
        }
    }

}

// MARK: - UITableViewDelegate

extension RepositoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITableViewDataSource

extension RepositoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.repositories.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RepositoryTableViewCell
        if let repository = viewModel?.repositories[indexPath.row] {
            cell.configure(with: repository)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel?.repositories[indexPath.row]

        let detailViewController = DetailViewController()

        detailViewController.name = repository?.name
        detailViewController.descriptionOfRepo = repository?.description



        if let navigationController = self.navigationController {
            // Set hidesBottomBarWhenPushed to true
            detailViewController.hidesBottomBarWhenPushed = true

            navigationController.pushViewController(detailViewController, animated: true)
        }else{
            print("no")
        }


        
    }

}


