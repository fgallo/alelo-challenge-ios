//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import AleloStore
import AleloStoreiOS

class LoaderSpy: ProductsLoader, ProductImageDataLoader {
    
    // MARK: - ProductsLoader
    
    private var productsRequests = [(ProductsLoader.Result) -> Void]()
    
    var loadProductsCallCount: Int {
        return productsRequests.count
    }
    
    func load(completion: @escaping (ProductsLoader.Result) -> Void) {
        productsRequests.append(completion)
    }
    
    func completeProductsLoading(with products: [Product] = [], at index: Int = 0) {
        productsRequests[index](.success(products))
    }
    
    func completeProductsLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        productsRequests[index](.failure(error))
    }
    
    // MARK: - ProductImageDataLoader
    
    private struct TaskSpy: ProductImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (ProductImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
