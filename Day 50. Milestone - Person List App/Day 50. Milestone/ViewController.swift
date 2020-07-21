//
//  ViewController.swift
//  Day 50. Milestone
//
//  Created by MacBook on 12/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pictures = [Picture]()
    @IBOutlet var cellButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My own photos"
        navigationController?.navigationBar.prefersLargeTitles = true
       

        let defaults = UserDefaults.standard
        
        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPictures)
            } catch {
                print("Failed to load pictures")
            } // if 'do' line fails, the 'catch' method will be executed instead.
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewPicture))
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func addNewPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) { // 80% quality
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Picture(name: "", image: imageName)
        
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Enter the name of the picture", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            picture.name = newName
            self?.tableView.reloadData()
            self?.pictures.append(picture)
            self?.save()
            self?.tableView.reloadData() // Not sure if we need to reloadData() twice :P
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let pictureInCell = pictures[indexPath.row]
        cell.textLabel?.text = pictureInCell.name
        cell.accessoryType = .disclosureIndicator // cell button >
        let path = getDocumentsDirectory().appendingPathComponent(pictureInCell.image)
        cell.imageView?.image = UIImage(contentsOfFile: path.path) //path.path -> we convert URL .path to String .path.
        

        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
            print("Picture saved.")
        } else {
            print("Failed to save pictures.")
        }
    }
    //The new thing here is that we have to get the picture from the FILE DIRECTORY, as before we used the photos from the bundle. Here, we have them saved in our device and we need to load them straight from the phone file directory:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let pictureImageName = pictures[indexPath.row].image
            let picture = getDocumentsDirectory().appendingPathComponent(pictureImageName)
            vc.selectedImage = picture.path
            vc.detailTitle = pictures[indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    

    
    

    

}

