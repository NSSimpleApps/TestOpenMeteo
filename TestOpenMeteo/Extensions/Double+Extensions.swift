//
//  Double+Extensions.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation
import UIKit


extension Double {
    /// Форматирование дробного числа. Отбрасываются нули и точка.
    func format(precision: Int) -> String {
        let string = self.formatted(.number.precision(.fractionLength(0...precision)))
        return string.replacingOccurrences(of: ",", with: ".")
    }
    
    var formattedTemperature: String {
        return self.format(precision: 1) + "°"
    }
}
/// Форматирование множественного числа существительных.
enum WeatherNumberCases {
    case nominative, genitive, plural
    
    func format(nominative: String, genitive: String, plural: String) -> String {
        switch self {
        case .nominative:
            return nominative
        case .genitive:
            return genitive
        case .plural:
            return plural
        }
    }
}
