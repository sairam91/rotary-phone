import UIKit
import AVFoundation

protocol RotaryDialDelegate: AnyObject {
    func didDialNumber(_ number: String)
    func didClearNumber()
}

class RotaryDialView: UIView {
    
    weak var delegate: RotaryDialDelegate?
    
    private var dialNumbers: [DialNumber] = []
    private var centerHole: UIView!
    private var fingerHole: UIView!
    private var isRotating = false
    private var initialTouchAngle: CGFloat = 0
    private var currentRotation: CGFloat = 0
    private var maxRotation: CGFloat = 0
    private var selectedNumber: String = ""
    private var stopperPosition: CGFloat = CGFloat.pi * 0.75 // Bottom right position
    private var audioPlayer: AVAudioPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDial()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDial()
    }
    
    private func setupDial() {
        backgroundColor = .clear
        setupDialBase()
        setupDialNumbers()
        setupCenterHole()
        setupFingerHole()
        setupGestureRecognizers()
        setupAudioPlayer()
    }
    
    private func setupDialBase() {
        layer.cornerRadius = bounds.width / 2
        backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        layer.borderWidth = 8
        layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        setupDialNumberPositions()
        setupFingerHolePosition()
    }
    
    private func setupDialNumbers() {
        let numbers = ["0", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
        let letters = [[""], ["WXYZ"], ["TUV"], ["PQRS"], ["MNO"], ["JKL"], ["GHI"], ["DEF"], ["ABC"], [""]]
        
        for i in 0..<numbers.count {
            let dialNumber = DialNumber()
            dialNumber.number = numbers[i]
            dialNumber.letters = letters[i]
            dialNumber.setupAppearance()
            addSubview(dialNumber)
            dialNumbers.append(dialNumber)
        }
    }
    
    private func setupDialNumberPositions() {
        let radius: CGFloat = bounds.width * 0.35
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Use 3/4 of the circle (270 degrees) starting from 4 o'clock
        let totalAngle: CGFloat = 3 * CGFloat.pi / 2  // 270 degrees
        let startAngle: CGFloat = CGFloat.pi / 3       // Start at 4 o'clock (60 degrees)
        
        for (index, dialNumber) in dialNumbers.enumerated() {
            let angle = startAngle + CGFloat(index) * (totalAngle / CGFloat(dialNumbers.count - 1))
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            dialNumber.frame = CGRect(x: x - 20, y: y - 20, width: 40, height: 40)
        }
    }
    
    private func setupCenterHole() {
        centerHole = UIView()
        centerHole.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        centerHole.layer.borderWidth = 2
        centerHole.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        addSubview(centerHole)
        
        let holeSize: CGFloat = 60
        centerHole.frame = CGRect(
            x: bounds.midX - holeSize/2,
            y: bounds.midY - holeSize/2,
            width: holeSize,
            height: holeSize
        )
        centerHole.layer.cornerRadius = holeSize / 2
    }
    
    private func setupFingerHole() {
        fingerHole = UIView()
        fingerHole.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        fingerHole.layer.borderWidth = 1
        fingerHole.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        addSubview(fingerHole)
        
        let holeSize: CGFloat = 15
        fingerHole.frame = CGRect(x: 0, y: 0, width: holeSize, height: holeSize)
        fingerHole.layer.cornerRadius = holeSize / 2
    }
    
    private func setupFingerHolePosition() {
        let radius: CGFloat = bounds.width * 0.42
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angle: CGFloat = CGFloat.pi * 0.4 // Between 0 and 1 on the dial
        
        let x = center.x + cos(angle) * radius
        let y = center.y + sin(angle) * radius
        
        let holeSize: CGFloat = 15
        fingerHole.frame = CGRect(x: x - holeSize/2, y: y - holeSize/2, width: holeSize, height: holeSize)
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupAudioPlayer() {
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        guard let audioURL = Bundle.main.url(forResource: "Firefly_audio_sound_of_a_rotary_dial_variation1", withExtension: "wav") else {
            print("❌ Could not find audio file in bundle")
            print("Bundle path: \(Bundle.main.bundlePath)")
            if let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) {
                print("Bundle contents: \(bundleContents)")
            }
            return
        }
        
        print("✅ Found audio file at: \(audioURL)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            print("✅ Audio player created successfully")
        } catch {
            print("❌ Error creating audio player: \(error)")
        }
    }
    
    private func playDialSound() {
        guard let player = audioPlayer else {
            print("❌ Audio player not initialized")
            return
        }
        
        player.stop()
        player.currentTime = 0
        let success = player.play()
        print("🔊 Attempting to play audio: \(success ? "SUCCESS" : "FAILED")")
    }
    
    private func stopDialSound() {
        audioPlayer?.stop()
        print("🔇 Audio stopped")
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        switch gesture.state {
        case .began:
            // Check if touch started on finger hole or a number
            if fingerHole.frame.contains(location) || isLocationOnNumber(location) {
                let angle = atan2(location.y - center.y, location.x - center.x)
                initialTouchAngle = angle
                isRotating = true
                selectedNumber = getNumberAtLocation(location)
                maxRotation = 0
                playDialSound()
            }
            
        case .changed:
            if isRotating {
                let currentAngle = atan2(location.y - center.y, location.x - center.x)
                var deltaAngle = currentAngle - initialTouchAngle
                
                // Normalize angle difference to handle crossing 0/2π boundary
                if deltaAngle > CGFloat.pi {
                    deltaAngle -= 2 * CGFloat.pi
                } else if deltaAngle < -CGFloat.pi {
                    deltaAngle += 2 * CGFloat.pi
                }
                
                // Only allow clockwise rotation (positive delta)
                if deltaAngle > 0 {
                    currentRotation += deltaAngle
                    maxRotation = max(maxRotation, currentRotation)
                    
                    // Limit rotation to prevent over-rotation
                    let maxAllowedRotation: CGFloat = CGFloat.pi * 0.8
                    currentRotation = min(currentRotation, maxAllowedRotation)
                    
                    transform = CGAffineTransform(rotationAngle: currentRotation)
                }
                
                initialTouchAngle = currentAngle
            }
            
        case .ended, .cancelled:
            if isRotating {
                isRotating = false
                stopDialSound()
                
                // Check if we rotated far enough to reach the stopper
                let stopperThreshold: CGFloat = CGFloat.pi * 0.6
                
                if maxRotation >= stopperThreshold && !selectedNumber.isEmpty {
                    // Number was dialed successfully
                    delegate?.didDialNumber(selectedNumber)
                    
                    // Find and animate the selected number
                    if let numberView = dialNumbers.first(where: { $0.number == selectedNumber }) {
                        numberView.animateSelection()
                    }
                }
                
                // Animate back to original position
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [], animations: {
                    self.transform = .identity
                }, completion: nil)
                
                // Reset state
                currentRotation = 0
                maxRotation = 0
                selectedNumber = ""
            }
            
        default:
            break
        }
    }
    
    private func isLocationOnNumber(_ location: CGPoint) -> Bool {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let distance = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
        let innerRadius: CGFloat = bounds.width * 0.25
        let outerRadius: CGFloat = bounds.width * 0.45
        return distance >= innerRadius && distance <= outerRadius
    }
    
    private func getNumberAtLocation(_ location: CGPoint) -> String {
        for dialNumber in dialNumbers {
            let expandedFrame = dialNumber.frame.insetBy(dx: -10, dy: -10)
            if expandedFrame.contains(location) {
                return dialNumber.number
            }
        }
        return ""
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        for dialNumber in dialNumbers {
            if dialNumber.frame.contains(location) {
                delegate?.didDialNumber(dialNumber.number)
                dialNumber.animateSelection()
                return
            }
        }
        
        if centerHole.frame.contains(location) {
            delegate?.didClearNumber()
            animateCenterHole()
        }
    }
    
    private func animateCenterHole() {
        UIView.animate(withDuration: 0.1, animations: {
            self.centerHole.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.centerHole.transform = .identity
            }
        }
    }
}

class DialNumber: UIView {
    var number: String = ""
    var letters: [String] = []
    
    private var numberLabel: UILabel!
    private var lettersLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
    }
    
    private func setupLabels() {
        numberLabel = UILabel()
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.boldSystemFont(ofSize: 16)
        numberLabel.textColor = .black
        
        lettersLabel = UILabel()
        lettersLabel.textAlignment = .center
        lettersLabel.font = UIFont.systemFont(ofSize: 8)
        lettersLabel.textColor = .darkGray
        
        addSubview(numberLabel)
        addSubview(lettersLabel)
    }
    
    func setupAppearance() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        
        numberLabel.text = number
        lettersLabel.text = letters.joined()
        
        numberLabel.frame = CGRect(x: 0, y: 5, width: 40, height: 20)
        lettersLabel.frame = CGRect(x: 0, y: 22, width: 40, height: 10)
    }
    
    func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.backgroundColor = UIColor.lightGray
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
                self.backgroundColor = UIColor.white
            }
        }
    }
}