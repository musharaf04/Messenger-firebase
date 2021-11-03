import UIKit
import FirebaseAuth
import ALLoadingView
class RegisterUserViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK:- Load
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
   
       imageView.layer.cornerRadius = imageView.frame.width/2.0
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
//    override func viewDidLayoutSubviews() {
//        imageView.layer.cornerRadius = imageView.width
//    }
    @objc func didTapChangeProfilePic()
    {
        presentPhotoActionSheet()
    }
    //MARK:- OutletFunctions
    @IBAction func btnRegister(_ sender: Any) {
        AnimationCall()
        DatabaseManager.shared.userExist(with: txtEmail.text!, completion: {exist in
            guard !exist else{
                //user ALready  exist
                return
            }
            
            Auth.auth().createUser(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { [weak self] authResult, error in
                guard let strongSelf = self else{
                    return
                }
                guard let result = authResult, error == nil else{
                    print("Falied to login")
                    self!.alertUserMessage(message: "Failed")
                    ActivityIndicator.activity.stopAnimating()
                    ActivityIndicator.activity.stopAnimating()
                  //  self!.alertUserMessage(message: "Failed To LogIN")
                    return
                }
                let user = result.user
                print("Logged in user = \(user)")
                let chatUser = ChatAppUser(fName: self!.txtFName.text!, lName: self!.txtLName.text!, emailAddress: self!.txtEmail.text!)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {succes in
                    if succes{
                        //UPLOAD IMAGE
                        guard let image = self!.imageView.image, let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.UploadProfilePicture(with: data, fileName: fileName, completion: {result in
                            switch result{
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print("Storage Manager Error:\(error)")
                            }
                        })
                    }
                } )
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
                self!.alertUserMessage(message: "Sucessful")
                ActivityIndicator.activity.stopAnimating()
                self!.dismissScreen()
            })
        })
        
       
    }
    //MARK:- Functions
    func dismissScreen()
    {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "MainTabBarController")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
        
    }
    fileprivate func AnimationCall() {
        ALLoadingView.manager.resetToDefaults(message: "Registering..")
        //ALLoadingView.manager.resetToDefaults()
        ALLoadingView.manager.blurredBackground = true
        ALLoadingView.manager.animationDuration = 1.0
        ALLoadingView.manager.itemSpacing = 30.0
        ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
    }
    func alertUserMessage(message: String = "Please Enter All Information")
    {
        let alert = UIAlertController(
            title: "Wops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
    
}

extension RegisterUserViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select photo",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc , animated: true)
    }
    func presentPhotoPicker()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc , animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
