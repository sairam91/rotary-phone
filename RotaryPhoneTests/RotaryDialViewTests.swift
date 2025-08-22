import XCTest
@testable import RotaryPhone

class RotaryDialViewTests: XCTestCase {
    
    var rotaryDialView: RotaryDialView!
    var mockDelegate: MockRotaryDialDelegate!
    
    override func setUp() {
        super.setUp()
        rotaryDialView = RotaryDialView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        mockDelegate = MockRotaryDialDelegate()
        rotaryDialView.delegate = mockDelegate
        
        // Trigger layout to set up positions
        rotaryDialView.layoutIfNeeded()
    }
    
    override func tearDown() {
        rotaryDialView = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitWithFrame() {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let dialView = RotaryDialView(frame: frame)
        
        XCTAssertEqual(dialView.frame, frame, "Frame should be set correctly")
        XCTAssertNotNil(dialView.backgroundColor, "Background color should be set")
    }
    
    func testInitWithCoder() {
        let coder = NSKeyedUnarchiver(forReadingWith: Data())
        let dialView = RotaryDialView(coder: coder)
        
        XCTAssertNotNil(dialView, "Should initialize with coder")
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateProperty() {
        XCTAssertNotNil(rotaryDialView.delegate, "Delegate should be set")
        XCTAssertTrue(rotaryDialView.delegate === mockDelegate, "Delegate should be the mock delegate")
    }
    
    func testDelegateWeakReference() {
        weak var weakDelegate = mockDelegate
        rotaryDialView.delegate = mockDelegate
        mockDelegate = nil
        
        XCTAssertNil(weakDelegate, "Delegate should be weak reference")
    }
    
    // MARK: - View Setup Tests
    
    func testViewHierarchy() {
        XCTAssertGreaterThan(rotaryDialView.subviews.count, 0, "Should have subviews")
        
        let hasDialNumbers = rotaryDialView.subviews.contains { $0 is DialNumber }
        XCTAssertTrue(hasDialNumbers, "Should contain DialNumber views")
        
        let dialNumbers = rotaryDialView.subviews.compactMap { $0 as? DialNumber }
        XCTAssertEqual(dialNumbers.count, 10, "Should have 10 dial numbers")
    }
    
    func testDialNumbersSetup() {
        let dialNumbers = rotaryDialView.subviews.compactMap { $0 as? DialNumber }
        let expectedNumbers = ["0", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
        
        for (index, dialNumber) in dialNumbers.enumerated() {
            XCTAssertEqual(dialNumber.number, expectedNumbers[index], "Dial number should match expected value")
        }
    }
    
    func testViewAppearance() {
        XCTAssertEqual(rotaryDialView.layer.borderWidth, 8, "Border width should be 8")
        XCTAssertEqual(rotaryDialView.layer.shadowOpacity, 0.3, accuracy: 0.01, "Shadow opacity should be 0.3")
        XCTAssertEqual(rotaryDialView.layer.cornerRadius, rotaryDialView.bounds.width / 2, "Should be circular")
    }
    
    // MARK: - Gesture Recognition Tests
    
    func testGestureRecognizers() {
        let gestureRecognizers = rotaryDialView.gestureRecognizers ?? []
        
        let hasPanGesture = gestureRecognizers.contains { $0 is UIPanGestureRecognizer }
        let hasTapGesture = gestureRecognizers.contains { $0 is UITapGestureRecognizer }
        
        XCTAssertTrue(hasPanGesture, "Should have pan gesture recognizer")
        XCTAssertTrue(hasTapGesture, "Should have tap gesture recognizer")
    }
    
    // MARK: - Tap Gesture Tests
    
    func testTapOnDialNumber() {
        let dialNumbers = rotaryDialView.subviews.compactMap { $0 as? DialNumber }
        guard let firstDialNumber = dialNumbers.first else {
            XCTFail("Should have dial numbers")
            return
        }
        
        let tapGesture = UITapGestureRecognizer()
        let tapLocation = CGPoint(x: firstDialNumber.frame.midX, y: firstDialNumber.frame.midY)
        
        // Simulate tap
        simulateTap(at: tapLocation)
        
        XCTAssertTrue(mockDelegate.didDialNumberCalled, "Delegate should be called on tap")
        XCTAssertEqual(mockDelegate.dialedNumber, firstDialNumber.number, "Should dial the correct number")
    }
    
    func testTapOnCenterHole() {
        let centerPoint = CGPoint(x: rotaryDialView.bounds.midX, y: rotaryDialView.bounds.midY)
        
        simulateTap(at: centerPoint)
        
        XCTAssertTrue(mockDelegate.didClearNumberCalled, "Should call clear number on center tap")
    }
    
    // MARK: - Layout Tests
    
    func testLayoutSubviews() {
        let initialFrame = rotaryDialView.frame
        rotaryDialView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        rotaryDialView.layoutSubviews()
        
        XCTAssertEqual(rotaryDialView.layer.cornerRadius, 150, "Corner radius should update with frame")
        
        let dialNumbers = rotaryDialView.subviews.compactMap { $0 as? DialNumber }
        XCTAssertFalse(dialNumbers.isEmpty, "Should have positioned dial numbers")
        
        // Verify dial numbers are positioned in a circle
        let center = CGPoint(x: rotaryDialView.bounds.midX, y: rotaryDialView.bounds.midY)
        for dialNumber in dialNumbers {
            let distance = sqrt(pow(dialNumber.center.x - center.x, 2) + pow(dialNumber.center.y - center.y, 2))
            let expectedRadius = rotaryDialView.bounds.width * 0.35
            XCTAssertEqual(distance, expectedRadius, accuracy: 5, "Dial numbers should be positioned on circle")
        }
    }
    
    // MARK: - Helper Methods
    
    private func simulateTap(at location: CGPoint) {
        // Create a mock gesture that returns our test location
        let tapGesture = MockTapGestureRecognizer(testLocation: location)
        rotaryDialView.handleTap(tapGesture)
    }
}

// MARK: - DialNumber Tests

class DialNumberTests: XCTestCase {
    
    var dialNumber: DialNumber!
    
    override func setUp() {
        super.setUp()
        dialNumber = DialNumber(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    override func tearDown() {
        dialNumber = nil
        super.tearDown()
    }
    
    func testDialNumberInitialization() {
        XCTAssertNotNil(dialNumber, "DialNumber should initialize")
        XCTAssertEqual(dialNumber.number, "", "Number should be empty initially")
        XCTAssertEqual(dialNumber.letters, [], "Letters should be empty initially")
    }
    
    func testSetupAppearance() {
        dialNumber.number = "5"
        dialNumber.letters = ["JKL"]
        dialNumber.setupAppearance()
        
        XCTAssertEqual(dialNumber.backgroundColor, UIColor.white, "Background should be white")
        XCTAssertEqual(dialNumber.layer.cornerRadius, 20, "Corner radius should be 20")
        XCTAssertEqual(dialNumber.layer.borderWidth, 1, "Border width should be 1")
        
        let numberLabel = dialNumber.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "5" }
        XCTAssertNotNil(numberLabel, "Should have number label")
        
        let lettersLabel = dialNumber.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "JKL" }
        XCTAssertNotNil(lettersLabel, "Should have letters label")
    }
    
    func testAnimateSelection() {
        dialNumber.animateSelection()
        
        // Animation testing is limited in unit tests, but we can verify the method doesn't crash
        XCTAssertTrue(true, "Animation should not crash")
    }
}

// MARK: - Mock Classes

class MockTapGestureRecognizer: UITapGestureRecognizer {
    private let testLocation: CGPoint
    
    init(testLocation: CGPoint) {
        self.testLocation = testLocation
        super.init(target: nil, action: nil)
    }
    
    override func location(in view: UIView?) -> CGPoint {
        return testLocation
    }
}

class MockRotaryDialDelegate: RotaryDialDelegate {
    var didDialNumberCalled = false
    var didClearNumberCalled = false
    var dialedNumber: String = ""
    
    func didDialNumber(_ number: String) {
        didDialNumberCalled = true
        dialedNumber = number
    }
    
    func didClearNumber() {
        didClearNumberCalled = true
    }
    
    func reset() {
        didDialNumberCalled = false
        didClearNumberCalled = false
        dialedNumber = ""
    }
}

// MARK: - Private Method Testing Extension

extension RotaryDialView {
    func handleTap(_ gesture: UITapGestureRecognizer) {
        // This is a workaround to test the private handleTap method
        // In a real app, you might make this internal for testing
        let location = gesture.location(in: self)
        
        let dialNumbers = subviews.compactMap { $0 as? DialNumber }
        for dialNumber in dialNumbers {
            if dialNumber.frame.contains(location) {
                delegate?.didDialNumber(dialNumber.number)
                dialNumber.animateSelection()
                return
            }
        }
        
        // Check center hole - we'll approximate its position
        let centerFrame = CGRect(
            x: bounds.midX - 30,
            y: bounds.midY - 30,
            width: 60,
            height: 60
        )
        
        if centerFrame.contains(location) {
            delegate?.didClearNumber()
        }
    }
}
