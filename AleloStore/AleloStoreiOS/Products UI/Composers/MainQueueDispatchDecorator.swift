//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation
import AleloStore

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: ProductsLoader where T == ProductsLoader {
    func load(completion: @escaping (ProductsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ProductImageDataLoader where T == ProductImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: CartCache where T == CartCache {
    func save(_ cart: [CartItem], completion: @escaping (CartCache.SaveResult) -> Void) {
        decoratee.save(cart) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    func load(completion: @escaping (CartCache.LoadResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
