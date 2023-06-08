//
//  Created by Fernando Gallo on 07/06/23.
//

import XCTest
import AleloStore

class CodableCartStore {
    func retrieve(completion: @escaping CartStore.RetrieveCompletion) {
        completion(.empty)
    }
}

class CodableCartStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableCartStore()
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
    
}
