//
//  ChatListViewController.swift
//  Messenger
//
//  Created by 김종현 on 2021/01/30.
//  Copyright © 2021 kjh. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD



class ChatListViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noChatsLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅 상대가 없습니다"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapSearchButton))
        
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noChatsLabel)
        setUpTableView()
        
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil, queue: .main, using: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
                                                                
            strongSelf.startListeningForConversations()
        })
    }
    
    @objc private func didTapSearchButton() {
        
        let vc = SearchBarViewController()
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false)
        
        vc.completion = { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAdress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
    }
    
    private func createNewConversation(result: SearchResult) {
        
        let name = result.name
        
        let email = DatabaseManager.safeEmail(emailAdress: result.email)
        
        // check in database if conversatino with these two users exists
        // if it does, reuse conversation id
        //otherwise use existing code
        
        DatabaseManager.shared.conversationExists(with: email) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func startListeningForConversations() {
        //처음 앱을 열고 로그인했을때 email정보가 없어서 데이터가 안들어옴. 따라서 viewDidLoad에서 로그인됨과 동시에 이 함수를 불러오게 함
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] (result) in
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noChatsLabel.isHidden = false
                    print("conversations is empty")
                    return
                }
                self?.noChatsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                print("convos: \(conversations)")
                
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noChatsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noChatsLabel.frame = CGRect(x: 10,
                                    y: (view.height-100)/2,
                                    width: view.width-20,
                                    height: 100)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
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
    
    

}


//MARK: - UITableView Extension

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        //옆에 화살표 생기는 효과
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        // **isNewConversation true/false 는 나중에 생각해서 고치기**
        //vc.isNewConversation = true
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { (success) in
                if !success {
                    // Can add model and row back and show error alert
                    print("failed to delete")
                }
            }

            tableView.endUpdates()
        }
    }
    
}
