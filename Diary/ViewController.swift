//
//  ViewController.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    //diaryList 프로퍼티 옵저버
    private var diaryList = [Diary]() {
        //diaryList 배열에 변경이 일어날 때마다 userDefaults에 저장
        didSet {
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()

        //NotificationCenter 옵저버 추가 
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            //날짜 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    @objc func starDiaryNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList[index].isStar = isStar
    }
    @objc func deleteDiaryNotification(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //세그웨이로 이동되는 컨트롤러가 무엇인지 알 수 있게
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self //delegate 위임
        }
    }
    
    //MARK: - configureCollectionView
    //등록된 일기를 collectionView에 보여줌
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    //MARK: - dateToString
    //date -> string 반환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    //MARK: - saveDiaryList
    //diary를 userdefaults에 딕셔너리 형태로 저장(앱을 재시작해도 등록한 목록 유지)
    private func saveDiaryList(){
        let date = self.diaryList.map {
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    //MARK: - loadDiaryList
    //userDefaults에 저장된 값 불러오는 메서드
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard

        //diary의 key(diaryList)값으로 리스트 가져오기
        //object는 Any타입으로 반환하기 때문에 딕셔너리 배열 형태로 타입 캐스팅
        //nil이 반환될 수 있기 때문에 옵서녈 바인딩
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }
        
        //최신순으로 정렬
        //왼쪽 데이터를 오른쪽 데이터 비교해가며 내림차순으로 정렬되게
        self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedDescending
        })
    }
}

//MARK: - WriteDiaryViewDelegate
//WriteDiaryViewController의 delegate 사용해서 등록한 diary 넘겨받기
extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        debugPrint(diary)
        self.diaryList.append(diary)
        //왼쪽 데이터를 오른쪽 데이터 비교해가며 내림차순으로 정렬되게
        self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedAscending
        })
        self.collectionView.reloadData() //추가할 때마다 일기 목록에서 표시
    }
}

//MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DiaryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCollectionViewCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        debugPrint(diary)
        
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    //표시할 셀의 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //(아이폰 넓이/2) - contents inset의 left, right(각 10씩)
        return CGSize(width: (UIScreen.main.bounds.width/2) - 20, height: 200)
    }
}

//MARK: - UICollectionVeiwDelegate
//디테일 페이지로 데이터 넘김
extension ViewController: UICollectionViewDelegate {
    //특정 셀이 선택되었음을 알리는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
       // viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
