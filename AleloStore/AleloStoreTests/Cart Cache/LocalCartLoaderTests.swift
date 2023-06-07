//
//  Created by Fernando Gallo on 07/06/23.
//

import XCTest
import AleloStore

class LocalCartLoader {
    private let store: CartStore
    
    init(store: CartStore) {
        self.store = store
    }
    
    func save(_ cart: [CartItem]) {
        store.deleteCachedCart { [unowned self] error in
            if error == nil {
                self.store.insert(cart)
            }
        }
    }
}

class CartStore {
    enum ReceivedMessage: Equatable {
        case insert([CartItem])
        case delete
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private(set) var deletionCompletions = [(Error?) -> Void]()
    
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
    
    func insert(_ cart: [CartItem]) {
        receivedMessages.append(.insert(cart))
    }
}

class LocalCartLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        
        sut.save(cart)
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        let deletionError = anyNSError()
        
        sut.save(cart)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        
        sut.save(cart)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.delete, .insert(cart)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCartLoader, store: CartStore) {
        let store = CartStore()
        let sut = LocalCartLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func makeCartItem() -> CartItem {
        let size = ProductSize(size: "a size", sku: "a sku", available: true)
        let product = Product(name: "a name", regularPrice: "a regular price",
                              salePrice: "a sale price", onSale: true,
                              imageURL: anyURL(), sizes: [size])
        return CartItem(product: product, quantity: 1)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL? {
        return URL(string: "http://any-url.com")
    }
    
}
