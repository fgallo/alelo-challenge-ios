//
//  Created by Fernando Gallo on 06/06/23.
//

import UIKit
import AleloStore

final class ProductCellController {
    private var task: ProductImageDataLoaderTask?
    private let model: Product
    private let imageLoader: ProductImageDataLoader
    
    init(model: Product, imageLoader: ProductImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.nameLabel.text = model.name
        cell.regularPriceLabel.text = model.regularPrice
        cell.salePriceLabel.text = model.salePrice
        cell.sizesLabel.text = model.sizes.first?.size
        cell.saleContainer.isHidden = !model.onSale
        cell.productImageView.image = nil
        cell.imageContainer.isShimmering = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            if let url = self.model.imageURL {
                self.task = self.imageLoader.loadImageData(from: url) { [weak cell] result in
                    let data = try? result.get()
                    let image = data.map(UIImage.init) ?? nil
                    cell?.productImageView.image = image
                    cell?.imageContainer.isShimmering = false
                }
            }
        }
        
        loadImage()
        
        return cell
    }
    
    func preload() {
        if let url = model.imageURL {
            task = imageLoader.loadImageData(from: url) { _ in }
        }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
