import UIKit

class LeaderboardViewController: UIViewController {
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPixelBackground()
        setupUI()
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
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "ТАБЛИЦА ЛИДЕРОВ"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 42, weight: .black)
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

// MARK: - UITableViewDataSource & Delegate
extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Replace with actual data from database
        // For now, return 0 or placeholder data
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        // TODO: Configure cell with actual data
        // cell.configure(rank: indexPath.row + 1, username: "Player", score: 1000)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Leaderboard Cell
class LeaderboardCell: UITableViewCell {
    private let rankLabel = UILabel()
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
        
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
        rankLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        rankLabel.textAlignment = .center
        containerView.addSubview(rankLabel)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .medium)
        usernameLabel.textColor = .white
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
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 20),
            usernameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    func configure(rank: Int, username: String, score: Int) {
        rankLabel.text = "#\(rank)"
        usernameLabel.text = username
        scoreLabel.text = "\(score)"
    }
}
