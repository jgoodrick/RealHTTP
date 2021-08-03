//
//  IndomioNetwork
//
//  Created by the Mobile Team @ ImmobiliareLabs
//  Email: mobile@immobiliare.it
//  Web: http://labs.immobiliare.it
//
//  Copyright ©2021 Immobiliare.it SpA. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

// MARK: - HTTPDecodableResponse

/// Allows to customize the decode of an object.
/// If you can't implement `Decodable` you can customize your own decoding mechanism.
public protocol HTTPDecodableResponse {
    
    /// Allows to customize the decode of an HTTP response.
    /// Should return `.objectDecodeFailed` in case of failure.
    ///
    /// - Parameter response: response.
    static func decode(_ response: HTTPRawResponse) -> Result<Self, Error>
    
}

// MARK: - HTTPDecodableResponse for Codable

// Provide default implementation for Decodable models.
public extension HTTPDecodableResponse where Self: Decodable {

    static func decode(_ response: HTTPRawResponse) -> Result<Self, Error> {
        guard let data = response.data else {
            return .failure(HTTPError(.noDataToDecode)) // empty response
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedObj = try decoder.decode(Self.self, from: data)
            return .success(decodedObj)
        } catch {
            // deocde failed by JSONDecoder
            return .failure(HTTPError(.objectDecodeFailed, error: error))
        }
    }
    
}