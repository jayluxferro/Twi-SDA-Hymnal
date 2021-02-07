import FirebaseFirestoreSwift

struct Hymn: Codable {
    @DocumentID var documentId: String?
    let id: Int?
    let title: String?
    let twi: String?
    let eng: String?
    let num: String?
    let midi: String?
    let scripture: Bool?
}
