import Foundation

// MARK: - Base View Protocol
// SOLID: Interface Segregation Principle - Generic view protocol that can be extended
protocol BaseViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
}
