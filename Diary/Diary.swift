//
//  Diary.swift
//  Diary
//
//  Created by 이니텍 on 2021/12/01.
//

import Foundation

struct Diary {
    var uuidString: String
    var title: String
    var contents: String
    var date: Date
    var isStar: Bool //즐겨찾기 여부 저장
}
