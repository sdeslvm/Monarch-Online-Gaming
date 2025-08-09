import Foundation
import SwiftUI

struct MonarchEntryScreen: View {
    @StateObject private var loader: MonarchWebLoader

    init(loader: MonarchWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            MonarchWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                MonarchProgressIndicator(value: percent)
            case .failure(let err):
                MonarchErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                MonarchOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct MonarchProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            MonarchLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct MonarchErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct MonarchOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
