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

/** IntentExport. */
public struct IntentExport {

    /// The name of the intent.
    public var intentName: String

    /// The timestamp for creation of the intent.
    public var created: String?

    /// The timestamp for the last update to the intent.
    public var updated: String?

    /// The description of the intent.
    public var description: String?

    /// An array of objects describing the user input examples for the intent.
    public var examples: [Example]?

    /**
     Initialize a `IntentExport` with member variables.

     - parameter intentName: The name of the intent.
     - parameter created: The timestamp for creation of the intent.
     - parameter updated: The timestamp for the last update to the intent.
     - parameter description: The description of the intent.
     - parameter examples: An array of objects describing the user input examples for the intent.

     - returns: An initialized `IntentExport`.
    */
    public init(intentName: String, created: String? = nil, updated: String? = nil, description: String? = nil, examples: [Example]? = nil) {
        self.intentName = intentName
        self.created = created
        self.updated = updated
        self.description = description
        self.examples = examples
    }
}

extension IntentExport: Codable {

    private enum CodingKeys: String, CodingKey {
        case intentName = "intent"
        case created = "created"
        case updated = "updated"
        case description = "description"
        case examples = "examples"
        static let allValues = [intentName, created, updated, description, examples]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        intentName = try container.decode(String.self, forKey: .intentName)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        updated = try container.decodeIfPresent(String.self, forKey: .updated)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        examples = try container.decodeIfPresent([Example].self, forKey: .examples)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(intentName, forKey: .intentName)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(updated, forKey: .updated)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(examples, forKey: .examples)
    }

}
