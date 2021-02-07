import UIKit
import AVFoundation
import Firebase

class HymnViewController: UIViewController {

    var currentHymn: Hymn?
    @IBOutlet weak var engHymnContent: UITextView!
    @IBOutlet weak var toggleView: UISegmentedControl!
    @IBOutlet weak var twiHymnContent: UITextView!
    private var isPlayingMidi = false
    private var isFavoriteHymn = false
    private var audioPlayer: MidiPlayerManager?
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var favBtn: UIBarButtonItem!
    private let fav = K.favDb
    private var uid: String?
    private var favId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContent()
        updateView(category: K.hymnView.eng)
        toggleView.addTarget(self, action: #selector(toggleViewResponse), for: .valueChanged)
        getUserFavoriteHymn()
        
        // display only categories with content
        checkIfAllCategoriesAreActive()
    }
    
    func checkIfAllCategoriesAreActive(){
        if let eng = currentHymn?.eng, let twi = currentHymn?.twi {
            if eng == "" {
                toggleView.selectedSegmentIndex = 1
                toggleView.removeSegment(at: 0, animated: true)
                updateView(category: K.hymnView.twi)
            }
            
            if twi == "" {
                toggleView.selectedSegmentIndex = 0
                toggleView.removeSegment(at: 1, animated: true)
                updateView(category: K.hymnView.eng)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMidi()
    }
    
    @IBAction func updateUserFavHymn(_ sender:
        UIBarButtonItem) {

        if uid != nil, let hymn = currentHymn {
            if isFavoriteHymn {
                // removing from favorite hymn
                if let doc = favId {
                    self.fav.document(doc).delete { (error) in
                        if let err = error {
                            print(err)
                        }
                    }
                    self.isFavoriteHymn = false
                    self.favId = nil
                    self.updateFavoriteHymnView()
                }
                return
            }
            
            // new request
            var ref: DocumentReference? = nil
            let userFavoriteData = FavHymn(num: hymn.num!, hymn: hymn, uid: uid!)
            do{
                ref = try fav.addDocument(from: userFavoriteData) { (error) in
                    if error != nil {
                        print(error as Any)
                    }else {
                        self.favId = ref?.documentID
                        self.isFavoriteHymn = true
                        self.updateFavoriteHymnView()
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func getUserFavoriteHymn(){
        if let hymn = currentHymn {
            if let userId = Auth.auth().currentUser?.uid {
                self.uid = userId
                self.fav
                    .whereField(K.favHymn.uid, isEqualTo: userId)
                    .whereField(K.hymn.num, isEqualTo: hymn.num!)
                    .limit(to: 1)
                    .addSnapshotListener{ (snapShot, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        
                        for document in snapShot!.documents {
                            self.favId = document.documentID
                            self.isFavoriteHymn = true
                            self.updateFavoriteHymnView()
                        }
                        
                }
            }
        }
    }
    
    func updateFavoriteHymnView(){
        favBtn.image = isFavoriteHymn ? UIImage(systemName: K.icons.yes) : UIImage(systemName: K.icons.no)
    }
    
    
    @objc
    func toggleViewResponse(){
        switch toggleView.selectedSegmentIndex {
        case 0:
            // english
            updateView(category: K.hymnView.eng)
            break
        case 1:
            updateView(category: K.hymnView.twi)
            break
        default:
            break
        }
    }
    
    @IBAction func playMidi(_ sender: UIBarButtonItem) {
        if let midi = currentHymn?.midi {
            if !isPlayingMidi {
                do {
                    if let path = Bundle.main.path(forResource: "\(K.sound.midiDirectory)/\(midi)", ofType : K.sound.audioFormat) {
                        let url = URL(fileURLWithPath : path)
                        
                        let avPlayer = try AVMIDIPlayer(contentsOf: url, soundBankURL: K.sound.soundbank)
                        
                        audioPlayer = MidiPlayerManager(mp: avPlayer)
                        audioPlayer?.mp.prepareToPlay()
                        playMidi()
                    }
                } catch {
                    print ("Error playing sound: \(error)")
                }
                return
            }
            
            // stop midi
            stopMidi()
        }
        
    }
    
    func playMidi(){
        audioPlayer?.mp.play{
            DispatchQueue.main.async {
                self.isPlayingMidi = false
                self.playButton.image = UIImage(systemName: K.icons.play)
            }
        }
        isPlayingMidi = true
        playButton.image = UIImage(systemName: K.icons.stop)
    }
    
    func stopMidi(){
        audioPlayer?.mp.stop()
        isPlayingMidi = false
        playButton.image = UIImage(systemName: K.icons.play)
    }
    
    
    func updateView(category: String){
        if category == K.hymnView.eng {
            engHymnContent.isHidden = false
            twiHymnContent.isHidden = true
        }
        else{
            engHymnContent.isHidden = true
            twiHymnContent.isHidden = false
        }
    }
    
    func loadContent(){
        if let data = currentHymn {
            self.navigationItem.title = "\(data.num!) - \(data.title!)"
            engHymnContent.text = data.scripture! ? data.eng!.htmlString : data.eng!
            engHymnContent.font = UIFont(name: K.font.engFont, size: CGFloat(K.font.engFontSize))
            twiHymnContent.text = data.scripture! ? data.twi!.htmlString : data.twi!
            twiHymnContent.font = UIFont(name: K.font.twiFont, size: CGFloat(K.font.twiFontSize))
        }
    }
}
