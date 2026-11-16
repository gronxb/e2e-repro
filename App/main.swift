import UIKit
import WebKit

// One full-screen window: a native "Tap me" button with a tap counter above a
// WKWebView that starts loading at launch. Right after the web view loads,
// agent-device's snapshot can come back without the window's screen origin.
final class ViewController: UIViewController {
  private var taps = 0
  private let counter = UILabel()
  private let web = WKWebView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let button = UIButton(type: .system)
    button.setTitle("Tap me", for: .normal)
    button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    button.accessibilityIdentifier = "tap-me"
    button.addTarget(self, action: #selector(tapped), for: .touchUpInside)

    counter.text = "Taps: 0"
    counter.accessibilityIdentifier = "tap-count"

    let reload = UIButton(type: .system)
    reload.setTitle("Reload web view", for: .normal)
    reload.accessibilityIdentifier = "reload-web"
    reload.addTarget(self, action: #selector(loadPage), for: .touchUpInside)

    let column = UIStackView(arrangedSubviews: [button, counter, reload, web])
    column.axis = .vertical
    column.spacing = 12
    view.addSubview(column)
    column.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      column.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      column.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      column.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      column.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])
    loadPage()
  }

  @objc private func loadPage() {
    let items = (0..<3000).map { "<li><a href=\"#\(  $0)\">Web row \($0)</a></li>" }.joined()
    web.loadHTMLString(
      "<!doctype html><meta name=viewport content='width=device-width'><h1>Web content</h1><button>Web button</button><ul>\(items)</ul>",
      baseURL: nil
    )
  }

  @objc private func tapped() {
    taps += 1
    counter.text = "Taps: \(taps)"
  }
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = ViewController()
    window.makeKeyAndVisible()
    self.window = window
    // `defaults write dev.e2e.repro.taporigin placed -bool YES` asks iPadOS windowed apps for a
    // window smaller than the screen: a placed window whose root is not at the screen origin.
    if UserDefaults.standard.bool(forKey: "placed") {
      window.windowScene?.sizeRestrictions?.maximumSize = CGSize(width: 551, height: 813)
    }
    return true
  }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
