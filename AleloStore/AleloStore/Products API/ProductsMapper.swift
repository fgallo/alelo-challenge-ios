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
        let image: URL?
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
        
        enum CodingKeys: CodingKey {
            case name
            case regular_price
            case actual_price
            case on_sale
            case image
            case sizes
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.regular_price = try container.decode(String.self, forKey: .regular_price)
            self.actual_price = try container.decode(String.self, forKey: .actual_price)
            self.on_sale = try container.decode(Bool.self, forKey: .on_sale)
            self.sizes = try container.decode([ProductSizeItem].self, forKey: .sizes)
            self.image = URL(string: (try container.decodeIfPresent(String.self, forKey: .image) ?? ""))
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
            return .failure(RemoteProductsLoader.Error.invalidData)
        }

        return .success(root.productsList)
    }
}
