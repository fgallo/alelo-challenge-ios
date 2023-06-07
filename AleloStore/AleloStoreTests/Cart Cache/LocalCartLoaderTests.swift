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
    
    func save(_ cart: [CartItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedCart { [unowned self] error in
            if let error = error {
                completion(error)
            } else {
                self.store.insert(cart, completion: completion)
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
    private(set) var insertionCompletions = [(Error?) -> Void]()
    
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
    
    func insert(_ cart: [CartItem], completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert(cart))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
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
        
        sut.save(cart) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        let deletionError = anyNSError()
        
        sut.save(cart) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.delete])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        
        sut.save(cart) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.delete, .insert(cart)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        let deletionError = anyNSError()
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.save(cart) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let cart = [makeCartItem(), makeCartItem()]
        let insertionError = anyNSError()
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.save(cart) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, insertionError)
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
