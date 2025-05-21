//
//  WeatherApiHandler.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation

/// Обработчик данных от api.open-meteo.com.
actor OpenMeteoHandler: OpenMeteoProviderProtocol {
    private let openMeteoDataProvider: OpenMeteoDataProviderProtocol
    private let openMeteoWeatherCodesManager: OpenMeteoWeatherCodesManager
    
    init(openMeteoDataProvider: any OpenMeteoDataProviderProtocol) throws(NSError) {
        self.openMeteoDataProvider = openMeteoDataProvider
        self.openMeteoWeatherCodesManager = try OpenMeteoWeatherCodesManager(decoder: nil)
    }
    
    func getWeather(latitude: Double, longitude: Double) async throws(CancellationError) -> Result<OpenMeteoInfo, NSError> {
        let dailyAttributes = [
            OpenMeteoDataDailyKeys.temperature_2m_mean.stringValue,
            OpenMeteoDataDailyKeys.relative_humidity_2m_mean.stringValue,
            OpenMeteoDataDailyKeys.weather_code.stringValue,
            OpenMeteoDataDailyKeys.wind_speed_10m_max.stringValue,
            OpenMeteoDataDailyKeys.sunrise.stringValue,
            OpenMeteoDataDailyKeys.sunset.stringValue
        ]
        let weatherDataResult = try await self.openMeteoDataProvider.getWeatherData(requestData: .init(latitude: latitude, longitude: longitude,
                                                                                                       days: 5,
                                                                                                       dailyAttributes: dailyAttributes))
        
        switch weatherDataResult {
        case .success(let weatherData):
            do {
                let openMeteoData = try JSONDecoder().decode(OpenMeteoData.self, from: weatherData)
                let times = openMeteoData.time
                let temperatures = openMeteoData.temperature
                let relativeHumidities = openMeteoData.relativeHumidity
                let weatherCodes = openMeteoData.weatherCode
                let windSpeeds = openMeteoData.windSpeed
                let sunrises = openMeteoData.sunrise
                let sunsets = openMeteoData.sunset
                let timesCount = times.count
                
                if temperatures.count == timesCount,
                   relativeHumidities.count == timesCount,
                   weatherCodes.count == timesCount,
                   windSpeeds.count == timesCount,
                   sunrises.count == timesCount,
                   sunsets.count == timesCount {
                    let now = Date()
                    var calendar = Calendar(identifier: .gregorian)
                    calendar.locale = Locale(identifier: "en")
                    if let timeZone = TimeZone(identifier: openMeteoData.timezone) {
                        calendar.timeZone = timeZone
                    }
                    let openMeteoDateParser = OpenMeteoDateParser(calendar: calendar)
                    
                    let shortMonthSymbols = calendar.shortStandaloneMonthSymbols
                    let openMeteoDateFormatter =
                    OpenMeteoDateFormatter(calendar: calendar, dateFormats: [.d, .space,
                                                                             ._MMM(shortMonthSymbols: shortMonthSymbols), .space,
                                                                             .yyyy])
                    
                    let openMeteoDayModels = (0..<timesCount).compactMap { index in
                        if let date = openMeteoDateParser.date(from: times[index]),
                           let weatherCode = self.openMeteoWeatherCodesManager.weatherCode(code: weatherCodes[index]) {
                            let title: String
                            let weather: String
                            let weatherIcon: URL
                            
                            if calendar.isDate(date, inSameDayAs: now) {
                                title = "Today"
                                if let sunrise = openMeteoDateParser.date(from: sunrises[index]),
                                   let sunset = openMeteoDateParser.date(from: sunsets[index]) {
                                    if now >= sunrise && now <= sunset {
                                        weather = weatherCode.day.description
                                        weatherIcon = weatherCode.day.image
                                    } else {
                                        weather = weatherCode.night.description
                                        weatherIcon = weatherCode.night.image
                                    }
                                } else {
                                    weather = weatherCode.day.description
                                    weatherIcon = weatherCode.day.image
                                }
                            } else {
                                title = openMeteoDateFormatter.string(from: date)
                                weather = weatherCode.day.description
                                weatherIcon = weatherCode.day.image
                            }
                            return OpenMeteoDayModel(title: title,
                                                     weather: weather,
                                                     weatherIcon: weatherIcon,
                                                     temperature: temperatures[index].formattedTemperature,
                                                     windSpeed: "Wind speed: " + windSpeeds[index].format(precision: 1) + " m/s",
                                                     humidity: "Humidity: " + String(relativeHumidities[index]) + "%")
                        } else {
                            return nil
                        }
                    }
                    
                    return .success(.init(dayModels: openMeteoDayModels))
                } else {
                    return .failure(NSError(code: -1, reason: "Inconsistent data."))
                }
            } catch {
                return .failure(error as NSError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

/// Данные о погоде: время, температура, влажность, погодный код, ветер, рассвет, закат.
enum OpenMeteoDataDailyKeys: String, CodingKey {
    case time
    case temperature_2m_mean
    case relative_humidity_2m_mean
    case weather_code
    case wind_speed_10m_max
    case sunrise
    case sunset
}
/// Данные о погоде: временная зона годора и прогноз по дням.
enum OpenMeteoDataKeys: String, CodingKey {
    case timezone
    case daily
}
/// Предварительные погодные данные от сервера.
struct OpenMeteoData: Decodable {
    let timezone: String
    let time: [String]
    let temperature: [Double]
    let relativeHumidity: [Int]
    let weatherCode: [Int]
    let windSpeed: [Double]
    let sunrise: [String]
    let sunset: [String]
    
    init(from decoder: any Decoder) throws {
        let openMeteoDataContainer = try decoder.container(keyedBy: OpenMeteoDataKeys.self)
        self.timezone = try openMeteoDataContainer.decode(String.self, forKey: .timezone)
        
        let openMeteoDailyContainer = try openMeteoDataContainer.nestedContainer(keyedBy: OpenMeteoDataDailyKeys.self, forKey: .daily)
        self.time = try openMeteoDailyContainer.decode([String].self, forKey: .time)
        self.temperature = try openMeteoDailyContainer.decode([Double].self, forKey: .temperature_2m_mean)
        self.relativeHumidity = try openMeteoDailyContainer.decode([Int].self, forKey: .relative_humidity_2m_mean)
        self.weatherCode = try openMeteoDailyContainer.decode([Int].self, forKey: .weather_code)
        self.windSpeed = try openMeteoDailyContainer.decode([Double].self, forKey: .wind_speed_10m_max)
        self.sunrise = try openMeteoDailyContainer.decode([String].self, forKey: .sunrise)
        self.sunset = try openMeteoDailyContainer.decode([String].self, forKey: .sunset)
    }
}
