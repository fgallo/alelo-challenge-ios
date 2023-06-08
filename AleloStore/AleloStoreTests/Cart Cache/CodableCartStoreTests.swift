//
//  Created by Fernando Gallo on 07/06/23.
//

import XCTest
import AleloStore

class CodableCartStore {
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insert(_ cart: [LocalCartItem], completion: @escaping CartStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(cart)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
    
    func retrieve(completion: @escaping CartStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cart = try! decoder.decode([LocalCartItem].self, from: data)
        completion(.found(cart))
    }
}

class CodableCartStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: storeURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let cart = makeCart().local
        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(cart) { insertionError in
            XCTAssertNil(insertionError, "Expected cart to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedCart):
                    XCTAssertEqual(retrievedCart, cart)
                default:
                    XCTFail("Expected found result with cart \(cart), got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableCartStore {
        let sut = CodableCartStore(storeURL: storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first!.appendingPathComponent("cart.store")
    }
    
}
