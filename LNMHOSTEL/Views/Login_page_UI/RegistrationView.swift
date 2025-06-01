//
//  RegistrationView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 21/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var father = ""
    @State private var password = ""
    @State private var rollno = ""
    @State private var contact = ""
    @State private var alertmessage = ""
    @State private var hostel = "N/A"
    @State private var room = "N/A"
    @State private var showerror : Bool = false
    @State private var isRegistering = false
    @State private var isRegistrationSuccess = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView{
                ZStack{
                    
                    Color("BgColor").ignoresSafeArea(.all)
                    
                    VStack{
                        
                        Spacer()
                        
                        
                        Text("Register")
                            .font(.largeTitle)
                            .padding()
                        
                        Text("Email")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Email adress",text: $email).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Text("Password")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Password",text: $password).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Text("Name")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Name",text: $name).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Text("Roll Number")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Roll Number",text: $rollno).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Text("Father's Name")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Father's Name",text: $father).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Text("Contanct (10 digit)")
                            .font(Montserrat.medium.font(size: 25))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding()
                        
                        TextField("Enter Contanct",text: $contact).padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .shadow(color: Color.black.opacity(0.08),radius: 30,x: 0,y: 14)
                            .submitLabel(.done)
                        
                        Button{
                            if Validform(){
                                registration()
                            }else{
                                showerror = true
                            }
                        }label: {
                            Text("Register")
                                .font(Montserrat.medium.font(size: 25))
                                .foregroundStyle(.white)
                                .frame(width: 200,height: 50)
                                .background(Color("blue1"))
                                .cornerRadius(30)
                                .padding()
                        }.disabled(isRegistering)
                            .alert(isPresented : $showerror){
                                Alert(title: Text("Error"),
                                      message: Text(alertmessage),
                                      dismissButton: .default(Text("OK"))
                                )
                            }
                        
                    }
                }
            }
    }
    
    func registration() {
        
        
        let domain = email.split(separator: "@")[1]
        if !["gmail.com","lnmiit.ac.in"].contains(domain){
            alertmessage = "Invalid email domain. Please use either gmail.com or lnmiit.ac.in."
            showerror = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password){
            result,error in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.alertmessage = error.localizedDescription
                    self.showerror = true
                }else if let user = result?.user{
                    
                    let userDetails = [
                        "email":email,
                        "studentId":user.uid,
                        "name":name,
                        "fatherName":father,
                        "rollno":rollno,
                        "contact":contact,
                        "hostel":hostel,
                        "room":room
                    ]
                    
                    
                    Firestore.firestore().collection("user_details").document(user.uid).setData(userDetails){
                        error in
                        if let error = error {
                            print("Error storing student data: \(error.localizedDescription)")
                        } else {
                            print("Registration and data storage successful")
                            isRegistrationSuccess = true
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    
                }
            }
        }
        
    }
    
   private func Validform() -> Bool {
        
        if email.isEmpty {
            alertmessage = "Please Enter the email"
            return false
        }
        
        if password.isEmpty {
            alertmessage = "Please Enter the Password"
            return false
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !isValidAlfhabatic(trimmedName) ||
            trimmedName.isEmpty {
            alertmessage = "Please Enter a Valid Name"
            return false
        }
        
        let trimmedFather = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !isValidAlfhabatic(trimmedFather) ||
            trimmedFather.isEmpty {
            alertmessage = "Please Enter a Valid Father Name"
            return false
        }
        
        if  rollno.isEmpty {
            alertmessage = "Enter a Valid Roll Number"
            return false
        }
        
        if contact.isEmpty || contact.count != 10 {
            alertmessage = "Enter a Valid 10-digit Contact Number"
            return false
        }
        
        if !isValidPassword(password){
            alertmessage = "Password must be at least 8 characters and contain a lowercase letter, uppercase letter, number, and special character."
            return false
        }
        
        if !isValidRoll(rollno) {
                alertmessage = "Roll number can only contain alphanumeric characters."
                return false
            }
        
        
        return true
    }
    
   private func isValidAlfhabatic(_ input: String)-> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES %@","^[a-zA-Z ]+$")
        
        return predicate.evaluate(with: input)
    }
    
    private func isValidPassword(_ password: String)-> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES %@","^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*_=+-]).{8,}$")
        
        return predicate.evaluate(with: password)
    }
    
    private func isValidRoll(_ roll: String)->Bool{
        return NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9]+$").evaluate(with: roll)
    }
}

#Preview {
    RegistrationView()
}
