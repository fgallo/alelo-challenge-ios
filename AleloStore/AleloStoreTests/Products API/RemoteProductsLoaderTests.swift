//
//  Created by Fernando Gallo on 03/06/23.
//

import XCTest
import AleloStore

class RemoteProductsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(RemoteProductsLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(RemoteProductsLoader.Error.invalidData), when: {
                let json = makeProductsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(RemoteProductsLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = makeProductsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let product1 = makeProduct(
            name: "a name",
            regularPrice: "2",
            salePrice: "1",
            onSale: true,
            imageURL: URL(string: "https://a-url.com"),
            size: "S",
            sku: "123",
            available: true
        )
        
        let product2 = makeProduct(
            name: "another name",
            regularPrice: "3",
            salePrice: "3",
            onSale: false,
            imageURL: URL(string: "https://another-url.com"),
            size: "L",
            sku: "321",
            available: true
        )
        
        let products = [product1.model, product2.model]
        
        expect(sut, toCompleteWithResult: .success(products), when: {
            let json = makeProductsJSON([product1.json, product2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteProductsLoader? = RemoteProductsLoader(url: url, client: client)
        
        var capturedResults = [RemoteProductsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeProductsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func makeProduct(name: String, regularPrice: String, salePrice: String, onSale: Bool,
                             imageURL: URL?, size: String, sku: String, available: Bool) -> (model: Product, json: [String: Any]) {
        
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
        
        let json = ([
            "name": model.name,
            "regular_price": model.regularPrice,
            "actual_price": model.salePrice,
            "on_sale": model.onSale,
            "image": model.imageURL?.absoluteString,
            "sizes": [[
                "size": size.size,
                "sku": size.sku,
                "available": size.available
            ] as [String : Any]]
        ] as [String : Any?])
        
        return (model, json.compactMapValues { $0 })
    }
    
    private func makeProductsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["products": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteProductsLoader, toCompleteWithResult expectedResult: RemoteProductsLoader.Result,
                        when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedProducts), .success(expectedProducts)):
                XCTAssertEqual(receivedProducts, expectedProducts, file: file, line: line)
                
            case let (.failure(receivedError as RemoteProductsLoader.Error), .failure(expectedError as RemoteProductsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }

}
