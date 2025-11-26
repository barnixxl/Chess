
import UIKit

class MainMenuViewController: UIViewController {
    private var stars: [UIView] = []
    private var pixelParticles: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupStarAnimation()
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
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupStarAnimation() {
        // Создаем пиксельные звезды на фоне
        for i in 0 ..< 30 {
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
            
            // Мерцание звезд
            let duration = Double.random(in: 1.0 ... 3.0)
            let delay = Double(i) * 0.1
            
            UIView.animate(withDuration: duration, delay: delay, options: [.repeat, .autoreverse], animations: {
                star.alpha = CGFloat.random(in: 0.2 ... 1.0)
            }, completion: nil)
        }
    }
    
    private func setupUI() {
        // Заголовок в стиле пиксельной игры
        let titleLabel = UILabel()
        titleLabel.text = "MCP CHESS"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 56, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 6, height: 6)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        view.addSubview(titleLabel)
        
        // Шахматная иконка под заголовком
        let chessIcon = UILabel()
        chessIcon.text = "♔"
        chessIcon.font = UIFont.systemFont(ofSize: 70)
        chessIcon.textAlignment = .center
        chessIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chessIcon)

        // Основные кнопки по центру
        let mainButtonsStack = UIStackView()
        mainButtonsStack.axis = .vertical
        mainButtonsStack.spacing = 18
        mainButtonsStack.alignment = .fill
        mainButtonsStack.distribution = .fillEqually
        mainButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainButtonsStack)

        let mainButtonsData: [(title: String, color: UIColor, action: Selector)] = [
            ("ИГРА С КОМПЬЮТЕРОМ", UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0), #selector(playTapped)),
            ("ИГРА С ДРУГОМ", UIColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 1.0), #selector(friendsTapped))
        ]

        for data in mainButtonsData {
            let button = createPixelButton(title: data.title, color: data.color)
            button.addTarget(self, action: data.action, for: .touchUpInside)
            mainButtonsStack.addArrangedSubview(button)
        }

        // Маленькие иконки внизу
        let bottomIconsStack = UIStackView()
        bottomIconsStack.axis = .horizontal
        bottomIconsStack.spacing = 15
        bottomIconsStack.alignment = .center
        bottomIconsStack.distribution = .fillEqually
        bottomIconsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomIconsStack)

        let iconsData: [(icon: String, color: UIColor, action: Selector)] = [
            ("🏆", UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0), #selector(leaderboardTapped)),
            ("⏱", UIColor(red: 0.4, green: 0.6, blue: 0.5, alpha: 1.0), #selector(historyTapped)),
            ("⚙️", UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), #selector(accountSettingsTapped)),
            ("👥", UIColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0), #selector(friendsTapped))
        ]

        for data in iconsData {
            let button = createIconButton(icon: data.icon, color: data.color)
            button.addTarget(self, action: data.action, for: .touchUpInside)
            bottomIconsStack.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            chessIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chessIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            mainButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainButtonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            mainButtonsStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            mainButtonsStack.heightAnchor.constraint(equalToConstant: 160),
            
            bottomIconsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomIconsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            bottomIconsStack.widthAnchor.constraint(equalToConstant: 280),
            bottomIconsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createIconButton(icon: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(icon, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.backgroundColor = color
        
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0
        
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true

        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    private func createPixelButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .black)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 6, height: 6)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0

        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    @objc private func buttonPressed(_ sender: UIButton) {
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

    @objc private func gameSettingsTapped() {
        print("Game Settings Tapped")
    }

    @objc private func accountSettingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        settingsVC.modalTransitionStyle = .crossDissolve
        present(settingsVC, animated: true, completion: nil)
    }

    @objc private func leaderboardTapped() {
        print("Leaderboard Tapped")
    }

    @objc private func friendsTapped() {
        print("Friends Tapped")
    }
    
    @objc private func historyTapped() {
        print("History Tapped")
    }

    @objc private func playTapped() {
        guard let windowScene = view.window?.windowScene,
              let delegate = windowScene.delegate as? SceneDelegate
        else {
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
