# GoAnime

GoAnime 是一用來顯示日本動畫與漫畫資訊的應用程式，主要基於 `https://docs.api.jikan.moe` 提供之API進行資訊擷取。

## System Requirements
本專案是基於 XCode 13.4.1 和 Swift 5.6.1 開發，deplyment target 為 iOS 15.5。

--

## 程式架構

GoAnime 將基於 MVVM 架構做為開發基礎，並加入 Coordinator 以及 Interactor，以分離邏輯並加強可測性。
資料取得部分，將透過 `Session` 來取得Anime/Manga資訊。

<img width="1105" alt="截圖 2022-07-16 下午5 13 48" src="https://user-images.githubusercontent.com/8021888/179348683-6943677a-4ca3-4736-8dee-e85ad804b477.png">
