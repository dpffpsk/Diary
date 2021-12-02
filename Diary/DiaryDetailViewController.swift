//
//  DiaryDateViewController.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

/* delegate로 데이터 넘김
protocol DiaryDetailViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
    func didSelectStar(indexPath: IndexPath, isStar: Bool)
}
*/

class DiaryDetailViewController: UIViewController {

    var diary: Diary?
    var indexPath: IndexPath?
//    weak var delegate: DiaryDetailViewDelegate?
    var starButton: UIBarButtonItem?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    
    //수정버튼
    @IBAction func tapEditButton(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        
        //NotificationCenter 옵저버 추가
        NotificationCenter.default.addObserver(self, selector: #selector(editDiaryNotification(_:)), name: NSNotification.Name("editDiary"), object: nil)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func editDiaryNotification(_ notification :Notification){
        //post메서드로 보낸 데이터 가져옴
        guard let diary = notification.object as? Diary else { return }
        self.diary = diary
        self.configureView()
    }
    
    //삭제버튼
    @IBAction func tapDeleteButton(_ sender: Any) {
        guard let uuidString = self.diary?.uuidString else { return }
//        self.delegate?.didSelectDelete(indexPath: indexPath)
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }
    @objc func starDiaryNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
        }
    }
    
    //MARK: - configureView
    //프로퍼티를 통해 전달받은 다이어리 객체를 뷰에 초기화
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    @objc func tapStarButton() {
        guard let isStar = self.diary?.isStar else { return }

        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: Notification.Name("starDiary"),
            object: [
                "diary" : self.diary,
                "isStar" : self.diary?.isStar ?? false,
                "indexPath" : diary?.uuidString
            ],
            userInfo: nil
        )
        //self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false) //즐겨찾기 상태 전달
    }

    //MARK: - dateToString
    //date -> string 반환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    //NotificationCenter 관찰이 필요없을 때는 옵저버 제거
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
