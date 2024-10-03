import Foundation

// Структура для работы с данными о валютах из API
struct CurrencyData: Decodable, Hashable {
    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let time_last_update_utc: String
    let time_next_update_unix: Int
    let time_next_update_utc: String
    let base_code: String
    let conversion_rates: [String: Double]
}

// Структура для отображения данных в таблице
struct TableViewData: Equatable, Identifiable, Hashable, Decodable {
    var id = UUID()
    var base: String
    var currencyCode: String
    var currencyName: String
    var currencyValue: Double
    var currencySymbol: String
}

// Структура, представляющая валюту
struct Currency {
    var code: String
    var symbol: String
}
