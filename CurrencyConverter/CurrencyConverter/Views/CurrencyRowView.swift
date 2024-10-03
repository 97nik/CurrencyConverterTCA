import SwiftUI

// Представление строки валюты в списке
struct CurrencyRowView: View {
    @State var tableViewData: TableViewData  // Данные для отображения

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text(tableViewData.currencyName).font(.caption)
                Text(tableViewData.currencyCode).font(.subheadline).bold()
            }
            Spacer()
            Text(String(tableViewData.currencyValue)).font(.headline)  // Отображение значения валюты
        }
        .padding()
    }
}

struct CurrencyRowView_Previews: PreviewProvider {
    static var previews: some View {
        let tableViewData = TableViewData(base: "EUR",
                                          currencyCode: "EUR",
                                          currencyName: "Евро",
                                          currencyValue: 10.222,
                                          currencySymbol: "$")
        CurrencyRowView(tableViewData: tableViewData)
    }
}
