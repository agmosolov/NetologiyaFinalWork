//
//  LogInViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 16.12.2025.
//

import Foundation
import UIKit

protocol LoginDelegate: AnyObject {
    func loginDidSucceed()
    func logoutRequested()
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: LoginDelegate?
    
    private var bottomConstraint: NSLayoutConstraint?
    
    private let mainStack = UIStackView()
    
    private let whiteStack1 = UIStackView()
    private let whiteStack2 = UIStackView()
    private let whiteStack3 = UIStackView()
    private let whiteStack4 = UIStackView()
    private let whiteStack5 = UIStackView()
    private let whiteStack6 = UIStackView()
    
    private let appLogoView = UIImageView()
    private let appNameLabel = UILabel()
    private let loginLabel = UILabel()
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
        self.navigationItem.title = ""
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        
        loginField.delegate = self
        passwordField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
        
        
        
        mainStack.axis = .vertical
        mainStack.distribution = .equalSpacing
        mainStack.spacing = 0
        mainStack.alignment = .center
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        appLogoView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        whiteStack1.translatesAutoresizingMaskIntoConstraints = false
        whiteStack2.translatesAutoresizingMaskIntoConstraints = false
        whiteStack3.translatesAutoresizingMaskIntoConstraints = false
        whiteStack4.translatesAutoresizingMaskIntoConstraints = false
        whiteStack5.translatesAutoresizingMaskIntoConstraints = false
        whiteStack6.translatesAutoresizingMaskIntoConstraints = false
        
        appLogoView.image = UIImage(named: "ForLaunchScreen")
        
        appNameLabel.text = "REGIME"
        appNameLabel.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        appNameLabel.textColor = .darkGray
        
        loginLabel.text = "Be in one's regime"
        loginLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        loginLabel.textColor = .lightGray
        loginLabel.textAlignment = .center
        
        loginField.placeholder = "Введите логин"
        loginField.layer.cornerRadius = 5
        loginField.layer.borderColor = UIColor.darkGray.cgColor
        loginField.layer.borderWidth = 0.2
        loginField.textAlignment = .left
        loginField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        loginField.leftViewMode = .always
        loginField.keyboardType = .asciiCapable
        loginField.autocorrectionType = .no
        loginField.autocapitalizationType = .none
        loginField.spellCheckingType = .no
        loginField.autocapitalizationType = .none
        loginField.textContentType = .username
        
        passwordField.placeholder = "Введите пароль"
        passwordField.isSecureTextEntry = true
        passwordField.layer.cornerRadius = 5
        passwordField.layer.borderColor = UIColor.darkGray.cgColor
        passwordField.layer.borderWidth = 0.2
        passwordField.textAlignment = .left
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        passwordField.leftViewMode = .always
        passwordField.keyboardType = .asciiCapable
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.spellCheckingType = .no
        passwordField.autocapitalizationType = .none
        passwordField.textContentType = .password
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderColor = UIColor.darkGray.cgColor
        loginButton.layer.borderWidth = 0
        loginButton.backgroundColor = .systemBlue.withAlphaComponent(0.25)
        loginButton.setTitleColor(.darkGray, for: .normal)
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.1
        loginButton.layer.shadowRadius = 2
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.masksToBounds = false
        
        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderColor = UIColor.darkGray.cgColor
        registerButton.layer.borderWidth = 0
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        registerButton.backgroundColor = .systemBlue.withAlphaComponent(0.25)
        registerButton.setTitleColor(.darkGray, for: .normal)
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.1
        registerButton.layer.shadowRadius = 2
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        registerButton.layer.masksToBounds = false
        
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(appLogoView)
        mainStack.addArrangedSubview(whiteStack1)
        mainStack.addArrangedSubview(appNameLabel)
        mainStack.addArrangedSubview(whiteStack2)
        mainStack.addArrangedSubview(loginLabel)
        mainStack.addArrangedSubview(whiteStack3)
        mainStack.addArrangedSubview(loginField)
        mainStack.addArrangedSubview(whiteStack4)
        mainStack.addArrangedSubview(passwordField)
        mainStack.addArrangedSubview(whiteStack5)
        mainStack.addArrangedSubview(loginButton)
        mainStack.addArrangedSubview(whiteStack6)
        mainStack.addArrangedSubview(registerButton)
        
        let padding: CGFloat = 50
        let mainStackTopPadding = view.safeAreaLayoutGuide.layoutFrame.height * 0.1
        
        // простые констрейнты (адаптируйте под стиль)
        NSLayoutConstraint.activate([
            
            
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: mainStackTopPadding),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            mainStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            
            appLogoView.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.2),
            whiteStack1.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.02),
            appNameLabel.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.12),
            whiteStack2.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.01),
            loginLabel.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.08),
            whiteStack3.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.01),
            loginField.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.10),
            whiteStack4.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.02),
            passwordField.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.10),
            whiteStack5.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.05),
            loginButton.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.13),
            whiteStack6.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.02),
            registerButton.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.13),
            
            appLogoView.widthAnchor.constraint(equalTo: appLogoView.heightAnchor),
            
            loginField.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 0),
            loginField.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: 0),
            passwordField.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 0),
            passwordField.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: 0),
            
            loginButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.8),
            registerButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.8)
        ])
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    @objc private func dismissKeyboard() {
           view.endEditing(true)
       }

       deinit {
           NotificationCenter.default.removeObserver(self)
       }

    @objc private func didTapLogin() {
        let username = loginField.text ?? ""
        let password = passwordField.text ?? ""
        if AuthService.shared.login(username: username, password: password) {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(username, forKey: "loggedUsername")
            NotificationCenter.default.post(name: NSNotification.Name("LoginDidSucceed"), object: nil)
        } else {
            // показать алерт об ошибке
            let alert = UIAlertController(title: "Ошибка входа",
                                          message: "Неверное имя пользователя или пароль.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func didTapRegister() {
        // переход к RegistrationViewController
        let regVC = RegistrationViewController()
        navigationController?.pushViewController(regVC, animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("RegisterDidTap"), object: nil)
    }
    
    private func logoutRequested() {
            delegate?.logoutRequested()
        }
}



