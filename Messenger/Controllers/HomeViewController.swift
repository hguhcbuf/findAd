//
//  ViewController.swift
//  Messenger
//
//  Created by 김종현 on 2021/01/13.
//  Copyright © 2021 kjh. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class HomeViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    let chatListViewController = ChatListViewController()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noCreatorLabel: UILabel = {
        let label = UILabel()
        label.text = "등록된 크리에이터가 없습니다"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapSearchButton))
        
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noCreatorLabel)
        setUpTableView()
        
        fetchCreators()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    
    // completion 과 createNewConversation 함수는 크리에이터들의 프로필.controller으로 나중에 옮길거임
    @objc private func didTapSearchButton() {
        let vc = SearchBarViewController()
        vc.completion = { result in
            
        }
            

        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false)
    }
    
    
    //유저가 로그인 안돼있을경우
    private func validateAuth() {
        //currentUser property는 로그인하면 자동으로 생성됨
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false, completion: nil)
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchCreators() {
        tableView.isHidden = false
    }

}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        //옆에 화살표 생기는 효과
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CreatorInfoViewController()
        vc.title = "김종현님의 정보"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
