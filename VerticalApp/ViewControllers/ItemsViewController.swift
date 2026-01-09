//
//  ItemsViewController.swift
//  VerticalApp
//
//  Main view controller - empty screen
//

import UIKit

class ItemsViewController: UIViewController {
    
    private var tileImageViews: [UIImageView] = []
    private let bottomOffset: CGFloat = 50
    private let tileSpacing: CGFloat = 3
    private let tileNames = ["1b", "2b", "3b", "4b", "5b"]
    
    private func tileWidth(for screenWidth: CGFloat) -> CGFloat {
        return (screenWidth / 5.0) - 5.0
    }
    
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
        
        // Create tile image views for each tile
        for tileName in tileNames {
            let tileImageView = UIImageView()
            tileImageView.backgroundColor = .systemBackground
            tileImageView.contentMode = .scaleAspectFit
            tileImageView.clipsToBounds = false
            
            // Load the tile image
            if let image = UIImage(named: tileName) {
                tileImageView.image = image
                print("✓ Successfully loaded \(tileName) image")
            } else {
                tileImageView.image = UIImage(systemName: "square.fill")
                tileImageView.tintColor = .red
                print("✗ Failed to load \(tileName) image")
            }
            
            tileImageViews.append(tileImageView)
            view.addSubview(tileImageView)
        }
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
        let tileWidth = tileWidth(for: screenWidth)
        let tileCount = CGFloat(tileImageViews.count)
        let totalWidth = (tileWidth * tileCount) + (tileSpacing * (tileCount - 1))
        let startX = (screenWidth - totalWidth) / 2 // Center all tiles horizontally
        let tileY = view.bounds.height - bottomOffset - tileWidth - safeAreaBottom
        
        // Position each tile in a row
        for (index, tileImageView) in tileImageViews.enumerated() {
            let x = startX + (CGFloat(index) * (tileWidth + tileSpacing))
            tileImageView.frame = CGRect(
                x: x,
                y: tileY,
                width: tileWidth,
                height: tileWidth
            )
        }
    }
}
