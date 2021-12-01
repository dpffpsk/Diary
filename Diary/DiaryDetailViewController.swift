//
//  DiaryDateViewController.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    var diary: Diary?
    var indexPath: IndexPath?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func tapEditButton(_ sender: Any) {
    }
    @IBAction func tapDeleteButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    //MARK: - configureView
    //프로퍼티를 통해 전달받은 다이어리 객체를 뷰에 초기화
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }

    //MARK: - dateToString
    //date -> string 반환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
