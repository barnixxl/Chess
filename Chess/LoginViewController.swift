
import UIKit

class LoginViewController: UIViewController {
    var onSuccess: (() -> Void)?
    private var stars: [UIView] = []

    private let nameTextfield = UITextField()
    private let passwordTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupStarAnimation()
        setupUI()
        setupKeyboardHandling()
    }

    private func setupPixelBackground() {
        // Пиксельный градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupStarAnimation() {
        // Создаем пиксельные звезды
        for i in 0 ..< 25 {
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
            view.addSubview(star)
            stars.append(star)

            let duration = Double.random(in: 1.0 ... 3.0)
            let delay = Double(i) * 0.1
            UIView.animate(withDuration: duration, delay: delay, options: [.repeat, .autoreverse], animations: {
                star.alpha = CGFloat.random(in: 0.2 ... 1.0)
            }, completion: nil)
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
        titleLabel.text = "ВХОД"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 48, weight: .black)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
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
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.9)
        containerView.layer.cornerRadius = 0
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Email поле в пиксельном стиле
        nameTextfield.placeholder = "ИМЯ ПОЛЬЗОВАТЕЛЯ"
        nameTextfield.textColor = .white
        nameTextfield.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        nameTextfield.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        nameTextfield.layer.cornerRadius = 0
        nameTextfield.layer.borderWidth = 3
        nameTextfield.layer.borderColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0).cgColor
        nameTextfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        nameTextfield.leftViewMode = .always
        nameTextfield.autocapitalizationType = .none
        nameTextfield.autocorrectionType = .no
        nameTextfield.keyboardType = .emailAddress
        nameTextfield.returnKeyType = .next
        nameTextfield.delegate = self
        nameTextfield.translatesAutoresizingMaskIntoConstraints = false
        // Изменяем цвет placeholder
        nameTextfield.attributedPlaceholder = NSAttributedString(
            string: "ИМЯ ПОЛЬЗОВАТЕЛЯ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        containerView.addSubview(nameTextfield)

        // Password поле в пиксельном стиле
        passwordTextField.placeholder = "ПАРОЛЬ"
        passwordTextField.textColor = .white
        passwordTextField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold)
        passwordTextField.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        passwordTextField.layer.cornerRadius = 0
        passwordTextField.layer.borderWidth = 3
        passwordTextField.layer.borderColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0).cgColor
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "ПАРОЛЬ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        containerView.addSubview(passwordTextField)

        // Кнопка подтверждения в пиксельном стиле
        confirmButton.setTitle("ВОЙТИ", for: .normal)
        confirmButton.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .black)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
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

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.heightAnchor.constraint(equalToConstant: 160),

            nameTextfield.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            nameTextfield.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameTextfield.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameTextfield.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: nameTextfield.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 40),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 220),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
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

        // Переход в игру (без проверок)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.onSuccess?()
        }
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextfield {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            confirmTapped()
        }
        return true
    }
}

