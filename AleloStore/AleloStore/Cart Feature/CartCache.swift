//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public protocol CartCache {
    typealias SaveResult = Error?
    
    func save(_ cart: [CartItem], completion: @escaping (SaveResult) -> Void)
}
