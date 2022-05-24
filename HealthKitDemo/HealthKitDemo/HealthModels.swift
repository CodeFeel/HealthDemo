//
//  HealthModels.swift
//  HealthKitDemo
//
//  Created by ios on 2022/3/12.
//

import Foundation
import UIKit
import SwiftUI

struct HealthKitMeasurement: Hashable, Identifiable, Decodable {
    let id: String
    let quantityString: String
    let quantityDouble: Double
    let date: Date
    let dateString: String
    let deviceName: String?
    let type: String
    let icon: String
    let unit: String
}

struct HealthKitCorrelationMeasurement: Hashable, Identifiable, Decodable {
    let id: String
    let type: String
    let icon: String
    let unit: String
    let date: Date
    let dateString: String
    let measurement1 : HealthKitMeasurement
    let measurement2 : HealthKitMeasurement
}
