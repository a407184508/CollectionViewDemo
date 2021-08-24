//
//  SwiftUICollectionView.swift
//  CollectionView
//
//  Created by Mac on 2021/8/24.
//

import SwiftUI

struct SwiftUICollectionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CollectionViewController
    
    func makeUIViewController(context: Context) -> CollectionViewController {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController else {
            return CollectionViewController()
        }
        // setting Coordinator
//        context.coordinator = ..
        // 事例
//        controller.collectionView.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CollectionViewController, context: Context) {
        // 可以在此修改数据源
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate {
        // todo:
    }
}

struct SwiftUICollectionView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUICollectionView()
    }
}
