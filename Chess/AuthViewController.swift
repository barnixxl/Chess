
import UIKit

class AuthViewController: UIViewController {

    private let bubbleLayer = CAEmitterLayer()
    private var bubbles: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupBubbleAnimation()
        setupUI()
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.5, blue: 0.8, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupBubbleAnimation() {
        // Создаем пузырьки на фоне
        for i in 0..<15 {
            let bubble = UIView()
            let size = CGFloat.random(in: 40...120)
            bubble.frame = CGRect(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: view.bounds.height + size,
                width: size,
                height: size
            )
            bubble.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            bubble.layer.cornerRadius = size / 2
            bubble.layer.borderWidth = 2
            bubble.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            view.addSubview(bubble)
            bubbles.append(bubble)

            // Анимация подъема пузырька
            let duration = Double.random(in: 3...8)
            let delay = Double(i) * 0.3
            let xOffset = CGFloat.random(in: -50...50)

            UIView.animate(withDuration: duration, delay: delay, options: [.repeat, .curveLinear], animations: {
                bubble.frame.origin.y = -size
                bubble.frame.origin.x += xOffset
            }, completion: nil)

            // Пульсация
            UIView.animate(withDuration: 1.5, delay: delay, options: [.repeat, .autoreverse], animations: {
                bubble.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
        }
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "♟️ Chess"
        titleLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Выберите действие"
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let loginButton = createBubbleButton(title: "Войти", color: UIColor(red: 0.2, green: 0.7, blue: 0.9, alpha: 1.0))
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)

        let registerButton = createBubbleButton(title: "Зарегистрироваться", color: UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1.0))
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        stackView.addArrangedSubview(registerButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    private func createBubbleButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3

        // Анимация при нажатии
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
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

    @objc private func loginTapped() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.onSuccess = { [weak self] in
            self?.dismiss(animated: true) {
                self?.navigateToGame()
            }
        }
        present(loginVC, animated: true)
    }

    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        registerVC.onSuccess = { [weak self] in
            self?.dismiss(animated: true) {
                self?.navigateToGame()
            }
        }
        present(registerVC, animated: true)
    }

    private func navigateToGame() {
        guard let windowScene = view.window?.windowScene,
              let delegate = windowScene.delegate as? SceneDelegate else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateInitialViewController()

        UIView.transition(with: delegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            delegate.window?.rootViewController = gameVC
        }, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}

