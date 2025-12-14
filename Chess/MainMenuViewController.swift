
import UIKit

class MainMenuViewController: UIViewController {
    private var pixelParticles: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Создаем звезды асинхронно после появления экрана для лучшей производительности
        DispatchQueue.main.async { [weak self] in
            // Stars removed
        }
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

    // Star animation function removed
    
    private func setupUI() {
        // Заголовок в стиле пиксельной игры
        let titleLabel = UILabel()
        titleLabel.text = "MCB CHESS"
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

        // Большая кнопка игры с компьютером по центру с иконкой
        let playButton = createPixelButton(title: "ИГРА С КОМПЬЮТЕРОМ", color: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0))
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add chess icon to play button
        if let playIcon = UIImage(named: "play_icon") {
            playButton.setImage(playIcon, for: .normal)
            playButton.imageView?.contentMode = .scaleAspectFit
            playButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            playButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
        view.addSubview(playButton)

        // Маленькие иконки внизу
        let bottomIconsStack = UIStackView()
        bottomIconsStack.axis = .horizontal
        bottomIconsStack.spacing = 20
        bottomIconsStack.alignment = .center
        bottomIconsStack.distribution = .fillEqually
        bottomIconsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomIconsStack)

        // Create beautiful icon buttons with chess symbols and images
        let leaderboardButton = createEnhancedIconButton(
            imageName: "leaderboard_icon",
            fallbackSymbol: "♔",
            color: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        )
        leaderboardButton.addTarget(self, action: #selector(leaderboardTapped), for: .touchUpInside)
        bottomIconsStack.addArrangedSubview(leaderboardButton)
        
        let settingsButton = createEnhancedIconButton(
            imageName: nil,
            fallbackSymbol: "♟",
            color: UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        )
        settingsButton.addTarget(self, action: #selector(accountSettingsTapped), for: .touchUpInside)
        bottomIconsStack.addArrangedSubview(settingsButton)
        
        let statisticsButton = createEnhancedIconButton(
            imageName: nil,
            fallbackSymbol: "♜",
            color: UIColor(red: 0.4, green: 0.7, blue: 0.6, alpha: 1.0)
        )
        statisticsButton.addTarget(self, action: #selector(statisticsTapped), for: .touchUpInside)
        bottomIconsStack.addArrangedSubview(statisticsButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            chessIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chessIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            
            bottomIconsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomIconsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            bottomIconsStack.widthAnchor.constraint(equalToConstant: 240),
            bottomIconsStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func createEnhancedIconButton(imageName: String?, fallbackSymbol: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        // Try to use image first, fallback to chess symbol
        if let imageName = imageName, let image = UIImage(named: imageName) {
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.tintColor = .white
        } else {
            button.setTitle(fallbackSymbol, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            button.setTitleColor(.white, for: .normal)
        }
        
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true

        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    private func createPixelButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .black)
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

    @objc private func accountSettingsTapped() {
        SoundManager.shared.playButtonSound()
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        settingsVC.modalTransitionStyle = .crossDissolve
        present(settingsVC, animated: true, completion: nil)
    }

    @objc private func leaderboardTapped() {
        SoundManager.shared.playButtonSound()
        let leaderboardVC = LeaderboardViewController()
        leaderboardVC.modalPresentationStyle = .fullScreen
        leaderboardVC.modalTransitionStyle = .crossDissolve
        present(leaderboardVC, animated: true, completion: nil)
    }
    
    @objc private func statisticsTapped() {
        SoundManager.shared.playButtonSound()
        let statsVC = StatisticsViewController()
        statsVC.modalPresentationStyle = .fullScreen
        statsVC.modalTransitionStyle = .crossDissolve
        present(statsVC, animated: true, completion: nil)
    }
    
    @objc private func playTapped() {
        SoundManager.shared.playButtonSound()
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
