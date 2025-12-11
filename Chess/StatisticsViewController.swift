import UIKit

class StatisticsViewController: UIViewController {
    private var statistics: StatisticsResponse?
    private var loadingIndicator: UIActivityIndicatorView?
    private var bestTimeValue: UILabel?
    private var winsValue: UILabel?
    private var lossesValue: UILabel?
    private var ratioBar: UIView?
    private var ratioValue: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        loadStatistics()
    }
    
    private func loadStatistics() {
        // Показываем индикатор загрузки
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        loadingIndicator = indicator
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        indicator.startAnimating()
        
        // Загружаем статистику с бэка
        APIService.shared.getStatistics { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator?.stopAnimating()
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                
                switch result {
                case .success(let stats):
                    self.statistics = stats
                    self.setupUI()
                case .failure(let error):
                    // В случае ошибки показываем UI с нулевыми значениями
                    print("Ошибка загрузки статистики: \(error.localizedDescription)")
                    self.statistics = StatisticsResponse(totalWins: 0, totalLosses: 0, bestWinTime: nil)
                    self.setupUI()
                }
            }
        }
    }
    
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
        
        // Add stars
        for _ in 0 ..< 20 {
            let star = UIView()
            let size: CGFloat = [4, 6].randomElement()!
            star.frame = CGRect(
                x: CGFloat.random(in: 0 ... view.bounds.width),
                y: CGFloat.random(in: 0 ... view.bounds.height),
                width: size,
                height: size
            )
            star.backgroundColor = .white
            star.alpha = CGFloat.random(in: 0.3 ... 0.8)
            view.addSubview(star)
        }
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "СТАТИСТИКА"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 42, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        contentView.addSubview(titleLabel)
        
        // Username (if available)
        let username = Storage.shared.username ?? "Игрок"
        let usernameLabel = UILabel()
        usernameLabel.text = username.uppercased()
        usernameLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)
        
        // Best Win Time Card
        let bestTimeCard = createStatCard()
        contentView.addSubview(bestTimeCard)
        
        let bestTimeTitle = createSectionLabel(text: "ЛУЧШЕЕ ВРЕМЯ ВЫИГРЫША")
        bestTimeCard.addSubview(bestTimeTitle)
        
        let bestTimeValue = createValueLabel()
        self.bestTimeValue = bestTimeValue
        if let time = statistics?.bestWinTime {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            bestTimeValue.text = String(format: "%02d:%02d", minutes, seconds)
        } else {
            bestTimeValue.text = "--:--"
            bestTimeValue.textColor = .gray
        }
        bestTimeCard.addSubview(bestTimeValue)
        
        // Wins/Losses Card
        let winsLossesCard = createStatCard()
        contentView.addSubview(winsLossesCard)
        
        let winsLabel = createSectionLabel(text: "ПОБЕДЫ")
        winsLossesCard.addSubview(winsLabel)
        
        let winsValue = createValueLabel()
        self.winsValue = winsValue
        winsValue.text = "\(statistics?.totalWins ?? 0)"
        winsLossesCard.addSubview(winsValue)
        
        let lossesLabel = createSectionLabel(text: "ПОРАЖЕНИЯ")
        winsLossesCard.addSubview(lossesLabel)
        
        let lossesValue = createValueLabel()
        self.lossesValue = lossesValue
        lossesValue.text = "\(statistics?.totalLosses ?? 0)"
        lossesValue.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        winsLossesCard.addSubview(lossesValue)
        
        // Win/Loss Ratio Bar
        let ratioCard = createStatCard()
        contentView.addSubview(ratioCard)
        
        let ratioTitle = createSectionLabel(text: "СООТНОШЕНИЕ ПОБЕД/ПОРАЖЕНИЙ")
        ratioCard.addSubview(ratioTitle)
        
        let ratioBar = createRatioBar()
        self.ratioBar = ratioBar
        ratioCard.addSubview(ratioBar)
        
        let ratioValue = createValueLabel()
        self.ratioValue = ratioValue
        let total = (statistics?.totalWins ?? 0) + (statistics?.totalLosses ?? 0)
        if total > 0 {
            let winPercentage = Double(statistics?.totalWins ?? 0) / Double(total) * 100
            ratioValue.text = String(format: "%.1f%%", winPercentage)
        } else {
            ratioValue.text = "0%"
        }
        ratioCard.addSubview(ratioValue)
        
        // Back Button
        let backButton = createPixelButton(title: "НАЗАД", color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        contentView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            bestTimeCard.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 30),
            bestTimeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bestTimeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bestTimeCard.heightAnchor.constraint(equalToConstant: 120),
            
            bestTimeTitle.topAnchor.constraint(equalTo: bestTimeCard.topAnchor, constant: 15),
            bestTimeTitle.centerXAnchor.constraint(equalTo: bestTimeCard.centerXAnchor),
            
            bestTimeValue.topAnchor.constraint(equalTo: bestTimeTitle.bottomAnchor, constant: 15),
            bestTimeValue.centerXAnchor.constraint(equalTo: bestTimeCard.centerXAnchor),
            
            winsLossesCard.topAnchor.constraint(equalTo: bestTimeCard.bottomAnchor, constant: 20),
            winsLossesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            winsLossesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            winsLossesCard.heightAnchor.constraint(equalToConstant: 140),
            
            winsLabel.topAnchor.constraint(equalTo: winsLossesCard.topAnchor, constant: 15),
            winsLabel.leadingAnchor.constraint(equalTo: winsLossesCard.leadingAnchor, constant: 20),
            
            winsValue.topAnchor.constraint(equalTo: winsLabel.bottomAnchor, constant: 10),
            winsValue.leadingAnchor.constraint(equalTo: winsLossesCard.leadingAnchor, constant: 20),
            
            lossesLabel.topAnchor.constraint(equalTo: winsLossesCard.topAnchor, constant: 15),
            lossesLabel.trailingAnchor.constraint(equalTo: winsLossesCard.trailingAnchor, constant: -20),
            
            lossesValue.topAnchor.constraint(equalTo: lossesLabel.bottomAnchor, constant: 10),
            lossesValue.trailingAnchor.constraint(equalTo: winsLossesCard.trailingAnchor, constant: -20),
            
            ratioCard.topAnchor.constraint(equalTo: winsLossesCard.bottomAnchor, constant: 20),
            ratioCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratioCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ratioCard.heightAnchor.constraint(equalToConstant: 160),
            
            ratioTitle.topAnchor.constraint(equalTo: ratioCard.topAnchor, constant: 15),
            ratioTitle.centerXAnchor.constraint(equalTo: ratioCard.centerXAnchor),
            
            ratioBar.topAnchor.constraint(equalTo: ratioTitle.bottomAnchor, constant: 20),
            ratioBar.leadingAnchor.constraint(equalTo: ratioCard.leadingAnchor, constant: 20),
            ratioBar.trailingAnchor.constraint(equalTo: ratioCard.trailingAnchor, constant: -20),
            ratioBar.heightAnchor.constraint(equalToConstant: 40),
            
            ratioValue.topAnchor.constraint(equalTo: ratioBar.bottomAnchor, constant: 15),
            ratioValue.centerXAnchor.constraint(equalTo: ratioCard.centerXAnchor),
            
            backButton.topAnchor.constraint(equalTo: ratioCard.bottomAnchor, constant: 30),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func createStatCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        card.layer.borderWidth = 3
        card.layer.borderColor = UIColor.black.cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 4, height: 4)
        card.layer.shadowRadius = 0
        card.layer.shadowOpacity = 1.0
        return card
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createValueLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createRatioBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.black.cgColor
        
        let total = (statistics?.totalWins ?? 0) + (statistics?.totalLosses ?? 0)
        let winPercentage: CGFloat = total > 0 ? CGFloat(statistics?.totalWins ?? 0) / CGFloat(total) : 0.0
        
        // Green (wins) portion
        let winsBar = UIView()
        winsBar.translatesAutoresizingMaskIntoConstraints = false
        winsBar.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        container.addSubview(winsBar)
        
        // Red (losses) portion
        let lossesBar = UIView()
        lossesBar.translatesAutoresizingMaskIntoConstraints = false
        lossesBar.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        container.addSubview(lossesBar)
        
        NSLayoutConstraint.activate([
            winsBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            winsBar.topAnchor.constraint(equalTo: container.topAnchor),
            winsBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            winsBar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: winPercentage),
            
            lossesBar.leadingAnchor.constraint(equalTo: winsBar.trailingAnchor),
            lossesBar.topAnchor.constraint(equalTo: container.topAnchor),
            lossesBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            lossesBar.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
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
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
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
            sender.layer.shadowOffset = CGSize(width: 4, height: 4)
            sender.transform = .identity
        }
    }
    
    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}
