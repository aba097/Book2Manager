//
//  isbn.swift
//  Book2Manager
//
//  Created by 相場智也 on 2022/04/25.
//


import Foundation

class Isbn: Decodable {
    
    let onix: Onix
    let summary:Summary
    
}

class Summary: Decodable {
    let title: String
    let publisher: String
    let author: String
}

class Onix: Decodable {
    let CollateralDetail: CCollateralDetail
}
class CCollateralDetail: Decodable {
    let TextContent: [CTextContent]
}

class CTextContent: Decodable {
    let Text: String
}

/*
 [
   {
     "onix": {
       "RecordReference": "9784023315686",
       "NotificationType": "03",
       "ProductIdentifier": {
         "ProductIDType": "15",
         "IDValue": "9784023315686"
       },
       "DescriptiveDetail": {
         "ProductComposition": "00",
         "ProductForm": "BA",
         "ProductFormDetail": "B112",
         "Measure": [
           {
             "MeasureType": "01",
             "Measurement": "172",
             "MeasureUnitCode": "mm"
           },
           {
             "MeasureType": "02",
             "Measurement": "107",
             "MeasureUnitCode": "mm"
           }
         ],
         "TitleDetail": {
           "TitleType": "01",
           "TitleElement": {
             "TitleElementLevel": "01",
             "TitleText": {
               "collationkey": "トイックエルアンドアールテスト",
               "content": "ＴＯＥＩＣ　Ｌ＆Ｒ　ＴＥＳＴ"
             },
             "Subtitle": {
               "collationkey": "デルタントッキュウキンノフレーズ",
               "content": "出る単特急金のフレーズ"
             }
           }
         },
         "Contributor": [
           {
             "SequenceNumber": "1",
             "ContributorRole": [
               "A01"
             ],
             "PersonName": {
               "collationkey": "ティーイーエックスカトウ",
               "content": "ＴＥＸ加藤"
             }
           }
         ],
         "Language": [
           {
             "LanguageRole": "01",
             "LanguageCode": "jpn",
             "CountryCode": "JP"
           }
         ],
         "Subject": [
           {
             "MainSubject": "",
             "SubjectSchemeIdentifier": "78",
             "SubjectCode": "0082"
           }
         ],
         "Audience": [
           {
             "AudienceCodeType": "22",
             "AudienceCodeValue": "00"
           }
         ]
       },
       "CollateralDetail": {
         "TextContent": [
           {
             "TextType": "03",
             "ContentAudience": "00",
             "Text": "【語学/英米語】TOEIC界の絶対バイブル「金フレ」が、新形式に対応して完全改訂。著者のTEX氏が3年かけて吟味、推敲を重ねた「100％の単語帳」。質・内容・コスパ、これ以上のTOEIC単語集はありません！　面白いです。スコアも上がります。"
           }
         ]
       },
   

     },
    
     "summary": {
       "isbn": "9784023315686",
       "title": "ＴＯＥＩＣ　Ｌ＆Ｒ　ＴＥＳＴ",
       "volume": "",
       "series": "",
       "publisher": "朝日新聞出版",
       "pubdate": "20170106",
       "cover": "",
       "author": "ＴＥＸ加藤／著"
     }
   }
 ]
 */

