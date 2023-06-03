//
//  Created by Fernando Gallo on 03/06/23.
//
    

import Foundation

struct Product {
    let name: String
    let regularPrice: String
    let salePrice: String
    let onSale: Bool
    let imageURL: URL
    let sizes: [ProductSize]
}