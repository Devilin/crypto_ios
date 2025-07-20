import SwiftUI
import Charts

struct PriceChartView: View {
    @StateObject private var viewModel = PriceChartViewModel()
    @State private var selectedTimeRange: TimeRange = .oneYear
    
    enum TimeRange: String, CaseIterable {
        case oneDay = "1D"
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case oneYear = "1Y"
        case all = "ALL"
    }
    
    var filteredPriceData: [PriceChartViewModel.PricePoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .oneDay:
            startDate = calendar.date(byAdding: .day, value: -1, to: now)!
        case .oneWeek:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        case .oneMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)!
        case .oneYear:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        case .all:
            return viewModel.priceData
        }
        
        return viewModel.priceData.filter { $0.date >= startDate }
    }
    
    var filteredEvents: [Event] {
        let priceData = filteredPriceData
        guard let minDate = priceData.first?.date,
              let maxDate = priceData.last?.date else {
            return []
        }
        
        return viewModel.events.filter { event in
            event.date >= minDate && event.date <= maxDate
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Ethereum")
                        .font(.title2)
                        .bold()
                    Text("$3,142.75") // Current price would come from API
                        .font(.title)
                        .bold()
                    
                    Text("+2.34% (24h)")
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleSimulation()
                }) {
                    Image(systemName: viewModel.isSimulating ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.isSimulating ? .red : .blue)
                }
            }
            .padding()
            
            // Chart
            Chart {
                // Price line
                ForEach(filteredPriceData) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Price", point.price)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.blue.gradient)
                    .lineWidth(2)
                }
                
                // Event annotations
                ForEach(filteredEvents) { event in
                    PointMark(
                        x: .value("Event Date", event.date),
                        y: .value("Price", priceAtDate(event.date) ?? 0)
                    )
                    .annotation(position: .top) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(eventColor(for: event))
                            .onTapGesture {
                                viewModel.selectEvent(event)
                            }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 300)
            .padding()
            
            // Time range selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(action: {
                            selectedTimeRange = range
                        }) {
                            Text(range.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTimeRange == range ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTimeRange == range ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            
            // Event details
            if let selectedEvent = viewModel.selectedEvent {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(selectedEvent.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(selectedEvent.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Impact:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(selectedEvent.impact.rawValue)
                            .font(.subheadline)
                            .foregroundColor(impactColor(for: selectedEvent.impact))
                    }
                    
                    Text(selectedEvent.newsExample)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                .transition(.opacity)
            }
            
            Spacer()
        }
        .animation(.easeInOut, value: selectedTimeRange)
        .animation(.easeInOut, value: viewModel.selectedEvent)
    }
    
    private func priceAtDate(_ date: Date) -> Double? {
        let calendar = Calendar.current
        return filteredPriceData
            .first { calendar.isDate($0.date, inSameDayAs: date) }?
            .price
    }
    
    private func eventColor(for event: Event) -> Color {
        switch event.impact {
        case .upward, .potentialUpward:
            return .green
        case .downward:
            return .red
        case .mixed:
            return .yellow
        }
    }
    
    private func impactColor(for impact: Event.Impact) -> Color {
        switch impact {
        case .upward, .potentialUpward:
            return .green
        case .downward:
            return .red
        case .mixed:
            return .orange
        }
    }
}

#Preview {
    PriceChartView()
}
