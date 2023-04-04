import Foundation
import Alamofire

class APIClient {

    static let sharedManager = APIClient()

    static func get(endpoint: Endpoint, completion: @escaping (Result<[Repository], AFError>) -> Void) {
        print(endpoint.urlString)
        AF.request(endpoint.urlString, method: .get)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [Repository].self) { response in
                switch response.result {
                    case .success(let repositories):
                        print("Fetch Successful")
                        completion(.success(repositories))
                    case .failure(let error):
                        debugPrint(error)
                        completion(.failure(error))
                }
            }
    }


}
