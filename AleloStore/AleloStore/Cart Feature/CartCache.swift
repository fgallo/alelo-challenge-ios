//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public protocol CartCache {
    typealias SaveResult = Error?
    typealias LoadResult = Swift.Result<[CartItem], Error>
    
    func save(_ cart: [CartItem], completion: @escaping (SaveResult) -> Void)
    func load(completion: @escaping (LoadResult) -> Void)
}
