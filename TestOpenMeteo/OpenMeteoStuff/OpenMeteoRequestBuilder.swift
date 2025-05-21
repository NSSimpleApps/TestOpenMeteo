//
//  OpenMeteoRequestBuilder.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation
import Alamofire


/// Построение запросов к api.open-meteo.com.
final class OpenMeteoRequestBuilder: OpenMeteoRequestBuilderProtocol {
    private let baseRequest: URLRequest
    
    init() {
        let baseURL = URL(string: "https://api.open-meteo.com/v1/forecast")!
        var baseRequest = URLRequest(url: baseURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        baseRequest.method = .get
        self.baseRequest = baseRequest
    }
    func weather(requestData: OpenMeteoRequestData) throws(NSError) -> URLRequest {
        do {
            let latitude = requestData.latitude.format(precision: 2)
            let longitude = requestData.longitude.format(precision: 2)
            var parameters: [String: String] = [
                "latitude": latitude, "longitude": longitude,
                "daily": requestData.dailyAttributes.joined(separator: ","),
                "timezone": "auto",
                "wind_speed_unit": "ms"
            ]
            if case let days = requestData.days, days > 0 {
                parameters["forecast_days"] = String(days)
            }
            
            return try URLEncoding.queryString.encode(self.baseRequest, with: parameters)
        } catch let afError as AFError {
            throw NSError.initFrom(afError: afError)
        } catch {
            throw error as NSError
        }
    }
}
