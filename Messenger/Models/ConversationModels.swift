//
//  ConversationModels.swift
//  Messenger
//
//  Created by 김종현 on 2021/02/07.
//  Copyright © 2021 kjh. All rights reserved.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
