//
//  Created by Fernando Gallo on 05/06/23.
//

import XCTest
import UIKit
import AleloStore

final class ProductsViewController: UIViewController {
    private var loader: ProductsLoader?
    
    convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
    }
}

final class ProductsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadProducts() {
        let loader = LoaderSpy()
        _ = ProductsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsProducts() {
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy: ProductsLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (AleloStore.LoadProductsResult) -> Void) {
            loadCallCount += 1
        }
    }
    
}