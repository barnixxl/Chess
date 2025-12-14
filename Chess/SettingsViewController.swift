import UIKit

class SettingsViewController: UIViewController {
    var isGameActive: Bool = false

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
        
        // Stars removed per user request
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
        titleLabel.text = "НАСТРОЙКИ"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 48, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.shadowRadius = 0
        titleLabel.layer.shadowOpacity = 1.0
        contentView.addSubview(titleLabel)

        // --- Audio Settings Section ---
        let audioLabel = createSectionHeader(text: "ЗВУКИ")
        contentView.addSubview(audioLabel)

        // Music Volume
        let musicLabel = createLabel(text: "ФОНОВАЯ МУЗЫКА")
        contentView.addSubview(musicLabel)
        
        let musicSlider = UISlider()
        musicSlider.minimumValue = 0
        musicSlider.maximumValue = 1
        musicSlider.value = Storage.shared.backgroundMusicVolume
        musicSlider.tintColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        musicSlider.thumbTintColor = .white
        musicSlider.addTarget(self, action: #selector(musicVolumeChanged(_:)), for: .valueChanged)
        musicSlider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(musicSlider)

        // Sound Effects Toggles
        let moveSoundRow = createToggleRow(title: "ДВИЖЕНИЕ ФИГУРЫ", isOn: Storage.shared.isMoveSoundEnabled, selector: #selector(moveSoundToggled(_:)))
        contentView.addSubview(moveSoundRow)
        
        let captureSoundRow = createToggleRow(title: "ПРОИГРЫШ ФИГУРЫ", isOn: Storage.shared.isCaptureSoundEnabled, selector: #selector(captureSoundToggled(_:)))
        contentView.addSubview(captureSoundRow)
        
        let winSoundRow = createToggleRow(title: "ВЫИГРЫШ", isOn: Storage.shared.isWinSoundEnabled, selector: #selector(winSoundToggled(_:)))
        contentView.addSubview(winSoundRow)
        
        let loseSoundRow = createToggleRow(title: "ПРОИГРЫШ", isOn: Storage.shared.isLoseSoundEnabled, selector: #selector(loseSoundToggled(_:)))
        contentView.addSubview(loseSoundRow)
        
        let keySoundRow = createToggleRow(title: "НАЖАТИЕ КНОПОК", isOn: Storage.shared.isKeySoundEnabled, selector: #selector(keySoundToggled(_:)))
        contentView.addSubview(keySoundRow)

        // --- Back Button ---
        let backTitle = isGameActive ? "ВЕРНУТЬСЯ К ИГРЕ" : "НАЗАД В МЕНЮ"
        let backButton = createPixelButton(title: backTitle, color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0))
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        contentView.addSubview(backButton)

        if !isGameActive {
            let accountLabel = createSectionHeader(text: "АККАУНТ")
            contentView.addSubview(accountLabel)

            let accountButton = createPixelButton(title: "НАСТРОЙКИ АККАУНТА", color: UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0))
            accountButton.addTarget(self, action: #selector(accountSettingsTapped), for: .touchUpInside)
            contentView.addSubview(accountButton)
            
            // Constraints for Account Section
             NSLayoutConstraint.activate([
                accountLabel.topAnchor.constraint(equalTo: keySoundRow.bottomAnchor, constant: 40),
                accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                
                accountButton.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20),
                accountButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                accountButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
                accountButton.heightAnchor.constraint(equalToConstant: 50),
            ])
            
            // Connect back button to account button
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: accountButton.bottomAnchor, constant: 40)
            ])
        } else {
            // If game is active, skip account section and connect back button to keySoundRow
             NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: keySoundRow.bottomAnchor, constant: 40)
            ])
        }

        // Constraints
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
            
            audioLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            audioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            musicLabel.topAnchor.constraint(equalTo: audioLabel.bottomAnchor, constant: 20),
            musicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            musicSlider.centerYAnchor.constraint(equalTo: musicLabel.centerYAnchor),
            musicSlider.leadingAnchor.constraint(equalTo: musicLabel.trailingAnchor, constant: 20),
            musicSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            moveSoundRow.topAnchor.constraint(equalTo: musicLabel.bottomAnchor, constant: 20),
            moveSoundRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            moveSoundRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            moveSoundRow.heightAnchor.constraint(equalToConstant: 40),
            
            captureSoundRow.topAnchor.constraint(equalTo: moveSoundRow.bottomAnchor, constant: 10),
            captureSoundRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captureSoundRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            captureSoundRow.heightAnchor.constraint(equalToConstant: 40),
            
            winSoundRow.topAnchor.constraint(equalTo: captureSoundRow.bottomAnchor, constant: 10),
            winSoundRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            winSoundRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            winSoundRow.heightAnchor.constraint(equalToConstant: 40),
            
            loseSoundRow.topAnchor.constraint(equalTo: winSoundRow.bottomAnchor, constant: 10),
            loseSoundRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loseSoundRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loseSoundRow.heightAnchor.constraint(equalToConstant: 40),
            
            keySoundRow.topAnchor.constraint(equalTo: loseSoundRow.bottomAnchor, constant: 10),
            keySoundRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            keySoundRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            keySoundRow.heightAnchor.constraint(equalToConstant: 40),
            
            // accountLabel.topAnchor.constraint(equalTo: keySoundRow.bottomAnchor, constant: 40),
            // accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // accountButton.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20),
            // accountButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // accountButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            // accountButton.heightAnchor.constraint(equalToConstant: 50),
            
            // See above for dynamic constraints
            // backButton.topAnchor.constraint(equalTo: accountButton.bottomAnchor, constant: 40),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func createSectionHeader(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createToggleRow(title: String, isOn: Bool, selector: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = createLabel(text: title)
        container.addSubview(label)
        
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        toggle.addTarget(self, action: selector, for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(toggle)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor)
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
        return button
    }

    // MARK: - Actions

    @objc private func musicVolumeChanged(_ sender: UISlider) {
        Storage.shared.backgroundMusicVolume = sender.value
        SoundManager.shared.setBackgroundMusicVolume(sender.value)
    }
    
    @objc private func moveSoundToggled(_ sender: UISwitch) {
        Storage.shared.isMoveSoundEnabled = sender.isOn
    }
    
    @objc private func captureSoundToggled(_ sender: UISwitch) {
        Storage.shared.isCaptureSoundEnabled = sender.isOn
    }
    
    @objc private func winSoundToggled(_ sender: UISwitch) {
        Storage.shared.isWinSoundEnabled = sender.isOn
    }
    
    @objc private func loseSoundToggled(_ sender: UISwitch) {
        Storage.shared.isLoseSoundEnabled = sender.isOn
    }
    
    @objc private func keySoundToggled(_ sender: UISwitch) {
        Storage.shared.isKeySoundEnabled = sender.isOn
    }

    @objc private func accountSettingsTapped() {
        SoundManager.shared.playButtonSound()
        let accountVC = AccountSettingsViewController()
        accountVC.modalPresentationStyle = .overFullScreen
        accountVC.modalTransitionStyle = .crossDissolve
        present(accountVC, animated: true, completion: nil)
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
