//
//  LoginView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 14.05.2022.
//

import SwiftUI
import Firebase
import GoogleSignIn
import _AuthenticationServices_SwiftUI

struct SignInView: View {

    // MARK: - vars

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isButtonDisabled: Bool = true
    @State private var isShowingPassword: Bool = false

    @State private var alertText: String?

    @Binding var isPresented: Bool

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case emailField
        case passwordField
    }

    @EnvironmentObject private var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var channelViewModel: ChannelViewModel
    @EnvironmentObject private var presenceViewModel: PresenceViewModel

    // MARK: - body
    var body: some View {
        VStack(spacing: 30) {

            HStack(spacing: 15) {

                Button {
                    withAnimation {
                        self.isPresented = false
                    }
                } label: {
                    Image(systemName: "arrow.backward.circle.fill")
                        .toButtonLightStyle(size: 40)
                }

                Text("Sign In")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.primary.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            inputFields

            VStack {

                signInButton

                Text("OR")
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(.gray)

                // add google photo
                googleButton
                    .foregroundColor(.brown)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(Color.brown, lineWidth: 2)
                    )
                    .background(.clear)
                    .cornerRadius(35)

                SignInWithAppleButton { request in
                    let nonce =  viewModel.randomNonceString()
                    viewModel.currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                } onCompletion: { result in
                    viewModel.signInWithApple(result: result) { user in
                        chattingViewModel.currentUser = user
                        chattingViewModel.getChats()
                        channelViewModel.currentUser = user
                        channelViewModel.getChannels()
                        Haptics.shared.notify(.success)
                    }
                }
                .frame(width: 280, height: 45, alignment: .center)

            }

            Spacer()

        }
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .overlay {
            customAlert
        }
        .overlay {
            if viewModel.isShowLoader {
                withAnimation {
                    GeometryReader { reader in
                        Loader()
                            .position(x: reader.size.width/2, y: reader.size.height/2)
                    }.background {
                        Color.black
                            .opacity(0.65)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
        }
        .addRightGestureRecognizer {
            if alertText == nil {
                withAnimation {
                    self.isPresented = false
                }
            }
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder private var inputFields: some View {
        VStack {
            Group {
                HStack {
                    Image(systemName: "mail")
                        .foregroundColor(.gray)

                    TextField("Email", text: $email)
                        .focused($focusedField, equals: .emailField)
                        .submitLabel(.next)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit({
                            self.focusedField = .passwordField
                        })
                        .onChange(of: email) { _ in
                            updateButton()
                        }
                }

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)

                    if self.isShowingPassword {

                        TextField("Password", text: $password)
                            .focused($focusedField, equals: .passwordField)
                            .textContentType(.password)
                            .submitLabel(.done)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onSubmit({
                                focusedField = nil
                            })
                            .onChange(of: password) { _ in
                                updateButton()
                            }
                        Button {
                            self.isShowingPassword.toggle()
                        } label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                        }
                    } else {
                        SecureField("Password", text: $password)
                            .focused($focusedField, equals: .passwordField)
                            .submitLabel(.done)
                            .disableAutocorrection(true)
                            .onSubmit({
                                focusedField = nil
                            })
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
            }
            .padding()
            .padding(.horizontal, 20)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                    .padding(5)
            )
        }
    }

    @ViewBuilder private var signInButton: some View {
        Button {
            signInButtonTapped()
        } label: {
            Text("Sign in")
                .toButtonGradientStyle()
                .padding(.horizontal, 80)
                .opacity(isButtonDisabled ? 0.6 : 1 )

        }

    }

    @ViewBuilder private var customAlert: some View {
        if viewModel.alertText != nil {
            CustomAlert(text: $viewModel.alertText, type: .failure)
        } else if alertText != nil {
            CustomAlert(text: $alertText, type: .failure)
        }
    }

    @ViewBuilder private var googleButton: some View {
        Button {
            googleButtonTapped()
        } label: {
            Image("google")
                .resizable()
                .frame(width: 32, height: 32)
        }
    }

    // MARK: - Functions

    func signInButtonTapped() {
        focusedField = nil
        if isButtonDisabled {
            withAnimation(.easeInOut) {
                if email.isEmpty || !email.contains("@gmail.com") {
                    alertText = "Please, type correctly your email address. We need it to authenticate you."
                } else if password.count < 8 {
                    alertText = "Your password must be at least 8 characters long."
                }
            }
        } else {
            viewModel.signIn(email: self.email, password: self.password) { user in
                chattingViewModel.currentUser = user
                chattingViewModel.getChats()
                channelViewModel.currentUser = user
                channelViewModel.getChannels()
                presenceViewModel.startSetup(user: user)
                Haptics.shared.notify(.success)
            }
        }
    }

    func googleButtonTapped() {
        // handle singin

        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) {[self] user, error in

            if error != nil {
                self.alertText = error?.localizedDescription ?? ""
                print("failed to signIn with google: \(error?.localizedDescription ?? "")")
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

            viewModel.signIn(credential: credential) { user in
                chattingViewModel.currentUser = user
                chattingViewModel.getChats()
                channelViewModel.currentUser = user
                channelViewModel.getChannels()
                Haptics.shared.notify(.success)
            }
        }
    }

    private func updateButton() {
        let time: Double = 0.3
        withAnimation(.easeInOut(duration: time)) {
            if email.isEmpty || password.isEmpty || password.count < 8 || !email.contains("@gmail.com") {
                isButtonDisabled = true
            } else {
                isButtonDisabled = false
            }
        }
    }

}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(isPresented: .constant(true))
            .environmentObject(UserViewModel())
    }

}

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }
}
