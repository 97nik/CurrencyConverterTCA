import Foundation
import ComposableArchitecture

// Редьюсер для управления логикой конвертера валют
struct CurrencyConverter: Reducer {
    typealias Currencies = [TableViewData]
    private let baseURL = "https://v6.exchangerate-api.com/v6/"
    private let accessKey = "c1a4fe51ecfcebb4ddda0835"

    struct State: Equatable {
        var initialCurrencies: Currencies = []  // Изначальный список валют
        var currencies: Currencies = []  // Текущий список валют
        var priceQuantityEntered = "1"  // Введенное количество
        var selectedBaseCurrency: String = "EUR"  // Выбранная базовая валюта
    }
    
    // Действия, которые могут произойти в приложении
    enum Action: Equatable {
        case onAppear  // При появлении экрана
        case processAPIResponse(CurrencyData)  // При получении данных от API
        case updateCurrencies(Currencies)  // Обновление списка валют
        case quantityTextFieldEntered(String)  // Ввод текста в поле суммы
        case countryCodePickerSelected(String)  // Выбор валюты в списке
    }
    
    var body: some ReducerOf<Self> {
        Reduce{ state, action in
            let selectedBase = state.selectedBaseCurrency
            switch action {
            case .onAppear:
                return .run { send in
                    // Запрос данных о текущих курсах валют с API
                    let (data, _) = try await URLSession.shared.data(from: URL(string: baseURL + accessKey + "/latest/\(selectedBase)")!)
                    let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                    await send(.processAPIResponse(currencyData))
                }
            case let .processAPIResponse(data):
                // Обработка полученных данных и обновление списка валют
                let currencies = getTableViewDataArray(currencyListView: data)
                state.initialCurrencies = currencies
                
                guard let convertPrice = Double(state.priceQuantityEntered) else {
                    return .none
                }
                if convertPrice > 1.0 {
                    return .send(.updateCurrencies(reactToEnteredAmount(state: state, amount: Double(state.priceQuantityEntered) ?? 1.0)))
                } else {
                    return .send(.updateCurrencies(currencies))
                }
            case let .updateCurrencies(currencies):
                state.currencies = currencies  // Обновляем список валют в состоянии
                return .none
            case let .quantityTextFieldEntered(string):
                state.priceQuantityEntered = string  // Обновляем введенное значение
                return .send(.updateCurrencies(reactToEnteredAmount(state: state, amount: Double(string) ?? 1.0)))
            case let .countryCodePickerSelected(currencyCode):
                state.selectedBaseCurrency = currencyCode  // Обновляем выбранную базовую валюту
                return .run { send in
                    // Получение обновленных курсов для выбранной валюты
                    let (data, _) = try await URLSession.shared.data(from: URL(string: baseURL + accessKey + "/latest/\(currencyCode)")!)
                    let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                    await send(.processAPIResponse(currencyData))
                }
            }
        }
    }
}

// Приватные методы для обработки данных о валютах
private extension CurrencyConverter {
    func getTableViewDataArray(currencyListView: CurrencyData) -> Currencies {
        let currencyDet = self.fetchAllCurrencyDetails()
        var arrayOfTableViewData: Currencies = Currencies()
        
        // Проходим по всем полученным курсам валют
        for (key, value) in currencyListView.conversion_rates {
            guard let currencySymbol = currencyDet.filter({ $0.code.contains(key)}).last else {
                continue
            }
            let locale = Locale.current
            guard let currencyName = locale.localizedString(forCurrencyCode: key) else {
                continue
            }
            let tableViewData = TableViewData(base: "EUR", currencyCode: key,
                                              currencyName: currencyName,
                                              currencyValue: value.rounded(toPlaces: 2),
                                              currencySymbol: currencySymbol.symbol)
            arrayOfTableViewData.append(tableViewData)
        }
        // Сортируем валюты по алфавиту
        arrayOfTableViewData = arrayOfTableViewData.sorted(by: { $0.currencyCode.localizedCaseInsensitiveCompare($1.currencyCode) == .orderedAscending })
        return arrayOfTableViewData
    }

    // Получаем информацию о всех доступных валютах
    func fetchAllCurrencyDetails() -> [Currency] {
        var currencyDet: [Currency] = [Currency]()
        for localeID in Locale.availableIdentifiers {
            let locale = Locale(identifier: localeID)
            guard let currencyCode = locale.currency?.identifier,
                  let currencySymbol = locale.currencySymbol else {
                continue
            }
            if !currencySymbol.validateGenericString(currencySymbol) {
                if currencyDet.filter { $0.code.contains(currencyCode) }.isEmpty {
                    currencyDet.append(Currency(code: currencyCode, symbol: currencySymbol))
                }
            }
        }
        return currencyDet
    }

    // Реакция на изменение введенного значения
    func reactToEnteredAmount(state: CurrencyConverter.State, amount: Double) -> Currencies {
        if amount != 0 {
            return state.initialCurrencies.map { data in
                return TableViewData(base: state.selectedBaseCurrency,
                                     currencyCode: data.currencyCode,
                                     currencyName: data.currencyName,
                                     currencyValue: (data.currencyValue * amount).rounded(toPlaces: 2),
                                     currencySymbol: data.currencySymbol)
            }
        }
        return []
    }
}

// Валидация строк для проверки символов
extension String {
    func validateGenericString(_ string: String) -> Bool {
        return string.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil
    }
}

// Расширение для округления значений с плавающей точкой
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
