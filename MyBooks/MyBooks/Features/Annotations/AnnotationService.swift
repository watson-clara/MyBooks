//
//  AnnotationService.swift
//  MyBooks
//
//  Created by clarafication on 7/1/26.
//

import Foundation
import SwiftData

struct AnnotationService {

    func createAnnotation(
        bookID: String,
        sessionResult: AnnotationSessionResult,
        context: ModelContext
    ) -> AnnotationRecord {

        let locationData = try? JSONEncoder().encode(
            CodableRect(rect: sessionResult.canvasBounds)
        )

        let record = AnnotationRecord(
            bookID: bookID,
            pageIndex: sessionResult.pageIndex,
            drawingData: sessionResult.drawing.dataRepresentation(),
            tabYPosition: 0.5
        )

        record.locationData = locationData
        record.handwritingDetectionStatus = DetectionStatus.scanning.rawValue
        record.highlightedTextDetectionStatus = DetectionStatus.scanning.rawValue

        context.insert(record)
        try? context.save()

        return record
    }
}
