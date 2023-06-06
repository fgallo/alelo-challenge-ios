//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation

public protocol ProductImageDataLoaderTask {
    func cancel()
}

public protocol ProductImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ProductImageDataLoaderTask
}
