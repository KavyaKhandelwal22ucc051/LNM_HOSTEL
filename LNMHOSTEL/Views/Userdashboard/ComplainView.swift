//
//  ComplainView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 25/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ComplainView: View {
    @State private var selectedComplainType = ""
    @State private var isError = false
    @State private var alertMessage = ""
    @State private var complaintDetails = ""
    @State private var selectedDate = Date()
    @State private var selectedTimeFrom = Date()
    @State private var selectedTimeTo = Date()
    @State private var complainSubmitted = false

    
    @State private var name = ""
    @State private var RollNO = ""
    @State private var roomNo = ""
    @State private var Hostel = ""
    @State private var contact = ""
    
    
    var complaintTypes = ["AC Repair", "Air Ducts Repair", "Infrastructure related", "Furniture related", "Plumbing related", "Common Complaints", "Electricity Related", "Other"]
    
   
    var body: some View {
        NavigationStack{
            Form{
                
                Section{
                    NavigationLink{
                        PreviousComplainView()
                    }label: {
                        Text("View Previous Complaints")
                            .foregroundColor(.blue)
                    }
                }
                
                Complaintype()
                ComplainDetails()
                PrefferedDate()
                PreferredTime()
                DisplayUserDetails()
                sumbitButtom()
                
            }
            .onAppear{
                fetchDetailsOfUser()
            }
        }
    }
    
    // MARK: - Sections
    
    
    func Complaintype() -> some View {
        Section(header: Text("Complain Type")){
            Picker("Complaint Type", selection: $selectedComplainType){
                ForEach(complaintTypes,id: \.self){
                    complain in
                    Text(complain)
                }
            }
        }
    }
    
    func ComplainDetails() -> some View{
        Section(header: Text("Complaint Details")){
            TextField("Complaint Details",text: $complaintDetails)
                .submitLabel(.done)
                .frame(height: 50)
        }
    }
    
    func PrefferedDate() -> some View{
        Section(header: Text("Preferred Date")){
            
            DatePicker("Preferred Date", selection: $selectedDate, in: .now..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
    
    func PreferredTime() -> some View {
        Section(header: Text("Preferred Time")){
            
            DatePicker("From", selection: $selectedTimeFrom, in: .now..., displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
            
            DatePicker("To", selection: $selectedTimeTo, in: .now..., displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .onChange(of: selectedTimeTo){ newValue in
                    Validtime()
                }
        }
    }
    
    private func DisplayUserDetails() -> some View{
        Section(header: Text("User Details")){
            DetailedRow(title: "Name", value: name)
                .font(Montserrat.semibold.font(size: 17))
            DetailedRow(title: "Roll No", value: RollNO)
                .font(Montserrat.semibold.font(size: 17))
            DetailedRow(title: "Room No", value: roomNo)
                .font(Montserrat.semibold.font(size: 17))
            DetailedRow(title: "Contact", value: contact)
                .font(Montserrat.semibold.font(size: 17))
        }
    }
    
    private func sumbitButtom() -> some View {
        Section{
            HStack{
                Spacer()
                Button{
                    sumbitComplainDetails()
                }label: {
                    Text("Sumbit Complaint")
                }
                .alert("Error", isPresented: $isError, actions: {
                    Button("OK") {
                        isError = false
                    }
                }, message: {
                    Text(alertMessage)
                })
                .alert("Complaint Submitted", isPresented: $complainSubmitted, actions: {
                    Button("OK") {
                        
                        complainSubmitted = false
                    }
                }, message: {
                    Text("Your complaint has been submitted successfully.")
                })

                
                Spacer()
            }
        }
    }
    
    // MARK: - Functions
    
    private func Validtime(){
        let calendar = Calendar.current
        let componets = calendar.dateComponents([.hour], from: selectedTimeFrom, to: selectedTimeTo)
        
        if let hour = componets.hour , hour < 1 {
            alertMessage = "The time span between 'From' and 'To' should be at least 1 hour."
            isError = true
            
            selectedTimeTo = calendar.date(byAdding: .hour, value: 1, to: selectedTimeFrom) ?? selectedTimeTo
        }
    }
    
   
    
   
    
    func sumbitComplainDetails() {
        
       
        
        guard !selectedComplainType.isEmpty,
              !complaintDetails.isEmpty,
                !Hostel.isEmpty else{
            print("error please fill the fields")
            self.alertMessage =  "Please fill in all required fields before submitting a complaint."
            isError = true
            return
        }
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        let complaintDetails : [String : Any] = [
            "userId":userId,
            "status":"pending",
            "complaintType":selectedComplainType,
            "complaintDetails":complaintDetails,
            "userName":name,
            "hostel":Hostel,
            "room":roomNo,
            "rollNo":RollNO,
            "contact":contact,
            "preferredDate":selectedDate,
            "preferredTimeFrom":selectedTimeFrom,
            "preferredTimeTo":selectedTimeTo
        ]
        
        Firestore.firestore().collection("Complaints").addDocument(data: complaintDetails){
            error in
            if let error = error {
                print("Error in putting complaints :\(error.localizedDescription)")
            }
            
           
            
            print("Complaint submitted successfully!")
            clearField()
            
                complainSubmitted = true
            
        }
    }
    
    func fetchDetailsOfUser(){
        Task{
            
            do{
                guard let UserId = Auth.auth().currentUser?.uid else{
                    return
                }
                
                let document = try await Firestore.firestore().collection("user_details").document(UserId).getDocument()
                
                if document.exists {
                    let data = document.data()
                    self.name = data?["name"] as? String ?? ""
                    self.contact = data?["contact"] as? String ??
                    ""
                    self.roomNo = data?["room"] as? String ?? ""
                    self.Hostel = data?["hostel"] as? String ?? ""
                    self.RollNO = data?["rollno"] as? String ?? ""
                    
                    if Hostel == "N/A" {
                        self.alertMessage = "You have not booked a room . Please book a room first"
                        self.isError = true
                    }
                }else{
                    print("user details not fount")
                }
            }catch{
                print("error fetching user details\(error.localizedDescription)")
            }
        }
        
    }
    
    struct DetailedRow: View {
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
    
    func clearField(){
        complaintDetails = ""
        selectedComplainType = ""
        selectedDate = Date()
        selectedTimeTo = Date()
        selectedTimeFrom = Date()
        
    }
}

#Preview {
    ComplainView()
}
