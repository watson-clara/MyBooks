//
//  AnnotationRecord.swift
//  MyBooks
//
//  Created by clarafication on 6/29/26.
//

import Foundation
import SwiftData

@Model
final class AnnotationRecord {

    @Attribute(.unique) var id: UUID

    var bookID: String
    var pageIndex: Int

    var drawingData: Data?

    var detectedHandwritingText: String
    var handwritingDetectionStatus: String

    var highlightedText: String
    var highlightedTextDetectionStatus: String

    var tabYPosition: Double
    var locationData: Data?

    var createdAt: Date
    var modifiedAt: Date

    var category: AnnotationCategory?

    init(
        bookID: String,
        pageIndex: Int,
        drawingData: Data? = nil,
        tabYPosition: Double = 0.5,
        category: AnnotationCategory? = nil
    ) {
        self.id = UUID()
        self.bookID = bookID
        self.pageIndex = pageIndex
        self.drawingData = drawingData

        self.detectedHandwritingText = ""
        self.handwritingDetectionStatus = DetectionStatus.notStarted.rawValue

        self.highlightedText = ""
        self.highlightedTextDetectionStatus = DetectionStatus.notStarted.rawValue

        self.tabYPosition = tabYPosition
        self.locationData = nil

        self.createdAt = .now
        self.modifiedAt = .now

        self.category = category
    }

    var handwritingStatus: DetectionStatus {
        DetectionStatus(rawValue: handwritingDetectionStatus) ?? .notStarted
    }

    var highlightedTextStatus: DetectionStatus {
        DetectionStatus(rawValue: highlightedTextDetectionStatus) ?? .notStarted
    }
}

enum DetectionStatus: String, Codable {
    case notStarted
    case scanning
    case complete
    case failed
}
