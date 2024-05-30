//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by PhuongDo on 27/05/2024.
//

import UIKit
import CoreData

class NewRestaurantController: UITableViewController {
    var restaurant:Restaurant!
    
    //MARK: - Add Restaurant Data from form to Core Data
    @IBAction func saveRestaurantInfomation(_ sender: UIBarButtonItem) {
        if (nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == ""){
            let alertController = UIAlertController(title: "Oops", message: "Please note that all fields are required.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)
            restaurant.name = nameTextField.text!
            restaurant.type = typeTextField.text!
            restaurant.location = addressTextField.text!
            restaurant.phone = phoneTextField.text!
            restaurant.summary = descriptionTextView.text
            restaurant.isFavorite = false

            if let imageData = newImageView.image?.pngData() {
                    restaurant.image = imageData
                }

            print("Saving data to context...")
            appDelegate.saveContext()
        }
        
        dismiss(animated: true, completion: nil)
                
    }
    
    
    @IBOutlet var nameTextField:UITextField!{
        didSet{
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var typeTextField:UITextField!{
        didSet{
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet var addressTextField:UITextField!{
        didSet{
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet var phoneTextField:UITextField!{
        didSet{
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView:UITextView!{
        didSet{
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var newImageView:UIImageView!{
        didSet{
            newImageView.layer.cornerRadius = 10.0
            newImageView.layer.masksToBounds = true
        }
    }
    
    //MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the superview's layout
        let margins = newImageView.superview!.layoutMarginsGuide

        // Disable auto resizing mask to use auto layout programmatically
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        newImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        newImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        newImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        newImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        //Edit NavigationBar
        if let appearance = navigationController?.navigationBar.standardAppearance{
            if let customFont = UIFont(name: "Nunito-Bold", size: 40.0){
                appearance.titleTextAttributes = [.foregroundColor:UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor:UIColor(named: "NavigationBarTitle")!,.font:customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance

        }
        
        //Off keyboard gesture
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Choose the source of image
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            let imagePicker = UIImagePickerController()
                            imagePicker.allowsEditing = false
                            imagePicker.sourceType = .camera
                            imagePicker.delegate = self

                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler:{ (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            photoSourceRequestController.addAction(cancelAction)
            present(photoSourceRequestController, animated: true, completion: nil)
            
            }

        }
}

extension NewRestaurantController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag+1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
// the chosen image is new image

extension NewRestaurantController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            newImageView.image = selectedImage
            newImageView.contentMode = .scaleAspectFill
            newImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
