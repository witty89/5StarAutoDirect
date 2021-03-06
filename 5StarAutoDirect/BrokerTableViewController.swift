//
//  BrokerTableViewController.swift
//  5StarAutoDirect
//
//  Created by Alex Whitlock on 6/15/17.
//  Copyright © 2017 PineAPPle LLC. All rights reserved.
//

import UIKit
import Firebase

class BrokerTableViewController: UITableViewController {
    
    static let shared = BrokerTableViewController()
    
    var user: User?
    
    var users: [User] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserList()
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserController.shared.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        let user = UserController.shared.users[indexPath.row]
        cell.textLabel?.text = user.name
        
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UserController.shared.deleteUser()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let currentUser = self.users[indexPath.row]
            self.showChatController(user: currentUser)
        }
    }
    
    func showChatController(user: User) {
        let messageDetailVC = MessageDetailViewController()
        MessagesTableViewController.shared.user = user
        navigationController?.pushViewController(messageDetailVC, animated: true)
    }
    
    
    func fetchUserList() {
        UserController.fetchUsers { (users) in
            self.users = users
        }
    }
}
