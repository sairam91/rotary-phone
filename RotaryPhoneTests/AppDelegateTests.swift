import XCTest
@testable import RotaryPhone

class AppDelegateTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }
    
    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }
    
    // MARK: - App Launch Tests
    
    func testApplicationDidFinishLaunchingWithOptions() {
        // Given
        let application = UIApplication.shared
        let launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        
        // When
        let result = appDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Then
        XCTAssertTrue(result, "App should launch successfully")
    }
    
    func testApplicationDidFinishLaunchingWithOptionsReturnsTrue() {
        // Given
        let application = UIApplication.shared
        let launchOptions: [UIApplication.LaunchOptionsKey: Any]? = [
            .sourceApplication: "com.test.app"
        ]
        
        // When
        let result = appDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Then
        XCTAssertTrue(result, "App should handle launch options correctly")
    }
    
    // MARK: - Scene Session Tests
    
    func testAppDelegateHasSceneConfigurationMethod() {
        // Test that the method exists
        let hasMethod = appDelegate.responds(to: #selector(UIApplicationDelegate.application(_:configurationForConnecting:options:)))
        XCTAssertTrue(hasMethod, "AppDelegate should respond to scene configuration method")
    }
    
    func testAppDelegateHasDidDiscardSceneSessionsMethod() {
        // Test that the method exists
        let hasMethod = appDelegate.responds(to: #selector(UIApplicationDelegate.application(_:didDiscardSceneSessions:)))
        XCTAssertTrue(hasMethod, "AppDelegate should respond to didDiscardSceneSessions method")
    }
    
    // MARK: - App Delegate Instance Tests
    
    func testAppDelegateConformsToUIApplicationDelegate() {
        // Then
        XCTAssertTrue(appDelegate is UIApplicationDelegate, "AppDelegate should conform to UIApplicationDelegate")
    }
    
    func testAppDelegateInheritsFromUIResponder() {
        // Then
        XCTAssertTrue(appDelegate is UIResponder, "AppDelegate should inherit from UIResponder")
    }
}

