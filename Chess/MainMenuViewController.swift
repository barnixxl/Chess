
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
    
        // Добавляем падающие пиксельные частицы
        //for i in 0 ..< 8 {
          //  let particle = UIView()
            //let size: CGFloat = 6
            //particle.frame = CGRect(
              //  x: CGFloat.random(in: 0 ... view.bounds.width),
                //y: -size,
                //width: size,
                //height: size
            //)
            //particle.backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.6)
            //view.addSubview(particle)
            //pixelParticles.append(particle)

            //let duration = Double.random(in: 4 ... 8)
            //let delay = Double(i) * 0.5
            //UIView.animate(withDuration: duration, delay: delay, options: [.repeat, //.curveLinear], animations: {
                //particle.frame.origin.y = self.view.bounds.height + size
            //}, completion: nil)
        //}
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let buttonsData: [(title: String, color: UIColor, action: Selector)] = [
            ("НАСТРОЙКИ ИГРЫ", UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0), #selector(gameSettingsTapped)),
            ("НАСТРОЙКИ АККАУНТА", UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0), #selector(accountSettingsTapped)),
            ("ТАБЛИЦА РЕКОРДОВ", UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0), #selector(leaderboardTapped)),
            ("ДРУЗЬЯ", UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0), #selector(friendsTapped)),
            ("ИГРАТЬ", UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0), #selector(playTapped))
        ]

        for data in buttonsData {
            let button = createPixelButton(title: data.title, color: data.color)
            button.addTarget(self, action: data.action, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalToConstant: 400)
        ])
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
        print("Account Settings Tapped")
    }

    @objc private func leaderboardTapped() {
        print("Leaderboard Tapped")
    }

    @objc private func friendsTapped() {
        print("Friends Tapped")
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
