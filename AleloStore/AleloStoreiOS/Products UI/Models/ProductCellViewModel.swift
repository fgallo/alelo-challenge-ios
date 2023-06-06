//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import UIKit
import AleloStore

final class ProductCellViewModel {
    private var task: ProductImageDataLoaderTask?
    private let model: Product
    private let imageLoader: ProductImageDataLoader
    
    init(model: Product, imageLoader: ProductImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var name: String? {
        return model.name
    }
    
    var regularPrice: String? {
        return model.regularPrice
    }
    
    var salePrice: String? {
        return model.salePrice
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
    
    var onImageLoad: ((UIImage) -> Void)?
    var onImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImageData() {
        if let url = model.imageURL {
            onImageLoadStateChange?(true)
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                self?.handle(result)
            }
        }
    }
    
    private func handle(_ result: ProductImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        }
        onImageLoadStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
    
}
