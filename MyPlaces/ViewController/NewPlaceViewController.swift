//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Anatoly Valkov on 6/9/20.
//  Copyright © 2020 Anatoly Valkov. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace    : Place!
    var imageIsChanged  = false
    var currentRating   = 0.0
    
    @IBOutlet weak var placeImage   : UIImageView!
    @IBOutlet weak var saveButton   : UIBarButtonItem!
    @IBOutlet weak var placeName    : UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    @IBOutlet weak var placeType: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false        
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cameraIcon = #imageLiteral(resourceName: "camera")
        let photoIcon = #imageLiteral(resourceName: "photo")
        
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                // TODO: chooseImagePicker
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                // TODO: chooseImagePicker
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC      = segue.destination as? MapViewController
            else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name      = placeName.text!
            mapVC.place.location  = placeLocation.text!
            mapVC.place.type      = placeType.text!
            mapVC.place.imageData = placeImage.image?.pngData()
        }
        
        
    }
    
    func savePlace() {
        
        guard let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder") else { return }
        
        let imageData = image.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text!,
                             type: placeType.text!,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        if currentPlace != nil {
            try! realm.write{
                currentPlace?.name      = newPlace.name
                currentPlace?.location  = newPlace.location
                currentPlace?.type      = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating    = newPlace.rating
                
                CloudManager.updateCloudData(place: currentPlace, with: image)
            }
        } else {
            CloudManager.saveDataToCloud(place: newPlace, with: image) { (recordID) in
                DispatchQueue.main.async {
                    try! realm.write {
                        newPlace.recordID = recordID
                    }
                }
            }
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data)  else { return }
            
            placeImage.contentMode  = .scaleAspectFill
            placeImage.image        = image
            placeName.text          = currentPlace?.name
            placeLocation.text      = currentPlace?.location
            placeType.text          = currentPlace?.type
            ratingControl.rating    = currentPlace.rating
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - TextFieldDelegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    // Hide keyboard by tapping on done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker             = UIImagePickerController()
            imagePicker.delegate        = self
            imagePicker.allowsEditing   = true
            imagePicker.sourceType      = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image         = info[.editedImage] as? UIImage
        placeImage.contentMode   = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged           = true
        
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}


