import Foundation

struct GameSold: Codable {
    var id_game: Int
    var quantity: Int
    var tags: [String]?
    
    // Initialize with the correct parameter order to match the backend
    init(id_game: Int, quantity: Int, tags: [String]? = nil) {
        self.id_game = id_game
        self.quantity = quantity
        self.tags = tags
    }
}

struct Sale: Identifiable, Codable {
    var id_sale: String?  // Make optional for creation
    var date: Date?
    var amount: Double
    var comission: Double
    var payment_method: String
    var id_seller: String
    var id_client: Int
    var id_session: Int?
    var games_sold: [GameSold]
    
    // Add the id property for Identifiable conformance
    var id: String {
        return id_sale ?? UUID().uuidString
    }
        
    enum CodingKeys: String, CodingKey {
        case id_sale, date, amount, comission, payment_method, id_seller, id_client, id_session, games_sold
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id_sale = try container.decodeIfPresent(String.self, forKey: .id_sale)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        
        // Handle numeric values that might be encoded as strings
        if let amountString = try? container.decode(String.self, forKey: .amount) {
            amount = Double(amountString) ?? 0.0
        } else {
            amount = try container.decode(Double.self, forKey: .amount)
        }
        
        if let comissionString = try? container.decode(String.self, forKey: .comission) {
            comission = Double(comissionString) ?? 0.0
        } else {
            comission = try container.decode(Double.self, forKey: .comission)
        }
        
        payment_method = try container.decode(String.self, forKey: .payment_method)
        id_seller = try container.decode(String.self, forKey: .id_seller)
        id_client = try container.decode(Int.self, forKey: .id_client)
        id_session = try container.decode(Int.self, forKey: .id_session)
        games_sold = try container.decodeIfPresent([GameSold].self, forKey: .games_sold) ?? []
    }
    
    // For encoding - don't include id_sale when creating a new sale
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Only encode id_sale if it's not empty (for existing sales)
        if let idSale = id_sale, !idSale.isEmpty {
            try container.encode(idSale, forKey: .id_sale)
        }
        
        try container.encodeIfPresent(date, forKey: .date)
        try container.encode(amount, forKey: .amount)
        try container.encode(comission, forKey: .comission)
        try container.encode(payment_method, forKey: .payment_method)
        try container.encode(id_seller, forKey: .id_seller)
        try container.encode(id_client, forKey: .id_client)
        try container.encode(id_session, forKey: .id_session)
        try container.encode(games_sold, forKey: .games_sold)
    }
    
    // Regular initializer for creating sales in code
    init(id_sale: String? = nil, date: Date? = nil, amount: Double, comission: Double, payment_method: String, 
         id_seller: String, id_client: Int, id_session: Int, games_sold: [GameSold] = []) {
        self.id_sale = id_sale
        self.date = date
        self.amount = amount
        self.comission = comission
        self.payment_method = payment_method
        self.id_seller = id_seller
        self.id_client = id_client
        self.id_session = id_session
        self.games_sold = games_sold
    }
}
