import UIKit
import FirebaseAuth
//import MaterialActivityIndicator
//import NVActivityIndicatorView
import ALLoadingView

class LogInViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK:- Labels/Variables
    //let indicator = MaterialActivityIndicatorView()
    
    //MARK:- Load
    override func viewDidLoad() {
        super.viewDidLoad()
        validate()
    }
    
    //MARK:- OutletFunctions
    @IBAction func btnLogin(_ sender: Any) {
        
        ActivityIndicator.activity.startAnimating()
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!, completion: { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else{
                print("Falied to login")
                ActivityIndicator.activity.stopAnimating()
                self!.alertUserMessage(message: "Failed To LogIN")
                return
            }
            let user = result.user
            
            UserDefaults.standard.set(self!.txtEmail.text!, forKey: "email")
            print("Logged in user = \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            ActivityIndicator.activity.stopAnimating()
            self!.dismissScreen()
        })
    }
    
    //MARK:- Functions
    private func validate()
    {
        if Auth.auth().currentUser != nil{
            
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "ConversationViewController")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func dismissScreen()
    {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MainTabBarController")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible() 
        
    }
    func alertUserMessage(message: String = "Please Enter All Information")
    {
        let alert = UIAlertController(
        title: "Wops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
}
