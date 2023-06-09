//
//  Created by Fernando Gallo on 08/06/23.
//

import UIKit
import AleloStore

public final class CartUIComposer {
    private init() {}
    
    public static func cartComposedWith(imageLoader: ProductImageDataLoader, cartCache: CartCache) -> CartViewController {
        let cartViewModel = CartViewModel(
            cartCache: MainQueueDispatchDecorator(decoratee: cartCache)
        )
        
        let cartViewController = makeCartViewController(title: "Cart")
        cartViewController.viewModel = cartViewModel
        
        cartViewModel.onCartLoad = adaptCartItemToCellControllers(
            forwardingTo: cartViewController,
            loader: MainQueueDispatchDecorator(decoratee: imageLoader)
        )
        
        return cartViewController
    }
    
    private static func makeCartViewController(title: String) -> CartViewController {
        let bundle = Bundle(for: CartViewController.self)
        let storyboard = UIStoryboard(name: "Cart", bundle: bundle)
        let cartViewController = storyboard.instantiateInitialViewController() as! CartViewController
        cartViewController.title = title
        return cartViewController
    }
    
    private static func adaptCartItemToCellControllers(forwardingTo controller: CartViewController, loader: ProductImageDataLoader) -> ([CartItem]) -> Void {
        return { [weak controller] cart in
            controller?.tableModel = cart.map { model in
                let viewModel = CartCellViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return CartCellController(viewModel: viewModel)
            }
        }
    }
}
