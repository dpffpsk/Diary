//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

//등록 or 수정 구분
enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary) //수정의 경우 detail페이지에서 데이터 받기
}


//해당 delegate를 통해 작성된 다이어리객체 전달
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var confirmButton: UIBarButtonItem!
    
    //등록 버튼
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        //NotificationCenter : 등록된 이벤트가 발생하면 해당 이벤트들에 대한 행동을 취함(앱 내에서 아무데나서 메세지 던지면 아무데서나 받을 수 있음), post 메서드로 이벤트 전달, 옵저버 등록해서 이벤트 받음
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(title: title, contents: contents, date: date, isStar: false)
            self.delegate?.didSelectRegister(diary: diary)
        case let .edit(indexPath, diary):
            let diary = Diary(title: title, contents: contents, date: date, isStar: diary.isStar)
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: [
                    "indexPath.row" : indexPath.row
                ] //notification과 관련된 값 넘겨줌
            )
        }
        self.navigationController?.popViewController(animated: true) //일기장 화면으로 이동
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false
    }

    
    //MARK: - configureContentsTextView
    //내용 textView 테두리 설정
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    
    //MARK: - configureDatePicker
    //datePicker 설정
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) //값이 변경될 때(valueChanged) 함수(datePickerValueDidChange) 호출
        self.datePicker.locale = Locale(identifier: "ko-KR") //datePicker 선택창 한국어로 표현
        self.dateTextField.inputView = self.datePicker //dateTextField 선택 시 datePicker 올라오도록
    }
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formater = DateFormatter() //날짜와 텍스트 반환
        formater.dateFormat = "yyyy년 MM월 dd일(EEEEE)" //요일은 한글자로만 표현되도록
        formater.locale = Locale(identifier: "ko_KR") //dateFormat 한국어로 표현
        self.diaryDate = datePicker.date
        self.dateTextField.text = formater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged) //날짜 변경될 때마다 dateTextFieldDidChange 메서드 호출
    }
    
    
    //MARK: - touchesBegan
    //빈 화면 클릭시 키보드나 데이트 피커 닫히게 설정
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: - configureInputField
    private func configureInputField(){
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    
    //MARK: - validateInputField
    //등록버튼의 활성화 여부를 판단하는 메서드
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
    
    //MARK: - configureEditorMode
    //수정일 경우, 전달 받은 데이터로 초기화
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
        default:
            break
        }
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


//MARK: - UITextViewDelegte
//텍스트 뷰에 내용이 입력될 때마다 호출되는 메서드
extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
