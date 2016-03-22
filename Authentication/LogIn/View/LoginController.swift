//
//  LoginController.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/7/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Rex
import enum Result.NoError

/**
    Log In View Controller that takes care of managing the login, from
    validating email and password fields, to binding a login view to the
    view model and infoming a log in controller delegate when certain 
    events occur for it to act upon them.
    If there are more than one errors in a field, the controller presents
    only the first one.
 */
public final class LoginController: UIViewController {
    
    private let _viewModel: LoginViewModelType
    private let _loginViewFactory: () -> LoginViewType
    private let _delegate: LoginControllerDelegate

    public lazy var loginView: LoginViewType = self._loginViewFactory()
    
    private lazy var _notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    private var _disposable = CompositeDisposable()
    private let _keyboardDisplayed = MutableProperty(false)
    
    /**
        Initializes a login controller with the view model, delegate,
        a factory method for the login view and onRegister closure to use.
     
        - Params:
            - viewModel: view model to bind to and use.
            - loginViewFactory: factory method to call only once
            to get the login view to use.
            - delegate: delegate which adds behaviour to certain
            events, like handling a login error or selecting log
            in option, as handling register or recover password
            selection.
     
        - Returns: A valid login view controller ready to use.
     
    */
    init(viewModel: LoginViewModelType,
        loginViewFactory: () -> LoginViewType,
        delegate: LoginControllerDelegate) {
            _viewModel = viewModel
            _loginViewFactory = loginViewFactory
            _delegate = delegate
            super.init(nibName: nil, bundle: nil)
            addKeyboardObservers()
    }
    
    deinit {
        _disposable.dispose()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = loginView.view
    }

    
    public override func viewDidLoad() {
        loginView.render()
        bindViewModel()
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

private extension LoginController {
    
    func bindViewModel() {
        
        bindEmailElements()
        bindPasswordElements()
        bindButtons()
        
        _viewModel.logInExecuting.observeNext { [unowned self] executing in
            if executing {
                self._delegate.loginControllerWillExecuteLogIn(self)
            } else {
                self._delegate.loginControllerDidExecuteLogIn(self)
            }
        }
        
        _viewModel.logInErrors.observeNext { [unowned self] in self._delegate.loginController(self, didLogInWithError: $0) }
        
    }
    
    func bindEmailElements() {
        _viewModel.email <~ loginView.emailTextField.rex_textSignal
        loginView.emailLabel.text = _viewModel.emailText
        loginView.emailTextField.placeholder = _viewModel.emailPlaceholderText
        _viewModel.emailValidationErrors.signal.observeNext { [unowned self] errors in
            if errors.isEmpty {
                self._delegate.loginControllerDidPassEmailValidation(self)
            } else {
                self._delegate.loginController(self, didFailEmailValidationWithErrors: errors)
            }
        }
        if let emailValidationMessageLabel = loginView.emailValidationMessageLabel {
            emailValidationMessageLabel.rex_text <~ _viewModel.emailValidationErrors.signal.map { $0.first ?? " " }
        }
    }
    
    func bindPasswordElements() {
        _viewModel.password <~ loginView.passwordTextField.rex_textSignal
        loginView.passwordLabel.text = _viewModel.passwordText
        loginView.passwordTextField.placeholder = _viewModel.passwordPlaceholderText
        _viewModel.passwordValidationErrors.signal.observeNext { [unowned self] errors in
            if errors.isEmpty {
                self._delegate.loginControllerDidPassPasswordValidation(self)
            } else {
                self._delegate.loginController(self, didFailPasswordValidationWithErrors: errors)
            }

        }
        if let passwordValidationMessageLabel = loginView.passwordValidationMessageLabel {
            passwordValidationMessageLabel.rex_text <~ _viewModel.passwordValidationErrors.signal.map { $0.first ?? " " }
        }
        if let passwordVisibilityButton = loginView.passwordVisibilityButton {
            passwordVisibilityButton.rex_title <~ _viewModel.showPassword.producer.map { [unowned self] _ in
                self._viewModel.passwordVisibilityButtonTitle
            }
            passwordVisibilityButton.rex_pressed.value = _viewModel.togglePasswordVisibility.unsafeCocoaAction
            _viewModel.showPassword.signal.observeNext { [unowned self] showPassword in
                self.loginView.showPassword = showPassword
            }
        }
    }
    
    func bindButtons() {
        loginView.logInButton.setTitle(_viewModel.loginButtonTitle, forState: .Normal)
        loginView.logInButton.rex_pressed.value = _viewModel.logInCocoaAction
        loginView.logInButtonEnabled = false
        loginView.logInButton.rex_enabled.signal.observeNext { [unowned self] in self.loginView.logInButtonEnabled = $0 }
        
        loginView.registerButton.setTitle(_viewModel.registerButtonTitle, forState: .Normal)
        loginView.registerButton.setAction { [unowned self] _ in self._delegate.onRegister(self) }
        
        loginView.recoverPasswordButton.setTitle(_viewModel.recoverPasswordButtonTitle, forState: .Normal)
        loginView.recoverPasswordButton.setAction { [unowned self] _ in self._delegate.onRecoverPassword(self) }
    }
    
}

extension LoginController {
    
    public func addKeyboardObservers() {
        _disposable += _keyboardDisplayed <~ _notificationCenter
            .rac_notifications(UIKeyboardDidHideNotification)
            .map { _ in false }
        
        _disposable += _notificationCenter
            .rac_notifications(UIKeyboardWillShowNotification)
            .startWithNext { [unowned self] notification in self.keyboardWillShow(notification) }
        
        _disposable += _notificationCenter
            .rac_notifications(UIKeyboardWillHideNotification)
            .startWithNext { [unowned self] _ in self.view.frame.origin.y = 0 }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if !_keyboardDisplayed.value {
                _keyboardDisplayed.value = true
                let keyboardOffset = keyboardSize.height
                let emailOffset = loginView.emailTextField.convertPoint(loginView.emailTextField.frame.origin, toView: self.view).y - 10
                if emailOffset > keyboardOffset {
                    self.view.frame.origin.y -= keyboardOffset
                } else {
                    self.view.frame.origin.y -= emailOffset
                }
                let navBarOffset = (self.navigationController?.navigationBarHidden ?? true) ? 0 : self.navigationController?.navigationBar.frame.size.height ?? 0
                self.view.frame.origin.y += navBarOffset
            }
        }
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        if _keyboardDisplayed.value {
            _keyboardDisplayed.value = false
            self.view.endEditing(true)
        }
    }
    
}

public extension SessionServiceError {
    var message: String {
        switch self {
        case .InvalidCredentials(let error):
            return "login-error.invalid-credentials.message".localized + (error?.localizedDescription ?? "")
        case .NetworkError(let error):
            return "login-error.network-error.message".localized + error.localizedDescription
        }
    }
}
