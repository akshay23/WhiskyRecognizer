//
//  HomeScene.swift
//  WhiskyRecognizer
//
//  Created by Akshay Bharath on 4/23/18.
//  Copyright © 2018 Akshay Bharath. All rights reserved.
//

import Foundation

class HomeScene: Scene {
    
    let viewModel: HomeVM
    
    init(homeVM: HomeVM) {
        viewModel = homeVM
    }
    
    func controller() -> BaseController {
        var viewController = HomeVC()
        viewController.bindViewModel(to: viewModel)
        return viewController
    }
}
