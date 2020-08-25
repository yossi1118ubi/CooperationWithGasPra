//
//  ViewController.swift
//  CooperationWithGasPra
//
//  Created by Daichi Yoshikawa on 2020/08/25.
//  Copyright © 2020 Daichi Yoshikawa. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate{
    
      //Cellの総数を返すdatasourceメソッド
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return movieList.count
      }
      
      //Cellに値を設定するdatasourceメソッド
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
          //今回表示を行う, Cellオブジェクト(1行)を取得する
          let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
          //動画のタイトルを設定
          cell.textLabel?.text = movieList[indexPath.row].movie
          
          return cell
      }
      
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ){
        //ハイライト削除
        tableView.deselectRow(at: indexPath, animated: true)
        //SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: movieList[indexPath.row].movie_url)
        
        //delegateの通知先を自分自身
        safariViewController.delegate = self
        
        //SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
        
    }
    
    //SafariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController){
        //SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableOfView: UITableView!
    
    //動画のリスト(タプル配列)
    var movieList: [(movie:String, movie_url: URL, channel: String, tag: String)] = []
    var listCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        searchBar.placeholder = "キーワードを入力"
        
        //Table Of ViewのdataSourceの設定
        tableOfView.dataSource = self
        
        //Table Of ViewのDelegateを設定
        tableOfView.delegate = self
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        //iOSはキーボードは自動で開くが, 閉じるのは手動
        view.endEditing(true)
        
        if let searchWord = searchBar.text{
            print(searchWord)
            
            //キーワードが入力されたら検索
            searchMovie(keyword: searchWord)
            
        }
    }
    
    //検索するURLを作る
    func searchMovie(keyword: String){
        //キーワードをURLにエンコード
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else{
            return
        }
        
        //リクエストURL組み立て
        guard let req_url = URL(string: "https://script.google.com/macros/s/AKfycbxl5q0yNZqLnQM3O3mThBJGuOmCDOqON8QCDmQ-AfwqwtU5MGQ/exec?q=\(keyword_encode)")else{
            return
        }
        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate:nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            //セッション終了
            session.finishTasksAndInvalidate()
            //do try catch エラーハンドリング
            do{
                //JSONDecoderのインスタンスを取得
                let decoder = JSONDecoder()
                print("decoderは生成できた")
                print(data!)
                print(response!)
                //受け取ったJSONデータをパースして格納
                let json: [ItemJson] = try decoder.decode([ItemJson].self, from: data!)
                
                print(json)
                
                self.listCount = json.count - 1
                
                self.movieList.removeAll()
                
                for i in 0...self.listCount {
                    if let movie = json[i].movie, let movie_url = json[i].movie_url, let channel = json[i].channel, let tag = json[i].tag{
                        
                        //タプルで管理
                        let movie_taple = (movie, movie_url, channel, tag)
                        //配列にappend
                        self.movieList.append(movie_taple)
                    }
                }
                //TableViewを更新
                self.tableOfView.reloadData()
                
                if let moviedb = self.movieList.first{
                    print("-----------------")
                    print("okashiList[0] = \(moviedb)")
                }
                
            }catch{
                //エラー処理
                print("エラーが出ました")
            }
        })
        task.resume()
        
    }
    
    
  
    
    struct ItemJson: Codable{
        //要素
        let movie: String?
        let movie_url: URL?
        let channel: String?
        let tag: String?
    }
    
//    struct ResultJson: Codable{
//        //複数要素
//        let item:[ItemJson]?
//    }

}

