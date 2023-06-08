//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit

public final class ProductCell: UITableViewCell {
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var regularPriceLabel: UILabel!
    @IBOutlet private(set) public var salePriceLabel: UILabel!
    @IBOutlet private(set) public var sizesLabel: UILabel!
    @IBOutlet private(set) public var saleContainer: UIView!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var productImageView: UIImageView!
    @IBOutlet private(set) public var addToCartButton: UIButton!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        imageContainer.layer.borderWidth = 1
        imageContainer.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    var onAdd: (() -> Void)?
    
    @IBAction private func addButtonTapped() {
        onAdd?()
    }
}
