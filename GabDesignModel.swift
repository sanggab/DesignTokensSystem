import Foundation
import UIKit
import SwiftUI

struct GabShadow {
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let spread: CGFloat
    let color: UIColor
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

enum GabDesignModel {
    enum Asset {
        enum Amber {
            static var friendinvitationreward: String { ColorLoader.shared.getString(named: "asset.amber.friendInvitationReward") ?? "https://cdn.zeplin.io/6368af377aee4b1c08c3894e/assets/dcbe9f4f-f54d-4049-acce-10b4f3995edc-2x.png" }
        }
        enum Lostark {
            static var mococo1: String { ColorLoader.shared.getString(named: "asset.lostark.mococo1") ?? "https://i3.ruliweb.com/img/21/12/22/17ddfc9c18019a54f.png" }
            static var mococo2: String { ColorLoader.shared.getString(named: "asset.lostark.mococo2") ?? "https://i3.ruliweb.com/img/21/12/22/17ddfc9e10c19a54f.png" }
            static var mococo3: String { ColorLoader.shared.getString(named: "asset.lostark.mococo3") ?? "https://d3kxs6kpbh59hp.cloudfront.net/community/COMMUNITY/f10fa801f04a40229d8903d53694c88c/87c377a1e34f4e349137641089d6c4ee_1640345594.jpg" }
            static var special1: String { ColorLoader.shared.getString(named: "asset.lostark.special1") ?? "https://blog.kakaocdn.net/dna/ccQnmC/btrqbGYaDhI/AAAAAAAAAAAAAAAAAAAAAMk5Lzq5cZskqV6Nqmfg0wFWLdaOM0By6ReF0LiyRAWr/img.png?credential=yqXZFxpELC7KVnFOS48ylbz2pIh7yKj8&expires=1769871599&allow_ip=&allow_referer=&signature=yWzBGUYVF%2Bo94f9pjAMMDMd6OKU%3D" }
            static var special2: String { ColorLoader.shared.getString(named: "asset.lostark.special2") ?? "https://pbs.twimg.com/media/FG4GQ_vaAAQwHy5.jpg" }
            static var special3: String { ColorLoader.shared.getString(named: "asset.lostark.special3") ?? "https://upload3.inven.co.kr/upload/2023/09/24/bbs/i16195278416.jpg" }
            static var special4: String { ColorLoader.shared.getString(named: "asset.lostark.special4") ?? "https://upload3.inven.co.kr/upload/2025/09/19/bbs/i0105041521.gif" }
        }
    }
    enum Global {
        enum Ref {
            static let blackRaw = "#"
            enum Gray {
                static var n20: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.20") ?? "#FF202020"
                    return UIColor(hex: hex)
                }
                static var n20Color: Color { Color(uiColor: n20) }
                static var n50: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.50") ?? "#FF505050"
                    return UIColor(hex: hex)
                }
                static var n50Color: Color { Color(uiColor: n50) }
                static var n90: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.90") ?? "#FF909090"
                    return UIColor(hex: hex)
                }
                static var n90Color: Color { Color(uiColor: n90) }
                static var a4: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.a4") ?? "#FFA4A4A4"
                    return UIColor(hex: hex)
                }
                static var a4Color: Color { Color(uiColor: a4) }
                static var d4: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.d4") ?? "#FFD4D4D4"
                    return UIColor(hex: hex)
                }
                static var d4Color: Color { Color(uiColor: d4) }
                static var e1: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.e1") ?? "#FFE1E1E1"
                    return UIColor(hex: hex)
                }
                static var e1Color: Color { Color(uiColor: e1) }
                static var f1: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.f1") ?? "#FFF1F1F1"
                    return UIColor(hex: hex)
                }
                static var f1Color: Color { Color(uiColor: f1) }
                static var fa: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.fa") ?? "#FFFAFAFA"
                    return UIColor(hex: hex)
                }
                static var faColor: Color { Color(uiColor: fa) }
                static var two: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.two") ?? "#FFB8B8B8"
                    return UIColor(hex: hex)
                }
                static var twoColor: Color { Color(uiColor: two) }
                static var warm: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.gray.warm") ?? "#FF707070"
                    return UIColor(hex: hex)
                }
                static var warmColor: Color { Color(uiColor: warm) }
            }
            static var white: UIColor {
                let hex = ColorLoader.shared.getColorHex(named: "global.ref.white") ?? "#FFFFFFFF"
                return UIColor(hex: hex)
            }
            static var whiteColor: Color { Color(uiColor: white) }
            enum Yellow {
                static var n100: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.100") ?? "#FFFEFBEC"
                    return UIColor(hex: hex)
                }
                static var n100Color: Color { Color(uiColor: n100) }
                static var n150: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.150") ?? "#FFFFFAE4"
                    return UIColor(hex: hex)
                }
                static var n150Color: Color { Color(uiColor: n150) }
                static var n200: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.200") ?? "#FFFFF7D6"
                    return UIColor(hex: hex)
                }
                static var n200Color: Color { Color(uiColor: n200) }
                static var n250: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.250") ?? "#FFFFF3C5"
                    return UIColor(hex: hex)
                }
                static var n250Color: Color { Color(uiColor: n250) }
                static var n300: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.300") ?? "#FFFFEEA8"
                    return UIColor(hex: hex)
                }
                static var n300Color: Color { Color(uiColor: n300) }
                static var n350: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.350") ?? "#FFFFE788"
                    return UIColor(hex: hex)
                }
                static var n350Color: Color { Color(uiColor: n350) }
                static var n400: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.400") ?? "#FFFFE064"
                    return UIColor(hex: hex)
                }
                static var n400Color: Color { Color(uiColor: n400) }
                static var n450: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.450") ?? "#FFFFD52E"
                    return UIColor(hex: hex)
                }
                static var n450Color: Color { Color(uiColor: n450) }
                static var n500: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "global.ref.yellow.500") ?? "#FFFFCE0E"
                    return UIColor(hex: hex)
                }
                static var n500Color: Color { Color(uiColor: n500) }
            }
        }
    }
    enum Popup {
        enum Content {
            static var amber: String { ColorLoader.shared.getString(named: "popup.content.amber") ?? "https://cdn.zeplin.io/6368af377aee4b1c08c3894e/assets/dcbe9f4f-f54d-4049-acce-10b4f3995edc-2x.png" }
        }
        enum Sys {
            enum Background {
                static var primary: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.background.primary") ?? "#FFFFFFFF"
                    return UIColor(hex: hex)
                }
                static var primaryColor: Color { Color(uiColor: primary) }
            }
            enum Border {
                static var color: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.border.color") ?? "#5B000000"
                    return UIColor(hex: hex)
                }
                static var colorColor: Color { Color(uiColor: color) }
            }
            enum Button {
                static var background: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.button.background") ?? "#FFFFCE0E"
                    return UIColor(hex: hex)
                }
                static var backgroundColor: Color { Color(uiColor: background) }
                static var radius: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.button.radius") ?? 45.0 }
                static var title: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.button.title") ?? "#FF202020"
                    return UIColor(hex: hex)
                }
                static var titleColor: Color { Color(uiColor: title) }
            }
            enum Content {
                static var description: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.content.description") ?? "#FF707070"
                    return UIColor(hex: hex)
                }
                static var descriptionColor: Color { Color(uiColor: description) }
                enum Padding {
                    static var bottom: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.content.padding.bottom") ?? 16.0 }
                    static var horizontal: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.content.padding.horizontal") ?? 16.0 }
                    static var top: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.content.padding.top") ?? 20.0 }
                }
                static var subtitle: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.content.subtitle") ?? "#FF505050"
                    return UIColor(hex: hex)
                }
                static var subtitleColor: Color { Color(uiColor: subtitle) }
                static var title: UIColor {
                    let hex = ColorLoader.shared.getColorHex(named: "popup.sys.content.title") ?? "#FF202020"
                    return UIColor(hex: hex)
                }
                static var titleColor: Color { Color(uiColor: title) }
                enum Vstack {
                    static var spacing: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.content.vstack.spacing") ?? 12.0 }
                }
            }
            enum Primary {
                enum Padding {
                    static var horizontal: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.primary.padding.horizontal") ?? 12.0 }
                }
            }
            enum Radius {
                static var primary: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.radius.primary") ?? 12.0 }
            }
            enum Shadow {
                enum Primary {
                    static var x: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.shadow.primary.x") ?? 0.0 }
                    static var y: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.shadow.primary.y") ?? 2.0 }
                    static var blur: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.shadow.primary.blur") ?? 6.0 }
                    static var spread: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.shadow.primary.spread") ?? 0.0 }
                    static var color: UIColor {
                        let hex = ColorLoader.shared.getColorHex(named: "popup.sys.shadow.primary.color") ?? "#5B000000"
                        return UIColor(hex: hex)
                    }
                    static var colorColor: Color { Color(uiColor: color) }
                    static var value: GabShadow { GabShadow(x: CGFloat(x), y: CGFloat(y), blur: CGFloat(blur), spread: CGFloat(spread), color: color) }
                }
            }
            enum Vstack {
                static var spacing: CGFloat { ColorLoader.shared.getCGFloat(named: "popup.sys.vstack.spacing") ?? 20.0 }
            }
        }
    }
}
