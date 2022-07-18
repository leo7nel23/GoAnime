# GoAnime

GoAnime 是一用來顯示日本動畫與漫畫資訊的應用程式，主要基於 `https://docs.api.jikan.moe` 提供之API進行資訊擷取。

## System Requirements
本專案是基於 XCode 13.4.1 和 Swift 5.6.1 開發，deplyment target 為 iOS 15.5。

--

## 程式架構

GoAnime 將基於 MVVM 架構做為開發基礎，並加入 Coordinator 以及 Interactor，以分離邏輯並加強可測性。
資料取得部分，將透過 `Session` 來取得Anime/Manga資訊。

### Coordinator

Coordinator 包含
- AppCoordinator
用於驅動App初始頁面 - UINavigationController

- AnimeCoordinator
主要頁面 AnimeViewController

- FilterCordinator
Filter 頁面

![截圖 2022-07-18 下午9 14 07](https://user-images.githubusercontent.com/8021888/179519116-5f1ce127-e6a2-4046-95bd-af89254b1088.png)

## AnimeViewController

這個Controller 是App的主要畫面，包含 UISegmentControl 以及 UICollectionView 兩大元件組合而成。針對 不同的 類別、 Filter 來對 Interactor 進行資料存取。詳細架構參考如下圖：

![截圖 2022-07-18 下午9 11 50](https://user-images.githubusercontent.com/8021888/179518969-cce108cf-df85-4992-a103-ffdf2300ac3d.png)

## 主要技術
- Combine
- `DiffableDataSource` `CellRegistration`
- Swift Package Manager 達成模組拆分
