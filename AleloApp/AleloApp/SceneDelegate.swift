//
//  Created by Fernando Gallo on 08/06/23.
//

import UIKit
import AleloStore
import AleloStoreiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        window?.rootViewController = navigationController
    }
    
    private lazy var navigationController = UINavigationController(
        rootViewController: ProductsUIComposer.productsComposedWith(
            productsLoader: makeProductsLoader(),
            imageLoader: makeImageLoader(),
            cartCache: makeCartLoader(),
            selection: showCart
        ))
    
    private func makeProductsLoader() -> ProductsLoader {
        let url = URL(string: "http://www.mocky.io/v2/59b6a65a0f0000e90471257d")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        return RemoteProductsLoader(url: url, client: client)
    }
    
    private func makeImageLoader() -> ProductImageDataLoader {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        return RemoteProductImageDataLoader(client: client)
    }
    
    private func makeCartLoader() -> CartCache {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("cart.store")
        let store = CodableCartStore(storeURL: storeURL)
        return LocalCartLoader(store: store)
    }
    
    private func showCart() {
        let cartCache = makeCartLoader()
        let loader =  makeImageLoader()
        let CartViewController = CartUIComposer.cartComposedWith(imageLoader: loader, cartCache: cartCache)
        navigationController.pushViewController(CartViewController, animated: true)
    }
}
