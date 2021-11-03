//
//  ProfileViewController.swift
//  MessengerFireBase
//
//  Created by apple on 02/11/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {

    let data = ["Log Out"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = createTableHeader()
        // Do any additional setup after loading the view.
    }
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "image/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        headerView.backgroundColor = .blue
        let imageView = UIImageView(frame: CGRect(x: (headerView.frame.width-150) / 2, y: 75, width: 150, height: 150))
      
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(path: path, completion: {[weak self]resullt in
            switch resullt{
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("failed to got download url")
            }
        })
        
        return headerView
    }
    func downloadImage(imageView: UIImageView, url: URL)
    {
        URLSession.shared.dataTask(with: url, completionHandler: {data, _,error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
}
extension ProfileViewController : UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
//            guard let strongSelf = self else{
//                return
//            }
            
            do{
                try Auth.auth().signOut()
                
                let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                let initialViewController = self!.storyboard!.instantiateViewController(withIdentifier: "NV")
                appDelegate.window?.rootViewController = initialViewController
                appDelegate.window?.makeKeyAndVisible()
            }catch
            {
                print("Failed to LogOut")
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet,animated: true)
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ProfileTableViewCell
        
        cell.lblLogout.text = data[indexPath.row]
        
        //if int
        //cell.price.text = "\(device.price!)"
        return cell
    }
    
    
    
}
