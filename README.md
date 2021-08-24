
# 1. UICollectionView 的简单实现和使用

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d9c53a339d554303852374aa0fa036e3~tplv-k3u1fbpfcp-watermark.image)

- 我这里直接使用了`UIStoryBoard`创建了`UICollectionViewController`
- 在默认布局里只需要使用两个代理方法即可完成`collectionView`的演示


```swift
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
```
- 但是这里显示的系统的默认布局的方式，实现`UICollectionViewDelegateFlowLayout`进行布局，或者直接拿到`UICollectionViewController`的`collectionViewLayout`进行属性赋值即可


```Swift
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
```

## 数据源

- 顾名思义，是和`tableView`一样，需要一个数组（展示数据），简单理解就是数据源头
- 例如需要展现的单元格个数，需要展示的样式、移动，删除，设置header、footer等


```Swift
// 返回的section 数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

// 每个seciton对应的单元格数量
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

// 单元格的实现
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// 自定义header/footer 的使用
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
```

## 代理

- 顾名思义就是显示单元格将要显示以后的处理的一些事件
- 常用的一些，类似于`willDisplayCell` 将要显示、点击、高亮事件等


```Swift
// 单元格是否可以点击
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// 如果实现此方法必须实现上面的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// 单元格将要显示的时候调用- 类似于可以从代理里看UICollectionView的生命周期
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0));

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
```

## 自定义`layout`

- 这里我做了一个瀑布流的实现，来自定义`layout`

1. 我先写了一个协议，用来回调实现每个`cell`的布局信息

```Swift
protocol CollectionViewLayoutDelegate: NSObject {
    func itemHeight(layout: CollectionViewLayout, indexPath: IndexPath, itemWith: CGFloat) -> CGFloat
    func itemColumnCount(layout: CollectionViewLayout) -> Int
    func itemColumnSpcing(layout: CollectionViewLayout) -> CGFloat
    func itemRowSpcing(layout: CollectionViewLayout) -> CGFloat
    func itemEdgeInsetd(layout: CollectionViewLayout) -> UIEdgeInsets
    // todo .. 当然也可以自定义更多的代理，看你自己的需求需要哈

}
```

2. 继承UICollectionViewLayout写layout
- 核心方法


```Swift
// cell复用的时候调用，初始化，还原参数
override func prepare(){
    super.prepare()
    
    contentHeight = 0

    itemWidth  = ((self.collectionView?.frame.width ?? 0) - CGFloat(itemColumnCount + 1) * itemColumnSpcing) / CGFloat(itemColumnCount)
    colsHeight = Array(repeating: 0.0, count: itemColumnCount)
    var array = [UICollectionViewLayoutAttributes]()
    let items = collectionView?.numberOfItems(inSection: 0) ?? 0

    for index in 0..<items {
        if  let attr = layoutAttributesForItem(at: IndexPath(item: index, section: 0)){
            array.append(attr)
        }
    }
    layoutAttributes = array
}

override var collectionViewContentSize: CGSize {
    CGSize(width: 0, height: contentHeight)
}

override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    layoutAttributes
}

// 重写每个单元格的布局属性#核心#
override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

    let arrt = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    var shorHeight = colsHeight.first ?? 0
    var shortCol = 0

    for (index, temp) in colsHeight.enumerated() {
        if shorHeight > temp {
            shorHeight = temp
            shortCol = index
        }
    }

    let x = CGFloat(shortCol + 1) * itemColumnSpcing + CGFloat(shortCol) * itemWidth
    let y = shorHeight + itemColumnSpcing
    let height = delegate?.itemHeight(layout: self, indexPath: indexPath, itemWith: itemWidth) ?? 0

    arrt.frame = .init(x: x, y: y, width: itemWidth, height: height)
    colsHeight[shortCol] = arrt.frame.maxY

    let maxColHeight = colsHeight[shortCol]

    if contentHeight < maxColHeight {
        contentHeight = maxColHeight
    }
    return arrt
}

override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    true
}
```

- 主要代理的实现

```Swift
weak var delegate: CollectionViewLayoutDelegate?

var itemColumnCount: Int {
    delegate?.itemColumnCount(layout: self) ?? 2
}

var itemColumnSpcing: CGFloat {
    delegate?.itemColumnSpcing(layout: self) ?? 0
}

var itemRowSpcing: CGFloat {
    delegate?.itemRowSpcing(layout: self) ?? 0
}
```

- 具体运行效果可以观看demo


# 2. UICollectionView 在RxDataSource中的使用

```swift
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

        // 直接使用layout来布局，不需要协议
        layout.estimatedItemSize = .zero
        layout.itemSize = CGSize(width: (collectionView.frame.width - 60) / 3, height: (collectionView.frame.width - 60) / 3 * 1.25)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 5, bottom: 10, right: 5)

        //设置数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, UIImage>>(configureCell: { (ds, cv, ip, item) -> UICollectionViewCell in

            let cell = cv.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: ip) as! CollectionViewCell
            DispatchQueue.main.async {
                cell.image.image = item
            }

            return cell
        })

       // 将数据转换成信号
        Observable<[UIImage]>.just(datas)
            .map { [SectionModel(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // 点击事件
        collectionView.rx.modelSelected(UIImage.self)
            .subscribe(onNext: { model in
                print(model)
            })
            .disposed(by: disposeBag)
    }
}
```


### RxDataSource 使用技巧
> 1. RxCollectionViewSectionedReloadDataSource 创建数据源，并且指定类型，我是直接使用 RxDataSource 自带的类型 SectionModel 
> 2. 需要自定义 SectionModel 的话，需要继承它 一个 String 参数代表表头信息，一个 item 表示每一个 cell 的 model 类型
> 3. 用 rx 将数据变换成信号，在每次数据更新的时候都会自动的 reload
> 4. cell 点击也只需要一个方法就解决了

之前写一篇关于 rx 的文章，可以学习下 [ RxSwift ](https://juejin.cn/post/6844903911296335879)

# 3. 扩展UICollectionView 中SwiftUI中的使用

- SwiftUI是新的UI开发框架，但是没有类似于UICollectionView的布局控件，如果需要stack、list来实现，还是比较麻烦，所以我们可以直接使用桥接


```Swift
import SwiftUI


struct SwiftUICollectionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CollectionViewController

    func makeUIViewController(context: Context) -> CollectionViewController {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController else {

            return CollectionViewController()
        }
        
        // setting Coordinator
//        context.coordinator = ..
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
```


```Swift
let controller = UIHostingController(rootView: SwiftUICollectionView())
show(controller, sender: nil)
```

### SwiftUI 和UIKit 的转换
1. SwiftUI 里都是结构体struct controller需要实现UIViewControllerRepresentable协议`struct SwiftUICollectionView: UIViewControllerRepresentable`
2. 需要实现 `makeUIViewController` `updateUIViewController`方法通过中间商（context）链接
3. 如果需要实现代理可以是用类部类实现实现 `makeCoordinator` 方法，返回代理的类，设置需要代理的class `controller.collectionView.delegate = context.coordinator`
4. `UIHostingController` 是将SwiftUI转换成controller的方法

## 一些注意事项&遇到的一些问题：

- 如果在使用中，只有一个`cell`的情况下，试图剧中布局，取消自动获取`cell`大小，即可解决；或者重写`layout`，在只有一个的时候进行特殊处理

## 知识点汇总：Swift 语法篇


```swift
// swift 直接使用 weak 声明代理，防止循环引用。？代表可选类型，就是可以为nil的意思
weak var delegate: CollectionViewLayoutDelegate?

// 默认的get方法，省略了get、retrun 等字样，在swift中只有一句语句的情况下是可以忽略return，以这条语句为返回值
// ?? 可选属性为nil 时，可以用 2替换
// 相较于oc每次还需要判断 delegate是否实现更节省
var itemColumnCount: Int {
    delegate?.itemColumnCount(layout: self) ?? 2
}

// 完整写法
var itemColumnCount: Int {
    get {
        if let delegate = delegate {
            return delegate.itemColumnCount(layout: self) 
        }
        return 2
    }
}

// 同上 可以忽略return
override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
  true
}

// 0-39 的int数组 sorted 是数组的排序， map(Swift高阶语法) 是将 int 转换成 UIImage 数组 {} 中代表每一个数据转换的格式闭包
let dataSource = (0..<39).sorted().map { UIImage(named: "\($0)" )}

// 强转 as as! as? 
(collectionViewLayout as! CollectionViewLayout).delegate = self
```

[CollectionViewDemo](https://github.com/a407184508/CollectionViewDemo.git)
