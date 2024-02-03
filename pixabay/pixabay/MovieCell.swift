//
//  PhotoCell.swift
//  pixabay
//
//  Created by yernar on 12.10.2023.
//

import UIKit
import SnapKit

class MovieCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
        }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let sfProTextFont = UIFont(name: "SFProText-Regular", size: 17.0)
        label.font = sfProTextFont
        label.textColor = .black
        label.backgroundColor = UIColor(red: 237/255, green: 248/255, blue: 235/255, alpha: 1.0)
        return label
    }()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(){
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView)
            make.right.equalTo(imageView)
            make.bottom.equalToSuperview()
            make.width.equalTo(imageView)
        }
        
        
    }
}
