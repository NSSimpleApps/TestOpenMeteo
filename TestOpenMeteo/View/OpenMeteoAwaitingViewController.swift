//
//  OpenMeteoAwaitingViewController.swift
//  TestOpenMeteo
//
//  Created by user on 21.05.2025.
//


import UIKit

/// Экран-заглушка, который показывается при предварительной загрузке данных.
final class OpenMeteoAwaitingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        self.view.autoLayoutSubview(activityIndicatorView)
        activityIndicatorView.centerEquals(to: self.view)
    }
}
