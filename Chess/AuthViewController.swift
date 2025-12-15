
import UIKit

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
    }
    


    private func setupPixelBackground() {
        // Пиксельный градиентный фон
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
        gradientLayer.shouldRasterize = true // Оптимизация производительности
        gradientLayer.rasterizationScale = UIScreen.main.scale
        view.layer.insertSublayer(gradientLayer, at: 0)
    }



    private func setupUI() {
        // Пиксельный заголовок
        let titleLabel = UILabel()
        titleLabel.text = "MCP CHESS"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 48, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Добавляем пиксельную тень
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        view.addSubview(titleLabel)

        // Шахматная иконка
        let chessIcon = UILabel()
        chessIcon.text = "♟️"
        chessIcon.font = UIFont.systemFont(ofSize: 60)
        chessIcon.textAlignment = .center
        chessIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chessIcon)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "ВЫБЕРИТЕ ДЕЙСТВИЕ"
        subtitleLabel.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        subtitleLabel.textColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 25
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let loginButton = createPixelButton(title: "ВХОД", color: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0))
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)

        let registerButton = createPixelButton(title: "РЕГИСТРАЦИЯ", color: UIColor(red: 1.0, green: 0.3, blue: 0.6, alpha: 1.0))
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        stackView.addArrangedSubview(registerButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            chessIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chessIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: chessIcon.bottomAnchor, constant: 20),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 140),
        ])
    }

    private func createPixelButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .black)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        
        // Пиксельный стиль - без скругления
        button.layer.cornerRadius = 0
        
        // Пиксельная тень
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 6, height: 6)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 0.8
        
        // Пиксельная рамка
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor

        // Анимация при нажатии
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        // Пиксельная анимация нажатия - смещение тени
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

    @objc private func loginTapped() {
        SoundManager.shared.playButtonSound()
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
        SoundManager.shared.playButtonSound()
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
              let delegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }

        let mainMenuVC = MainMenuViewController()
        
        UIView.transition(with: delegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            delegate.window?.rootViewController = mainMenuVC
        }, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}
