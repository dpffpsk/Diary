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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let writeDiaryViewController = segue.destination as? WriteDiaryViewController else { return }
        writeDiaryViewController.delegate = self
    }

}

extension ViewController: WriteDiaryViewDelegate {
    func didSelectReigster(diary: Diary) {
        self.diaryList.append(diary)
//        self.diaryCollectionView.reloadData()
    }
}

