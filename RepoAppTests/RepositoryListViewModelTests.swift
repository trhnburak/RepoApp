//
//  RepositoryListViewModelTests.swift
//  RepoAppTests
//
//  Created by Burak Turhan on 5.04.2023.
//

import XCTest
@testable import RepoApp

enum APIError: Error {
    case networkError
    case invalidResponse
    case authenticationError

}

class RepositoryListViewModelTests: XCTestCase {

    var sut: RepositoryListViewModel!
    var mockAPIClient: MockAPIClient!




    override func setUp() {
        super.setUp()

        // Create an instance of RepositoryListViewModel
        sut = RepositoryListViewModel()

        // Create a mock APIClient to replace the actual APIClient used in sut
        mockAPIClient = MockAPIClient()
        sut.apiClient = mockAPIClient as APIClient // Set the apiClient property of sut to mockAPIClient
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        mockAPIClient = nil
    }

    // MARK: - Test Fetching Repositories

    // MARK: - Test Fetching Repositories

    func testFetchRepositories_WithValidData_ShouldUpdateRepositories() {
        // Given
        let repo1Data = "{\"name\": \"Repo1\"}".data(using: .utf8)!
        let repo2Data = "{\"name\": \"Repo2\"}".data(using: .utf8)!
        let decoder = JSONDecoder()
        let repo1 = try! decoder.decode(Repository.self, from: repo1Data)
        let repo2 = try! decoder.decode(Repository.self, from: repo2Data)
        let expectedRepositories = [repo1, repo2]
        mockAPIClient.result = .success(expectedRepositories) as Result<[Repository], APIError>

        // When
        sut.fetchRepositories(page: 1)

        // Then
        XCTAssertTrue(mockAPIClient.isGetEndpointCalled)
        XCTAssertEqual(sut.repositories, expectedRepositories)
    }




    func testFetchRepositories_WithError_ShouldCallDidFailToUpdateRepositories() {
        // Given
        let expectedError = APIError.networkError
        mockAPIClient.result = .failure(expectedError)
        var didFailToUpdateRepositoriesCalled = false
        sut.didFailToUpdateRepositories = { errorMessage in
            didFailToUpdateRepositoriesCalled = true
        }

        // When
        sut.fetchRepositories(page: 1)

        // Then
        XCTAssertTrue(mockAPIClient.isGetEndpointCalled)
        XCTAssertTrue(didFailToUpdateRepositoriesCalled)
    }


    // MARK: - Test Pagination

    func testLoadNextPage_WithCurrentPageLessThanTotalPages_ShouldLoadNextPage() {
        // Given
        let initialPage = sut.currentPage
        let totalPages = sut.totalPages
        sut.totalPages = totalPages + 1

        // When
        sut.loadNextPage()

        // Then
        XCTAssertEqual(sut.currentPage, initialPage + 1)
    }

    func testLoadNextPage_WithCurrentPageEqualToTotalPages_ShouldNotLoadNextPage() {
        // Given
        let initialPage = sut.currentPage
        let totalPages = sut.totalPages
        sut.totalPages = totalPages

        // When
        sut.loadNextPage()

        // Then
        XCTAssertEqual(sut.currentPage, initialPage)
    }

    func testLoadFirstPage_ShouldLoadFirstPage() {
        // Given
        let initialPage = sut.currentPage

        // When
        sut.loadFirstPage()

        // Then
        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertNotEqual(sut.currentPage, initialPage)
    }

    func testLoadPreviousPage_WithCurrentPageGreaterThan1_ShouldLoadPreviousPage() {
        // Given
        sut.currentPage = 3

        // When
        sut.loadPreviousPage()

        // Then
        XCTAssertEqual(sut.currentPage, 2)
    }

    func testLoadPreviousPage_WithCurrentPageEqualTo1_ShouldNotLoadPreviousPage() {
        // Given
        sut.currentPage = 1

        // When
        sut.loadPreviousPage()

        // Then
        XCTAssertEqual(sut.currentPage, 1)
    }

    func testLoadLastPage_WithTotalPagesGreaterThan1_ShouldLoadLastPage() {
        // Given
        let totalPages = sut.totalPages
        sut.totalPages = totalPages + 1

        // When
        sut.loadLastPage()

        // Then
        XCTAssertEqual(sut.currentPage, totalPages + 1)
    }

    func testLoadLastPage_WithTotalPagesEqualTo1_ShouldNotLoadLastPage() {
        // Given
        sut.totalPages = 1

        // When
        sut.loadLastPage()

        // Then
        XCTAssertEqual(sut.currentPage, 1)
    }

    

}

// MARK: - Mock APIClient

class MockAPIClient: APIClient {

    var result: Result<[Repository], APIError>?
    var isGetEndpointCalled = false

     func get<T>(endpoint: String, parameters: [String: Any], completion: @escaping (Result<T, APIError>) -> Void) where T : Decodable {
        isGetEndpointCalled = true
        if let result = result as? Result<T, APIError> {
            completion(result)
        }
    }
}

