//
//  ChatModel.swift
//  ChatApp
//

import Foundation

struct ChatModel: Codable {
    var messageID: Int
    var dateLeft: String
    var textMessage : String?
    var imageMessage: String?
    var status: String
}

struct TableAttributes {
    var header: String
    var messageAttributes: [MessageAttributes]
}

struct MessageAttributes {
    var status: String
    var text: String?
    var imagename: String?
}

