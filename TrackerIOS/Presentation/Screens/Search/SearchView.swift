import SwiftUI

struct SearchView: View {
    var onAddRecentSearch: ((String, String) -> Void)?

    @StateObject private var viewModel = SearchViewModel()
    @State private var navigateToResults = false
    @State private var selectedLineId: String? = nil
    @State private var navigateToTracker = false

    var body: some View {
        VStack(spacing: 0) {
            searchForm

            if viewModel.state.isLoading {
                ProgressView()
                    .padding(.top, 40)
                Spacer()
            } else if let error = viewModel.state.error {
                EmptyStateView(
                    icon: "exclamationmark.circle",
                    title: "No results",
                    subtitle: error
                )
                .padding(.top, 40)
                Spacer()
            } else {
                Spacer()
            }
        }
        .navigationTitle("Plan Journey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToResults) {
            if let journeys = viewModel.state.journeyResults {
                JourneyResultsView(
                    journeys: journeys,
                    fromQuery: viewModel.state.fromQuery,
                    toQuery: viewModel.state.toQuery,
                    onSelectLeg: { lineId in
                        selectedLineId = lineId
                        navigateToTracker = true
                    }
                )
            }
        }
        .navigationDestination(isPresented: $navigateToTracker) {
            if let lineId = selectedLineId {
                TrackerView(lineId: lineId)
            }
        }
        .sheet(item: Binding(
            get: { viewModel.state.disambiguation },
            set: { if $0 == nil { viewModel.dismissDisambiguation() } }
        )) { disambig in
            DisambiguationSheet(
                disambiguation: disambig,
                onSelect: { viewModel.selectDisambiguationOption($0) },
                onDismiss: { viewModel.dismissDisambiguation() }
            )
            .presentationDetents([.medium, .large])
        }
        .onChange(of: viewModel.state.journeyResults) { results in
            if results != nil { navigateToResults = true }
        }
        .onChange(of: navigateToResults) { active in
            if !active { viewModel.clearResults() }
        }
    }

    private var searchForm: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                locationField(
                    placeholder: "From",
                    text: Binding(
                        get: { viewModel.state.fromQuery },
                        set: { viewModel.updateFromQuery($0) }
                    ),
                    icon: "circle.fill",
                    iconColor: AppTheme.Colors.busStart,
                    suggestions: viewModel.state.fromSuggestions,
                    onSelect: viewModel.selectFromSuggestion
                )
                locationField(
                    placeholder: "To",
                    text: Binding(
                        get: { viewModel.state.toQuery },
                        set: { viewModel.updateToQuery($0) }
                    ),
                    icon: "mappin.circle.fill",
                    iconColor: AppTheme.Colors.busEnd,
                    suggestions: viewModel.state.toSuggestions,
                    onSelect: viewModel.selectToSuggestion
                )
            }
            .padding(16)

            Button(action: { viewModel.planJourney() }) {
                HStack {
                    Spacer()
                    if viewModel.state.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Plan Journey")
                            .font(AppTheme.Fonts.semiBold(16))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(AppTheme.Colors.primary)
                .cornerRadius(12)
            }
            .disabled(viewModel.state.isLoading ||
                      viewModel.state.fromQuery.isEmpty ||
                      viewModel.state.toQuery.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }

    private func locationField(
        placeholder: String,
        text: Binding<String>,
        icon: String,
        iconColor: Color,
        suggestions: [StopPoint],
        onSelect: @escaping (StopPoint) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                TextField(placeholder, text: text)
                    .font(AppTheme.Fonts.regular(15))
                    .autocorrectionDisabled()
                if !text.wrappedValue.isEmpty {
                    Button { text.wrappedValue = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(AppTheme.Colors.surfaceVariant)
            .cornerRadius(10)

            if !suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestions) { stop in
                        Button { onSelect(stop) } label: {
                            HStack {
                                Image(systemName: "bus")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text(stop.name)
                                    .font(AppTheme.Fonts.regular(14))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        if stop.id != suggestions.last?.id {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            }
        }
    }
}

private extension Binding where Value == DisambiguationState? {
    // Allows DisambiguationState to be used with .sheet(item:)
}

extension DisambiguationState: Identifiable {
    var id: String { "\(field)-\(query)" }
}

private struct DisambiguationSheet: View {
    let disambiguation: DisambiguationState
    let onSelect: (StopPoint) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List(disambiguation.options) { option in
                Button(action: { onSelect(option) }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.name)
                            .font(AppTheme.Fonts.medium(15))
                            .foregroundColor(.primary)
                        Text(option.id)
                            .font(AppTheme.Fonts.regular(12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }

    private var titleText: String {
        switch disambiguation.field {
        case .from: return "Choose starting point"
        case .to: return "Choose destination"
        }
    }
}
