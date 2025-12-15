
import UIKit

class ViewController: UIViewController {
    private var game: Game = .init()
    private var isPaused: Bool = false
    private var gameStartTime: Date?
    private var gameResult: String? // "win", "loss", "draw"

    @IBOutlet var boardView: BoardView?
    
    // Legacy Storyboard Outlets (Required to prevent crash)
    @IBOutlet var undoButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var whiteToggle: UISegmentedControl?
    @IBOutlet var blackToggle: UISegmentedControl?

    // UI Elements
    private var modeButton: UIButton?
    private var settingsButton: UIButton?
    private var exitButton: UIButton?
    private var restartButton: UIButton?

    private lazy var saveURL: URL = {
        var directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        #if os(macOS)
            directory = directory.appendingPathComponent(Bundle.main.bundleIdentifier!)
        #endif
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("game.json")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        boardView?.delegate = self
        try? load(from: saveURL)
        
        // Hide legacy UI from storyboard
        undoButton?.isHidden = true
        resetButton?.isHidden = true
        whiteToggle?.isHidden = true
        blackToggle?.isHidden = true
        
        setupInGameUI()
        
        // Ensure game state matches UI
        game.whiteIsHuman = true 
        // Sync mode button text with loaded game state
        updateModeButtonText()
        
        boardView?.board = game.board
        isPaused = game.inProgress
        if !game.inProgress {
            gameStartTime = Date()
        } else {
            gameStartTime = Storage.shared.savedGameStartTime
        }

        updateUI()
        update()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func setupInGameUI() {
        // 1. Settings Button (Top Right)
        let settingsBtn = createPixelButton(
            title: "НАСТРОЙКИ", 
            color: UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        )
        settingsBtn.addTarget(self, action: #selector(settings), for: .touchUpInside)
        view.addSubview(settingsBtn)
        self.settingsButton = settingsBtn
        
        // 2. Mode Toggle (Below Board)
        let modeBtn = createPixelButton(
            title: "ЧЕРНЫЕ: ИГРОК", // Initial text, will update
            color: UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)
        )
        modeBtn.addTarget(self, action: #selector(togglePlayerType), for: .touchUpInside)
        view.addSubview(modeBtn)
        self.modeButton = modeBtn
        
        // 3. Menu/Exit Button (Bottom Left)
        let exitBtn = createPixelButton(
            title: "МЕНЮ", 
            color: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        )
        exitBtn.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitBtn)
        self.exitButton = exitBtn
        
        // 4. Restart Button (Bottom Right)
        let restartBtn = createPixelButton(
            title: "РЕСТАРТ", 
            color: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        )
        restartBtn.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(restartBtn)
        self.restartButton = restartBtn
        
        // --- Constraints ---
        guard let boardView = boardView else { return }
        
        NSLayoutConstraint.activate([
            // Settings: Top Right
            settingsBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            settingsBtn.widthAnchor.constraint(equalToConstant: 140),
            settingsBtn.heightAnchor.constraint(equalToConstant: 44),
            
            // Mode Toggle: Below Board, Centered
            modeBtn.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 20),
            modeBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeBtn.widthAnchor.constraint(equalToConstant: 240),
            modeBtn.heightAnchor.constraint(equalToConstant: 50),
            
            // Exit: Bottom Left
            exitBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            exitBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            exitBtn.widthAnchor.constraint(equalToConstant: 160),
            exitBtn.heightAnchor.constraint(equalToConstant: 60),
            
            // Restart: Bottom Right
            restartBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            restartBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            restartBtn.widthAnchor.constraint(equalToConstant: 160),
            restartBtn.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func createPixelButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .black)
        button.setTitleColor(.white, for: .normal)
        
        button.backgroundColor = color
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor
        
        // Pixel art style shadow
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
            sender.transform = CGAffineTransform(translationX: 2, y: 2)
        }
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.layer.shadowOffset = CGSize(width: 4, height: 4)
            sender.transform = .identity
        }
    }

    @objc private func didEnterBackground() {
        // Only save if game is actually in progress, not finished
        if game.inProgress {
            try? save(to: saveURL)
            if let startTime = gameStartTime {
                Storage.shared.savedGameStartTime = startTime
            }
            pauseGame()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        // Theme logic remains
        if let themeName = Storage.shared.boardTheme,
           let theme = Theme(rawValue: themeName) {
            boardView?.theme = theme
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isPaused {
            pauseGame()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    @objc private func togglePlayerType() {
        SoundManager.shared.playButtonSound()
        // Toggle black player state
        game.blackIsHuman.toggle()
        
        game.whiteIsHuman = true // Always true for now based on previous code
        
        updateModeButtonText()
        makeComputerMove()
    }
    
    private func updateModeButtonText() {
        let text = game.blackIsHuman ? "ЧЕРНЫЕ: ИГРОК" : "ЧЕРНЫЕ: БОТ"
        modeButton?.setTitle(text, for: .normal)
    }

    /* Undo removed */
    
    @objc private func exitTapped() {
        SoundManager.shared.playButtonSound()
        if game.inProgress {
            let alert = UIAlertController(title: "Выход", message: "Текущий прогресс будет сохранен.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
                self?.performExit()
            })
            present(alert, animated: true)
        } else {
            performExit()
        }
    }
    
    private func performExit() {
        SoundManager.shared.playButtonSound()
        
        // Clear saved game if game is finished
        if !game.inProgress {
            try? FileManager.default.removeItem(at: saveURL)
            Storage.shared.savedGameStartTime = nil
        }
        
        if let windowScene = view.window?.windowScene,
           let delegate = windowScene.delegate as? SceneDelegate,
           delegate.window?.rootViewController == self {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menu = MainMenuViewController()
             menu.modalTransitionStyle = .crossDissolve
             
            UIView.transition(with: delegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                delegate.window?.rootViewController = menu
            }, completion: nil)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction private func resetGame() {
        SoundManager.shared.playButtonSound()
        
        // Clear any previous game result and saved state
        gameResult = nil
        try? FileManager.default.removeItem(at: saveURL)
        Storage.shared.savedGameStartTime = nil
        
        game.reset()
        gameStartTime = Date()
        UIView.animate(withDuration: 0.4, animations: {
            self.boardView?.board = self.game.board
            self.updateUI()
        }, completion: { [weak self] _ in
            self?.update()
        })
        setSelection(nil)
    }

    // Undo function removed
/*
    @IBAction private func undo() {
        SoundManager.shared.playButtonSound()
        game.undo()
        UIView.animate(withDuration: 0.4, animations: {
            self.boardView?.board = self.game.board
            self.updateUI()
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if self.game.playerIsHuman() || !self.game.playerIsHuman(self.game.turn.other) {
                self.update()
            } else {
                self.undo()
            }
        })
        setSelection(nil)
    }
*/

    @IBAction private func settings() {
        SoundManager.shared.playButtonSound()
        let vc = SettingsViewController()
        vc.isGameActive = true
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}

extension ViewController {
    func load(from url: URL) throws {
        let data = try Data(contentsOf: url)
        game = try JSONDecoder().decode(Game.self, from: data)
    }

    func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(game)
        try data.write(to: url, options: .atomic)
    }
}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, didTap position: Position) {
        guard let selection = boardView.selection else {
            if game.canSelectPiece(at: position) {
                setSelection(position)
            } else {
                boardView.jigglePiece(at: position)
            }
            return
        }
        guard game.canMove(from: selection, to: position) else {
            if selection == position {
                setSelection(nil)
            } else if game.canSelectPiece(at: position) {
                setSelection(position)
            }
            return
        }
        makeMove(Move(from: selection, to: position))
    }
}

    // canUndo removed
/*
    var canUndo: Bool {
        game.inProgress && (game.playerIsHuman() || game.playerIsHuman(game.turn.other))
    }
*/

extension ViewController {

    func updateUI() {
        // Undo/Reset logic handled by custom UI state if needed, mostly handled by button actions now
        // setControl(undoButton, enabled: canUndo) // Removed
        // setControl(resetButton, enabled: game.inProgress) // Removed
        boardView?.flipBlackPieces = game.blackIsHuman && Storage.shared.flipBlackWhenHuman
    }

    func setControl(_ control: UIControl?, enabled: Bool) {
        control?.isEnabled = enabled
        control?.alpha = enabled ? 1 : 0.5
    }

    func update() {
        let gameState = game.state
        switch gameState {
        case .checkMate, .staleMate, .insufficientMaterial:
            let message: String
            switch gameState {
            case .staleMate:
                message = "Stalemate: Nobody wins"
                gameResult = "draw"
                submitGameResult(result: "draw", opponentType: "computer")
            case .insufficientMaterial:
                message = "Insufficient material: Nobody wins"
                gameResult = "draw"
                submitGameResult(result: "draw", opponentType: "computer")
            case .checkMate:
                message = "Checkmate: \(game.turn.other) wins"
                let humanWon: Bool
                if game.turn.other == .white {
                    humanWon = game.whiteIsHuman
                } else {
                    humanWon = game.blackIsHuman
                }
                
                gameResult = humanWon ? "win" : "loss"
                
                if humanWon {
                    SoundManager.shared.playWinSound()
                } else {
                    SoundManager.shared.playLoseSound()
                }
                
                submitGameResult(result: gameResult!, opponentType: "computer")
            case .check, .idle:
                preconditionFailure()
            }
            let alert = UIAlertController(
                title: "Game Over",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .check:
            boardView?.pulsePiece(at: game.kingPosition(for: game.turn)) {
                self.makeComputerMove()
            }
        case .idle:
            makeComputerMove()
        }
    }
    

    func pauseGame() {
        isPaused = true
        switch game.state {
        case .check, .idle:
            let alert = UIAlertController(
                title: "Game in Progress",
                message: "\(game.turn.rawValue.capitalized)'s turn",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Resume", style: .default) { _ in
                self.isPaused = false
                self.update()
            })
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
                self.isPaused = false
                self.resetGame()
            })
            present(alert, animated: true)
        case .checkMate, .staleMate, .insufficientMaterial:
            update()
        }
    }

    func setSelection(_ position: Position?) {
        let moves = position.map(game.movesForPiece(at:)) ?? []
        UIView.animate(withDuration: 0.2, animations: {
            self.boardView?.selection = position
            self.boardView?.moves = moves
        })
    }

    func makeComputerMove() {
        if !isPaused, !game.playerIsHuman(), let move = game.nextMove(for: game.turn) {
            makeMove(move)
        } else {
            updateUI()
        }
    }

    func makeMove(_ move: Move) {
        guard let boardView = boardView else {
            return
        }
        if gameStartTime == nil && !game.inProgress {
            gameStartTime = Date()
        }
        
        let oldGame = game
        let isCapture = game.board.piece(at: move.to) != nil
        
        game.makeMove(move)
        let board1 = game.board
        let kingPosition = game.kingPosition(for: oldGame.turn)
        let wasInCheck = game.pieceIsThreatened(at: kingPosition)
        let wasPromoted = !wasInCheck && game.canPromotePiece(at: move.to)
        let wasHuman = oldGame.playerIsHuman()
        if wasInCheck {
            game = oldGame
        } else {
            if isCapture {
                SoundManager.shared.playCaptureSound()
            } else {
                SoundManager.shared.playMoveSound()
            }
        }
        let board2 = game.board
        UIView.animate(withDuration: 0.4, animations: {
            boardView.selection = nil
            boardView.board = board1
            boardView.moves = []
            self.updateUI()
        }, completion: { [weak self] _ in
            guard let self = self, board2 == self.game.board else { return }
            if wasInCheck {
                UIView.animate(withDuration: 0.2, animations: {
                    boardView.board = board2
                })
                boardView.jigglePiece(at: kingPosition)
                return
            }
            if wasPromoted {
                if !wasHuman {
                    self.game.promotePiece(at: move.to, to: .queen)
                    let board2 = self.game.board
                    UIView.animate(withDuration: 0.4, animations: {
                        boardView.board = board2
                    }, completion: { [weak self] _ in
                        guard board2 == self?.game.board else { return }
                        self?.update()
                    })
                    return
                }
                let alert = UIAlertController(
                    title: "Promote Pawn",
                    message: nil,
                    preferredStyle: .alert
                )
                for piece in [PieceType.queen, .rook, .bishop, .knight] {
                    alert.addAction(UIAlertAction(
                        title: piece.rawValue.capitalized,
                        style: .default
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.game.promotePiece(at: move.to, to: piece)
                        boardView.board = self.game.board
                        self.update()
                    })
                }
                self.present(alert, animated: true)
                return
            }
            self.update()
        })
    }
    
    // Moved helper here since it's private to file/extension
    private func submitGameResult(result: String, opponentType: String) {
        // Prevent duplicate submissions
        guard gameResult != nil else {
            print("⚠️ Попытка повторной отправки результата предотвращена")
            return
        }
        
        let startTime = gameStartTime ?? Date()
        if gameStartTime == nil {
             print("⚠️ Время начала не найдено, используем текущее время (0 длительность)")
        }
        
        let isWin = (result == "win")
        let isDraw = (result == "draw")
        let elo = 0 
        
        // Calculate duration
        let duration = Date().timeIntervalSince(startTime)
        print("⏱️ Game Duration: \(String(format: "%.2f", duration)) seconds")
        
        // Clear game result immediately to prevent duplicate submissions
        gameResult = nil
        gameStartTime = nil
        Storage.shared.savedGameStartTime = nil
        
        // Clear saved game file since game is finished
        try? FileManager.default.removeItem(at: saveURL)
        
        APIService.shared.submitGameResult(
            isWin: isWin,
            isDraw: isDraw,
            eloBefore: elo,
            eloAfter: elo,
            duration: duration
        ) { result in
            switch result {
            case .success:
                print("✅ Результат игры успешно отправлен на сервер (с временем)")
            case .failure(let error):
                print("❌ Ошибка отправки результата игры: \(error.localizedDescription)")
            }
        }
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        Theme.allCases.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        Theme.allCases[row].rawValue
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        boardView?.theme = Theme.allCases[row]
    }
}
