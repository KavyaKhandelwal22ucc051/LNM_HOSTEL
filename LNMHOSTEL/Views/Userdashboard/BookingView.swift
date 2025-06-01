//
//  BookingView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 25/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BookingView: View {
    @State private var selectedHostel : String = "BH1"
    @State private var isError = false
    @State private var alertMessage = ""
    @State private var availableRooms : [String] = []
    @State private var bookingsuccess = false
    
    let hostel = ["BH1","BH2","BH3","GH"]
    let db = Firestore.firestore()
    var body: some View {        
        VStack{
            HStack{
                Text("Room Booking")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                Spacer()
            }
            
            Spacer()
            
            HStack{
                Text("Select Hostel")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()
                
                Spacer()
            }
            
            Picker("Select Hostel", selection: $selectedHostel){
                ForEach(hostel,id: \.self){
                    hostel in
                    Text(hostel)
                }
            }.onChange(of: selectedHostel){
                _ in
                fetchAvailableRooms()
            }.alert(isPresented: $bookingsuccess){
                Alert(title:  Text(isError ? "Cannot Book Room" : "Success"),message: Text(alertMessage),dismissButton: .default(Text("OK")))
            }.pickerStyle(.segmented)
            Spacer()
            
            if !selectedHostel.isEmpty {
                List(availableRooms,id: \.self){
                    room in
                    HStack{
                        Text(room)
                        Spacer()
                        Button{
                            BookRoom(room: room)
                        }label: {
                            Text("Book")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }.onAppear{
            fetchAvailableRooms()
        }
    }
    
    func fetchAvailableRooms(){
        if selectedHostel.isEmpty {
            return
        }
        
        let hostelRef = db.collection("Hostels")
        hostelRef.whereField("hostelId", isEqualTo: selectedHostel).getDocuments{
            result , error in
            if let error = error {
                print("error in fetching available rooms \(error.localizedDescription)")
                return
            }
            
            guard let documents = result?.documents else{
                return
            }
            
            var fetchedRooms : [String] = []
            for document in documents {
                let hostelData = document.data()
                if let availableRoomsarray = hostelData["availableRooms"] as?[String]{
                    fetchedRooms += availableRoomsarray
                }
            }
            
            fetchBookedRooms{
                bookedRooms in
                let filterRooms = fetchedRooms.filter{
                    !bookedRooms.contains($0)
                    
                }
                
                self.availableRooms = filterRooms
            }
                
           
            
        }
        
        
    }
    
    func fetchBookedRooms(completion: @escaping([String]) -> Void){
        let bookedRef = db.collection("Bookings")
        bookedRef.whereField("hostel", isEqualTo: selectedHostel).whereField("bookingStatus", in: ["pending","approved"]).getDocuments{
            QuerySnapshot , error in
            
            if let error = error {
                print("error fectching booked rooms:\(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = QuerySnapshot?.documents else{
                completion([])
                return
            }
            
            var bookedRooms : [String] = []
            for document in documents {
                let bookingData = document.data()
                if let bookRoom = bookingData["room"] as? String{
                    bookedRooms.append(bookRoom)
                }
            }
            
            completion(bookedRooms)
        }
    }
    
    func BookRoom(room : String){
        
        guard !availableRooms.isEmpty else {
            return
        }

        // Check if the room is still available
        guard availableRooms.contains(room) else {
            // Room is no longer available
            print("Room \(room) is no longer available.")
            return
        }
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        Firestore.firestore().collection("user_details").document(userID).getDocument{
            document , error in
            if let error = error {
                print("error fetching user details \(error.localizedDescription)")
                return
            }
            
            guard let userData = document?.data() else{
                return
            }
            
            let roomNo = userData["room"] as? String ?? ""
            
            if roomNo != "N/A" {
                self.showBookingAlert(message: "You already have a room booked.")
                print("You already have a room booked.")

                
            }else{
                
                let studentName = userData["name"] as? String ?? ""
                let studentEmail = userData["email"] as? String ?? ""
                let rollNo = userData["rollno"] as?String ?? ""
                let studentId = userData["studentId"] as?String ?? ""
                
                let bookRef = Firestore.firestore().collection("Bookings")
                bookRef.whereField("studentEmail", isEqualTo: studentEmail).whereField("bookingStatus", in: ["pending","approved"]).getDocuments{
                    QuerySnapshot , error in
                    
                    if let error = error {
                        print("Error checking pending booking requests: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = QuerySnapshot?.documents,documents.isEmpty else{
                        self.showBookingAlert(message: "You cannot book another room until your previous booking request is processed.")
                        
                        print("You cannot book another room until your previous booking request is processed.")
                        return
                    }
                    
                    Firestore.firestore().collection("Bookings").addDocument(data: [
                        "hostel": self.selectedHostel,
                        "room": room,
                        "rollNo": rollNo,
                        "studentName": studentName,
                        "studentEmail": studentEmail,
                        "bookingStatus": "pending",
                        "studentID": studentId,
                        "adminApprovalTimestamp": Date(),
                    ]){
                        error in
                        if let error = error {
                            print("Error in stroing Booking request : \(error.localizedDescription)")
                            return
                        }
                        
                        print("Booking request submitted successfully")
                        showBookingAlert(message: "Booking request submitted successfully", isError: false)
                        
                        if let index = self.availableRooms.firstIndex(of: room)
                        {
                            self.availableRooms.remove(at: index)
                        }
                        
                        
                        // Update the UI with the new availableRooms array
                        // (This update may not be instant, and it depends on Firestore update speed)
                        self.availableRooms = self.availableRooms
                        
                        // Fetch the updated list of booked rooms to filter them out from available rooms
                        self.fetchBookedRooms { _ in }
                    }
                    
                    
                }
               
            }
        }
        
        
        
    }
    
    func showBookingAlert(message: String, isError: Bool = true) {
        self.alertMessage = message
        self.isError = isError
        self.bookingsuccess = true
    }

}

#Preview {
    BookingView()
}
