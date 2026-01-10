//
//  ItemsViewController.swift
//  VerticalApp
//
//  Main view controller - empty screen
//

import UIKit

class ItemsViewController: UIViewController {
    
    // Single master list of all tiles (14 total: 5 top + 4 middle + 5 bottom)
    private var allTiles: [UIImageView] = []
    private var allTileNames: [String] = []
    
    // Display rows (populated from master list)
    private var topRowImageViews: [UIImageView] = []
    private var backRowImageViews: [UIImageView] = []
    private var tileImageViews: [UIImageView] = []
    
    private let bottomOffset: CGFloat = 50
    private let tileSpacing: CGFloat = 3
    private let aspectRatio: CGFloat = 0.8 // width / height ratio (0.8 means height is 1.25x width)
    private let rowSpacing: CGFloat = 2 // Space between the rows
    private let topRowCount = 5
    private let middleRowCount = 4
    private let bottomRowCount = 5
    
    // Drag and drop state
    private var draggedTile: UIImageView?
    private var draggedTileOriginalIndex: Int?
    private var dragOffset: CGPoint = .zero
    
    // Track tile names using tags (1b=1, 2b=2, etc.)
    private func tileNameToTag(_ name: String) -> Int {
        if name.hasPrefix("1") && name.hasSuffix("b") { return 1 }
        if name.hasPrefix("2") && name.hasSuffix("b") { return 2 }
        if name.hasPrefix("3") && name.hasSuffix("b") { return 3 }
        if name.hasPrefix("4") && name.hasSuffix("b") { return 4 }
        if name.hasPrefix("5") && name.hasSuffix("b") { return 5 }
        return 0
    }
    
    private func tagToTileName(_ tag: Int) -> String {
        return "\(tag)b"
    }
    
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
        
        // Initialize master list with 14 tiles: top row (5) + middle row (4) + bottom row (5)
        let initialTileNames = [
            // Top row (5 tiles)
            "1b", "2b", "3b", "4b", "5b",
            // Middle row (4 tiles)
            "1b", "2b", "3b", "4b",
            // Bottom row (5 tiles)
            "1b", "2b", "3b", "4b", "5b"
        ]
        
        // Create all tiles in the master list
        for tileName in initialTileNames {
            let tileImageView = UIImageView()
            tileImageView.backgroundColor = .white
            tileImageView.contentMode = .scaleAspectFit
            tileImageView.clipsToBounds = true
            tileImageView.layer.cornerRadius = 8
            
            // Load the tile image
            if let image = UIImage(named: tileName) {
                tileImageView.image = image
                tileImageView.tag = tileNameToTag(tileName)
                print("✓ Successfully loaded \(tileName) image")
            } else {
                tileImageView.image = UIImage(systemName: "square.fill")
                tileImageView.tintColor = .red
                tileImageView.tag = 0
                print("✗ Failed to load \(tileName) image")
            }
            
            allTiles.append(tileImageView)
            allTileNames.append(tileName)
            
            // Add pan gesture recognizer for drag and drop
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            tileImageView.addGestureRecognizer(panGesture)
            tileImageView.isUserInteractionEnabled = true
            
            view.addSubview(tileImageView)
        }
        
        // Redistribute tiles into rows
        redistributeTilesToRows()
    }
    
    private func redistributeTilesToRows() {
        // Clear display arrays
        topRowImageViews.removeAll()
        backRowImageViews.removeAll()
        tileImageViews.removeAll()
        
        // Redistribute from master list:
        // Top row: indices 0-4 (5 tiles)
        // Middle row: indices 5-8 (4 tiles)
        // Bottom row: indices 9-13 (5 tiles)
        for (index, tile) in allTiles.enumerated() {
            if index < topRowCount {
                topRowImageViews.append(tile)
                view.bringSubviewToFront(tile)
            } else if index < topRowCount + middleRowCount {
                backRowImageViews.append(tile)
                view.sendSubviewToBack(tile)
            } else {
                tileImageViews.append(tile)
                view.bringSubviewToFront(tile)
            }
        }
        
        // Ensure proper z-ordering: back row behind, then front and top
        for tile in backRowImageViews {
            view.sendSubviewToBack(tile)
        }
        for tile in tileImageViews {
            view.bringSubviewToFront(tile)
        }
        for tile in topRowImageViews {
            view.bringSubviewToFront(tile)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTilePosition()
    }
    
    private func updateTilePosition(animated: Bool = false) {
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
            let newFrame = CGRect(
                x: x,
                y: frontRowY,
                width: tileW,
                height: tileH
            )
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    tileImageView.frame = newFrame
                }
            } else {
                tileImageView.frame = newFrame
            }
        }
        
        // Position back row (4 tiles) - first tile aligned with first tile in front row
        let backRowStartX = frontRowStartX
        let backRowY = frontRowY - tileH - rowSpacing
        
        for (index, tileImageView) in backRowImageViews.enumerated() {
            let x = backRowStartX + (CGFloat(index) * (tileW + tileSpacing))
            let newFrame = CGRect(
                x: x,
                y: backRowY,
                width: tileW,
                height: tileH
            )
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    tileImageView.frame = newFrame
                }
            } else {
                tileImageView.frame = newFrame
            }
        }
        
        // Position top row (5 tiles) - first tile aligned with first tile in front row, above back row
        let topRowStartX = frontRowStartX
        let topRowY = backRowY - tileH - rowSpacing
        
        for (index, tileImageView) in topRowImageViews.enumerated() {
            let x = topRowStartX + (CGFloat(index) * (tileW + tileSpacing))
            let newFrame = CGRect(
                x: x,
                y: topRowY,
                width: tileW,
                height: tileH
            )
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    tileImageView.frame = newFrame
                }
            } else {
                tileImageView.frame = newFrame
            }
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let tileView = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            // Find index in master list
            if let index = allTiles.firstIndex(of: tileView) {
                draggedTileOriginalIndex = index
            }
            
            draggedTile = tileView
            dragOffset = gesture.location(in: tileView)
            
            // Bring tile to front and scale it up slightly
            view.bringSubviewToFront(tileView)
            UIView.animate(withDuration: 0.2) {
                tileView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                tileView.alpha = 0.8
            }
            
        case .changed:
            // Move the tile with the gesture
            tileView.center = CGPoint(
                x: tileView.center.x + translation.x,
                y: tileView.center.y + translation.y
            )
            gesture.setTranslation(.zero, in: view)
            
        case .ended, .cancelled:
            // Determine drop position
            let dropLocation = gesture.location(in: view)
            handleDrop(at: dropLocation, tile: tileView)
            
            // Reset tile appearance
            UIView.animate(withDuration: 0.2) {
                tileView.transform = .identity
                tileView.alpha = 1.0
            }
            
            draggedTile = nil
            draggedTileOriginalIndex = nil
            
        default:
            break
        }
    }
    
    private func handleDrop(at location: CGPoint, tile: UIImageView) {
        guard let originalIndex = draggedTileOriginalIndex else { return }
        
        let screenWidth = view.bounds.width
        let safeAreaBottom = view.safeAreaInsets.bottom
        let tileW = tileWidth(for: screenWidth)
        let tileH = tileHeight(for: tileW)
        
        // Calculate which row and position the drop location corresponds to
        let frontRowY = view.bounds.height - bottomOffset - tileH - safeAreaBottom
        let backRowY = frontRowY - tileH - rowSpacing
        let topRowY = backRowY - tileH - rowSpacing
        
        // Calculate center X for all rows (they're all aligned)
        let totalTileWidth = (tileW * CGFloat(bottomRowCount)) + (tileSpacing * CGFloat(bottomRowCount - 1))
        let rowStartX = (screenWidth - totalTileWidth) / 2
        
        // Determine which row based on Y position
        var targetRow: Int = 0
        var targetRowY: CGFloat = frontRowY
        
        if location.y < topRowY + tileH / 2 {
            targetRow = 2 // Top row
            targetRowY = topRowY
        } else if location.y < backRowY + tileH / 2 {
            targetRow = 1 // Back row (middle)
            targetRowY = backRowY
        } else {
            targetRow = 0 // Front row (bottom)
            targetRowY = frontRowY
        }
        
        // Determine position within row based on X position
        // Use floor() instead of round() to always insert before the tile being dropped on
        let relativeX = location.x - rowStartX
        var targetRowIndex = Int(floor(relativeX / (tileW + tileSpacing)))
        
        // Get the tile name
        let tileTag = tile.tag
        let imageName = tagToTileName(tileTag)
        
        // Calculate target index in master list
        var targetIndex: Int
        switch targetRow {
        case 0: // Bottom row: indices 9-13 (5 tiles)
            targetRowIndex = max(0, min(targetRowIndex, bottomRowCount))
            targetIndex = topRowCount + middleRowCount + targetRowIndex
        case 1: // Middle row: indices 5-8 (4 tiles)
            targetRowIndex = max(0, min(targetRowIndex, middleRowCount))
            targetIndex = topRowCount + targetRowIndex
        case 2: // Top row: indices 0-4 (5 tiles)
            targetRowIndex = max(0, min(targetRowIndex, topRowCount))
            targetIndex = targetRowIndex
        default:
            targetIndex = originalIndex
        }
        
        // Only reorder if the position actually changed
        if targetIndex != originalIndex {
            // Remove tile from original position first
            allTiles.remove(at: originalIndex)
            allTileNames.remove(at: originalIndex)
            
            // Adjust target index if inserting after the original position (since we removed one item)
            if targetIndex > originalIndex {
                targetIndex -= 1
            }
            
            // Insert at new position in master list
            allTiles.insert(tile, at: targetIndex)
            allTileNames.insert(imageName, at: targetIndex)
            
            // Redistribute all tiles to rows (this maintains the 5-4-5 distribution)
            // This works for same-row reordering and cross-row moves
            redistributeTilesToRows()
            
            // Recalculate all positions with animation so tiles shift smoothly
            updateTilePosition(animated: true)
        }
    }
}
