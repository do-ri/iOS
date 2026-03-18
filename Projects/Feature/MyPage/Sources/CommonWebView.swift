//
//  CommonWebView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import DoriDesignSystem
import SwiftUI
import WebKit

// MARK: - WKWebViewRepresentable

struct WKWebViewRepresentable: UIViewRepresentable {
  let url: URL
  @Binding var isLoading: Bool
  @Binding var progress: Double
  @Binding var canGoBack: Bool
  @Binding var canGoForward: Bool
  
  var onNavigationAction: ((WKNavigationAction) -> WKNavigationActionPolicy)?
  var onDidFinish: (() -> Void)?
  var onDidFail: ((Error) -> Void)?
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = true
    
    // Progress 관찰
    webView.addObserver(
      context.coordinator,
      forKeyPath: #keyPath(WKWebView.estimatedProgress),
      options: .new,
      context: nil
    )
    
    // 초기 URL 로드
    let request = URLRequest(url: url)
    webView.load(request)
    
    // Coordinator에 웹뷰 참조 저장
    context.coordinator.webView = webView
    
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    // 현재 로딩 중인 URL과 새 URL 비교
    let currentURL = webView.url?.absoluteString ?? ""
    let newURL = url.absoluteString
    
    // URL이 실제로 다를 때만 로드
    // (쿼리 파라미터 제외하고 비교하려면 추가 로직 필요)
    if currentURL != newURL && !context.coordinator.isLoadingURL(newURL) {
      let request = URLRequest(url: url)
      webView.load(request)
      context.coordinator.markURLAsLoading(newURL)
    }
  }
  
  static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
    webView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress))
  }
  
  // MARK: - Coordinator
  
  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WKWebViewRepresentable
    weak var webView: WKWebView?
    private var loadingURLs: Set<String> = []
    
    init(_ parent: WKWebViewRepresentable) {
      self.parent = parent
    }
    
    func isLoadingURL(_ urlString: String) -> Bool {
      return loadingURLs.contains(urlString)
    }
    
    func markURLAsLoading(_ urlString: String) {
      loadingURLs.insert(urlString)
    }
    
    // KVO - Progress 관찰
    override func observeValue(
      forKeyPath keyPath: String?,
      of object: Any?,
      change: [NSKeyValueChangeKey : Any]?,
      context: UnsafeMutableRawPointer?
    ) {
//      if keyPath == #keyPath(WKWebView.estimatedProgress),
//         let webView = object as? WKWebView {
//        DispatchQueue.main.async {
//          self.parent.progress = webView.estimatedProgress
//        }
//      }
    }
    
    func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      if let handler = parent.onNavigationAction {
        let policy = handler(navigationAction)
        decisionHandler(policy)
      } else {
        decisionHandler(.allow)
      }
      
      DispatchQueue.main.async {
        self.parent.isLoading = true
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      DispatchQueue.main.async {
        self.parent.isLoading = false
        self.parent.canGoBack = webView.canGoBack
        self.parent.canGoForward = webView.canGoForward
        self.parent.onDidFinish?()
        
        // 로딩 완료 후 URL 목록에서 제거
        if let url = webView.url?.absoluteString {
          self.loadingURLs.remove(url)
        }
      }
    }
    
    func webView(
      _ webView: WKWebView,
      didFail navigation: WKNavigation!,
      withError error: Error
    ) {
      handleError(error, webView: webView)
    }
    
    func webView(
      _ webView: WKWebView,
      didFailProvisionalNavigation navigation: WKNavigation!,
      withError error: Error
    ) {
      handleError(error, webView: webView)
    }
    
    private func handleError(_ error: Error, webView: WKWebView) {
      let nsError = error as NSError
      
      // -999는 취소 에러이므로 무시
      guard nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled else {
        DispatchQueue.main.async {
          self.parent.isLoading = false
          self.parent.onDidFail?(error)
        }
        return
      }
      
      // 취소 에러는 조용히 처리
      DispatchQueue.main.async {
        self.parent.isLoading = false
        
        // 로딩 목록에서 제거
        if let url = webView.url?.absoluteString {
          self.loadingURLs.remove(url)
        }
      }
    }
  }
}

// MARK: - CommonWebView

struct CommonWebView: View {
  let navigationTitle: String
  let url: URL

  @State private var isLoading = false
  @State private var progress: Double = 0
  @State private var canGoBack = false
  @State private var canGoForward = false
  @State private var webViewStore = WebViewStore()
  @Environment(\.dismiss) private var dismiss

  init(
    navigationTitle: String,
    url: URL
  ) {
    self.navigationTitle = navigationTitle
    self.url = url
  }
  var body: some View {
    VStack(spacing: 0) {
      // 진행률 표시
      if isLoading && progress < 1.0 {
        ProgressView(value: progress, total: 1.0)
          .progressViewStyle(.linear)
          .tint(.blue)
      }
      
      // 웹뷰
      WKWebViewRepresentable(
        url: url,
        isLoading: $isLoading,
        progress: $progress,
        canGoBack: $canGoBack,
        canGoForward: $canGoForward,
        onNavigationAction: { action in
          return .allow
        },
        onDidFinish: {
          print("✅ 로딩 완료: \(url.absoluteString)")
        },
        onDidFail: { error in
          // 실제 에러만 출력 (-999 제외)
          print("❌ 로딩 실패: \(error.localizedDescription)")
        }
      )
      .onAppear {
        // 웹뷰 참조 저장 (필요시)
      }
      
      // 네비게이션 툴바
      toolbarView
    }
    .doriNavigationBar(.backWithTitle(navigationTitle, onBack: { dismiss() }))
  }
  
  private var toolbarView: some View {
    HStack(spacing: 20) {
      Button {
        webViewStore.webView?.goBack()
      } label: {
        Image(systemName: "chevron.left")
          .foregroundColor(canGoBack ? .blue : .gray)
      }
      .disabled(!canGoBack)
      
      Button {
        webViewStore.webView?.goForward()
      } label: {
        Image(systemName: "chevron.right")
          .foregroundColor(canGoForward ? .blue : .gray)
      }
      .disabled(!canGoForward)
      
      Spacer()
      
      Button {
        webViewStore.webView?.reload()
      } label: {
        Image(systemName: "arrow.clockwise")
      }
      
      Button {
        if isLoading {
          webViewStore.webView?.stopLoading()
        }
      } label: {
        Image(systemName: "xmark")
      }
      .disabled(!isLoading)
    }
    .padding()
    .background(Color(.systemBackground))
    .shadow(color: .black.opacity(0.1), radius: 1, y: -1)
  }
}

// MARK: - WebViewStore

@Observable
class WebViewStore {
  weak var webView: WKWebView?
}

// MARK: - Constants

extension NSError {
  static let NSURLErrorCancelled = -999
}

// MARK: - Preview

#Preview {
  NavigationStack {
    CommonWebView(
      navigationTitle: "개인정보처리방침",
      url: URL(string: "https://www.apple.com")!
    )
  }
}
