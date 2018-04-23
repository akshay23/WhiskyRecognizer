/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

/** The pagination data for the returned objects. */
public struct LogPagination {

    /// The URL that will return the next page of results, if any.
    public var nextUrl: String?

    /// Reserved for future use.
    public var matched: Int?

    /**
     Initialize a `LogPagination` with member variables.

     - parameter nextUrl: The URL that will return the next page of results, if any.
     - parameter matched: Reserved for future use.

     - returns: An initialized `LogPagination`.
    */
    public init(nextUrl: String? = nil, matched: Int? = nil) {
        self.nextUrl = nextUrl
        self.matched = matched
    }
}

extension LogPagination: Codable {

    private enum CodingKeys: String, CodingKey {
        case nextUrl = "next_url"
        case matched = "matched"
        static let allValues = [nextUrl, matched]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nextUrl = try container.decodeIfPresent(String.self, forKey: .nextUrl)
        matched = try container.decodeIfPresent(Int.self, forKey: .matched)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(nextUrl, forKey: .nextUrl)
        try container.encodeIfPresent(matched, forKey: .matched)
    }

}
