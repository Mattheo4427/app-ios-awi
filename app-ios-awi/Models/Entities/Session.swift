//
//  Session.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct Session: Identifiable, Codable {
    let id_session: Int
    var name: String
    var date_begin: Date
    var date_end: Date
    var deposit_fees: String
    var discount: String
    var comission_fees: String

    var id: Int { id_session }
}
