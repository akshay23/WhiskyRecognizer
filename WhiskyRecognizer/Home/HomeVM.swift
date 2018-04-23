//
//  HomeVM.swift
//  WhiskyRecognizer
//
//  Created by Akshay Bharath on 4/23/18.
//  Copyright © 2018 Akshay Bharath. All rights reserved.
//

import Action
import RxSwift
import RxSwiftExt

class HomeVM: NSObject {
    
    private let disposeBag: DisposeBag
    private let coordinator: CoordinatorDelegate
    
    init(coordinator: CoordinatorDelegate) {
        self.disposeBag = DisposeBag()
        self.coordinator = coordinator
        super.init()
    }
}
