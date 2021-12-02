//
//  StarCollectionViewCell.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

class StarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    //생성자
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
