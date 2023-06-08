//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation
import AleloStore

func makeCartItem() -> CartItem {
    let size = ProductSize(size: "a size", sku: "a sku", available: true)
    let product = Product(name: "a name", regularPrice: "a regular price",
                          salePrice: "a sale price", onSale: true,
                          imageURL: anyURL(), sizes: [size])
    return CartItem(product: product, quantity: 1)
}

func makeCart() -> (models: [CartItem], local: [LocalCartItem]) {
    let models = [makeCartItem(), makeCartItem()]
    let local = models.map { cartItem in
        let localSizes = cartItem.product.sizes.map { LocalProductSize(size: $0.size, sku: $0.sku, available: $0.available) }
        let localProduct = LocalProduct(
            name: cartItem.product.name,
            regularPrice: cartItem.product.regularPrice,
            salePrice: cartItem.product.salePrice,
            onSale: cartItem.product.onSale,
            imageURL: cartItem.product.imageURL,
            sizes: localSizes
        )
        return LocalCartItem(product: localProduct, quantity: cartItem.quantity)
    }
    
    return (models, local)
}
