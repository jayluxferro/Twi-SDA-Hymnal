//
//  FavoritesViewController.swift
//  Twi SDA Hymnal
//
//  Created by Jay on 04/04/2020.
//  Copyright © 2020 SPERIXLABS. All rights reserved.
//

import UIKit
import SwipeCellKit
import Firebase
import SVProgressHUD

class FavoritesViewController: UIViewController {
    private var hymns = [FavHymn]()
    private let favDB = K.favDb, hymnDB = K.dB
    private var uid: String?
    @IBOutlet weak var tableView: UITableView!
    private var selectedHymn: Hymn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: K.tableCell.favHymnCell)
        fetchUserFavs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
    }
    
    func fetchUserFavs(){
        if let userId = Auth.auth().currentUser?.uid {
            SVProgressHUD.showProgress(0, status: K.loader.loading)
            uid = userId
            
            // fetch all user favorites
            favDB.whereField(K.favHymn.uid, isEqualTo: userId)
                .order(by: K.hymn.id)
                .addSnapshotListener { (snapShot, error) in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        print(error as Any)
                        return
                    }
                    self.hymns = []
                    var counter = 1
                    let totalHymns = snapShot?.count
                    
                    if snapShot!.count == 0 {
                        SVProgressHUD.dismiss()
                    }
                    
                    for document in snapShot!.documents {
                        do{
                            var userFavHymn = try document.data(as: FavHymn.self)
                            // searching through main hymn db for data
                            
                            self.hymnDB
                                .whereField(K.hymn.num, isEqualTo: userFavHymn.num!)
                                .limit(to: 1)
                                .addSnapshotListener { (hymnSnapshot, hymnError) in
                                    if hymnError != nil {
                                        SVProgressHUD.dismiss()
                                        print(hymnError as Any)
                                        return
                                    }
                                    
                                    if hymnSnapshot!.count == 0 {
                                        SVProgressHUD.dismiss()
                                    }
                                    
                                    for hymnDoc in hymnSnapshot!.documents {
                                        do{
                                            userFavHymn.hymn = try hymnDoc.data(as: Hymn.self)
                                            self.hymns.append(userFavHymn)
                                            counter += 1
                                            if SVProgressHUD.isVisible() {
                                                SVProgressHUD.showProgress(Float(counter)/Float(totalHymns!), status: K.loader.loading)
                                            }
                                        }
                                        catch {
                                            print(error)
                                        }
                                       
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        if SVProgressHUD.isVisible(){
                                            SVProgressHUD.dismiss()
                                        }
                                    }
                            }
                        }
                        catch {
                            print(error)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            }
        }
    }
    
    func removeFavoriteHymn(_ id: String) {
        favDB.document(id).delete { (error) in
            if error != nil {
                print(error as Any)
            }else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - TableView Implementation
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            self.removeFavoriteHymn(self.hymns[indexPath.row].documentId!)
        }
        
        deleteAction.image = UIImage(systemName: K.icons.delete)
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hymns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCell.favHymnCell) as! SwipeTableViewCell
        let current_hymn = hymns[indexPath.row]
        cell.delegate = self
        cell.textLabel?.text = "\(String(describing: current_hymn.hymn!.num!)) - \(String(describing: current_hymn.hymn!.title!))."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedHymn = hymns[indexPath.row].hymn
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: K.segue.favToHymn, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segue.favToHymn {
            let vc = segue.destination as! HymnViewController
            vc.currentHymn = selectedHymn
        }
    }
}
