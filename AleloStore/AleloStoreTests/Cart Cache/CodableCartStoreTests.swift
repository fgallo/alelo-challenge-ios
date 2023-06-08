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
        
        do {
            let decoder = JSONDecoder()
            let cart = try decoder.decode([LocalCartItem].self, from: data)
            completion(.found(cart))
        } catch {
            completion(.failure(error))
        }
    }
}

class CodableCartStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let cart = makeCart().local
        
        insert(cart, to: sut)
        
        expect(sut, toRetrieve: .found(cart))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let cart = makeCart().local
        
        insert(cart, to: sut)
        
        expect(sut, toRetrieveTwice: .found(cart))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableCartStore {
        let sut = CodableCartStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cart: [LocalCartItem], to sut: CodableCartStore) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cart) { insertionError in
            XCTAssertNil(insertionError, "Expected cart to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableCartStore, toRetrieveTwice expectedResult: RetrieveCachedCartResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableCartStore, toRetrieve expectedResult: RetrieveCachedCartResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(expectedCart), .found(retrievedCart)):
                XCTAssertEqual(retrievedCart, expectedCart, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory,
                                        in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
