//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

internal final class ProductsMapper {
    private struct Root: Decodable {
        let products: [ProductItem]
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
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Product] {
        guard response.statusCode == OK_200 else {
            throw RemoteProductsLoader.Error.invalidData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let root = try decoder.decode(Root.self, from: data)
        return root.products.map { $0.product }
    }
}
