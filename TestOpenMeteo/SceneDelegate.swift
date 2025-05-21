//
//  SceneDelegate.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = OpenMeteoAwaitingViewController()
        self.window = window
        window.makeKeyAndVisible()
        
        Task.detached {
//            let openMeteoTestDataProvider = OpenMeteoTestDataProvider()
//            let openMeteoHandler = try OpenMeteoHandler(openMeteoDataProvider: openMeteoTestDataProvider)
            
            let openMeteoNetworkProvider = OpenMeteoNetworkProvider(requestBuilder: OpenMeteoRequestBuilder())
            let openMeteoHandler = try OpenMeteoHandler(openMeteoDataProvider: openMeteoNetworkProvider)
            
            let selectedCity = OpenMeteoCityData(cityName: "Novosibirsk", latitude: 55.01, longitude: 82.93)
            let cities: [OpenMeteoCityData] = [selectedCity,
                                               .init(cityName: "Moscow", latitude: 55.75, longitude: 37.61),
                                               .init(cityName: "New York", latitude: 0.73, longitude: -73.93),
                                               .init(cityName: "San Francisco", latitude: 37.77, longitude: -122.43)]
            
            await MainActor.run(body: {
                let openMeteoViewController = OpenMeteoViewController(openMeteoProviderProtocol: openMeteoHandler,
                                                                      cities: cities, selectedCity: selectedCity)
                window.rootViewController = UINavigationController(rootViewController: openMeteoViewController)
            })
        }
    }
}
