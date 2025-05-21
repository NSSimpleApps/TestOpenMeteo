//
//  OpenMeteoTestDataProvider.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import Foundation

actor OpenMeteoTestDataProvider: OpenMeteoDataProviderProtocol {
    func getWeatherData(requestData: OpenMeteoRequestData) async throws(CancellationError) -> Result<Data, NSError> {
        let fileName = "test_openmeteo"
        if let fileNameURL = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                return .success(try Data(contentsOf: fileNameURL))
            } catch {
                return .failure(error as NSError)
            }
        } else {
            return .failure(NSError(code: -1, reason: "\(fileName) not found."))
        }
    }
}
