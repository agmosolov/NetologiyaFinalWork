//
//  RegistrationViewController.swift
//  NetologiyaFinalWork
//
//  Created by Александр Мосолов on 16.12.2025.
//

import Foundation

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    private let mainStack = UIStackView()
    
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let registerBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
    }

    private func setupUI() {
        
    
        self.navigationItem.title = "Регистрация"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
        
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        
        [usernameField, passwordField, confirmPasswordField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 5
            $0.layer.borderColor = UIColor.darkGray.cgColor
            $0.layer.borderWidth = 0.2
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
            $0.leftViewMode = .always
            $0.adjustsFontSizeToFitWidth = true
        }
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.distribution = .fillEqually
        
        
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(usernameField)
        mainStack.addArrangedSubview(passwordField)
        mainStack.addArrangedSubview(confirmPasswordField)
        mainStack.addArrangedSubview(registerBtn)
        
        usernameField.placeholder = "Придумайте логин"
        usernameField.font = UIFont.systemFont(ofSize: 14)
        
        passwordField.placeholder = "Придумайте пароль"
        passwordField.isSecureTextEntry = true
        passwordField.font = UIFont.systemFont(ofSize: 14)
        
        confirmPasswordField.placeholder = "Повторите пароль"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.font = UIFont.systemFont(ofSize: 14)
        
        registerBtn.setTitle("Зарегистрироваться", for: .normal)
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.borderColor = UIColor.darkGray.cgColor
        registerBtn.layer.borderWidth = 0
        registerBtn.backgroundColor = .systemBlue.withAlphaComponent(0.25)
        registerBtn.setTitleColor(.darkGray, for: .normal)
        registerBtn.layer.shadowColor = UIColor.black.cgColor
        registerBtn.layer.shadowOpacity = 0.1
        registerBtn.layer.shadowRadius = 2
        registerBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        registerBtn.layer.masksToBounds = false

        
        let padding: CGFloat = 50
        let mainStackTopPadding = view.safeAreaLayoutGuide.layoutFrame.height * 0.1
        
        
        NSLayoutConstraint.activate([
            
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: mainStackTopPadding),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            mainStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
            
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    @objc private func dismissKeyboard() {
           view.endEditing(true)
       }

    @objc private func registerTapped() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmPasswordField.text ?? ""

        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard password.count >= 6 else { return }
        guard password == confirm else { return }

        AuthService.shared.register(username: trimmed, password: password)
        // переход осуществляйте через уведомление/делегат как обсуждали ранее
        NotificationCenter.default.post(name: NSNotification.Name("RegistrationDidSucceed"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}
