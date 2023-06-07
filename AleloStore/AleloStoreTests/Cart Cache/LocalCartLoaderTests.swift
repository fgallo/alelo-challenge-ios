//
//  Created by Fernando Gallo on 07/06/23.
//

import XCTest
import AleloStore

class LocalCartLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let cart = makeCart().models
        
        sut.save(cart) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let cart = makeCart().models
        let deletionError = anyNSError()
        
        sut.save(cart) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let cart = makeCart()
        
        sut.save(cart.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.delete, .insert(cart.local)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = CartStoreSpy()
        var sut: LocalCartLoader? = LocalCartLoader(store: store)
        
        var receivedResults = [LocalCartLoader.SaveResult]()
        sut?.save(makeCart().models) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = CartStoreSpy()
        var sut: LocalCartLoader? = LocalCartLoader(store: store)
        
        var receivedResults = [LocalCartLoader.SaveResult]()
        sut?.save(makeCart().models) { receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoCartOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCartOnNonEmptyCache() {
        let (sut, store) = makeSUT()
        let cart = makeCart()
        
        expect(sut, toCompleteWith: .success(cart.models), when: {
            store.completeRetrieval(with: cart.local)
        })
    }
    
    // MARK: - Helpers
    
    private class CartStoreSpy: CartStore {
        enum ReceivedMessage: Equatable {
            case insert([LocalCartItem])
            case delete
            case retrieve
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        private(set) var deletionCompletions = [(Error?) -> Void]()
        private(set) var insertionCompletions = [(Error?) -> Void]()
        private(set) var retrievalCompletions = [(RetrieveCachedCartResult) -> Void]()
        
        func deleteCachedCart(completion: @escaping (Error?) -> Void) {
            receivedMessages.append(.delete)
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ cart: [LocalCartItem], completion: @escaping (Error?) -> Void) {
            receivedMessages.append(.insert(cart))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
        
        func retrieve(completion: @escaping (RetrieveCachedCartResult) -> Void) {
            receivedMessages.append(.retrieve)
            retrievalCompletions.append(completion)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrievalWithEmptyCache(index: Int = 0) {
            retrievalCompletions[index](.empty)
        }
        
        func completeRetrieval(with cart: [LocalCartItem], at index: Int = 0) {
            retrievalCompletions[index](.found(cart))
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCartLoader, store: CartStoreSpy) {
        let store = CartStoreSpy()
        let sut = LocalCartLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCartLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.save(makeCart().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
    }
    
    private func expect(_ sut: LocalCartLoader, toCompleteWith expectedResult: CartCache.LoadResult, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedCart), .success(expectedCart)):
                XCTAssertEqual(receivedCart, expectedCart, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeCartItem() -> CartItem {
        let size = ProductSize(size: "a size", sku: "a sku", available: true)
        let product = Product(name: "a name", regularPrice: "a regular price",
                              salePrice: "a sale price", onSale: true,
                              imageURL: anyURL(), sizes: [size])
        return CartItem(product: product, quantity: 1)
    }
    
    private func makeCart() -> (models: [CartItem], local: [LocalCartItem]) {
        let models = [makeCartItem(), makeCartItem()]
        let local = models.map { cartItem in
            let localSizes = cartItem.product.sizes.map { LocalProductSize(size: $0.size, sku: $0.sku, available: $0.available) }
            let localProduct = LocalProduct(
                name: cartItem.product.name,
                regularPrice: cartItem.product.regularPrice,
                salePrice: cartItem.product.salePrice,
                onSale: cartItem.product.onSale,
                imageURL: cartItem.product.imageURL,
                sizes: localSizes
            )
            return LocalCartItem(product: localProduct, quantity: cartItem.quantity)
        }
        
        return (models, local)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL? {
        return URL(string: "http://any-url.com")
    }
    
}
