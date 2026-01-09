//
//  ItemsViewController.swift
//  VerticalApp
//
//  Main view controller - empty screen
//

import UIKit

class ItemsViewController: UIViewController {
    
    private var tileImageView: UIImageView!
    private let tileSize: CGFloat = 60
    private let bottomOffset: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTilePosition()
    }
    
    private func setupUI() {
        title = "Vertical"
        view.backgroundColor = .systemBackground
        
        // Create tile image view
        tileImageView = UIImageView()
        // Debug: make it visible even if image doesn't load
        tileImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        tileImageView.contentMode = .scaleAspectFit
        
        // Try to load the tile image
        // Note: After adding Images folder to Xcode manually, UIImage(named:) should work
        var loadedImage: UIImage?
        
        // Try without extension first (most common)
        loadedImage = UIImage(named: "1bam")
        
        // If that fails, try with extension
        if loadedImage == nil {
            loadedImage = UIImage(named: "1bam.png")
        }
        
        // Try with Images/ prefix
        if loadedImage == nil {
            loadedImage = UIImage(named: "Images/1bam")
        }
        
        // Try loading from bundle path (works if Images is a folder reference)
        if loadedImage == nil {
            if let bundlePath = Bundle.main.resourcePath,
               let imagePath = Bundle.main.path(forResource: "1bam", ofType: "png", inDirectory: "Images") {
                loadedImage = UIImage(contentsOfFile: imagePath)
                print("Loaded from path: \(imagePath)")
            }
        }
        
        if let image = loadedImage {
            tileImageView.image = image
            print("✓ Successfully loaded 1bam image")
        } else {
            // Fallback: use system image for debugging
            tileImageView.image = UIImage(systemName: "square.fill")
            tileImageView.tintColor = .red
            print("✗ Failed to load 1bam image, using fallback")
            
            // Debug: List what's in the bundle
            if let resourcePath = Bundle.main.resourcePath {
                print("Bundle resource path: \(resourcePath)")
                let fileManager = FileManager.default
                if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                    print("Bundle contents (first 20): \(contents.prefix(20))")
                }
                // Check if Images folder exists
                let imagesPath = (resourcePath as NSString).appendingPathComponent("Images")
                if fileManager.fileExists(atPath: imagesPath) {
                    print("Images folder found at: \(imagesPath)")
                    if let imageFiles = try? fileManager.contentsOfDirectory(atPath: imagesPath) {
                        print("Sample images in folder: \(imageFiles.filter { $0.hasSuffix(".png") }.prefix(10))")
                    }
                } else {
                    print("Images folder NOT found in bundle!")
                }
            }
        }
        
        view.addSubview(tileImageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTilePosition()
    }
    
    private func updateTilePosition() {
        guard view.bounds.width > 0 && view.bounds.height > 0 else {
            return // Wait for bounds to be set
        }
        
        let screenWidth = view.bounds.width
        let safeAreaBottom = view.safeAreaInsets.bottom
        let tileX = (screenWidth - tileSize) / 2 // Center horizontally
        let tileY = view.bounds.height - bottomOffset - tileSize - safeAreaBottom
        
        tileImageView.frame = CGRect(
            x: tileX,
            y: tileY,
            width: tileSize,
            height: tileSize
        )
        
        print("Tile frame: \(tileImageView.frame)")
        print("View bounds: \(view.bounds)")
        print("Image: \(tileImageView.image != nil ? "Loaded" : "Nil")")
    }
}
