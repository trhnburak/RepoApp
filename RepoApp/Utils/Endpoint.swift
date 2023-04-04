//
//  Endpoint.swift
//  RepoApp
//
//  Created by Burak Turhan on 2.04.2023.
//

import Foundation
import Alamofire

enum FilterOption: String {
    case organization = "Organization"
    case other1 = "Other1"
    case other2 = "Other2"
}

struct Endpoint {

    let urlString: String

    static func googleRepositories(page: Int, type: RepositoryListViewController.FilterOption? = nil) -> Endpoint {
        let url: String
        if let type = type {
            url = "https://api.github.com/orgs/\(type)/repos?page=\(page)"
        } else {
            url = "https://api.github.com/orgs/google/repos?page=\(page)"
        }
        return Endpoint(urlString: url)
    }

    static func repositoryDetails(owner: String, repo: String) -> Endpoint {
        return Endpoint(urlString: "https://api.github.com/repos/\(owner)/\(repo)")
    }

    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw AFError.invalidURL(url: urlString)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue

        return urlRequest
    }
}
