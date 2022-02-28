//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by rs on 2022/01/25.
//

import UIKit

//protocol DiaryDetailViewDelegate: AnyObject {
//    func didSelectDelete(indexPath: IndexPath)
////    func didSelectStar(indexPath: IndexPath, isStar: Bool)
//}

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //일기장 리스트에서 전달받을 프로퍼티 선언
    var diary: Diary?
    var indexPath: IndexPath?
    
    var starButton: UIBarButtonItem?
    
    //일기장 상세에서 삭제 눌렀을떄 필요한 요소
//    weak var delegate: DiaryDetailViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action:  #selector(tapStarButton))
        
        if #available(iOS 13.0, *) {
            self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        } else {
            // Fallback on earlier versions
        }
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
        
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath  = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editDiaryNotification(_:)),
                                               name: NSNotification.Name("editDiary"),
                                               object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diary = diary
        self.configureView()
    }
    
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: indexPath,
            userInfo: nil
        )
//        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    //즐겨찾기 버튼 클릭시 작동
    @objc func tapStarButton() {
        
        guard let isStar = self.diary?.isStar else { return }
        guard let indexPath = self.indexPath else { return }
        if isStar {
            if #available(iOS 13.0, *) {
                self.starButton?.image = UIImage(systemName: "star")
            } else {
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 13.0, *) {
                self.starButton?.image = UIImage(systemName: "star.fill")
            } else {
                // Fallback on earlier versions
            }
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(name: NSNotification.Name("starDiary"), object: ["isStar": self.diary?.isStar ?? false,
                                                                                         "indexPath": indexPath], userInfo: nil)
//        self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
