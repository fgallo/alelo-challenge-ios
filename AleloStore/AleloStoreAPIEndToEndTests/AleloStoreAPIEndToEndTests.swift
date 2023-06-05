//
//  Created by Fernando Gallo on 04/06/23.
//

import XCTest
import AleloStore

final class AleloStoreAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETProductsResult_matchesFixedData() {
        switch getProductsResult() {
        case let .success(products):
            XCTAssertEqual(products.count, 22, "Expected 2 items in the server.")
            
        case let .failure(error):
            XCTFail("Expected successful result, got \(error) instead.")
            
        default:
            XCTFail("Expected successful result, got no result instead.")
        }
    }
    
    // MARK: - Helper
    
    private func getProductsResult(file: StaticString = #filePath, line: UInt = #line) -> LoadProductsResult? {
        let testServerURL = URL(string: "http://www.mocky.io/v2/59b6a65a0f0000e90471257d")!
        let client = URLSessionHTTPClient()
        let loader = RemoteProductsLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadProductsResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }

}
