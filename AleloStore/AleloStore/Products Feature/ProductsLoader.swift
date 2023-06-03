//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

public enum LoadProductsResult {
    case success([Product])
    case failure(Error)
}

public protocol ProductsLoader {
    func load(completion: @escaping (LoadProductsResult) -> Void)
}
