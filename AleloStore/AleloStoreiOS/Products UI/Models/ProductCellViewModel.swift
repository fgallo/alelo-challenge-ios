//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import AleloStore

final class ProductCellViewModel<Image> {
    private var task: ProductImageDataLoaderTask?
    private let model: Product
    private let imageLoader: ProductImageDataLoader
    private let imageTransformer: (Data) -> Image?
    private var addedToCart = 0
    
    init(model: Product, imageLoader: ProductImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var name: String? {
        return model.name
    }
    
    var regularPrice: String? {
        return model.onSale ? model.salePrice : model.regularPrice
    }
    
    var salePrice: NSAttributedString? {
        guard model.onSale else {
            return nil
        }
        
        let price = model.regularPrice
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: price)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    var sizes: String? {
        let sizes = model.sizes.reduce("") { partialResult, productSize in
            if partialResult.isEmpty {
                return productSize.size
            }
            
            return "\(partialResult), \(productSize.size)"
        }
        
        return sizes
    }
    
    var isOnSale: Bool {
        return model.onSale
    }
    
    var onImageLoad: ((Image) -> Void)?
    var onImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImageData() {
        if let url = model.imageURL {
            onImageLoadStateChange?(true)
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                self?.handle(result)
            }
        }
    }
    
    func preloadImageData() {
        if let url = model.imageURL {
            onImageLoadStateChange?(true)
            task = imageLoader.loadImageData(from: url) { [weak self] _ in
                self?.onImageLoadStateChange?(false)
            }
        }
    }
    
    private func handle(_ result: ProductImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        }
        onImageLoadStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
    
    func addToCart() {
        addedToCart += 1
    }
    
    func toCartItem() -> CartItem {
        return CartItem(product: model, quantity: addedToCart)
    }
}
