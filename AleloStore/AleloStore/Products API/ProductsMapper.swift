//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

internal final class ProductsMapper {
    private struct Root: Decodable {
        let products: [ProductItem]
        
        var productsList: [Product] {
            return products.map { $0.product }
        }
    }
    
    private struct ProductItem: Decodable {
        let name: String
        let regular_price: String
        let actual_price: String
        let on_sale: Bool
        let image: URL
        let sizes: [ProductSizeItem]
        
        var product: Product {
            return Product(
                name: name,
                regularPrice: regular_price,
                salePrice: actual_price,
                onSale: on_sale,
                imageURL: image,
                sizes: sizes.map { $0.productSize }
            )
        }
    }
    
    private struct ProductSizeItem: Decodable {
        let size: String
        let sku: String
        let available: Bool
        
        var productSize: ProductSize {
            return ProductSize(
                size: size,
                sku: sku,
                available: available
            )
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteProductsLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.productsList)
    }
}
