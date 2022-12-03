//
//  DailyFeedModel.swift
//  DailyFeed
//
//  Created by Sumit Paul on 27/12/16.
//

import Foundation
import MobileCoreServices

enum DailyFeedModelUTI {
    static let kUUTTypeDailyFeedModel = "kUUTTypeDailyFeedModel"
}

enum DailyFeedModelError: Error {
    case invalidTypeIdentifier
    case invalidDailyFeedModel
}

struct Articles: Codable {
    var articles: [DailyFeedModel]
}

//Data Model
final class DailyFeedModel: NSObject, Serializable {
    
    public var title: String = ""
    public var author: String?
    public var publishedAt: String?
    public var urlToImage: String?
    public var articleDescription: String?
    public var url: String?
    
    private enum CodingKeys: String, CodingKey {
        case articleDescription = "description"
        case title, author, publishedAt, urlToImage, url
    }
}

// MARK :- NSProvider read/write method implementations

extension DailyFeedModel: NSItemProviderReading {
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [DailyFeedModelUTI.kUUTTypeDailyFeedModel]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> DailyFeedModel {
        if typeIdentifier == DailyFeedModelUTI.kUUTTypeDailyFeedModel {
            let dfm = DailyFeedModel()
            do {
                let dailyFeedModel = try dfm.deserialize(data: data)
                return dailyFeedModel
            } catch {
                throw DailyFeedModelError.invalidDailyFeedModel
            }
        } else {
            throw DailyFeedModelError.invalidTypeIdentifier
        }
    }
}

