//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

public struct ProductSize: Equatable, Decodable {
    public let size: String
    public let sku: String
    public let available: Bool
    
    public init(size: String, sku: String, available: Bool) {
        self.size = size
        self.sku = sku
        self.available = available
    }
}
