//
//  OpenMeteoModels.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation

/// Протокол, который возвращает json-данные о погоде в зависимости от координат и дней.
protocol OpenMeteoDataProviderProtocol: Sendable {
    func getWeatherData(requestData: OpenMeteoRequestData) async throws(CancellationError) -> Result<Data, NSError>
}

/// Протокол, который парсит json-данные о погоде и возвращает предварительную модель.
protocol OpenMeteoProviderProtocol: Sendable {
    func getWeather(latitude: Double, longitude: Double) async throws(CancellationError) -> Result<OpenMeteoInfo, NSError>
}

/// Предварительная погодная модель.
/// Включает в себя прогноз на несколько дней.
struct OpenMeteoInfo {
    let dayModels: [OpenMeteoDayModel]
}

/// Погода в указанный день.
struct OpenMeteoDayModel {
    let title: String
    let weather: String
    let weatherIcon: URL
    let temperature: String
    let windSpeed: String
    let humidity: String
}
