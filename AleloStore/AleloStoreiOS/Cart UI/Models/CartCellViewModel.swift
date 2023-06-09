//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation
import AleloStore

final class CartCellViewModel<Image> {
    private var task: ProductImageDataLoaderTask?
    private let model: CartItem
    private let imageLoader: ProductImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: CartItem, imageLoader: ProductImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var name: String? {
        return model.product.name
    }
    
    var price: String? {
        return model.product.salePrice
    }
    
    var totalPrice: String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        if let formattedPrice = price?.replacingOccurrences(of: "R$ ", with: "").replacingOccurrences(of: ",", with: "."),
           let priceDouble = Double(formattedPrice),
           let formattedTipAmount = formatter.string(from: priceDouble * Double(model.quantity) as NSNumber) {
            return formattedTipAmount
        }
        
        return "-"
    }
    
    var quantity: String? {
        return "\(model.quantity)"
    }
    
    var onImageLoad: ((Image) -> Void)?
    var onImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImageData() {
        if let url = model.product.imageURL {
            onImageLoadStateChange?(true)
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                self?.handle(result)
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
    
}
