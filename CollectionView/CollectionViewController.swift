//
//  CollectionViewController.swift
//  CollectionView
//
//  Created by Mac on 2021/8/23.
//

import UIKit

private let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var stepper: UIStepper!
    let dataSource = (0..<39).sorted().map { UIImage(named: "\($0)" )}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //        print(collectionViewLayout)
        (collectionViewLayout as! CollectionViewLayout).delegate = self
        
        stepper.value = 2
    }
    
    @IBAction func changedAction(_ sender: UIStepper) {
        if sender.value <= 0.0 {
            sender.value = 1
        }
        if sender.value >= 10 {
            sender.value = 10
        }
        navigationItem.title = "UICollectionView:col:\(Int(sender.value))"
        collectionView.reloadData()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIImage(named: "\(indexPath.row)")?.size ?? .zero
        
        let kSize = collectionView.frame.size
        let width = (kSize.width - 15) / 2
        
        let height = width * 1.25
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        DispatchQueue.main.async {
            cell.image.image = self.dataSource[indexPath.row]
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

extension CollectionViewController: CollectionViewLayoutDelegate {
    
    func itemHeight(layout: CollectionViewLayout, indexPath: IndexPath, itemWith: CGFloat) -> CGFloat {
        let size = dataSource[indexPath.row]?.size ?? .zero
        let height = itemWith / size.width * size.height
        return height
    }
    
    func itemColumnCount(layout: CollectionViewLayout) -> Int {
        Int(stepper.value)
    }
    
    func itemColumnSpcing(layout: CollectionViewLayout) -> CGFloat {
        5
    }
    
    func itemRowSpcing(layout: CollectionViewLayout) -> CGFloat {
        5
    }
    
    func itemEdgeInsetd(layout: CollectionViewLayout) -> UIEdgeInsets {
        .zero
    }
    
    
}
