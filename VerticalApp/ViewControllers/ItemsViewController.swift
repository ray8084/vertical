//
//  ItemsViewController.swift
//  VerticalApp
//
//  Main view controller - empty screen
//

import UIKit

class ItemsViewController: UIViewController {
    
    private var tileImageViews: [UIImageView] = []
    private var backRowImageViews: [UIImageView] = []
    private var topRowImageViews: [UIImageView] = []
    private let bottomOffset: CGFloat = 50
    private let tileSpacing: CGFloat = 3
    private let tileNames = ["1b", "2b", "3b", "4b", "5b"]
    private let backRowTileNames = ["1b", "2b", "3b", "4b"]
    private let topRowTileNames = ["1b", "2b", "3b", "4b", "5b"]
    private let aspectRatio: CGFloat = 0.8 // width / height ratio (0.8 means height is 1.25x width)
    private let rowSpacing: CGFloat = 2 // Space between the rows
    private let backRowRightShift: CGFloat = 0.15 // 15% shift to the right
    
    private func tileWidth(for screenWidth: CGFloat) -> CGFloat {
        return (screenWidth / 5.0) - 8.0 // 3 pixels more narrow (was -5.0, now -8.0)
    }
    
    private func tileHeight(for width: CGFloat) -> CGFloat {
        return width / aspectRatio
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
        // Really dark green, almost black with green tint
        view.backgroundColor = UIColor(red: 0.05, green: 0.08, blue: 0.05, alpha: 1.0)
        
        // Create back row tile image views (4 tiles)
        for tileName in backRowTileNames {
            let tileImageView = UIImageView()
            tileImageView.backgroundColor = .white
            tileImageView.contentMode = .scaleAspectFit
            tileImageView.clipsToBounds = true
            tileImageView.layer.cornerRadius = 8
            
            // Load the tile image
            if let image = UIImage(named: tileName) {
                tileImageView.image = image
                print("✓ Successfully loaded back row \(tileName) image")
            } else {
                tileImageView.image = UIImage(systemName: "square.fill")
                tileImageView.tintColor = .red
                print("✗ Failed to load back row \(tileName) image")
            }
            
            backRowImageViews.append(tileImageView)
            // Insert at index 0 to keep them behind the front row
            view.insertSubview(tileImageView, at: 0)
        }
        
        // Create front row tile image views (5 tiles)
        for tileName in tileNames {
            let tileImageView = UIImageView()
            tileImageView.backgroundColor = .white
            tileImageView.contentMode = .scaleAspectFit
            tileImageView.clipsToBounds = true
            tileImageView.layer.cornerRadius = 8
            
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
        
        // Create top row tile image views (5 tiles)
        for tileName in topRowTileNames {
            let tileImageView = UIImageView()
            tileImageView.backgroundColor = .white
            tileImageView.contentMode = .scaleAspectFit
            tileImageView.clipsToBounds = true
            tileImageView.layer.cornerRadius = 8
            
            // Load the tile image
            if let image = UIImage(named: tileName) {
                tileImageView.image = image
                print("✓ Successfully loaded top row \(tileName) image")
            } else {
                tileImageView.image = UIImage(systemName: "square.fill")
                tileImageView.tintColor = .red
                print("✗ Failed to load top row \(tileName) image")
            }
            
            topRowImageViews.append(tileImageView)
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
        let tileW = tileWidth(for: screenWidth)
        let tileH = tileHeight(for: tileW)
        
        // Position front row (5 tiles)
        let frontRowTileCount = CGFloat(tileImageViews.count)
        let frontRowTotalWidth = (tileW * frontRowTileCount) + (tileSpacing * (frontRowTileCount - 1))
        let frontRowStartX = (screenWidth - frontRowTotalWidth) / 2 // Center all tiles horizontally
        let frontRowY = view.bounds.height - bottomOffset - tileH - safeAreaBottom
        
        for (index, tileImageView) in tileImageViews.enumerated() {
            let x = frontRowStartX + (CGFloat(index) * (tileW + tileSpacing))
            tileImageView.frame = CGRect(
                x: x,
                y: frontRowY,
                width: tileW,
                height: tileH
            )
        }
        
        // Position back row (4 tiles) - first tile aligned with first tile in front row
        let backRowStartX = frontRowStartX
        let backRowY = frontRowY - tileH - rowSpacing
        
        for (index, tileImageView) in backRowImageViews.enumerated() {
            let x = backRowStartX + (CGFloat(index) * (tileW + tileSpacing))
            tileImageView.frame = CGRect(
                x: x,
                y: backRowY,
                width: tileW,
                height: tileH
            )
        }
        
        // Position top row (5 tiles) - first tile aligned with first tile in front row, above back row
        let topRowStartX = frontRowStartX
        let topRowY = backRowY - tileH - rowSpacing
        
        for (index, tileImageView) in topRowImageViews.enumerated() {
            let x = topRowStartX + (CGFloat(index) * (tileW + tileSpacing))
            tileImageView.frame = CGRect(
                x: x,
                y: topRowY,
                width: tileW,
                height: tileH
            )
        }
    }
}
