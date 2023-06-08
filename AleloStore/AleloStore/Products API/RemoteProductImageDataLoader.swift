//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation

public final class RemoteProductImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
