import UIKit

class MainMenuViewController: UIViewController {

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
        
        // Buttons in "stairs" layout
        
        // 1. ИГРА С КОМПЬЮТЕРОМ (Top Left)
        let playButton = createMenuButton(
            title: "ИГРА С КОМПЬЮТЕРОМ",
            color: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        )
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        view.addSubview(playButton)
        
        // 2. РЕЙТИНГ (Mid Left)
        let leaderboardButton = createMenuButton(
            title: "РЕЙТИНГ",
            color: UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)
        )
        leaderboardButton.addTarget(self, action: #selector(leaderboardTapped), for: .touchUpInside)
        view.addSubview(leaderboardButton)
        
        // 3. НАСТРОЙКИ (Mid Right)
        let settingsButton = createMenuButton(
            title: "НАСТРОЙКИ",
            color: UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        )
        settingsButton.addTarget(self, action: #selector(accountSettingsTapped), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        // 4. СТАТИСТИКА (Bottom Right)
        let statisticsButton = createMenuButton(
            title: "СТАТИСТИКА",
            color: UIColor(red: 0.4, green: 0.7, blue: 0.6, alpha: 1.0)
        )
        statisticsButton.addTarget(self, action: #selector(statisticsTapped), for: .touchUpInside)
        view.addSubview(statisticsButton)

        NSLayoutConstraint.activate([
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // Play Button: Higher up, slightly left
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            playButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            playButton.widthAnchor.constraint(equalToConstant: 280),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Leaderboard Button: Below Play, slightly right of start
            leaderboardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            leaderboardButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 40),
            leaderboardButton.widthAnchor.constraint(equalToConstant: 280),
            leaderboardButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Settings Button: Below Leaderboard, further right
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            settingsButton.topAnchor.constraint(equalTo: leaderboardButton.bottomAnchor, constant: 40),
            settingsButton.widthAnchor.constraint(equalToConstant: 280),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Statistics Button: Below Settings, furthest right
            statisticsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            statisticsButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 40),
            statisticsButton.widthAnchor.constraint(equalToConstant: 280),
            statisticsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createMenuButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .black)
        button.setTitleColor(.white, for: .normal)
        
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor
        
        // Pixel art style shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0

        button.translatesAutoresizingMaskIntoConstraints = false
        
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
