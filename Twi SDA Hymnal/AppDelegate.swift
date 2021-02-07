import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    override init() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let err = error {
                print("SignIn error: \(String(describing: err))")
                return
            }
        }

    }
}

