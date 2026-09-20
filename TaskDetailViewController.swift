import UIKit
import PhotosUI
import Photos
import MapKit
import CoreLocation


class TaskDetailViewController: UIViewController, PHPickerViewControllerDelegate {
    var taskIndex = 0
    var taskTitle = ""
    var taskDescription = ""
    
    private var selectedPhotoLocation: CLLocationCoordinate2D?
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 12
        map.isHidden = true
        return map
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scavenger Hunt Task"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete this task by attaching a photo."
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // NEW: Displays the selected photo
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isHidden = true
        return imageView
    }()
    
    private let attachPhotoButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Attach Photo"
        configuration.image = UIImage(systemName: "photo")
        configuration.imagePadding = 8
        
        return UIButton(configuration: configuration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Task"
        
        if !taskTitle.isEmpty {
            titleLabel.text = taskTitle
        }
        
        if !taskDescription.isEmpty {
            descriptionLabel.text = taskDescription
        }
        
        setupUI()
        attachPhotoButton.addTarget(
            self,
            action: #selector(attachPhotoTapped),
            for: .touchUpInside
        )
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            photoImageView,
            mapView,
            attachPhotoButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            ),
            
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            
            // NEW: Gives the photo a visible size
            photoImageView.heightAnchor.constraint(
                equalToConstant: 250
            ),
            mapView.heightAnchor.constraint(
                equalToConstant: 250
            )
        ])
    }
    
    @objc private func attachPhotoTapped() {
        var configuration = PHPickerConfiguration(
            photoLibrary: .shared()
        )
        
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(
            configuration: configuration
        )
        
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else {
            return
        }
        
        // Get the photo's location
        if let assetIdentifier = result.assetIdentifier {
            let assets = PHAsset.fetchAssets(
                withLocalIdentifiers: [assetIdentifier],
                options: nil
            )
            
            if let asset = assets.firstObject,
               let location = asset.location {
                selectedPhotoLocation = location.coordinate
            }
        }
        
        // Load and display the photo
        result.itemProvider.loadObject(
            ofClass: UIImage.self
        ) { [weak self] object, error in
            
            guard let image = object as? UIImage else {
                return
            }
            
            DispatchQueue.main.async {
                self?.titleLabel.text = "Photo Attached!"
                self?.photoImageView.image = image
                self?.photoImageView.isHidden = false
                
                UserDefaults.standard.set(
                    true,
                    forKey: "taskCompleted_\(self?.taskIndex ?? 0)"
                )
                
                if let location = self?.selectedPhotoLocation {

                    print("Photo location: \(location.latitude), \(location.longitude)")

                    let coordinate = location

                    let region = MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 1000,
                        longitudinalMeters: 1000
                    )

                    self?.mapView.setRegion(
                        region,
                        animated: true
                    )

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "Photo Location"

                    self?.mapView.addAnnotation(annotation)
                    self?.mapView.isHidden = false

                } else {
                    print("This photo does not contain location data.")
                }
            }
        }
    }
}
