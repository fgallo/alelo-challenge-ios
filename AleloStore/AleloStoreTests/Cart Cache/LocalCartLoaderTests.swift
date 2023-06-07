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
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCartLoader, store: CartStore) {
        let store = CartStore()
        let sut = LocalCartLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCartLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.save([makeCartItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
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
