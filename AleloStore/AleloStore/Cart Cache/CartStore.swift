//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public enum RetrieveCachedCartResult {
    case empty
    case found([LocalCartItem])
    case failure(Error)
}

public protocol CartStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (RetrieveCachedCartResult) -> Void
    
    func deleteCachedCart(completion: @escaping DeletionCompletion)
    func insert(_ cart: [LocalCartItem], completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}
