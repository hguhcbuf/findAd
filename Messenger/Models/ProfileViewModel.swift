//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by 김종현 on 2021/02/07.
//  Copyright © 2021 kjh. All rights reserved.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
