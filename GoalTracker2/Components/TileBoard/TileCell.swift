//
//  TileCell.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/02/01.
//

import UIKit
import RxSwift
import RxCocoa

class TileCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    var indexLabel: UILabel?
    
    var imageWidth: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(imageWidth)
        }
    }
    
    func configure(statusRaw: String, dateLabelVisible: Bool, index: Int=0) {
        let status = GoalStatus(rawValue: statusRaw) ?? .none
        switch status {
        case .success:
            imageView.image = UIImage(named: "tile_success")
        case .fail:
            imageView.image = UIImage(named: "tile_fail")
        case .none:
            imageView.image = UIImage(named: "tile_empty")
        }
        
        if dateLabelVisible {
            setIndexLabel(index: index+1)
        } else {
            indexLabel?.isHidden = true
        }
    }
    
    private func setIndexLabel(index: Int) {
        indexLabel = UILabel()
        indexLabel?.textAlignment = .center
        indexLabel?.text = "\(index)"
        indexLabel?.font = .sfPro(size: 7, family: .Thin)
        
        imageView.addSubview(indexLabel!)
        indexLabel?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
