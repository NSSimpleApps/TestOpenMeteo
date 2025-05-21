//
//  OpenMeteoWeatherCodesManager.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation

/// Погодный код, который описывает состояние погоды.
struct OpenMeteoWeatherCode: Decodable {
    let description: String
    let image: URL
}
/// Погодный код для дня и ночи.
struct OpenMeteoWeatherCodeInfo: Decodable {
    let day: OpenMeteoWeatherCode
    let night: OpenMeteoWeatherCode
}
/// Класс, который парсит погодные коды.
final class OpenMeteoWeatherCodesManager: Sendable {
    private let weatherCodes: [Int: OpenMeteoWeatherCodeInfo]
    
    convenience init(decoder: JSONDecoder?) throws(NSError) {
        let fileName = "open_meteo_codes"
        if let openMeteoCodesURL = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let weatherCodesData = try Data(contentsOf: openMeteoCodesURL)
                try self.init(weatherCodesData: weatherCodesData, decoder: decoder)
            } catch {
                throw error as NSError
            }
        } else {
            throw NSError(code: -1, reason: "Cannot find \(fileName)")
        }
    }
    init(weatherCodesData: Data, decoder: JSONDecoder?) throws(NSError) {
        do {
            self.weatherCodes = try (decoder ?? JSONDecoder()).decode([Int: OpenMeteoWeatherCodeInfo].self, from: weatherCodesData)
        } catch {
            throw error as NSError
        }
    }
    
    func weatherCode(code: Int) -> OpenMeteoWeatherCodeInfo? {
        return self.weatherCodes[code]
    }
}
