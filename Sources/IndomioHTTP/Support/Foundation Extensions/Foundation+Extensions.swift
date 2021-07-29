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
import CoreServices

// MARK: - URLRequest

extension URLRequest {
    
    /// Create a new instance of `URLRequest` with passed settings.
    ///
    /// - Parameters:
    ///   - url: url convertible value.
    ///   - method: http method to use.
    ///   - cachePolicy: cache policy to use.
    ///   - timeout: timeout interval.
    ///   - headers: headers to use.
    /// - Throws: throw an exception if url is not valid and cannot be converted to request.
    public init(url: URLConvertible, method: HTTPMethod,
                cachePolicy: URLRequest.CachePolicy,
                timeout: TimeInterval,
                headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()

        self.init(url: url)

        self.httpMethod = method.rawValue
        self.timeoutInterval = timeout
        self.allHTTPHeaderFields = headers?.asDictionary
    }
    
}

// MARK: - NSNumber

extension NSNumber {
    
    internal var isBool: Bool {
        String(cString: objCType) == "c"
    }
    
}

// MARK: - String

extension String {
    
    /// Create an RFC 3986 compliant string used to compose query string in URL.
    ///
    /// - Parameter string: source string.
    /// - Returns: String
    public var queryEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowedSet) ?? self
    }
    
    /// Return the suggested mime type for path extension of the receiver.
    ///
    /// - Returns: String
    internal func suggestedMimeType() -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
            return contentType as String
        }

        return "application/octet-stream"
    }
    
}

// MARK: - Array

extension Array where Element == String {
    
    internal func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
    
}

// MARK: - CharacterSet

extension CharacterSet {
    
    /// From Alamofire.
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let urlQueryAllowedSet: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
    
}

// MARK: - Bundle

internal extension Bundle {
    
    private static let UnknownIdentifier = "Unknown"
    
    /// Bundle identifier.
    var bundleID: String {
        infoDictionary?["CFBundleIdentifier"] as? String ?? Bundle.UnknownIdentifier
    }
    
    /// Name of the executable which is running this library.
    var executableName: String {
        (infoDictionary?["CFBundleExecutable"] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            Bundle.UnknownIdentifier
    }
    
    /// Version of the application.
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? Bundle.UnknownIdentifier
    }
    
    /// Build of the application.
    var appBuild: String {
        infoDictionary?["CFBundleVersion"] as? String ?? Bundle.UnknownIdentifier
    }
    
    /// Name and version of the operating system.
    var osNameIdentifier: String {
        return "\(osName) \(osVersion)"
    }
    
    // Version of the operating system.
    var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    /// Name of the operating system.
    var osName: String {
        #if os(iOS)
        #if targetEnvironment(macCatalyst)
        return "macOS(Catalyst)"
        #else
        return "iOS"
        #endif
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(Linux)
        return "Linux"
        #elseif os(Windows)
        return "Windows"
        #else
        return "Unknown"
        #endif
    }
    
}