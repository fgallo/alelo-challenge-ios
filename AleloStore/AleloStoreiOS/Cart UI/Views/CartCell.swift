//
//  Created by Fernando Gallo on 08/06/23.
//

import UIKit

public final class CartCell: UITableViewCell {
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var priceLabel: UILabel!
    @IBOutlet private(set) public var totalPriceLabel: UILabel!
    @IBOutlet private(set) public var quantityLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var productImageView: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        imageContainer.layer.borderWidth = 1
        imageContainer.layer.borderColor = UIColor.lightGray.cgColor
    }
}
