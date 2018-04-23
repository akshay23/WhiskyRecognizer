//
//  BindableType.swift
//  Builder
//
//  Created by Akshay Bharath on 12/14/17.
//  Copyright © 2017 Animoto. All rights reserved.
//

import RxSwift

protocol BindableType {
    associatedtype ViewModelType
    var viewModel: ViewModelType? { get set }
    func bindViewModel()
}

// Ensure that viewModel variable is only assigned after view is loaded
extension BindableType where Self: UIViewController {
    mutating func bindViewModel(to model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
