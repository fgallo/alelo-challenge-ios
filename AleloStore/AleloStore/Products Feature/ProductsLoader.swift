//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

enum LoadProductsResult {
    case success([Product])
    case failure(Error)
}

protocol ProductsLoader {
    func load(completion: @escaping (LoadProductsResult) -> Void)
}
