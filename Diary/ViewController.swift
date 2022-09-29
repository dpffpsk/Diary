//
//  ViewController.swift
//  Diary
//
//  Created by wony on 2022/09/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var diaryCollectionView: UICollectionView!
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let writeDiaryViewController = segue.destination as? WriteDiaryViewController else { return }
        writeDiaryViewController.delegate = self
    }
    
    private func configureCollectionView() {
        self.diaryCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.diaryCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.diaryCollectionView.delegate = self
        self.diaryCollectionView.dataSource = self
    }
    
    // date -> string
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

}

extension ViewController: WriteDiaryViewDelegate {
    func didSelectReigster(diary: Diary) {
        self.diaryList.append(diary)
//        self.diaryCollectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = diaryCollectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        
        let diary = diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}
