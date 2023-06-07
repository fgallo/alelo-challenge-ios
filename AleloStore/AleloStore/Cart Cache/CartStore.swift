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
    func deleteCachedCart(completion: @escaping (Error?) -> Void)
    func insert(_ cart: [LocalCartItem], completion: @escaping (Error?) -> Void)
    func retrieve(completion: @escaping (RetrieveCachedCartResult) -> Void)
}
