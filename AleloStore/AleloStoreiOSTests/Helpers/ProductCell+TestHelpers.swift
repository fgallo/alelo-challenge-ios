//
//  Created by Fernando Gallo on 06/06/23.
//

import UIKit
import AleloStoreiOS

extension ProductCell {
    var nameText: String? {
        return nameLabel.text
    }
    
    var regularPriceText: String? {
        return regularPriceLabel.text
    }
    
    var salePriceText: String? {
        return salePriceLabel.text
    }
    
    var sizesText: String? {
        return sizesLabel.text
    }
    
    var isOnSale: Bool {
        return !saleContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return productImageView.image?.pngData()
    }
}
