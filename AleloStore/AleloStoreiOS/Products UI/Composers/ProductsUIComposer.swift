//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import AleloStore

public final class ProductsUIComposer {
    private init() {}
    
    public static func productsComposedWith(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) -> ProductsViewController {
        let productsViewModel = ProductsViewModel(productsLoader: productsLoader)
        let productsViewController = ProductsViewController(viewModel: productsViewModel, imageLoader: imageLoader)
        return productsViewController
    }
}
