//
//  LeaveFormView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 25/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LeaveFormView: View {
    @State private var reason = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var isSuccess = false
    @State private var isError = false
    @State private var isLeaveSubmitted = false
    @State private var alertMessage = ""
    
    
    @State private var userName = ""
    @State private var rollNo = ""
    @State private var roomNo = ""
    @State private var contact = ""
    @State private var selectedHostel = ""
    
    @State private var showPreviousLeaveForms = false
    var body: some View {
        Form{
            Section{
                NavigationLink{
                    PreviousLeaveFormView()
                }label: {
                    Text("View Previous Leave Form")
                        .foregroundColor(.blue)
                }
            }
            
            sectionUserDetails()
            sectionReason()
            startDateSection()
            endDateSection()
            submitLeaveForm()
            
        }.onAppear(perform: fetchuserdetails)
    }
    
    private func sectionReason() -> some View {
        Section(header: Text("Reason")) {
            TextField("Reason", text: $reason)
                .submitLabel(.done)
                .frame(height: 50)
        }
    }
    
    private func startDateSection() -> some View{
        Section(header: Text("Start Date")){
            DatePicker("Leave Date",selection: $startDate,in: Date()..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
    
    private func endDateSection() -> some View{
        Section(header: Text("End Date")){
            DatePicker("End date",selection: $endDate,in: Date()...,displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
    
    private func sectionUserDetails() -> some View {
        Section(header: Text("User Details")) {
            DetailRow(title: "Name:", value: userName).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "RollNo:", value: rollNo).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "RoomNo:", value: roomNo).font(Montserrat.semibold.font(size: 20))
            DetailRow(title: "Contact", value: contact).font(Montserrat.semibold.font(size: 20))
        }
    }
    
    private func submitLeaveForm() ->some View{
        Section{
            
            HStack{
                Spacer()
                
                Button{
                    submitLeaveRequest()
                }label: {
                    Text("Submit Leave Form")
                        .foregroundStyle(.blue)
                }
                .alert("Submitted", isPresented: $isSuccess, actions: {
                    Button("OK"){
                        isSuccess = false
                    }
                },message: {
                    Text("Leave form Submitted successfully")
                })
                .alert("Error", isPresented: $isError, actions: {
                    Button("OK"){
                        isError = false
                    }
                },message: {
                    Text(alertMessage)
                })
                
                
                Spacer()
            }
        }
    }
    
    private func fetchuserdetails(){
        Task {
            do {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let document = try await Firestore.firestore().collection("user_details").document(userID).getDocument()

                if document.exists {
                    userName = document["name"] as? String ?? ""
                    rollNo = document["rollno"] as? String ?? ""
                    roomNo = document["room"] as? String ?? ""
                    contact = document["contact"] as? String ?? ""

                    if let hostel = document["hostel"] as? String, hostel != "N/A" {
                        selectedHostel = hostel
                    } else {
                        alertMessage = "Room not yet booked. Please complete your booking before submitting a complaint."
                        isError = true
                    }
                } else {
                    print("User details not found")
                }
            } catch {
                print("Error fetching user details: \(error.localizedDescription)")
                alertMessage = "Error fetching user details: \(error.localizedDescription)"
                isError = true
                
            }
        }
    }
    
    private func submitLeaveRequest() {
        

        guard !reason.isEmpty else {
                isError = true
                alertMessage = "Reason cannot be empty."
                return
            }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User ID not available.")
           
            return
        }

        Firestore.firestore().collection("user_details").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                
                return
            }

            guard let userData = snapshot?.data(),
                  let name = userData["name"] as? String,
                  let rollNo = userData["rollno"] as? String,
                  let contact = userData["contact"] as? String,
                  let hostel = userData["hostel"] as? String else {
                print("Error: User details not available.")
               
                return
            }

            let leaveRequestData: [String: Any] = [
                "userID": userID,
                "name": name,
                "rollNo": rollNo,
                "contact": contact,
                "hostel": hostel,
                "reason": reason,
                "startDate": startDate,
                "endDate": endDate,
                "status": "pending",
            ]

            Firestore.firestore().collection("leaveform").addDocument(data: leaveRequestData) { error in
                
                if let error = error {
                    print("Error submitting leave request: \(error.localizedDescription)")
                } else {
                    print("Leave request submitted successfully")
                    isSuccess = true
                    clearFields()
                }
            }
        }
    }
    
    
    
    private func clearFields() {
        reason = ""
        startDate = Date()
        endDate = Date()
        
       
    }
    
    
}

struct DetailRow: View {
    var title : String
    var value : String
    var body: some View {
        HStack{
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    LeaveFormView()
}
