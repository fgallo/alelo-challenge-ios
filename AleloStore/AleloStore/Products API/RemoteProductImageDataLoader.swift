//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation

public final class RemoteProductImageDataLoader: ProductImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: ProductImageDataLoaderTask {
        private var completion: ((ProductImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (ProductImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ProductImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
                
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }
}
