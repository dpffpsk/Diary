//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 이니텍 on 2021/11/24.
//

import UIKit

//해당 delegate를 통해 작성된 다이어리객체 전달
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: WriteDiaryViewDelegate?
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var confirmButton: UIBarButtonItem!
    
    //등록 버튼
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        self.delegate?.didSelectRegister(diary: diary)
        self.navigationController?.popViewController(animated: true) //일기장 화면으로 이동
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
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
}


//MARK: - UITextViewDelegte
//텍스트 뷰에 내용이 입력될 때마다 호출되는 메서드
extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
