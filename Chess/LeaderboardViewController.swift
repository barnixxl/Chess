import UIKit

class LeaderboardViewController: UIViewController {
    private var tableView: UITableView!
    private var leaders: [LeaderboardEntry] = []
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
        loadLeaderboard()
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
        
        // Stars removed per user request
    }
    
    
    private func loadLeaderboard() {
        // Show loading indicator
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
        
        // Load leaderboard from API
        APIService.shared.getLeaderboard { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator?.stopAnimating()
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                
                switch result {
                case .success(let response):
                    self.leaders = response.leaders
                    self.tableView.reloadData()
                case .failure(let error):
                    print("❌ Ошибка загрузки лидерборда: \(error.localizedDescription)")
                    // Показываем алерт только если это не 404 (может быть просто нет данных)
                    if case .serverError(let code, _) = error, code == 404 {
                        print("⚠️ Лидерборд не найден (404), показываем пустую таблицу")
                        self.leaders = []
                        self.tableView.reloadData()
                    } else {
                        self.showErrorAlert(error: error)
                    }
                }
            }
        }
    }
    
    private func setupUI() {
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "LEADERBOARD"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 32, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        view.addSubview(titleLabel)
        
        // Table View
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        view.addSubview(tableView)
        
        // Back Button
        let backButton = createPixelButton(title: "НАЗАД", color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            backButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func showErrorAlert(error: APIError) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        SoundManager.shared.playButtonSound()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        let leader = leaders[indexPath.row]
        cell.configure(rank: leader.rank, username: leader.username, score: leader.wins)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Leaderboard Cell
class LeaderboardCell: UITableViewCell {
    private let rankLabel = UILabel()
    private let medalLabel = UILabel()
    private let usernameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(containerView)
        
        // Medal label for top 3
        medalLabel.font = UIFont.systemFont(ofSize: 28)
        medalLabel.textAlignment = .center
        medalLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(medalLabel)
        
        rankLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        rankLabel.textColor = .white
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rankLabel)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .medium)
        usernameLabel.textColor = .white
        usernameLabel.textAlignment = .left // Align to left
        containerView.addSubview(usernameLabel)
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        scoreLabel.textAlignment = .right
        containerView.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            medalLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            medalLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            medalLabel.widthAnchor.constraint(equalToConstant: 35),
            
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: medalLabel.trailingAnchor, constant: 5),
            rankLabel.widthAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 20),
            usernameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    
    func configure(rank: Int, username: String, score: Int) {
        // Show medal for top 3, otherwise show rank number
        if rank == 1 {
            medalLabel.text = "🥇"
            rankLabel.text = ""
            containerView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)
        } else if rank == 2 {
            medalLabel.text = "🥈"
            rankLabel.text = ""
            containerView.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.3)
        } else if rank == 3 {
            medalLabel.text = "🥉"
            rankLabel.text = ""
            containerView.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.3)
        } else {
            medalLabel.text = ""
            rankLabel.text = "#\(rank)"
            containerView.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        }
        
        usernameLabel.text = username
        scoreLabel.text = "\(score)"
    }
}
