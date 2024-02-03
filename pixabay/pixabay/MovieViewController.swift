//
//  ViewController.swift
//  pixabay
//
//  Created by yernar on 10.10.2023.
//

import UIKit
import SnapKit
class MovieDetailViewController: UIViewController {
    var selectedImage: UIImage?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = selectedImage
        view.addSubview(imageView)
    }
}
class MovieViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!

    var movieData = ["movieImages","movieImages","movieImages","movieImages",]
//    var imageDetailControllers: [ImageDetailViewController] = []
//    var selectedSegmentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        fetchPhotoFromPixabay()
        view.backgroundColor = .white

        // Collection View Setup
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        view.addSubview(collectionView)
        
        // Label
        let label = UILabel()
        label.text = "Movie & Images"
        label.textColor = UIColor(red: 24.0 / 255.0, green: 23.0 / 255.0, blue: 37.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "SF Pro Display", size: 20)
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        view.addSubview(label)

        
        // Segment Control
        let segmentControl = UISegmentedControl(items: ["Image", "Movie"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.layer.cornerRadius = 8.91
        view.addSubview(segmentControl)

        // Search Bar
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        // Label Constraints
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }

        // Segment Control Constraints
        segmentControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(105)
            make.width.equalTo(375)
            make.height.equalTo(36)
        }

        // Search Bar Constraints
        searchBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(157)
            make.width.equalTo(375)
            make.height.equalTo(36)
        }
        
        //CollectionView Constraints
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(210)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        

        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData.count
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.imageView.image = UIImage(named: movieData[indexPath.row])
        cell.titleLabel.text = "Movie \(indexPath.row + 1)"
                    
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 190,height: 190)
    }
}

