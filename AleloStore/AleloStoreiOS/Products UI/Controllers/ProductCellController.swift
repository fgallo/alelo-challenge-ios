//
//  Created by Fernando Gallo on 06/06/23.
//

import UIKit

final class ProductCellController {
    private let viewModel: ProductCellViewModel<UIImage>
    
    init(viewModel: ProductCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ProductCell = tableView.dequeueReusableCell()
        binded(cell)
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.preloadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: ProductCell) {
        cell.nameLabel.text = viewModel.name
        cell.regularPriceLabel.text = viewModel.regularPrice
        cell.salePriceLabel.attributedText = viewModel.salePrice
        cell.sizesLabel.text = viewModel.sizes
        cell.saleContainer.isHidden = !viewModel.isOnSale
        cell.productImageView.image = nil
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.productImageView.image = image
        }
        
        viewModel.onImageLoadStateChange = { [weak cell] isLoading in
            cell?.imageContainer.isShimmering = isLoading
        }
        
        cell.onAdd = { [weak self] in
            self?.viewModel.addToCart()
        }
    }
}
