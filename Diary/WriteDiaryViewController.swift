//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by rs on 2022/01/25.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.createView()
        self.confirmButton.isEnabled = false // 버튼 비활성화
    }
    
    private func createView() {
        self.contentsTextView.layer.borderWidth = 1.0
        self.contentsTextView.layer.borderColor = UIColor.black.cgColor
    }
    
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
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    
    //textView는 borderColor가 없어서 테두리가 보이지 않는다 이렇게 코드로 boaderColor를 지정해 줘야한다.
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0) //alpha는 투명도 이다.
        self.contentsTextView.layer.borderColor = borderColor.cgColor //layer 관련 컬러를 설정할때는 UIColor가 아니라 cgColor로 설정 해야한다.
      
        
    }
    
    //데이트 피커 ->  데이터 값 설정
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date //날짜만 나오게
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko_KR") //한국 방식으로 데이터 나오게
        self.dateTextField.inputView = self.datePicker
    }
    
    //textField에 입력 필드 구성 함수
    private func configureInputField() {
       
        self.contentsTextView.delegate = self
        
        //텍스트 필드에 내용이 채워 질때 마다 호출하는 함수 설정
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_ :))   , for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    //확인 버튼 작동 함수
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        
        switch self.diaryEditorMode {
        case .new:
            self.delegate?.didSelectRegister(diary: diary)
        case let .edit(IndexPath, _):
            NotificationCenter.default.post(name: NSNotification.Name("editDiary"),
                                            object: diary,
                                            userInfo: [
                                                "indexPath.row": IndexPath.row
                                            ]
            )
            
        }
        
        self.delegate?.didSelectRegister(diary: diary)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
        
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
     
    
    //빈 화면이나 바탕을 누르게 되면 키보드나 데이트 피커가 사라지는 함수. -> 유저가 화면을 터치하면 호출되는 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //등록버튼 활성화 시키는 함수
    private func validateInputField() {
        // textField text가 nil 값이 아니면 true로 해서 버튼이 활성회 되는 방식 (하나라도 false이면 false가 나오기때문에 3개 다 true로 나와야 한다.)
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
}

extension WriteDiaryViewController: UITextViewDelegate {
    
    //내용이 입력 될때 마다 호출 되는 함수
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
