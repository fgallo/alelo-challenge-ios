//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteProductsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([Product])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let items = try? ProductsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class ProductsMapper {
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
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Product] {
        guard response.statusCode == OK_200 else {
            throw RemoteProductsLoader.Error.invalidData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let root = try decoder.decode(Root.self, from: data)
        return root.products.map { $0.product }
    }
}
