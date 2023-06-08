//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation

public final class RemoteProductImageDataLoader {
    private let client: HTTPClient
 
    public init(client: HTTPClient) {
        self.client = client
    }
}
