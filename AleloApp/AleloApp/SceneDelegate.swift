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
        
        let url = URL(string: "http://www.mocky.io/v2/59b6a65a0f0000e90471257d")!
        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let productsLoader = RemoteProductsLoader(url: url, client: client)
        let imageLoader = RemoteProductImageDataLoader(client: client)
        
        let productsViewController = ProductsUIComposer.productsComposedWith(
            productsLoader: productsLoader,
            imageLoader: imageLoader
        )
        
        window?.rootViewController = productsViewController
    }
}
