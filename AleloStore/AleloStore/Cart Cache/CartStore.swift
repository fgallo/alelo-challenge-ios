//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public protocol CartStore {
    func deleteCachedCart(completion: @escaping (Error?) -> Void)
    func insert(_ cart: [LocalCartItem], completion: @escaping (Error?) -> Void)
    func retrieve(completion: @escaping (Error?) -> Void)
}
