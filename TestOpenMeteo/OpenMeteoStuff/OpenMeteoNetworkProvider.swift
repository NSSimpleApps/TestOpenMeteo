//
//  OpenMeteoNetworkProvider.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation
import Alamofire

/// Информация для запроса к погодному серверу.
struct OpenMeteoRequestData {
    let latitude: Double
    let longitude: Double
    let days: Int
    let dailyAttributes: [String]
}

/// Протокол для построения запросов к серверу.
protocol OpenMeteoRequestBuilderProtocol: Sendable {
    func weather(requestData: OpenMeteoRequestData) throws(NSError) -> URLRequest
}

/// Скачивание данных с сети в зависимости от запросов.
actor OpenMeteoNetworkProvider: OpenMeteoDataProviderProtocol {
    private let requestBuilder: OpenMeteoRequestBuilderProtocol
    private let session: Session
    
    init(requestBuilder: any OpenMeteoRequestBuilderProtocol) {
        self.requestBuilder = requestBuilder
        self.session = Session(startRequestsImmediately: false)
    }
    
    func getWeatherData(requestData: OpenMeteoRequestData) async throws(CancellationError) -> Result<Data, NSError> {
        let weatherRequest: URLRequest
        do {
            weatherRequest = try self.requestBuilder.weather(requestData: requestData)
        } catch {
            return .failure(error)
        }
        let sessionRequest = self.session.request(weatherRequest)
            .validate()
        let dataTask = sessionRequest.serializingData()
        sessionRequest.resume()
        let response = await dataTask.response
        try Task.checkIfCancelled()
        
        if let afError = response.error {
            let nsError = NSError.initFrom(afError: afError)
            if nsError.isCancelled {
                throw CancellationError()
            } else {
                return .failure(nsError)
            }
        } else if let httpResponse = response.response {
            let statusCode = httpResponse.statusCode
            if statusCode >= 200 && statusCode < 300 {
                if let data = response.data {
                    return .success(data)
                } else {
                    let nsError = NSError(code: statusCode, reason: "Empty response.")
                    return .failure(nsError)
                }
            } else {
                let nsError = NSError(code: statusCode, reason: "Invalid status code.")
                return .failure(nsError)
            }
        } else {
            let nsError = NSError(code: -1, reason: "There is not appropriate info.")
            return .failure(nsError)
        }
    }
}


