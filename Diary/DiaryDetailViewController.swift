//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by rs on 2022/01/25.
//

import UIKit

protocol DiaryDetailViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //일기장 리스트에서 전달받을 프로퍼티 선언
    var diary: Diary?
    var indexPath: IndexPath?
    
    //일기장 상세에서 삭제 눌렀을떄 필요한 요소
    weak var delegate: DiaryDetailViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
    }
    
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}
