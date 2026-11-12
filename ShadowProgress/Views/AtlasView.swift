import SwiftUI
import SafariServices

/// An original offline route diagram is paired with live, attributed maps from their publisher.
/// The diagram deliberately does not invent collectible positions or geographical coordinates.
struct AtlasRegion: Identifiable {
    let chapter: JourneyChapter
    let x: Double
    let y: Double
    let mapFile: String
    var id: String { chapter.id }
    var mapURL: URL {
        URL(string: "https://tombraiders.net/stella/walks/TR11walk/screenshots/" + mapFile)!
    }
    static let all: [AtlasRegion] = [
        .init(chapter: .cozumel, x: 0.26, y: 0.10, mapFile: "cozumel-map.png"),
        .init(chapter: .jungle, x: 0.66, y: 0.24, mapFile: "jungle-map.png"),
        .init(chapter: .kuwaqYaku, x: 0.31, y: 0.36, mapFile: "kuwaq-yaku-map.png"),
        .init(chapter: .eagle, x: 0.72, y: 0.46, mapFile: "eagle-trial-map.png"),
        .init(chapter: .paititi, x: 0.43, y: 0.58, mapFile: "hidden-city-full-map.png"),
        .init(chapter: .cenote, x: 0.22, y: 0.73, mapFile: "cenote-map.png"),
        .init(chapter: .oilFields, x: 0.72, y: 0.79, mapFile: "porvenir-map.png"),
        .init(chapter: .sanJuan, x: 0.42, y: 0.92, mapFile: "san-juan-map.png")
    ]
}

private struct MapDestination: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct AtlasView: View {
    @AppStorage("currentChapter") private var current = JourneyChapter.cozumel
    @State private var selected = AtlasRegion.all[0]
    @State private var zoom = 1.0
    @State private var map: MapDestination?
    @State private var showRegions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(title: "Follow the expedition", subtitle: "Choose a region to plan achievements or open its detailed map.")
                Button {
                    map = MapDestination(url: selected.mapURL)
                } label: {
                    Label("\(selected.chapter.title) map", systemImage: "map.fill")
                        .font(.subheadline.weight(.semibold)).padding(.vertical, 4)
                }.buttonStyle(.borderedProminent)
                GeometryReader { geometry in
                    ZStack(alignment: .topTrailing) {
                        ScrollView([.horizontal, .vertical]) {
                            RouteDiagram(selected: $selected)
                                .frame(width: max(geometry.size.width, 300) * zoom, height: 500 * zoom)
                        }.scrollIndicators(.hidden)
                        HStack(spacing: 0) {
                            Button("Zoom out", systemImage: "minus.magnifyingglass") { zoom = max(1, zoom - 0.35) }
                                .disabled(zoom <= 1).frame(width: 44, height: 44)
                            Button("Zoom in", systemImage: "plus.magnifyingglass") { zoom = min(2.4, zoom + 0.35) }
                                .disabled(zoom >= 2.4).frame(width: 44, height: 44)
                        }.labelStyle(.iconOnly).expeditionGlass().padding(12)
                    }
                    .background(Theme.panel).clipShape(RoundedRectangle(cornerRadius: 26))
                }.frame(height: 500)
                Label("Offline route diagram · not to scale", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.caption).foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: selected.chapter.symbol).font(.title2).foregroundStyle(Theme.gold)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(selected.chapter.title).font(.title2.bold())
                            Text(selected.chapter.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Text(selected.chapter.briefing).font(.subheadline).foregroundStyle(.secondary)
                    Button {
                        map = MapDestination(url: selected.mapURL)
                    } label: {
                        Label("Open detailed game map", systemImage: "map.fill").frame(maxWidth: .infinity).padding(.vertical, 6)
                    }.buttonStyle(.borderedProminent)
                    NavigationLink { ChapterDetail(chapter: selected.chapter) } label: {
                        Label("Achievements in this region", systemImage: "trophy")
                    }.font(.subheadline.weight(.semibold))
                    Text("Annotated map by Stella’s Tomb Raider Site. Opens inside the app with internet access; pinch the map to inspect it. Maps contain spoilers.")
                        .font(.caption).foregroundStyle(.secondary)
                }.expeditionCard()

                DisclosureGroup("All region maps", isExpanded: $showRegions) {
                    VStack(spacing: 0) {
                        ForEach(AtlasRegion.all) { region in
                            Button { selected = region; map = MapDestination(url: region.mapURL) } label: {
                                HStack {
                                    Label(region.chapter.title, systemImage: region.chapter.symbol)
                                    Spacer(); Image(systemName: "arrow.up.right")
                                }.font(.subheadline).padding(.vertical, 13)
                            }
                            if region.id != AtlasRegion.all.last?.id { Divider() }
                        }
                    }.padding(.top, 10)
                }.expeditionCard()
                Text("Paititi’s detailed map covers the lower city, upper city, and revisit, including the serpent trials. The offline diagram is an original planning aid, not the game’s navigable map.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Map credits and collectible index", systemImage: "safari") { map = MapDestination(url: GuideSource.maps.url) }
                    .font(.subheadline)
            }.padding(.horizontal, 20).padding(.bottom, 32)
        }.background(Theme.background).navigationTitle("Atlas")
            .sheet(item: $map) { destination in
                PublishedMapBrowser(url: destination.url).ignoresSafeArea()
            }
            .onAppear {
                // Match repeated Paititi visits to the same physical region on the diagram.
                let chapter: JourneyChapter = [.upperPaititi, .returnPaititi, .belly, .head, .mountain, .finale].contains(current) ? .paititi : current
                if let region = AtlasRegion.all.first(where: { $0.chapter == chapter }) { selected = region }
            }
    }
}

private struct RouteDiagram: View {
    @Binding var selected: AtlasRegion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    // Contours are decorative and intentionally carry no terrain measurements.
                    for line in 0..<23 {
                        var contour = Path()
                        for step in 0...50 {
                            let x = size.width * Double(step) / 50
                            let y = Double(line) * size.height / 22 + sin(Double(step) * 0.18 + Double(line) * 0.6) * 18
                            if step == 0 { contour.move(to: CGPoint(x: x, y: y)) }
                            else { contour.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(contour, with: .color(Theme.jungle.opacity(colorScheme == .dark ? 0.1 : 0.08)), lineWidth: 0.7)
                    }
                    var route = Path()
                    for (index, region) in AtlasRegion.all.enumerated() {
                        let point = CGPoint(x: size.width * region.x, y: size.height * region.y)
                        if index == 0 { route.move(to: point) } else { route.addLine(to: point) }
                    }
                    context.stroke(route, with: .color(Theme.gold.opacity(0.5)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 7]))
                }.accessibilityHidden(true)
                ForEach(AtlasRegion.all) { region in
                    Button { selected = region } label: {
                        VStack(spacing: 4) {
                            Image(systemName: region.chapter.symbol)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(selected.id == region.id ? Theme.background : Theme.jungle)
                                .frame(width: 36, height: 36)
                                .background(selected.id == region.id ? Theme.jungle : Theme.panel, in: Circle())
                                .overlay(Circle().stroke(Theme.jungle.opacity(0.3), lineWidth: 1))
                            Text(region.chapter.title).font(.caption2.weight(.semibold)).multilineTextAlignment(.center)
                                .foregroundStyle(.primary).padding(.horizontal, 6).padding(.vertical, 3)
                                .background(Theme.panel.opacity(0.95), in: Capsule())
                        }.frame(width: 132, height: 70)
                    }.buttonStyle(.plain)
                        .accessibilityLabel("Select \(region.chapter.title)")
                        .accessibilityAddTraits(selected.id == region.id ? .isSelected : [])
                        .position(x: geometry.size.width * region.x, y: geometry.size.height * region.y)
                }
            }
        }
    }
}

/// Safari's native viewer retains publisher attribution, zooming, and browser security controls.
struct PublishedMapBrowser: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.dismissButtonStyle = .close
        return controller
    }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
