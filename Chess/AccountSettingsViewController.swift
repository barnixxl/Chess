import UIKit

class AccountSettingsViewController: UIViewController {

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
    }

    private func setupUI() {
        // Container View for the "Small Window" effect
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "ACCOUNT"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 32, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Back Button
        let backButton = createPixelButton(title: "BACK", color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        containerView.addSubview(backButton)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            backButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 120),
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
        return button
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
