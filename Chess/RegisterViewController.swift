
import UIKit

class RegisterViewController: UIViewController {

    var onSuccess: (() -> Void)?
    private var bubbles: [UIView] = []

    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupBubbleAnimation()
        setupUI()
        setupKeyboardHandling()
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1.0).cgColor,
            UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupBubbleAnimation() {
        for i in 0..<12 {
            let bubble = UIView()
            let size = CGFloat.random(in: 35...90)
            bubble.frame = CGRect(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: view.bounds.height + size,
                width: size,
                height: size
            )
            bubble.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            bubble.layer.cornerRadius = size / 2
            bubble.layer.borderWidth = 2
            bubble.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            view.addSubview(bubble)
            bubbles.append(bubble)

            let duration = Double.random(in: 4...10)
            let delay = Double(i) * 0.35
            let xOffset = CGFloat.random(in: -30...30)

            UIView.animate(withDuration: duration, delay: delay, options: [.repeat, .curveLinear], animations: {
                bubble.frame.origin.y = -size
                bubble.frame.origin.x += xOffset
            }, completion: nil)

            UIView.animate(withDuration: 2.0, delay: delay, options: [.repeat, .autoreverse], animations: {
                bubble.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }, completion: nil)
        }
    }

    private func setupUI() {
        // Кнопка назад
        let backButton = UIButton(type: .system)
        backButton.setTitle("← Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        backButton.setTitleColor(.white, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Регистрация"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Контейнер для полей
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        containerView.layer.cornerRadius = 25
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Email поле
        emailTextField.placeholder = "Email или имя пользователя"
        emailTextField.font = UIFont.systemFont(ofSize: 18)
        emailTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        emailTextField.layer.cornerRadius = 15
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(emailTextField)

        // Password поле
        passwordTextField.placeholder = "Пароль"
        passwordTextField.font = UIFont.systemFont(ofSize: 18)
        passwordTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .next
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(passwordTextField)

        // Confirm Password поле
        confirmPasswordTextField.placeholder = "Подтвердите пароль"
        confirmPasswordTextField.font = UIFont.systemFont(ofSize: 18)
        confirmPasswordTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        confirmPasswordTextField.layer.cornerRadius = 15
        confirmPasswordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        confirmPasswordTextField.leftViewMode = .always
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(confirmPasswordTextField)

        // Кнопка подтверждения
        confirmButton.setTitle("Зарегистрироваться", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1.0)
        confirmButton.layer.cornerRadius = 25
        confirmButton.layer.shadowColor = UIColor.black.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmButton.layer.shadowRadius = 8
        confirmButton.layer.shadowOpacity = 0.3
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        confirmButton.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.heightAnchor.constraint(equalToConstant: 205),

            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 30),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 250),
            confirmButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        // Анимация нажатия
        UIView.animate(withDuration: 0.2, animations: {
            self.confirmButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
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

