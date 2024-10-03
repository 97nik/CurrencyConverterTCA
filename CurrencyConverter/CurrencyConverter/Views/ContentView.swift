import SwiftUI
import ComposableArchitecture

// Основная структура представления контента
struct ContentView: View {
    let store: StoreOf<CurrencyConverter> // Хранилище для состояния приложения
    @State var isHidden = false // Состояние для управления видимостью контента
    
    var body: some View {
        // WithViewStore связывает View со Store для наблюдения за состоянием
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                // Проверка на скрытие основного контента (пока данные загружаются)
                if isHidden {
                    HStack {
                        // Текстовое поле для ввода количества
                        TextField(
                            "Введите количество",
                            text: viewStore.binding(
                                get: \.priceQuantityEntered,
                                send: { .quantityTextFieldEntered($0) }
                            )
                        )
                        .keyboardType(.numberPad) // Установка типа клавиатуры
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        Spacer()
                        
                        // Выбор валюты с помощью Picker
                        Picker("Валюта",
                               selection: viewStore.binding(
                                get: \.selectedBaseCurrency,
                                send: { .countryCodePickerSelected($0) })
                        ) {
                            Text(viewStore.selectedBaseCurrency).tag(viewStore.selectedBaseCurrency)
                            ForEach(viewStore.currencies) {
                                Text($0.currencyCode).tag($0.currencyCode)
                            }
                        }
                        .pickerStyle(.menu) // Стиль меню для Picker
                    }
                    Spacer()
                    
                    // Отображение списка доступных валют
                    List(viewStore.currencies) { tableViewData in
                        CurrencyRowView(tableViewData: tableViewData)
                    }
                    .listStyle(.automatic)
                } else {
                    // Отображение индикатора загрузки до момента завершения загрузки данных
                    ProgressView("Загрузка")
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
                // Имитируем задержку для загрузки данных и отображаем контент
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    isHidden = true
                })
            }
        }
    }
}

// Превью контента для SwiftUI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialState: .init(), reducer: { CurrencyConverter() }))
    }
}
