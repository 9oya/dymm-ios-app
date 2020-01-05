//
//  AuthController.swift
//  Dymm
//
//  Created by eunsang lee on 23/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire
import SkyFloatingLabelTextField
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var topBarView: UIView!
    var formContainerView: UIView!
    var formGrayLineView: UIView!
    
    // UITextField
    var firstNameTextField: SkyFloatingLabelTextField!
    var lastNameTextField: SkyFloatingLabelTextField!
    var emailTextField: SkyFloatingLabelTextField!
    var passwordTextField: SkyFloatingLabelTextField!
    var confirmPassTextField: SkyFloatingLabelTextField!
    
    // UIButton
    var forgotButton: UIButton!
    var closeButton: UIButton!
    var formSwapButton: UIButton!
    var submitButton: UIButton!
    var fbLoginBtn: FBLoginButton!
    var gSignInBtn: GIDSignInButton!
    
    // UILabel
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
    // UIImageView
    var illustGirlImgView: UIImageView!
    
    // NSLayoutConstraint
    var formContainerTop: NSLayoutConstraint!
    var formContainerHeight: NSLayoutConstraint!
    var emailTextFieldTop: NSLayoutConstraint!

    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var isSignUpForm = false
    var lastEditedTxtField = 0
    var emailToFind: String?
    var verifCode: String?
    var newPassword: String?
    var confPassword: String?
    var isEmailFound = true
    var isCodeCorrect = true
    var fbParams: Parameters?
    var gParams: Parameters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        view.hideSpinner()
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .purple_B847FF
        present(alert, animated: true, completion: nil)
    }
    
    @objc func alertFindEmail() {
        var title = lang.titleForgotPasswordAlert
        if !isEmailFound {
            title = lang.titleEmailNotFound
        }
        let alert = UIAlertController(title: title, message: "\n" + lang.msgMailEnter, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleSubmit, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.emailToFind = text
                self.findEmail()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in
            self.isEmailFound = true
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .emailAddress
            textField.placeholder = self.lang.titleEmail
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                confirmAction.isEnabled = textField.text!.count > 0 && textField.text!.isValidEmail()
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertFoundEmailCompl() {
        let alert = UIAlertController(title: lang.titleEmailFound, message: "\n" + lang.msgMailSendValidCode(emailToFind!), preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleSend, style: .default) { _ in
            self.sendVerificationCodeToMail()
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertVerificationCode() {
        var title = lang.titleEmailValidCode
        if !isCodeCorrect {
            title = lang.titleIncorrectEmailCode
        }
        let alert = UIAlertController(title: title, message: "\n" + lang.msgValidCodeEnter, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleSubmit, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.verifCode = text
                self.verifyEmailCode()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in
            self.isCodeCorrect = true
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .allCharacters
            textField.keyboardType = .default
            textField.placeholder = self.lang.titleVerifCode
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                confirmAction.isEnabled = textField.text!.count > 5
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertChangePassword() {
        let alert = UIAlertController(title: lang.titlePasswordChange, message: "\n" + lang.msgShortPassword, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleSubmit, style: .default) { _ in
            self.changePassword()
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in
            self.isCodeCorrect = true
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .default
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textField.placeholder = self.lang.titlePasswordNew
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                self.newPassword = textField.text!
                if self.newPassword!.count >= 8 && self.newPassword == self.confPassword {
                    confirmAction.isEnabled = true
                }
            }
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .default
            textField.textContentType = .newPassword
            textField.isSecureTextEntry = true
            textField.placeholder = self.lang.titlePasswordConfirm
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                self.confPassword = textField.text!
                if self.newPassword!.count >= 8 && self.newPassword == self.confPassword {
                    confirmAction.isEnabled = true
                }
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertChangePasswordCompl() {
        self.view.hideSpinner()
        let alert = UIAlertController(title: lang.titlePasswordChangeCompl, message: "\n" + lang.msgChangePasswordCompl, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            return
        }
        alert.addAction(confirmAction)
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func formSwapButtonTapped() {
        if isSignUpForm {
            UIView.animate(withDuration: 0.5, animations: {
                self.formContainerHeight.constant = 260
                self.emailTextFieldTop.constant = 10
                self.firstNameTextField.isHidden = true
                self.lastNameTextField.isHidden = true
                self.confirmPassTextField.isHidden = true
                self.view.layoutIfNeeded()
            })
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = self.lang.titleSignIn
                self.formSwapButton.setTitle("\u{021C5}" + self.lang.titleSignUp.uppercased(), for: .normal)
            })
            isSignUpForm = false
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.formContainerHeight.constant = 425
                self.emailTextFieldTop.constant = 120
                self.firstNameTextField.isHidden = false
                self.lastNameTextField.isHidden = false
                self.confirmPassTextField.isHidden = false
                self.view.layoutIfNeeded()
            })
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = self.lang.titleSignUp
                self.formSwapButton.setTitle("\u{021C5}" + self.lang.titleSignIn.uppercased(), for: .normal)
            })
            isSignUpForm = true
        }
    }
    
    @objc func submitButtonTapped() {
        if isSignUpForm {
            accountSignUp()
        } else {
            accountSignIn()
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        UIView.animate(withDuration: 0.7) {
            self.formContainerTop.constant = CGFloat(topBarHeightInt + marginInt)
            self.view.layoutIfNeeded()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case firstNameTextField:
            if lastEditedTxtField < 3 {
                return
            }
            lastEditedTxtField = 0
            UIView.animate(withDuration: 0.7) {
                self.formContainerTop.constant = CGFloat(topBarHeightInt + marginInt)
                self.view.layoutIfNeeded()
            }
        case lastNameTextField:
            if lastEditedTxtField < 3 {
                return
            }
            lastEditedTxtField = 1
            UIView.animate(withDuration: 0.7) {
                self.formContainerTop.constant = CGFloat(topBarHeightInt + marginInt)
                self.view.layoutIfNeeded()
            }
        case emailTextField:
            if lastEditedTxtField < 3 {
                return
            }
            lastEditedTxtField = 2
            if isSignUpForm {
                UIView.animate(withDuration: 0.7) {
                    self.formContainerTop.constant = CGFloat(topBarHeightInt + marginInt)
                    self.view.layoutIfNeeded()
                }
            }
        case passwordTextField:
            if lastEditedTxtField < 3 {
                lastEditedTxtField = 3
                if isSignUpForm {
                    UIView.animate(withDuration: 0.7) {
                        self.formContainerTop.constant = 667 / UIScreen.main.bounds.height
                        self.view.layoutIfNeeded()
                    }
                }
            }
        case confirmPassTextField:
            lastEditedTxtField = 4
            UIView.animate(withDuration: 0.7) {
                self.formContainerTop.constant = -(33350 / UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            }
        default:
            return
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case emailTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string).isValidEmail()) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgFloatingInvalidEmail
            }
        case passwordTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string).count >= 8) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgShortPassword
            }
        case confirmPassTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string) == passwordTextField.text) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgFloatingMismatchConfirmPassword
            }
        default:
            return true
        }
        return true
    }
}

extension AuthViewController: LoginButtonDelegate {
    
    // MARK: Facebook login
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error)
        }
        if let result = result {
            if result.isCancelled {
                print("fb login cancelled")
            } else {
                print("fb login success")
                fetchFbAccessToken()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("logged out")
    }
}

extension AuthViewController: GIDSignInDelegate {
    
    // MARK: Google sign in
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            self.gParams = [
                "email": user.profile.email!,
                "first_name": user.profile.givenName ?? "Noob",
                "last_name": user.profile.familyName ?? user.profile.givenName!,
                "language_id": getDeviceLanguage()
            ]
            self.signWithGoogle()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("User has disconnected")
    }
}

extension AuthViewController {
    
    // MARK: Private methods
    
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor.whiteSmoke
        
        // Initialize subveiw properties
        topBarView = getAddtionalTopBarView()
        forgotButton = getBasicTextButton()
        forgotButton.setTitle(lang.titleForgotPassword, for: .normal)
        forgotButton.addTarget(self, action: #selector(alertFindEmail), for: .touchUpInside)
        closeButton = getCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        formGrayLineView = getGrayLineView()
        formContainerView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.addShadowView()
            _view.layer.cornerRadius = 10.0
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        titleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 25, weight: .bold)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .center
            _label.text = lang.titleSignIn
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        firstNameTextField = {
            let _textField = SkyFloatingLabelTextField()
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.selectedTitleColor = .green_3ED6A7
            _textField.selectedLineColor = .green_3ED6A7
            _textField.errorColor = .red_FF7187
            _textField.selectedLineHeight = 1
            _textField.placeholder = lang.titleFirstName
            _textField.title = lang.titleFirstName
            _textField.autocapitalizationType = .words
            _textField.autocorrectionType = .no
            _textField.keyboardType = .default
            _textField.isHidden = true
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        lastNameTextField = {
            let _textField = SkyFloatingLabelTextField()
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.selectedTitleColor = .green_3ED6A7
            _textField.selectedLineColor = .green_3ED6A7
            _textField.errorColor = .red_FF7187
            _textField.placeholder = lang.titleLastName
            _textField.title = lang.titleLastName
            _textField.autocapitalizationType = .words
            _textField.autocorrectionType = .no
            _textField.isHidden = true
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        emailTextField = {
            let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.selectedTitleColor = .green_3ED6A7
            _textField.selectedLineColor = .green_3ED6A7
            _textField.errorColor = .red_FF7187
            _textField.placeholder = lang.titleEmail
            _textField.title = lang.titleEmail
            _textField.textContentType = .emailAddress
            _textField.keyboardType = .emailAddress
            _textField.autocorrectionType = .no
            _textField.autocapitalizationType = .none
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        passwordTextField = {
            let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.selectedTitleColor = .green_3ED6A7
            _textField.selectedLineColor = .green_3ED6A7
            _textField.errorColor = .red_FF7187
            _textField.placeholder = lang.titlePassword
            _textField.title = lang.titlePassword
            _textField.isSecureTextEntry = true
            _textField.textContentType = .password
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        confirmPassTextField = {
            let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.selectedTitleColor = .green_3ED6A7
            _textField.selectedLineColor = .green_3ED6A7
            _textField.errorColor = .red_FF7187
            _textField.placeholder = lang.titlePasswordConfirm
            _textField.title = lang.titlePasswordConfirm
            _textField.isSecureTextEntry = true
            _textField.textContentType = .password
            _textField.isHidden = true
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        messageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textColor = .red_FF7187
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        formSwapButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.green_3ED6A7, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            _button.setTitle("\u{021C5}" + lang.titleSignUp.uppercased(), for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(formSwapButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        submitButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.green_3ED6A7, for: .normal)
            _button.setTitle(lang.titleSubmit.uppercased(), for: .normal)
            _button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
            _button.titleLabel?.font = .systemFont(ofSize: 16)
            _button.showsTouchWhenHighlighted = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        fbLoginBtn = {
            let _fbButton = FBLoginButton(frame: .zero, permissions: [.publicProfile, .email])
            _fbButton.addShadowView()
            _fbButton.translatesAutoresizingMaskIntoConstraints = false
            return _fbButton
        }()
        gSignInBtn = {
            let _gButton = GIDSignInButton()
            _gButton.addShadowView()
            _gButton.style = .wide
            _gButton.translatesAutoresizingMaskIntoConstraints = false
            return _gButton
        }()
        illustGirlImgView = {
            let _imageView = UIImageView()
            _imageView.image = .itemIllustGirl1
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        fbLoginBtn.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        
        // Setup subviews
        view.addSubview(illustGirlImgView)
        view.addSubview(formContainerView)
        view.addSubview(fbLoginBtn)
        view.addSubview(gSignInBtn)
        view.addSubview(topBarView)
        
        topBarView.addSubview(forgotButton)
        
        formContainerView.addSubview(titleLabel)
        formContainerView.addSubview(firstNameTextField)
        formContainerView.addSubview(lastNameTextField)
        formContainerView.addSubview(emailTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(confirmPassTextField)
        formContainerView.addSubview(messageLabel)
        formContainerView.addSubview(formSwapButton)
        formContainerView.addSubview(submitButton)
        formContainerView.addSubview(formGrayLineView)
        
        // Setup constraints
        topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        topBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        topBarView.heightAnchor.constraint(equalToConstant: CGFloat(topBarHeightInt)).isActive = true
        
        forgotButton.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 0).isActive = true
        forgotButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
        forgotButton.bottomAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 0).isActive = true
        
        illustGirlImgView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        illustGirlImgView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        formContainerTop = formContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(topBarHeightInt + marginInt))
        formContainerTop.priority = UILayoutPriority(rawValue: 999)
        formContainerTop.isActive = true
        formContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        formContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        formContainerHeight = formContainerView.heightAnchor.constraint(equalToConstant: 260)
        formContainerHeight.priority = UILayoutPriority(rawValue: 999)
        formContainerHeight.isActive = true
        
        fbLoginBtn.topAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 15).isActive = true
        fbLoginBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        gSignInBtn.topAnchor.constraint(equalTo: fbLoginBtn.bottomAnchor, constant: 15).isActive = true
        gSignInBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: 0).isActive = true
        
        firstNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        firstNameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        firstNameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10).isActive = true
        lastNameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        lastNameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        lastNameTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        emailTextFieldTop = emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        emailTextFieldTop.priority = UILayoutPriority(rawValue: 999)
        emailTextFieldTop.isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        confirmPassTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        confirmPassTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        confirmPassTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        confirmPassTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        messageLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 10).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -10).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: formGrayLineView.topAnchor, constant: -10).isActive = true
        
        formGrayLineView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 13)).isActive = true
        formGrayLineView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 13)).isActive = true
        formGrayLineView.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -60).isActive = true
        formGrayLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        formSwapButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 0).isActive = true
        formSwapButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 0).isActive = true
        formSwapButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 14).isActive = true
        formSwapButton.heightAnchor.constraint(equalToConstant: 59).isActive = true
        
        submitButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: 0).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 0).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 14).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 59).isActive = true
    }
    
    private func displayErrorMessage(_ message: String) {
        messageLabel.text = message
        UIView.transition(with: messageLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.messageLabel.isHidden = false
        })
    }
    
    private func unauthorized(_ pattern: Int) {
        switch pattern {
        case UnauthType.mailInvalid:
            displayErrorMessage(lang.msgUnauthInvalidEmail)
        case UnauthType.mailDuplicated:
            displayErrorMessage(lang.msgUnauthDuplicatedEmail)
        case UnauthType.passwordInvalid:
            displayErrorMessage(lang.msgUnauthInvalidPassword)
        default:
            fatalError()
        }
        if self.formContainerView.isHidden {
            self.view.hideSpinner()
            UIView.transition(with: formContainerView, duration: 0.6, options: .transitionCrossDissolve, animations: {
                self.formContainerView.isHidden = false
                self.fbLoginBtn.isHidden = false
                self.gSignInBtn.isHidden = false
            })
        } else {
            self.view.showSpinner()
            UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.formContainerView.isHidden = true
                self.fbLoginBtn.isHidden = true
                self.gSignInBtn.isHidden = true
            })
        }
    }
    
    private func accountSignIn() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        guard email.count > 0 else {
            displayErrorMessage(lang.msgEmptyEmail)
            return
        }
        guard email.isValidEmail() else {
            displayErrorMessage(lang.msgInvalidEmail)
            return
        }
        guard password.count > 0 else {
            displayErrorMessage(lang.msgEmptyPassword)
            return
        }
        guard password.count >= 8 else {
            displayErrorMessage(lang.msgShortPassword)
            return
        }
        var params: Parameters = [
            "email": email,
            "password": password
        ]
        let avatar_id = UserDefaults.standard.integer(forKey: email)
        if avatar_id > 0 {
            params["id"] = avatar_id
        }
        self.view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let service = Service(lang: lang)
        service.authOldAvatar(params: params, unauthorized: { pattern in
            self.unauthorized(pattern)
        }, popoverAlert: { message in
            self.retryFunction = self.accountSignIn
            self.alertError(message)
        }) { (auth) in
            let _avatar = auth.avatar
            UserDefaults.standard.setIsEmailConfirmed(value: _avatar.is_confirmed)
            UserDefaults.standard.setAccessToken(value: _avatar.access_token!)
            UserDefaults.standard.setRefreshToken(value: _avatar.refresh_token!)
            UserDefaults.standard.setAvatarId(value: _avatar.id)
            UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
            UserDefaults.standard.setIsSignIn(value: true)
            UserDefaults.standard.setIsSignInChanged(value: true)
            UserDefaults.standard.set(_avatar.id, forKey: _avatar.email)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func afterSignUp(_ auth: CustomModel.Auth) {
        view.hideSpinner()
        let _avatar = auth.avatar
        UserDefaults.standard.setIsEmailConfirmed(value: _avatar.is_confirmed)
        UserDefaults.standard.setAccessToken(value: _avatar.access_token!)
        UserDefaults.standard.setRefreshToken(value: _avatar.refresh_token!)
        UserDefaults.standard.setAvatarId(value: _avatar.id)
        UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
        UserDefaults.standard.setIsSignIn(value: true)
        UserDefaults.standard.setIsSignInChanged(value: true)
        UserDefaults.standard.set(_avatar.id, forKey: _avatar.email)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func accountSignUp() {
        guard let first_name = firstNameTextField.text,
            let last_name = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPassTextField.text else {
                return
        }
        guard first_name.count > 0 else {
            displayErrorMessage(lang.msgEmptyName)
            return
        }
        guard email.count > 0 else {
            displayErrorMessage(lang.msgEmptyEmail)
            return
        }
        guard email.isValidEmail() else {
            displayErrorMessage(lang.msgInvalidEmail)
            return
        }
        guard password.count > 0 else {
            displayErrorMessage(lang.msgEmptyPassword)
            return
        }
        guard password.count >= 8 else {
            displayErrorMessage(lang.msgShortPassword)
            return
        }
        guard passwordTextField.text == confirmPassword else {
            displayErrorMessage(lang.msgMismatchConfirmPassword)
            return
        }
        let params: Parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "password": password,
            "language_id": getDeviceLanguage()
        ]
        self.view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let service = Service(lang: lang)
        service.createNewAvatar(params: params, unauthorized: { pattern in
            self.unauthorized(pattern)
        }, popoverAlert: { (message) in
            self.retryFunction = self.accountSignUp
            self.alertError(message)
        }) { (auth) in
            self.afterSignUp(auth)
        }
    }
    
    private func findEmail() {
        let params: Parameters = [
            "email": emailToFind!
        ]
        let service = Service(lang: lang)
        service.solveAvatarEmail(option: MailOption.find,params: params, unauthorized: {
            self.isEmailFound = false
            self.alertFindEmail()
        }, popoverAlert: { (message) in
            self.retryFunction = self.findEmail
            self.alertError(message)
        }) {
            self.isEmailFound = true
            self.alertFoundEmailCompl()
        }
    }
    
    private func sendVerificationCodeToMail() {
        self.view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let params: Parameters = [
            "email": emailToFind!,
            "language_id": lang.currentLanguageId!
        ]
        let service = Service(lang: lang)
        service.solveAvatarEmail(option: MailOption.verify, params: params, unauthorized: {
            return
        }, popoverAlert: { (message) in
            self.retryFunction = self.sendVerificationCodeToMail
            self.alertError(message)
        }) {
            self.isCodeCorrect = true
            UIView.transition(with: self.formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.formContainerView.isHidden = false
                self.fbLoginBtn.isHidden = false
                self.gSignInBtn.isHidden = false
                self.view.hideSpinner()
            })
            self.alertVerificationCode()
        }
    }
    
    private func verifyEmailCode() {
        self.view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let params: Parameters = [
            "email": emailToFind!,
            "code": verifCode!
        ]
        let service = Service(lang: lang)
        service.solveAvatarEmail(option: MailOption.code, params: params, unauthorized: {
            self.isCodeCorrect = false
            self.alertVerificationCode()
        }, popoverAlert: { (message) in
            self.retryFunction = self.verifyEmailCode
            self.alertError(message)
        }) {
            self.isCodeCorrect = true
            UIView.transition(with: self.formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.formContainerView.isHidden = false
                self.fbLoginBtn.isHidden = false
                self.gSignInBtn.isHidden = false
                self.view.hideSpinner()
            })
            self.alertChangePassword()
        }
    }
    
    private func changePassword() {
        self.view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let params: Parameters = [
            "email": emailToFind!,
            "target": TagId.password,
            "new_info": confPassword!
        ]
        let service = Service(lang: lang)
        service.putAvatarInfo(params: params, unauthorized: { (pattern) in
            print(pattern)
        }, popoverAlert: { (message) in
            self.retryFunction = self.changePassword
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.changePassword()
        }) { (newInfoTxt) in
            UIView.transition(with: self.formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.formContainerView.isHidden = false
                self.fbLoginBtn.isHidden = false
                self.gSignInBtn.isHidden = false
                self.view.hideSpinner()
            })
            self.alertChangePasswordCompl()
        }
    }
    
    private func fetchFbAccessToken() {
        if let fbAccessToken = AccessToken.current {
            // Case user signed with facebook
            // parameters: gender, picture.type(large)
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name"], tokenString: fbAccessToken.tokenString, version: nil, httpMethod: .get)
            req.start { (connection, result, error) in
                if let error = error {
                    print("error \(error)")
                } else {
                    let jsonResult = result! as! Dictionary<String, AnyObject>
                    self.fbParams = [
                        "fb_id": jsonResult["id"]!,
                        "first_name": jsonResult["first_name"]!,
                        "last_name": jsonResult["last_name"]!,
                        "language_id": getDeviceLanguage()
                    ]
                    if let email = jsonResult["email"] {
                        self.fbParams!["email"] = email
                    }
                    self.signWithFacebook()
                }
            }
        }
    }
    
    private func signWithFacebook() {
        view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let service = Service(lang: lang)
        service.authWithFacebook(params: self.fbParams!, popoverAlert: { (message) in
            self.retryFunction = self.signWithFacebook
            self.alertError(message)
        }) { (auth) in
            self.afterSignUp(auth)
        }
    }
    
    private func signWithGoogle() {
        view.showSpinner()
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.fbLoginBtn.isHidden = true
            self.gSignInBtn.isHidden = true
        })
        let service = Service(lang: lang)
        service.authWithGoogle(params: self.gParams!, popoverAlert: { (message) in
            self.retryFunction = self.signWithGoogle
            self.alertError(message)
        }) { (auth) in
            self.afterSignUp(auth)
        }
    }
}
