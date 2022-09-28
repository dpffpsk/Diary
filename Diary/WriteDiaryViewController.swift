//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by wony on 2022/09/26.
//

import UIKit

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var registerButton: UIBarButtonItem! {
        didSet {
            registerButton.isEnabled = false
        }
    }
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        
    
    }

    // 등록 버튼
    @IBAction func tapRegisterButton(_ sender: Any) {
    }
    
    
    // contents
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/250, blue: 220/255, alpha: 0.7)
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 1.0
        self.contentsTextView.layer.cornerRadius = 5.0
        
    }
    
    // date
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date // 날짜만
        self.datePicker.preferredDatePickerStyle = .wheels
        
        // target: 타겟 설정, action: 응답할 메서드, for: 어떤 이벤트가 일어났을 때 반응할 것인지)
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date // 데이트 피커에서 선택된 date 값 넘기기
        self.dateTextField.text = formmater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    
    // title, contents, date value 확인 -> 등록 버튼 활성화
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField){
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField){
        self.validateInputField()
    }
    
    
    private func validateInputField() {
        self.registerButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 빈 화면 클릭시 입력 창 사라짐
        self.view.endEditing(true)
    }
}

extension WriteDiaryViewController: UITextViewDelegate, UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return Bool
//    }
//

    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
