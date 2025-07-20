import Foundation
import Combine

@MainActor
class PriceChartViewModel: ObservableObject {
    @Published var priceData: [PricePoint] = []
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var isSimulating = false
    
    private var cancellables = Set<AnyCancellable>()
    
    struct PricePoint: Identifiable {
        let id = UUID()
        let date: Date
        let price: Double
        let volume: Double
    }
    
    init() {
        loadEvents()
        generateMockPriceData()
    }
    
    private func loadEvents() {
        guard let url = Bundle.main.url(forResource: "events", withExtension: "json") else {
            print("Failed to find events.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let eventsData = try JSONDecoder().decode(EventsData.self, from: data)
            self.events = eventsData.pastEvents + eventsData.upcomingEvents
        } catch {
            print("Error decoding events: \(error)")
        }
    }
    
    private func generateMockPriceData() {
        var mockData: [PricePoint] = []
        let calendar = Calendar.current
        let now = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
        
        var currentDate = oneYearAgo
        var currentPrice = 1500.0
        
        while currentDate <= now {
            // Add some randomness to the price
            let priceChange = Double.random(in: -50...50)
            currentPrice = max(1000, min(4000, currentPrice + priceChange))
            
            mockData.append(PricePoint(
                date: currentDate,
                price: currentPrice,
                volume: Double.random(in: 1000...10000)
            ))
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        self.priceData = mockData
    }
    
    func toggleSimulation() {
        isSimulating.toggle()
        // In a real app, you would connect to a WebSocket or API for live data
    }
    
    func selectEvent(_ event: Event) {
        selectedEvent = event
    }
}
