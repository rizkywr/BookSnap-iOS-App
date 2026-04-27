//
//  AppModels.swift
//  BookNotesNewDesignC2
//

import Foundation
import SwiftData

enum InsightRoute: Hashable {
    case writeInsight
    case insightLibrary
    case taggedGenre(BookGenre)
}

@Model
final class InsightDraft {
    var id: UUID = UUID()
    var keyInsight: String
    var whyItMatters: String
    var tagOrComment: String
    var page: String
    var tags: [String]
    var createdAt: Date

    init(keyInsight: String, whyItMatters: String, tagOrComment: String, page: String, tags: [String], createdAt: Date = Date()) {
        self.keyInsight = keyInsight
        self.whyItMatters = whyItMatters
        self.tagOrComment = tagOrComment
        self.page = page
        self.tags = tags
        self.createdAt = createdAt
    }
}

@Model
final class BookRecord {
    var id: UUID = UUID()
    var title: String
    var author: String
    var genreRawValue: String
    var coverImageData: Data?
    
    @Relationship(deleteRule: .cascade) 
    var insights: [InsightDraft]

    var genre: BookGenre {
        get { BookGenre(rawValue: genreRawValue) ?? .coreKnowledge }
        set { genreRawValue = newValue.rawValue }
    }

    init(title: String, author: String, genre: BookGenre, coverImageData: Data?, insights: [InsightDraft] = []) {
        self.title = title
        self.author = author
        self.genreRawValue = genre.rawValue
        self.coverImageData = coverImageData
        self.insights = insights
    }
}

enum BookGenre: String, CaseIterable, Hashable {
    case coreKnowledge = "Core Knowledge"
    case psychology = "Psychology"
    case biography = "Biography"
    case socialAndPoliticalStudies = "Social and Political Studies"
    case spirituality = "Spirituality"
    case selfDevelopment = "Self-Development"
    case academicReferenceMaterials = "Academic / Reference Materials"

    var options: [String] {
        switch self {
        case .coreKnowledge:
            return ["Science", "Economics", "History", "Philosophy"]
        case .psychology:
            return []
        case .biography:
            return []
        case .socialAndPoliticalStudies:
            return []
        case .spirituality:
            return []
        case .selfDevelopment:
            return []
        case .academicReferenceMaterials:
            return []
        }
    }

    var displayTitle: String {
        if options.isEmpty {
            return rawValue
        }

        return "\(rawValue) (\(options.joined(separator: ", ")))"
    }

    var tagKeywords: [String] {
        let baseTag = "#\(rawValue.replacingOccurrences(of: " ", with: ""))"
        let optionTags = options.map { "#\($0.replacingOccurrences(of: " ", with: ""))" }
        return [baseTag] + optionTags
    }
}
