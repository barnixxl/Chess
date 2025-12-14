
import UIKit

class ViewController: UIViewController {
    private var game: Game = .init()
    private var isPaused: Bool = false
    private var gameStartTime: Date?
    private var gameResult: String? // "win", "loss", "draw"

    @IBOutlet var boardView: BoardView?
    @IBOutlet var undoButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var whiteToggle: UISegmentedControl? 
    @IBOutlet var blackToggle: UISegmentedControl?

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
        
        applyPixelStyle(to: undoButton)
        applyPixelStyle(to: resetButton)
        
        // Fix for NSUnknownKeyException: restore outlet but hide usage
        whiteToggle?.isHidden = true
        game.whiteIsHuman = true 
        blackToggle?.selectedSegmentIndex = game.blackIsHuman ? 0 : 1
        
        boardView?.board = game.board
        isPaused = game.inProgress
        if !game.inProgress {
            gameStartTime = Date()
        } else {
            gameStartTime = Storage.shared.savedGameStartTime
        }

        updateUI()
        update()
        
        // Re-create Settings Button programmatically
        let settingsBtn = UIButton(type: .system)
        settingsBtn.setTitle("⚙️", for: .normal)
        settingsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        settingsBtn.setTitleColor(.white, for: .normal)
        settingsBtn.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        settingsBtn.layer.borderWidth = 2
        settingsBtn.layer.borderColor = UIColor.white.cgColor
        settingsBtn.layer.cornerRadius = 4
        settingsBtn.translatesAutoresizingMaskIntoConstraints = false
        settingsBtn.addTarget(self, action: #selector(settings), for: .touchUpInside)
        view.addSubview(settingsBtn)
        
        NSLayoutConstraint.activate([
            settingsBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            settingsBtn.widthAnchor.constraint(equalToConstant: 40),
            settingsBtn.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Exit Button
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("EXIT TO MENU", for: .normal)
        exitButton.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        exitButton.layer.borderWidth = 2
        exitButton.layer.borderColor = UIColor.white.cgColor
        exitButton.layer.cornerRadius = 4
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            exitButton.heightAnchor.constraint(equalToConstant: 30),
            exitButton.widthAnchor.constraint(equalToConstant: 120)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func didEnterBackground() {
        try? save(to: saveURL)
        if let startTime = gameStartTime {
            Storage.shared.savedGameStartTime = startTime
        }
        if game.inProgress {
            pause()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        if let themeName = Storage.shared.boardTheme,
           let theme = Theme(rawValue: themeName) {
            boardView?.theme = theme
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isPaused {
            pause()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    @IBAction private func togglePlayerType() {
        game.whiteIsHuman = true
        game.blackIsHuman = blackToggle?.selectedSegmentIndex == 0
        makeComputerMove()
    }
    
    private func applyPixelStyle(to button: UIButton?) {
        guard let button = button else { return }
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
    }
    
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

private extension ViewController {
    var canUndo: Bool {
        game.inProgress && (game.playerIsHuman() || game.playerIsHuman(game.turn.other))
    }

    func updateUI() {
        setControl(undoButton, enabled: canUndo)
        setControl(resetButton, enabled: game.inProgress)
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
    

    func pause() {
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
        let startTime = gameStartTime ?? Date()
        if gameStartTime == nil {
             print("⚠️ Время начала не найдено, используем текущее время (0 длительность)")
        }
        
        let isWin = (result == "win")
        let isDraw = (result == "draw")
        let elo = 0 
        
        APIService.shared.submitGameResult(
            isWin: isWin,
            isDraw: isDraw,
            eloBefore: elo,
            eloAfter: elo
        ) { result in
            switch result {
            case .success:
                print("Результат игры успешно отправлен на сервер")
            case .failure(let error):
                print("Ошибка отправки результата игры: \(error.localizedDescription)")
            }
        }
        
        gameStartTime = nil
        Storage.shared.savedGameStartTime = nil
        gameResult = nil
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
