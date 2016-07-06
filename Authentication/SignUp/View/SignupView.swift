//
//  SignupViewType.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/18/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

public protocol SignupViewType: Renderable, SignupFormType {

    var titleLabel: UILabel { get }
    
    var loginLabel: UILabel? { get }
    var loginButton: UIButton? { get }
    
}

internal final class SignupView: UIView, SignupViewType {
    
    internal lazy var delegate: SignupViewDelegate = DefaultSignupViewDelegate()
    
    internal var titleLabel: UILabel { return titleLabelOutlet }
    @IBOutlet weak var titleLabelOutlet: UILabel! {
        didSet {
            titleLabel.text = titleText
        }
    }

    internal var usernameLabel: UILabel? { return .None }
    internal var usernameTextField: UITextField? { return .None }
    internal var usernameValidationMessageLabel: UILabel? { return .None }
    
    internal var emailLabel: UILabel? { return .None }
    internal var emailTextField: UITextField { return emailTextFieldOutlet }
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    internal var emailValidationMessageLabel: UILabel? { return emailValidationMessageLabelOutlet }
    @IBOutlet weak var emailValidationMessageLabelOutlet: UILabel!
    
    internal var passwordLabel: UILabel? { return .None }
    internal var passwordTextField: UITextField { return passwordTextFieldOutlet }
    @IBOutlet weak var passwordTextFieldOutlet: UITextField!
    internal var passwordValidationMessageLabel: UILabel? { return passwordValidationMessageLabelOutlet }
    @IBOutlet weak var passwordValidationMessageLabelOutlet: UILabel!
    internal var passwordVisibilityButton: UIButton? { return passwordVisibilityButtonOutlet }
    @IBOutlet weak var passwordVisibilityButtonOutlet: UIButton!
    
    internal var passwordConfirmLabel: UILabel? { return .None }
    internal var passwordConfirmTextField: UITextField? { return .None }
    internal var passwordConfirmValidationMessageLabel: UILabel? { return .None }
    internal var passwordConfirmVisibilityButton: UIButton? { return .None }
    
    internal var signupButton: UIButton { return signupButtonOutlet }
    @IBOutlet weak var signupButtonOutlet: UIButton!
    internal var signupErrorLabel: UILabel? { return .None }
    
    internal var termsAndServicesLabel: UILabel? { return termsAndServicesLabelOutlet }
    @IBOutlet weak var termsAndServicesLabelOutlet: UILabel! {
        didSet {
            termsAndServicesLabelOutlet.text = termsAndServicesLabelText
        }
    }
    internal var termsAndServicesButton: UIButton { return termsAndServicesButtonOutlet }
    @IBOutlet weak var termsAndServicesButtonOutlet: UIButton! {
        didSet {
            termsAndServicesButtonOutlet.setTitle(termsAndServicesButtonTitle, forState: .Normal)
        }
    }
    
    internal var loginLabel: UILabel? { return loginLabelOutlet }
    @IBOutlet weak var loginLabelOutlet: UILabel! {
        didSet {
            loginLabelOutlet.text = loginLabelText
        }
    }
    
    internal var loginButton: UIButton? { return loginButtonOutlet }
    @IBOutlet weak var loginButtonOutlet: UIButton! {
        didSet {
            loginButtonOutlet.setTitle(loginButtonTitle, forState: .Normal)
        }
    }

    internal var usernameTextFieldValid = false
    internal var usernameTextFieldSelected = false
    internal var emailTextFieldValid = false
    internal var emailTextFieldSelected = false
    internal var passwordTextFieldValid = false
    internal var passwordTextFieldSelected = false
    internal var showPassword = false
    internal var passwordConfirmationTextFieldValid = false
    internal var passwordConfirmationTextFieldSelected = false
    internal var showConfirmPassword = false
    internal var signupButtonEnabled = false
    internal var signupButtonPressed = false
    
    
    internal func render() {
        
        delegate.configureView(self)
        
    }
    
}

public extension SignupViewType {
    
    public var titleText: String {
        return "signup-view.title".localized
    }
    
    public var nameText: String {
        return "signup-view.name".localized
    }
    
    public var emailText: String {
        return "signup-view.email".localized
    }
    
    public var passwordText: String {
        return "signup-view.password".localized
    }
    
    public var confirmPasswordText: String {
        return "signup-view.confirm-password".localized
    }
    
    public var namePlaceholderText: String {
        return "signup-view.name-placeholder".localized
    }
    
    public var emailPlaceholderText: String {
        return "signup-view.email-placeholder".localized
    }
    
    public var passwordPlaceholderText: String {
        return "signup-view.password-placeholder".localized
    }
    
    public var confirmPasswordPlaceholderText: String {
        return "signup-view.confirm-password-placeholder".localized
    }
    
    public var termsAndServicesLabelText: String {
        return "signup-view.terms-and-services.label-text".localized
    }
    
    public var termsAndServicesButtonTitle: String {
        return "signup-view.terms-and-services.button-title".localized
    }

    public var signupButtonTitle: String {
        return "signup-view.signup-button-title".localized
    }
    
    private var loginLabelText: String {
        return "signup-view-model.login.label-text".localized
    }
    
    private var loginButtonTitle: String {
        return "signup-view-model.login.button-title".localized
    }
    
}
