import UIKit

class ViewController: UIViewController {
    
    private var phoneNumberLabel: UILabel!
    private var rotaryDialView: RotaryDialView!
    private var phoneBody: UIView!
    private var currentNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneInterface()
    }
    
    private func setupPhoneInterface() {
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        
        setupPhoneBody()
        setupPhoneNumberDisplay()
        setupRotaryDial()
    }
    
    private func setupPhoneBody() {
        phoneBody = UIView()
        phoneBody.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        phoneBody.layer.cornerRadius = 30
        phoneBody.layer.shadowColor = UIColor.black.cgColor
        phoneBody.layer.shadowOpacity = 0.3
        phoneBody.layer.shadowOffset = CGSize(width: 0, height: 10)
        phoneBody.layer.shadowRadius = 20
        phoneBody.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(phoneBody)
        
        NSLayoutConstraint.activate([
            phoneBody.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneBody.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phoneBody.widthAnchor.constraint(equalToConstant: 300),
            phoneBody.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    private func setupPhoneNumberDisplay() {
        phoneNumberLabel = UILabel()
        phoneNumberLabel.text = "___-___-____"
        phoneNumberLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        phoneNumberLabel.textColor = .white
        phoneNumberLabel.textAlignment = .center
        phoneNumberLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        phoneNumberLabel.layer.cornerRadius = 10
        phoneNumberLabel.layer.borderWidth = 2
        phoneNumberLabel.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        phoneBody.addSubview(phoneNumberLabel)
        
        NSLayoutConstraint.activate([
            phoneNumberLabel.topAnchor.constraint(equalTo: phoneBody.topAnchor, constant: 50),
            phoneNumberLabel.centerXAnchor.constraint(equalTo: phoneBody.centerXAnchor),
            phoneNumberLabel.widthAnchor.constraint(equalToConstant: 200),
            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupRotaryDial() {
        rotaryDialView = RotaryDialView()
        rotaryDialView.delegate = self
        rotaryDialView.translatesAutoresizingMaskIntoConstraints = false
        
        phoneBody.addSubview(rotaryDialView)
        
        NSLayoutConstraint.activate([
            rotaryDialView.centerXAnchor.constraint(equalTo: phoneBody.centerXAnchor),
            rotaryDialView.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 50),
            rotaryDialView.widthAnchor.constraint(equalToConstant: 250),
            rotaryDialView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func updatePhoneNumberDisplay() {
        let formatted = formatPhoneNumber(currentNumber)
        phoneNumberLabel.text = formatted
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number
        let template = "___-___-____"
        var result = template
        
        for (index, digit) in digits.enumerated() {
            if index < 10 {
                let templateIndex: String.Index
                switch index {
                case 0: templateIndex = result.index(result.startIndex, offsetBy: 0)
                case 1: templateIndex = result.index(result.startIndex, offsetBy: 1)
                case 2: templateIndex = result.index(result.startIndex, offsetBy: 2)
                case 3: templateIndex = result.index(result.startIndex, offsetBy: 4)
                case 4: templateIndex = result.index(result.startIndex, offsetBy: 5)
                case 5: templateIndex = result.index(result.startIndex, offsetBy: 6)
                case 6: templateIndex = result.index(result.startIndex, offsetBy: 8)
                case 7: templateIndex = result.index(result.startIndex, offsetBy: 9)
                case 8: templateIndex = result.index(result.startIndex, offsetBy: 10)
                case 9: templateIndex = result.index(result.startIndex, offsetBy: 11)
                default: continue
                }
                result.replaceSubrange(templateIndex...templateIndex, with: String(digit))
            }
        }
        
        return result
    }
}

extension ViewController: RotaryDialDelegate {
    func didDialNumber(_ number: String) {
        if currentNumber.count < 10 {
            currentNumber += number
            updatePhoneNumberDisplay()
            
            // Check if we have 10 digits and initiate call
            if currentNumber.count == 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.initiatePhoneCall()
                }
            }
        }
    }
    
    func didClearNumber() {
        currentNumber = ""
        updatePhoneNumberDisplay()
    }
}

// MARK: - Phone Call Functionality
extension ViewController {
    private func initiatePhoneCall() {
        guard currentNumber.count == 10 else { return }
        
        let phoneNumber = currentNumber
        let telURL = "tel://\(phoneNumber)"
        
        guard let url = URL(string: telURL) else {
            showCallError("Invalid phone number format")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            showCallConfirmation(for: phoneNumber) { [weak self] shouldCall in
                if shouldCall {
                    UIApplication.shared.open(url) { success in
                        DispatchQueue.main.async {
                            if !success {
                                self?.showCallError("Failed to initiate call")
                            } else {
                                self?.showCallInitiated()
                            }
                        }
                    }
                }
            }
        } else {
            showCallError("Phone calls not supported on this device")
        }
    }
    
    private func showCallConfirmation(for phoneNumber: String, completion: @escaping (Bool) -> Void) {
        let formattedNumber = formatPhoneNumber(phoneNumber)
        let alert = UIAlertController(
            title: "Make Call",
            message: "Call \(formattedNumber)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Call", style: .default) { _ in
            completion(true)
        })
        
        present(alert, animated: true)
    }
    
    private func showCallError(_ message: String) {
        let alert = UIAlertController(
            title: "Call Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.clearCurrentNumber()
        })
        
        present(alert, animated: true)
    }
    
    private func showCallInitiated() {
        phoneNumberLabel.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        phoneNumberLabel.text = "CALLING..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.clearCurrentNumber()
        }
    }
    
    private func clearCurrentNumber() {
        currentNumber = ""
        updatePhoneNumberDisplay()
        phoneNumberLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }
}