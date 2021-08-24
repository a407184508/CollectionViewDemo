//
//  ViewController.swift
//  CollectionView
//
//  Created by Mac on 2021/8/23.
//

import UIKit
import SwiftUI

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let controller = UIHostingController(rootView: SwiftUICollectionView())
            show(controller, sender: nil)
        }
    }
}

