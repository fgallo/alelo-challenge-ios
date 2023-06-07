//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public struct LocalProductSize: Equatable {
    public let size: String
    public let sku: String
    public let available: Bool
    
    public init(size: String, sku: String, available: Bool) {
        self.size = size
        self.sku = sku
        self.available = available
    }
}
