//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation

public class CodableCartStore: CartStore {
    private let storeURL: URL
    
    private let queue = DispatchQueue(label: "\(CodableCartStore.self)Queue", qos: .userInitiated)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedCart(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ cart: [LocalCartItem], completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(cart)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cart = try decoder.decode([LocalCartItem].self, from: data)
                completion(.found(cart))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
