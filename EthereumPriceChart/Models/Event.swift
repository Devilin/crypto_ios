import Foundation

struct Event: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let date: Date
    let impact: Impact
    let newsExample: String
    
    enum Impact: String, Decodable {
        case upward = "Upward"
        case downward = "Downward"
        case mixed = "Mixed"
        case potentialUpward = "Potential Upward"
    }
    
    enum CodingKeys: String, CodingKey {
        case name, date, impact, newsExample = "news_example"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let parsedDate = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        date = parsedDate
        
        impact = try container.decode(Impact.self, forKey: .impact)
        newsExample = try container.decode(String.self, forKey: .newsExample)
    }
}

struct EventsData: Decodable {
    let pastEvents: [Event]
    let upcomingEvents: [Event]
    
    enum CodingKeys: String, CodingKey {
        case pastEvents = "past_events"
        case upcomingEvents = "upcoming_events"
    }
}
