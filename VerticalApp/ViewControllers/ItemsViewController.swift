//
//  ItemsViewController.swift
//  VerticalApp
//
//  Main view controller - empty screen
//

import UIKit

class ItemsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Vertical"
        view.backgroundColor = .systemBackground
    }
}
