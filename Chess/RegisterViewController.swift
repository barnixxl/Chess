
import UIKit

class RegisterViewController: UIViewController {
    var onSuccess: (() -> Void)?
    private var stars: [UIView] = []

    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let confirmButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
        setupKeyboardHandling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Создаем звезды асинхронно после появления экрана для лучшей производительности
        DispatchQueue.main.async { [weak self] in
            self?.setupStarAnimation()
        }
    }

    private func setupPixelBackground() {
        // Пиксельный градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.4, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.shouldRasterize = true // Оптимизация производительности
        gradientLayer.rasterizationScale = UIScreen.main.scale
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupStarAnimation() {
        // Оптимизация: создаем меньше звезд и более эффективно
        let starCount = 18 // Уменьшено с 28 для лучшей производительности
        
        var starViews: [UIView] = []
        for i in 0 ..< starCount {
            let star = UIView()
            let size: CGFloat = [4, 6, 8].randomElement()!
            star.frame = CGRect(
                x: CGFloat.random(in: 0 ... view.bounds.width),
                y: CGFloat.random(in: 0 ... view.bounds.height),
                width: size,
                height: size
            )
            star.backgroundColor = .white
            star.alpha = CGFloat.random(in: 0.3 ... 1.0)
            star.layer.shouldRasterize = true
            star.layer.rasterizationScale = UIScreen.main.scale
            starViews.append(star)
            stars.append(star)
        }
        
        // Добавляем все звезды одним пакетом
        for star in starViews {
            view.addSubview(star)
        }
        
        // Запускаем анимации с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            for (i, star) in starViews.enumerated() {
                let duration = Double.random(in: 1.5 ... 3.0)
                let delay = Double(i) * 0.05
                
                UIView.animate(withDuration: duration, delay: delay, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    star.alpha = CGFloat.random(in: 0.2 ... 1.0)
                }, completion: nil)
            }
        }
    }

    private func setupUI() {
        // Кнопка назад в пиксельном стиле
        let backButton = UIButton(type: .system)
        backButton.setTitle("← НАЗАД", for: .normal)
        backButton.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        backButton.setTitleColor(UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "РЕГИСТРАЦИЯ"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 42, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Пиксельная тень
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        view.addSubview(titleLabel)

        // Пиксельный контейнер для полей
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.9)
        containerView.layer.cornerRadius = 0
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = UIColor(red: 0.8, green: 0.3, blue: 0.6, alpha: 1.0).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Email поле в пиксельном стиле
        emailTextField.placeholder = "ИМЯ ПОЛЬЗОВАТЕЛЯ"
        emailTextField.textColor = .white
        emailTextField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        emailTextField.backgroundColor = UIColor(red: 0.15, green: 0.05, blue: 0.15, alpha: 1.0)
        emailTextField.layer.cornerRadius = 0
        emailTextField.layer.borderWidth = 3
        emailTextField.layer.borderColor = UIColor(red: 0.9, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        emailTextField.layer.shouldRasterize = true // Оптимизация
        emailTextField.layer.rasterizationScale = UIScreen.main.scale
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        emailTextField.smartQuotesType = .no
        emailTextField.smartDashesType = .no
        emailTextField.smartInsertDeleteType = .no
        emailTextField.keyboardType = .default
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "ИМЯ ПОЛЬЗОВАТЕЛЯ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        containerView.addSubview(emailTextField)

        // Password поле в пиксельном стиле
        passwordTextField.placeholder = "ПАРОЛЬ"
        passwordTextField.textColor = .white
        passwordTextField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        passwordTextField.backgroundColor = UIColor(red: 0.15, green: 0.05, blue: 0.15, alpha: 1.0)
        passwordTextField.layer.cornerRadius = 0
        passwordTextField.layer.borderWidth = 3
        passwordTextField.layer.borderColor = UIColor(red: 0.9, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        passwordTextField.layer.shouldRasterize = true // Оптимизация
        passwordTextField.layer.rasterizationScale = UIScreen.main.scale
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.spellCheckingType = .no
        passwordTextField.smartQuotesType = .no
        passwordTextField.smartDashesType = .no
        passwordTextField.smartInsertDeleteType = .no
        passwordTextField.returnKeyType = .next
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "ПАРОЛЬ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        containerView.addSubview(passwordTextField)

        // Confirm Password поле в пиксельном стиле
        confirmPasswordTextField.placeholder = "ПОДТВЕРДИТЕ ПАРОЛЬ"
        confirmPasswordTextField.textColor = .white
        confirmPasswordTextField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        confirmPasswordTextField.backgroundColor = UIColor(red: 0.15, green: 0.05, blue: 0.15, alpha: 1.0)
        confirmPasswordTextField.layer.cornerRadius = 0
        confirmPasswordTextField.layer.borderWidth = 3
        confirmPasswordTextField.layer.borderColor = UIColor(red: 0.9, green: 0.4, blue: 0.7, alpha: 1.0).cgColor
        confirmPasswordTextField.layer.shouldRasterize = true // Оптимизация
        confirmPasswordTextField.layer.rasterizationScale = UIScreen.main.scale
        confirmPasswordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        confirmPasswordTextField.leftViewMode = .always
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocorrectionType = .no
        confirmPasswordTextField.spellCheckingType = .no
        confirmPasswordTextField.smartQuotesType = .no
        confirmPasswordTextField.smartDashesType = .no
        confirmPasswordTextField.smartInsertDeleteType = .no
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "ПОДТВЕРДИТЕ ПАРОЛЬ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        containerView.addSubview(confirmPasswordTextField)

        // Кнопка подтверждения в пиксельном стиле
        confirmButton.setTitle("РЕГИСТРАЦИЯ", for: .normal)
        confirmButton.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .black)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(red: 1.0, green: 0.3, blue: 0.6, alpha: 1.0)
        confirmButton.layer.cornerRadius = 0
        confirmButton.layer.shadowColor = UIColor.black.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 6, height: 6)
        confirmButton.layer.shadowRadius = 0
        confirmButton.layer.shadowOpacity = 0.8
        confirmButton.layer.borderWidth = 4
        confirmButton.layer.borderColor = UIColor.black.cgColor
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        confirmButton.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        view.addSubview(confirmButton)
        
        // Индикатор загрузки
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.heightAnchor.constraint(equalToConstant: 230),

            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 40),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 260),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 20),
        ])
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        // Пиксельная анимация нажатия
        UIView.animate(withDuration: 0.05) {
            sender.layer.shadowOffset = CGSize(width: 2, height: 2)
            sender.transform = CGAffineTransform(translationX: 4, y: 4)
        }
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.layer.shadowOffset = CGSize(width: 6, height: 6)
            sender.transform = .identity
        }
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        // Валидация полей
        guard let username = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else {
            showError(message: "Введите имя пользователя")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError(message: "Введите пароль")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showError(message: "Подтвердите пароль")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "Пароли не совпадают")
            return
        }
        
        // Анимация нажатия
        UIView.animate(withDuration: 0.1, animations: {
            self.confirmButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.confirmButton.transform = CGAffineTransform(translationX: 6, y: 6)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.confirmButton.layer.shadowOffset = CGSize(width: 6, height: 6)
                self.confirmButton.transform = .identity
            }
        }
        
        // Скрываем клавиатуру
        view.endEditing(true)
        
        // Показываем индикатор загрузки
        loadingIndicator.startAnimating()
        confirmButton.isEnabled = false
        
        // Вызов API
        APIService.shared.register(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            
            self.loadingIndicator.stopAnimating()
            self.confirmButton.isEnabled = true
            
            switch result {
            case .success(let tokenResponse):
                // Проверяем успешность ответа
                guard tokenResponse.success else {
                    self.showError(message: "Регистрация не удалась")
                    return
                }
                
                // Сохраняем токен и имя пользователя
                Storage.shared.authToken = tokenResponse.token
                Storage.shared.username = username
                
                // Переход в игру
                DispatchQueue.main.async {
                    self.onSuccess?()
                }
                
            case .failure(let error):
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupKeyboardHandling() {
        // Тап по экрану для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            confirmPasswordTextField.resignFirstResponder()
            confirmTapped()
        }
        return true
    }
}
