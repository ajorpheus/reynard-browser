//
//  AutoFillOverlay.swift
//  Reynard
//

import UIKit

final class AutoFillOverlay: UIView, UITextFieldDelegate {
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let containerView = UIView()
    private var onCredentials: ((String, String) -> Void)?

    init(onCredentials: @escaping (String, String) -> Void) {
        self.onCredentials = onCredentials
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        let titleLabel = UILabel()
        titleLabel.text = "AutoFill Password"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let hintLabel = UILabel()
        hintLabel.text = "Tap a field below, then use the password suggestion above the keyboard."
        hintLabel.font = .systemFont(ofSize: 13)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        usernameField.placeholder = "Username or Email"
        usernameField.textContentType = .username
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.borderStyle = .roundedRect
        usernameField.delegate = self
        usernameField.translatesAutoresizingMaskIntoConstraints = false

        passwordField.placeholder = "Password"
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.delegate = self
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        doneButton.setTitle("Fill", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, doneButton])
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, hintLabel, usernameField, passwordField, buttonStack])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stack)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),

            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            usernameField.heightAnchor.constraint(equalToConstant: 44),
            passwordField.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    func present(in parentView: UIView) {
        frame = parentView.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alpha = 0
        parentView.addSubview(self)

        UIView.animate(withDuration: 0.2) { self.alpha = 1 }
        usernameField.becomeFirstResponder()
    }

    @objc private func doneTapped() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        guard !password.isEmpty else { return }
        dismiss()
        onCredentials?(username, password)
        onCredentials = nil
    }

    @objc private func cancelTapped() {
        dismiss()
        onCredentials = nil
    }

    private func dismiss() {
        endEditing(true)
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }) { _ in
            self.removeFromSuperview()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else {
            doneTapped()
        }
        return false
    }
}
