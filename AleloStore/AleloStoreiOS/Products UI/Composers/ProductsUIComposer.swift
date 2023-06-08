//
//  Created by Fernando Gallo on 06/06/23.
//

import UIKit
import AleloStore

public final class ProductsUIComposer {
    private init() {}
    
    public static func productsComposedWith(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) -> ProductsViewController {
        let productsViewModel = ProductsViewModel(
            productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader)
        )
        
        let productsViewController = makeProductsViewController(title: "Products")
        productsViewController.viewModel = productsViewModel
        
        productsViewModel.onProductsLoad = adaptProductsToCellControllers(
            forwardingTo: productsViewController,
            loader: MainQueueDispatchDecorator(decoratee: imageLoader)
        )
        
        return productsViewController
    }
    
    private static func makeProductsViewController(title: String) -> ProductsViewController {
        let bundle = Bundle(for: ProductsViewController.self)
        let storyboard = UIStoryboard(name: "Products", bundle: bundle)
        let productsViewController = storyboard.instantiateInitialViewController() as! ProductsViewController
        productsViewController.title = title
        return productsViewController
    }
    
    private static func adaptProductsToCellControllers(forwardingTo controller: ProductsViewController, loader: ProductImageDataLoader) -> ([Product]) -> Void {
        return { [weak controller] products in
            controller?.tableModel = products.map { model in
                let viewModel = ProductCellViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return ProductCellController(viewModel: viewModel)
            }
        }
    }
}
