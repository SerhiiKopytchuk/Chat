//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import FirebaseAuth
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
    @State var isPresentLoginView: Bool = false
    
    private func updateButton() {
        let time:Double = 0.3
        //check if enable button
        if fullName.isEmpty || email.isEmpty || password.isEmpty || retryPassword.isEmpty{
            withAnimation(.easeInOut(duration: time)) {
                isButtonDisabled = true
            }
            
        }else{
            if password == retryPassword{
                if password.count >= 8{
                    if email.contains("@gmail.com") || email.contains("@email.com"){
                        withAnimation(.easeInOut(duration: time)) {
                            isButtonDisabled = false
                        }
                    }else{
                        withAnimation(.easeInOut(duration: time)) {
                            isButtonDisabled = true
                        }
                    }
                }else{
                    withAnimation(.easeInOut(duration: time)) {
                        isButtonDisabled = true
                    }
                }
            }else{
                withAnimation(.easeInOut(duration: time)) {
                    isButtonDisabled = true
                }
            }
        }
    }
    
    var body: some View {
        
        
        NavigationView{
            VStack(spacing: 30) {
                Spacer()
                HStack{
                    Text("Sign Up")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding()
                        .foregroundColor(.orange)
                    Spacer()
                }
                
                VStack{
                    Group {
                        HStack{
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                            TextField("Full Name", text: $fullName.onUpdate(updateButton))
                        }
                        
                        HStack{
                            Image(systemName: "mail")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email.onUpdate(updateButton))
                        }
                        
                        HStack{
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $password.onUpdate(updateButton))
                        }
                        HStack{
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Retry password", text: $retryPassword.onUpdate(updateButton))
                        }
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
                    .shadow(color:isButtonDisabled ? .gray : .orange, radius: isButtonDisabled ? 0 : 8, x: 0, y: 0)
                    
                    Button("Log In") {
                        //go to login Vc
                        self.isPresentLoginView = true
                    }
                    .foregroundColor(.brown)
                    .padding(.top, 20)
                    Spacer()
                    
                }
                NavigationLink(destination: LoginView(), isActive: $isPresentLoginView){}.navigationTitle(" Sign Up").navigationBarHidden(true)
            }
        }.accentColor(.orange)
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
