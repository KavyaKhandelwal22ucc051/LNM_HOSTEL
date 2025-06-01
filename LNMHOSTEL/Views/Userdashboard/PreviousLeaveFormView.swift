//
//  PreviousLeaveFormView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 29/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PreviousLeaveFormView: View {
    @State private var leaveforms : [LeaveForm] = []
    var body: some View {
        NavigationStack{
            List(leaveforms){leaveform in
                NavigationLink(destination: LeaveformDetailView(leaveform: leaveform)){
                    PreviousLeaveFormRow(leaveform: leaveform)
                }
            }
            }.onAppear{
                fetchuserdetails()
        }
    }
    
    func fetchuserdetails(){
        
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        
        Firestore.firestore().collection("leaveform")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching leave forms: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    return
                }

                var LeaveForms: [LeaveForm] = []
                for document in documents {
                    let leaveFormData = document.data()
                    
                    let startDateTimestamp = leaveFormData["startDate"] as? Timestamp ?? Timestamp(date: Date())
                    let endDateTimestamp = leaveFormData["endDate"] as? Timestamp ?? Timestamp(date: Date())

                    let userLeaveForm = LeaveForm(
                        id: document.documentID,
                        reason: leaveFormData["reason"] as? String ?? "",
                        startDate: startDateTimestamp.dateValue(),
                        endDate: endDateTimestamp.dateValue(),
                        status: leaveFormData["status"] as? String ?? ""
                        
                    )

                    LeaveForms.append(userLeaveForm)
                }

                self.leaveforms = LeaveForms
            }
    
    }
    
    
    
    
}

struct PreviousLeaveFormRow : View {
    let leaveform  : LeaveForm
    var body: some View {
        VStack(alignment: .leading){
            Text("Reason : \(leaveform.reason)")
                .font(.headline)
                .foregroundStyle(.black)
                .lineLimit(2)
                .truncationMode(.tail)
            
            Text("Status: \(leaveform.status)")
                .foregroundColor(leaveform.status == "pending" ? .orange : .teal)
                .font(.subheadline)
                .padding(.top, 5)
        }
    }
}

struct LeaveformDetailView : View {
    let leaveform : LeaveForm
    var body: some View {
        VStack{
            
            Text("Start Date: \(FormattedDate(leaveform.startDate))")
                .font(.headline)
                .padding()
            
            
            Text("End Date: \(FormattedDate(leaveform.endDate))")
                .font(.headline)
                .padding()
            
            Text("Status: \(leaveform.status)")
                .foregroundColor(leaveform.status == "pending" ? .orange : .teal)
                .font(.subheadline)
                .padding()
            
            
            
            
            Spacer()
        }
        .padding()
        .cornerRadius(10)
        .padding(.horizontal)
        .frame(maxWidth: 350)
        .navigationTitle("Leave Form Details")
    }
}

func FormattedDate(_ date:Date) -> String{
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

#Preview {
    PreviousLeaveFormView()
}
