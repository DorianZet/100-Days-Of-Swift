//
//  ViewController.swift
//  Project13
//
//  Created by MacBook on 14/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {  //These 2 delegates are required for UIImagePickerController() to work.
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        changeFilterButton.layer.borderColor = UIColor.lightGray.cgColor
        changeFilterButton.layer.borderWidth = 1
        changeFilterButton.layer.backgroundColor = UIColor.yellow.cgColor
        changeFilterButton.layer.cornerRadius = 10
        
        saveButton.layer.borderColor = UIColor.lightGray.cgColor
        saveButton.layer.borderWidth = 1
        saveButton.layer.backgroundColor = UIColor.yellow.cgColor
        saveButton.layer.cornerRadius = 10
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        imageView.alpha = 0 // the imageView is not visible...
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        applyRadiusProcessing()
        
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.imageView.alpha = 1 // ... but now it is, with a small fade-in, everytime a new picture is chosen.
        })
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Use the sender (which in this case is UIButton) as a source of our popoverPresentationController. The popover appears to come from our button (this works only on iPads).
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds // Uses button bounds to present the .actionSheet from the button directly.
        }
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        let ac = UIAlertController(title: "ERROR", message: "Load the image before using the filter.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        guard currentImage != nil else {
            present(ac, animated: true)
            return }// We are making sure that the user chose image.
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle) // We create a new CIFilter from the actionTitle that is passed in.
        changeFilterButton.setTitle(actionTitle, for: .normal) // We set the buttons name for the name of the filter. For that, we use the 'var changeFilterButton' property.
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        applyRadiusProcessing()
    }
    
    
    @IBAction func save(_ sender: Any) {
        let ac = UIAlertController(title: "ERROR", message: "There is no image loaded!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        guard let image = imageView.image else {
            present(ac, animated: true)
            return } // Now the app won't crash if there's no image in UIView.
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        intensity.isUserInteractionEnabled = true
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            // If we have intensity in the input key of our filter (OR: if the input key of our filter is kCIInputIntensityKey), then use our slider for that.
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 100, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            // Centering the filter on our image halfway of right, left, top and bottom.
        }
        
        if !inputKeys.contains(kCIInputIntensityKey) && !inputKeys.contains(kCIInputScaleKey) {
            intensity.isUserInteractionEnabled = false
        } // If the currentFilter's input keys don't contain any intensity or input scale keys, the slider is disabled.
        
        guard let outputImage = currentFilter.outputImage else { return } // If we can't read outputImage, bail out.
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage // Only NOW the filter changes are presented visually.
        }
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyRadiusProcessing()
    }
    
    func applyRadiusProcessing() {
        radius.isUserInteractionEnabled = true
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 500, forKey: kCIInputRadiusKey)
        } else {
            radius.isUserInteractionEnabled = false
        } // Now, because of the .isUserInteractioEnabled method, the 'Radius:' slider will be disabled if current filter doesn't have any radius properties (for example - sepia).
        
        guard let outputImage = currentFilter.outputImage else { return } // If we can't read outputImage, bail out.
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    // We get now 2 sliders - one for intensity, one for radius. If a filter works with .contains keys for both of those, we can use these 2 sliders there - first one to adjust the intensity of the filter, second one to adjust the radius of it (here, those filters are: "CIUnsharpMask" and "CIBumpDistortion".
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error { // If there's error:
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else { // If there is no error:
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

