//
//  RxCollectionViewController.swift
//  CollectionView
//
//  Created by Mac on 2021/8/24.
//

import UIKit
import RxDataSources
import RxSwift

class RxCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var datas = (0..<39).sorted().map { UIImage(named: "\($0)" )}.compactMap { $0 }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.estimatedItemSize = .zero
        layout.itemSize = CGSize(width: (collectionView.frame.width - 60) / 3, height: (collectionView.frame.width - 60) / 3 * 1.25)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 5, bottom: 10, right: 5)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, UIImage>>(configureCell: { (ds, cv, ip, item) -> UICollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: ip) as! CollectionViewCell
            DispatchQueue.main.async {
                cell.image.image = item
            }
            return cell
        })
        
        Observable<[UIImage]>.just(datas)
            .map { [SectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(UIImage.self)
            .subscribe(onNext: { model in
                print(model)
            })
            .disposed(by: disposeBag)
    }
}
