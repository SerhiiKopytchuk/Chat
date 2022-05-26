//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase
import GoogleSignIn
// Apple HIG
// Apple Human Interface Guidelines

// SF Symbols
struct SignUpView: View {
    
    
    @State var fullName:String = ""
    @State var email:String = ""
    @State var password:String = ""
    @State var retryPassword:String = ""
    
    @State var isButtonDisabled: Bool = true
    @State var isPresentLoginView: Bool = false
    @State var isShowingPassword:Bool = false
    @State var isShowingRetryPassword:Bool = false
    @State var isShowAlert = false
    @State var isShowLoader = false
    @State var alertText = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    private func updateButton() {
        let time:Double = 0.3
        //check if enable button
        
        withAnimation(.easeInOut(duration: time)) {
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
    }
    
    var body: some View {
        
        
        ZStack{
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
                            TextField("Full Name", text: $fullName)
                                .disableAutocorrection(true)
                                .onChange(of: fullName) { _ in
                                    updateButton()
                                }
                        }
                        HStack{
                            Image(systemName: "mail")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: email) { _ in
                                    updateButton()
                                }
                        }
                        HStack{
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            if self.isShowingPassword{
                                    
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: password) { _ in
                                        updateButton()
                                    }
                                Button {
                                    self.isShowingPassword.toggle()
                                } label: {
                                    Image(systemName: "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }else{
                                SecureField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: password) { _ in
                                        updateButton()
                                    }
                                Button {
                                    self.isShowingPassword.toggle()
                                } label: {
                                    Image(systemName: "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        HStack{
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            if self.isShowingRetryPassword{
                              
                                TextField("Re-enter", text: $retryPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: retryPassword) { _ in
                                        updateButton()
                                    }
                                Button {
                                    self.isShowingRetryPassword.toggle()
                                } label: {
                                    Image(systemName: "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }else{
                                SecureField("Re-enter", text: $retryPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: retryPassword) { _ in
                                        updateButton()
                                    }
                                Button {
                                    self.isShowingRetryPassword.toggle()
                                } label: {
                                    Image(systemName: "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                           
                        }
                    }
                    .padding()
                    .padding(.horizontal, 20)
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
                    Button("Create Account"){
                        if isButtonDisabled{
                            withAnimation(.easeInOut) {
                                alertText = "Fill all fields properly!"
                                isShowAlert.toggle()
                            }
                           
                        }else{
                            viewModel.signUp(username: self.fullName, email: self.email, password: self.password)
                        }
                    }
                        .foregroundColor(.white)
                        .padding(.horizontal, 80)
                        .padding()
                        .background(isButtonDisabled ? Color.gray : Color.orange)
                        .cornerRadius(30)
                        .shadow(color:isButtonDisabled ? .gray : .orange, radius: isButtonDisabled ? 0 : 8, x: 0, y: 0)

     
                    
                    
                    Button("Log In") {
                        //go to login Vc
                        self.isPresentLoginView = true
                    }
                    .foregroundColor(.brown)
                    .padding(.top, 20)
                    Text("OR")
                        .padding(.top, 50)
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    googleButton
                        .foregroundColor(.brown)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 35)
                                .stroke(Color.brown, lineWidth: 2)
                        )
                        .background(.clear)
                        .cornerRadius(35)
                        .padding(.top, 50)
                    Spacer()

                }
                NavigationLink(destination: SignInView(), isActive: $isPresentLoginView){}
                    
            }.navigationBarHidden(true).navigationBarBackButtonHidden(true)
            if isShowAlert || viewModel.showAlert{
                GeometryReader{ geometry in
                    if viewModel.showAlert{
                        customAlert(show: $isShowAlert, text: $viewModel.alertText)
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }else{
                        customAlert(show: $isShowAlert, text: $alertText)
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }
                     
                }.background(Color.white.opacity(0.65))
                    .edgesIgnoringSafeArea(.all)
                
            }
            
            if viewModel.showLoader{
                withAnimation {
                    GeometryReader{ reader in
                        Loader()
                            .position(x: reader.size.width/2, y:  reader.size.height/2)
                    }.background(Color.black.opacity(0.45).edgesIgnoringSafeArea(.all))
                }
            }
           
        }
            
    }
    
    var googleButton: some View{
        Button {
            //handle singin
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()){[self] user, error in
                
                if error != nil {
                   return
                 }

                 guard
                   let authentication = user?.authentication,
                   let idToken = authentication.idToken
                 else {
                   return
                 }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                 accessToken: authentication.accessToken)
                
                viewModel.signIn(credential: credential)
            }
        } label: {
            Image("google")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(AppViewModel())
.previewInterfaceOrientation(.portrait)
    }
}




