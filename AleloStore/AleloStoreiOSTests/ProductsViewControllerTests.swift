//
//  Created by Fernando Gallo on 05/06/23.
//

import XCTest
import UIKit
import AleloStore
import AleloStoreiOS

final class ProductsViewControllerTests: XCTestCase {
    
    func test_loadProductsActions_requestProductsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
    
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
    
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingProductsIndicator_isVisibleWhileLoadingProducts() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
    
        loader.completeProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadProductsCompletion_rendersSuccessfullyLoadedProducts() {
        let product0 = makeProduct(
            name: "a name",
            regularPrice: "a price",
            salePrice: "a sale name",
            onSale: true,
            imageURL: nil,
            size: "a size",
            sku: "a sku",
            available: true
        )
        
        let product1 = makeProduct(
            name: "another name",
            regularPrice: "another price",
            salePrice: "another sale name",
            onSale: true,
            imageURL: nil,
            size: "another size",
            sku: "another sku",
            available: true
        )
        
        let product2 = makeProduct(
            name: "new name",
            regularPrice: "new price",
            salePrice: "new sale name",
            onSale: false,
            imageURL: nil,
            size: "new size",
            sku: "new sku",
            available: true
        )
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeProductsLoading(with: [product0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedProductViews(), 1)
        assertThat(sut, isRendering: [product0])
        
        sut.simulateUserInitiatedProductsReload()
        loader.completeProductsLoading(with: [product0, product1, product2], at: 1)
        assertThat(sut, isRendering: [product0, product1, product2])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ProductsViewController, hasViewConfiguredFor product: Product, at index: Int,
                            file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.productView(at: index)
        
        guard let cell = view as? ProductCell else {
            return XCTFail("Expected \(ProductCell.self) instance, got \(String(describing: view)) instead.", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameText, product.name)
        XCTAssertEqual(cell.regularPriceText, product.regularPrice)
        XCTAssertEqual(cell.salePriceText, product.salePrice)
        XCTAssertEqual(cell.isOnSale, product.onSale)
        XCTAssertEqual(cell.sizesText, product.sizes.first?.size)
    }
    
    private func assertThat(_ sut: ProductsViewController, isRendering products: [Product], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) products, got \(sut.numberOfRenderedProductViews()) instead.", file: file, line: line)
        }
        
        products.enumerated().forEach { index, product in
            assertThat(sut, hasViewConfiguredFor: product, at: index, file: file, line: line)
        }
    }
    
    private func makeProduct(name: String, regularPrice: String, salePrice: String, onSale: Bool, imageURL: URL?, size: String, sku: String, available: Bool) -> Product {
        let size = ProductSize(
            size: size,
            sku: sku,
            available: available
        )

        let model = Product(
            name: name,
            regularPrice: regularPrice,
            salePrice: salePrice,
            onSale: onSale,
            imageURL: imageURL,
            sizes: [size]
        )
        
        return model
    }

    class LoaderSpy: ProductsLoader {
        private var completions = [(ProductsLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeProductsLoading(with products: [Product] = [], at index: Int) {
            completions[index](.success(products))
        }
    }
    
}

private extension ProductsViewController {
    func simulateUserInitiatedProductsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedProductViews() -> Int {
        return tableView.numberOfRows(inSection: productsSection)
    }
    
    func productView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: productsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var productsSection: Int {
        return 0
    }
}

private extension ProductCell {
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
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
