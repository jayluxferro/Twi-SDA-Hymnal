import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var hymns = [Hymn]()
    var filterHymns = [Hymn]()
    
    let cellReuseIdentifier = K.tableCell.cellIdentifier
    let db = K.dB
    
    var selectedHymn: Hymn?
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        // fetchData
        fetch_data()
    }
    
    
    func reloadTable(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func fetch_data(){
        SVProgressHUD.showProgress(0, status: K.loader.loading)
        db.order(by: K.hymn.id)
            .addSnapshotListener{ (querySnapshot, err) in
                if err != nil {
                    SVProgressHUD.dismiss()
                    print("Error getting documents: \(String(describing: err))")
                }else{
                    
                    if querySnapshot!.count == 0 {
                        SVProgressHUD.dismiss()
                    }
                    
                    // clear current hymns
                    self.hymns = []
                    var counter = 1
                    let totalHymns = querySnapshot?.count
                    for document in querySnapshot!.documents {
                        do {
                            try self.hymns.append(document.data(as: Hymn.self)!)
                            counter += 1
                            if SVProgressHUD.isVisible() {
                                SVProgressHUD.showProgress(Float(counter)/Float(totalHymns!), status: K.loader.loading)
                            }
                        }catch {
                            print(error)
                        }
                    }
                    DispatchQueue.main.async {
                        self.reloadTable()
                        if SVProgressHUD.isVisible(){
                            SVProgressHUD.dismiss()
                        }
                    }
                    
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segue.gotoHymn {
            let vc = segue.destination as! HymnViewController
            vc.currentHymn = selectedHymn
            
        }
    }
}

// MARK: - HTML Attribute
extension String {
var utfData: Data? {
        return self.data(using: .utf8)
    }

    var htmlAttributedString: NSAttributedString? {
        guard let data = self.utfData else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    var htmlString: String {
        return htmlAttributedString?.string ?? self
    }
}

// MARK: - SearchBar Implementation
extension HomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false
        
        searchBar.showsCancelButton = true
        if let textEntered = searchBar.text {
            if textEntered.count > 0 {
                searchActive = true
            }else{
                searchActive = false
            }
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        
        if searchText == "" {
            searchActive = false
            tableView.reloadData()
            return
        }
    
        filterHymns = hymns.filter({ (Hymn) -> Bool in
            let tmpHymn:Hymn = Hymn
            let hymnNumber = tmpHymn.num! as NSString
            let hymnTitle = tmpHymn.title! as NSString
            let hymnNumberFound = hymnNumber.range(of: searchText.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive)
            let titleFound = hymnTitle.range(of: searchText.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive)
            
            return (hymnNumberFound.location != NSNotFound || titleFound.location != NSNotFound)
            
        })
        tableView.reloadData()
    }
}

// MARK: - TableView Implementation
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filterHymns.count
        }
        return hymns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!

        var current_hymn = hymns[indexPath.row]
        if searchActive {
           current_hymn = filterHymns[indexPath.row]
        }
        cell.textLabel?.text = "\(String(describing: current_hymn.num!)) - \(String(describing: current_hymn.title!))."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchActive {
            selectedHymn = filterHymns[indexPath.row]
        }else {
            selectedHymn = hymns[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: K.segue.gotoHymn, sender: self)
    }
}
