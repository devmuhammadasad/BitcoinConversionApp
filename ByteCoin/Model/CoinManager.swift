
import Foundation

protocol CoinManagerDelegate {
    func didUpdateValues(_ coinManager: CoinManager, values: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "6357540D-8BAB-434C-B764-407E2C32D6A9"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let values = self.parseJSON(safeData) {
                        self.delegate?.didUpdateValues(self, values: values)
                    }
                }
            }
            task.resume()
            }
        }
        func parseJSON(_ data: Data) -> CoinModel? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CoinData.self, from: data)
                let rate = decodedData.rate
                let values = CoinModel(rate: rate)
                return values
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    }
