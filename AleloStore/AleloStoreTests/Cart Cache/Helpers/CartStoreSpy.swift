//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation
import AleloStore

class CartStoreSpy: CartStore {
    enum ReceivedMessage: Equatable {
        case insert([LocalCartItem])
        case delete
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private(set) var deletionCompletions = [(Error?) -> Void]()
    private(set) var insertionCompletions = [(Error?) -> Void]()
    private(set) var retrievalCompletions = [(RetrieveCachedCartResult) -> Void]()
    
    func deleteCachedCart(completion: @escaping DeletionCompletion) {
        receivedMessages.append(.delete)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ cart: [LocalCartItem], completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(cart))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
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
