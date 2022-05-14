//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI

// Apple HIG
// Apple Human Interface Guidelines

// SF Symbols
struct RootView: View {
    
    @State var fullName:String = ""
    @State var email:String = ""
    @State var password:String = ""
    @State var retryPassword:String = ""
    
    @State var isShowingAlert: Bool = false
    @State var isButtonDisabled: Bool = true
    
    private func updateButton() {
        //check if enable button
        if fullName.isEmpty || email.isEmpty || password.isEmpty || retryPassword.isEmpty{
            isButtonDisabled = true
            
        }else{
            if password == retryPassword{
                if password.count >= 8{
                    if email.contains("@gmail.com") || email.contains("@email.com"){
                        isButtonDisabled = false
                    }else{
                        isButtonDisabled = true
                    }
                }else{
                    isButtonDisabled = true
                }
            }else{
                isButtonDisabled = true
            }
        }
    }
    
    var body: some View {
        
        ZStack {
            //            VStack {
            //            here I can make a gradiend
            //            }
            //            .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 30) {
                Spacer()
                HStack{
                    Text("Sign Up")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding()
                    Spacer()
                }
                
                
                
                VStack{
                    Group {
                        
                        TextField("Full Name", text: $fullName.onUpdate(updateButton))
                        
                        TextField("Email", text: $email.onUpdate(updateButton))
                        
                        SecureField("Password", text: $password.onUpdate(updateButton))
                        
                        SecureField("Retry password", text: $retryPassword.onUpdate(updateButton))
                    }
                    .padding()
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                            .padding(5)
                    )
                    
                    
                    
                }
                
                
                Spacer()
                VStack {
                    Button("Create Account") {
                        //how to automaticly change prop
                        
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 80)
                    .padding(.trailing, 80)
                    .padding()
                    .background(isButtonDisabled ? Color.gray : Color.orange)
                    .cornerRadius(30)
                    .disabled(isButtonDisabled)
                    Spacer()
                    
                    Button("Log In") {
                        //firebase login
                    }
                    .foregroundColor(.blue)
                }
                
                
                
                
                .alert("Invalid Entry", isPresented: $isShowingAlert) {
                    EmptyView()
                } message: {
                    Text("You entered an invalid string")
                }
                
                //                Spacer()
            }
        }
    }
}
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

extension Binding {
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}
