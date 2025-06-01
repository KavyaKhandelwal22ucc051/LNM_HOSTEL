//
//  Card.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 20/05/25.
//

import Foundation

struct Card : Identifiable {
    var id : Int
    var title : String
    var description : String
}

var testData : [Card] = [
    Card(id: 1, title: "Login", description: "Welcome Back: Seamlessly Access Your Account and Dive Right In"),
    
    Card(id: 2, title: "Create Account", description: "Join Us Today: Create Your Account and Unlock a World of Possibilities!")
]

