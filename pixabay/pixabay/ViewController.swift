//
//  ViewController.swift
//  pixabay
//
//  Created by yernar on 10.10.2023.
//

import UIKit
import SnapKit
import AVKit
import AVFoundation


class ImageDetailViewController: UIViewController {
    var selectedImage: UIImage?

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = selectedImage {
            imageView.image = image
            view.addSubview(imageView)
            view.addSubview(closeBtn)
        }

        closeBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        closeBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-200)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let imageSize = CGSize(width: view.frame.width, height: 400)
        let x = (view.bounds.width - imageSize.width) / 2
        let y = (view.bounds.height - imageSize.height) / 2
        imageView.frame = CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)
    }


    
    private let closeBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    @objc func closeBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
}

class VideoViewController: UIViewController {
    var videoURL: URL!

    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoURL = videoURL else {
            // Handle nil or invalid video URL
            return
        }

        player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        if let playerViewController = playerViewController {
            addChild(playerViewController)
            view.addSubview(playerViewController.view)
            playerViewController.view.frame = view.bounds
            print("IS PLAYING")
            player?.play()
            player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.status) {
            if player?.status == .failed {
                print("Player failed with error: \(player?.error?.localizedDescription ?? "Unknown Error")")
            }
        }
    }

    deinit {
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
    }
}

struct PixabayVideoResponse: Codable {
    let total: Int
    let totalHits: Int
    let hits: [PixabayVideo]
}

struct PixabayVideo: Codable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let duration: Int
    let videos: PixabayVideoURLs
}

struct PixabayVideoURLs: Codable {
    let large: PixabayVideoURL
}

struct PixabayVideoURL: Codable {
    let url: String
    let width: Int
    let height: Int
    let size: Int
}


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!

    var photoData: [String] = []
    var videoUrls: [String] = []
    
    let videoViewController = VideoViewController()

    var selectedSegmentIndex: Int = 0
    var imageUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        fetchRandomImagesFromPixabay { imageUrls in
            self.imageUrls = imageUrls
            DispatchQueue.main.async {
            self.collectionView.reloadData()
            }
        }
        fetchRandomMediaFromPixabay(mediaType: "video") { videoUrls in
            self.videoUrls = videoUrls
            DispatchQueue.main.async {
            self.collectionView.reloadData()
            }
        }
    
        setupViews()
        setupConstraints()
    }
    let segmentControl = UISegmentedControl(items: ["Image", "Movie"])
    let layout = UICollectionViewFlowLayout()
    let label = UILabel()
    let searchBar = UISearchBar()

    func setupViews() {
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        view.addSubview(collectionView)
        
        // Label
        label.text = "Movie & Images"
        label.textColor = UIColor(red: 24.0 / 255.0, green: 23.0 / 255.0, blue: 37.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "SF Pro Display", size: 20)
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        view.addSubview(label)

        
        // Segment Control
     
        segmentControl.selectedSegmentIndex = 0
        segmentControl.layer.cornerRadius = 8.91
        view.addSubview(segmentControl)
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)

        // Search Bar
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

    }

    func setupConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }

        segmentControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(105)
            make.width.equalTo(375)
            make.height.equalTo(36)
        }

        searchBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(157)
            make.width.equalTo(375)
            make.height.equalTo(36)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(210)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    @objc func segmentControlValueChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        collectionView.reloadData()

//        if selectedSegmentIndex == 1{
//            fetchVideosFromPixabay()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedSegmentIndex == 0 {
            return imageUrls.count
        } else {
            return videoUrls.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedSegmentIndex == 1 {
            if videoUrls.indices.contains(indexPath.row) {
                if let videoURL = URL(string: videoUrls[indexPath.row]) {
                    let player = AVPlayer(url: videoURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    playerViewController.modalPresentationStyle = .fullScreen
                    present(playerViewController, animated: true) {
                        player.play()
                    }
                } else {
                    print("Invalid video URL at index: \(indexPath.row)")
                }
            } else {
                print("Invalid video URL at index: \(indexPath.row)")
            }
        } else{
            let imageDetailViewController = ImageDetailViewController()
                if let imageUrl = photoData[safe: indexPath.row], let url = URL(string: imageUrl) {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        
                        imageDetailViewController.selectedImage = image
                        imageDetailViewController.modalPresentationStyle = .fullScreen
                        imageDetailViewController.modalTransitionStyle = .crossDissolve
                        present(imageDetailViewController, animated: true, completion: nil)
                    }
                }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.frame = CGRect(x: 0, y: 0, width: 190, height: 190)
        print(selectedSegmentIndex)
        if selectedSegmentIndex == 1 {
            if videoUrls.indices.contains(indexPath.row) {
                cell.imageView.image = nil
                let videoUrl = videoUrls[indexPath.row]
                let videoName = URL(string: videoUrl)?.lastPathComponent ?? "Video"
                cell.titleLabel.text = videoName
                
                let player = AVPlayer(url: URL(string: videoUrl)!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = cell.imageView.bounds
                playerLayer.videoGravity = .resizeAspect

                cell.imageView.layer.addSublayer(playerLayer)
                
                player.play()
            } else {
                print("Invalid video URL at index: \(indexPath.row)")
            }
        }else {
            if let imageUrl = photoData[safe: indexPath.row], let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    cell.imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

                    cell.imageView.loadImage(from: url)
                    cell.titleLabel.text = url.lastPathComponent
                }
            }
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 190,height: 190)
    }
    
    
    func fetchRandomImagesFromPixabay(completion: @escaping ([String]) -> Void) {
            let apiKey = "40281882-47dcd566a544bd6419def5351"
            let urlString = "https://pixabay.com/api/?key=\(apiKey)&order=popular&per_page=10"
            
            guard let url = URL(string: urlString) else {
                completion([])
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error fetching images: \(error)")
                    completion([])
                    return
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let hits = json?["hits"] as? [[String: Any]] {
                            let imageUrls = hits.compactMap { $0["webformatURL"] as? String }
                            self.photoData = imageUrls
                            completion(imageUrls)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion([])
                    }
                }
            }.resume()
        }
    
    func fetchRandomMediaFromPixabay(mediaType: String, completion: @escaping ([String]) -> Void) {
            let apiKey = "40281882-47dcd566a544bd6419def5351"
            let apiUrl = "https://pixabay.com/api/videos/?key=\(apiKey)&order=popular&per_page=10"

            guard let url = URL(string: apiUrl) else {
                print("Invalid API URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error fetching data: \(error)")
                    return
                }

                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                        let decoder = JSONDecoder()
                        let videoResponse = try decoder.decode(PixabayVideoResponse.self, from: data)
                        let videoURLs = videoResponse.hits.map { $0.videos.large.url }
                        completion(videoURLs)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIImage {
    func resize(toSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        return newImage
    }
}

extension UIImageView {
    func loadImage(from url: URL, retries: Int = 3) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error, retries > 0 {
                print("Error loading image: \(error)")
                // Retry the request with decreased number of retries
                self?.loadImage(from: url, retries: retries - 1)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image.resize(toSize: CGSize(width: 190, height: 190))
                }
            } else {
                print("Invalid data or image format")
            }
        }.resume()
    }
}
