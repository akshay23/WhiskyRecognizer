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

/** Whether or not to return important people, places, geopolitical, and other entities detected in the analyzed content. */
public struct EntitiesOptions {

    /// Maximum number of entities to return.
    public var limit: Int?

    /// Set this to true to return locations of entity mentions.
    public var mentions: Bool?

    /// Enter a custom model ID to override the standard entity detection model.
    public var model: String?

    /// Set this to true to return sentiment information for detected entities.
    public var sentiment: Bool?

    /// Set this to true to analyze emotion for detected keywords.
    public var emotion: Bool?

    /**
     Initialize a `EntitiesOptions` with member variables.

     - parameter limit: Maximum number of entities to return.
     - parameter mentions: Set this to true to return locations of entity mentions.
     - parameter model: Enter a custom model ID to override the standard entity detection model.
     - parameter sentiment: Set this to true to return sentiment information for detected entities.
     - parameter emotion: Set this to true to analyze emotion for detected keywords.

     - returns: An initialized `EntitiesOptions`.
    */
    public init(limit: Int? = nil, mentions: Bool? = nil, model: String? = nil, sentiment: Bool? = nil, emotion: Bool? = nil) {
        self.limit = limit
        self.mentions = mentions
        self.model = model
        self.sentiment = sentiment
        self.emotion = emotion
    }
}

extension EntitiesOptions: Codable {

    private enum CodingKeys: String, CodingKey {
        case limit = "limit"
        case mentions = "mentions"
        case model = "model"
        case sentiment = "sentiment"
        case emotion = "emotion"
        static let allValues = [limit, mentions, model, sentiment, emotion]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        mentions = try container.decodeIfPresent(Bool.self, forKey: .mentions)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        sentiment = try container.decodeIfPresent(Bool.self, forKey: .sentiment)
        emotion = try container.decodeIfPresent(Bool.self, forKey: .emotion)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(limit, forKey: .limit)
        try container.encodeIfPresent(mentions, forKey: .mentions)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(sentiment, forKey: .sentiment)
        try container.encodeIfPresent(emotion, forKey: .emotion)
    }

}
