import UIKit

class AccountSettingsViewController: UIViewController {
    
    private var nicknameTextField: UITextField!
    private var currentPasswordTextField: UITextField!
    private var newPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
        setupKeyboardDismissal()
    }
    
    // Add stars removed by request (actually only background gradient remains)

    private func setupPixelBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 1.0).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        // Stars removed
    }
    
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        // Scroll View для поддержки клавиатуры
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Container View for the "Small Window" effect
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "НАСТРОЙКИ АККАУНТА"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 21, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Current username label
        let currentUserLabel = UILabel()
        currentUserLabel.text = "Текущий: \(Storage.shared.username ?? "Не указан")"
        currentUserLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        currentUserLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        currentUserLabel.textAlignment = .center
        currentUserLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(currentUserLabel)
        
        // Nickname Section
        let nicknameLabel = createLabel(text: "НОВЫЙ НИКНЕЙМ")
        containerView.addSubview(nicknameLabel)
        
        nicknameTextField = createTextField(placeholder: "Введите новый никнейм")
        containerView.addSubview(nicknameTextField)
        
        let changeNicknameButton = createPixelButton(
            title: "ИЗМЕНИТЬ НИК",
            color: UIColor(red: 0.4, green: 0.7, blue: 0.5, alpha: 1.0)
        )
        changeNicknameButton.addTarget(self, action: #selector(changeNicknameTapped), for: .touchUpInside)
        containerView.addSubview(changeNicknameButton)
        
        // Divider
        let divider1 = createDivider()
        containerView.addSubview(divider1)
        
        // Password Section
        let passwordLabel = createLabel(text: "ИЗМЕНИТЬ ПАРОЛЬ")
        containerView.addSubview(passwordLabel)
        
        currentPasswordTextField = createTextField(placeholder: "Текущий пароль")
        currentPasswordTextField.isSecureTextEntry = true
        containerView.addSubview(currentPasswordTextField)
        
        newPasswordTextField = createTextField(placeholder: "Новый пароль")
        newPasswordTextField.isSecureTextEntry = true
        containerView.addSubview(newPasswordTextField)
        
        let changePasswordButton = createPixelButton(
            title: "ИЗМЕНИТЬ ПАРОЛЬ",
            color: UIColor(red: 0.7, green: 0.5, blue: 0.4, alpha: 1.0)
        )
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        containerView.addSubview(changePasswordButton)
        
        // Divider
        let divider2 = createDivider()
        containerView.addSubview(divider2)

        // Back Button
        let backButton = createPixelButton(title: "НАЗАД", color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        containerView.addSubview(backButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            currentUserLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            currentUserLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            nicknameLabel.topAnchor.constraint(equalTo: currentUserLabel.bottomAnchor, constant: 25),
            nicknameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            nicknameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            
            nicknameTextField.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            nicknameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            nicknameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            changeNicknameButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 15),
            changeNicknameButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            changeNicknameButton.widthAnchor.constraint(equalToConstant: 200),
            changeNicknameButton.heightAnchor.constraint(equalToConstant: 45),
            
            divider1.topAnchor.constraint(equalTo: changeNicknameButton.bottomAnchor, constant: 20),
            divider1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            divider1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            divider1.heightAnchor.constraint(equalToConstant: 2),
            
            passwordLabel.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            passwordLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            
            currentPasswordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 10),
            newPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            newPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            changePasswordButton.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 15),
            changePasswordButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            changePasswordButton.widthAnchor.constraint(equalToConstant: 200),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 45),
            
            divider2.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 20),
            divider2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            divider2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            divider2.heightAnchor.constraint(equalToConstant: 2),

            backButton.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 20),
            backButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        textField.textColor = .white
        textField.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        textField.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0).cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }

    private func createPixelButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .black)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func changeNicknameTapped() {
        SoundManager.shared.playButtonSound()
        guard let newNickname = nicknameTextField.text, !newNickname.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите новый никнейм")
            return
        }
        
        // TODO: Call API to update nickname
        APIService.shared.updateNickname(newNickname: newNickname) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Storage.shared.username = newNickname
                    self?.showAlert(title: "Успех", message: "Никнейм успешно изменен")
                    self?.nicknameTextField.text = ""
                case .failure(let error):
                    self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func changePasswordTapped() {
        SoundManager.shared.playButtonSound()
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите текущий пароль")
            return
        }
        
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите новый пароль")
            return
        }
        
        guard newPassword.count >= 6 else {
            showAlert(title: "Ошибка", message: "Новый пароль должен быть не менее 6 символов")
            return
        }
        
        // TODO: Call API to update password
        APIService.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "Успех", message: "Пароль успешно изменен")
                    self?.currentPasswordTextField.text = ""
                    self?.newPasswordTextField.text = ""
                case .failure(let error):
                    self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    @objc private func backTapped() {
        SoundManager.shared.playButtonSound()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}
