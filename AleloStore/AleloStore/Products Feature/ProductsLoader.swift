//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

public protocol ProductsLoader {
    typealias Result = Swift.Result<[Product], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
