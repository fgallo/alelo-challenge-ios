//
//  Created by Fernando Gallo on 08/06/23.
//

import UIKit

final class CartCellController {
    private let viewModel: CartCellViewModel<UIImage>
    
    init(viewModel: CartCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell: CartCell = tableView.dequeueReusableCell()
        binded(cell)
        viewModel.loadImageData()
        return cell
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: CartCell) {
        cell.nameLabel.text = viewModel.name
        cell.priceLabel.text = viewModel.price
        cell.totalPriceLabel.text = viewModel.totalPrice
        cell.quantityLabel.text = viewModel.quantity
        cell.productImageView.image = nil
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.productImageView.image = image
        }
        
        viewModel.onImageLoadStateChange = { [weak cell] isLoading in
            cell?.imageContainer.isShimmering = isLoading
        }
    }
}
