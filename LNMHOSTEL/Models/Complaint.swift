//
//  Complaint.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 28/05/25.
//


import Foundation



struct Complaint: Identifiable, Codable {
    var id: String
    var complaintType: String
    var complaintDetails: String
    var userName: String
    var rollNo: String
    var roomNo: String
    var contact: String
    var hostel: String
    var preferredDate: Date
    var preferredTimeFrom: Date
    var preferredTimeTo: Date
    var status: String
}
