//
//  ViewController.swift
//  Diary
//
//  Created by rs on 2022/01/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
   
    //프로퍼티 옵저버
    //diaryList에 값이 추가가 되거나 삭제 될때 작동함
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiryList() //saveDiryList 함수가 실행 되면서 UserDefaults에 저장 됨
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    
    //저장한 값을 UserDefaults에 저장 시켜서 앱이 재 실행 돼도 값이 사라지지않고 나오겠금 하는것. (쿠키느낌?)
    private func saveDiryList() {
        let date = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
        
    }
    
    //UserDefaults에서 값을 가져오기
    private func loadDiaryList() {
        
        let userDefaults = UserDefaults.standard
        
        //Any type으로 반환 되기 때문에 디셔너리 타입으로 타입 캐스팅 해줘야한다.
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil}
            guard let isStar = $0["isStar"] as? Bool else { return nil}
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        
        //sort 정렬로 orderedDescending 내림 차순 정렬 (최신순 정렬)
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        cell.layer.borderWidth = 1
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
    
}

extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
        self.collectionView.reloadData()
        
        //sort 정렬로 orderedDescending 내림 차순 정렬 (최신순 정렬)
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
}

