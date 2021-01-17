//
//  ContentView.swift
//  Design Tokens
//
//  Created by Jules Simplicio on 12/8/20.
//  Copyright © 2020 Jules Simplicio. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import CoreData

struct designToken: Identifiable {
  let id: Int
  let icon: Image
  let name: Text
  let description: Text
}

struct ContentView: View {
    @State var showingDetail = false
    @State var designTokens =
        [
            designToken(id: 0, icon: Image("Color"),name: Text("Color"), description: Text("View color tokens")),
            designToken(id: 1, icon: Image("Space"),name: Text("Space"), description: Text("View space tokens")),
            designToken(id: 2, icon: Image("Size"),name: Text("Size"), description: Text("View size tokens")),
            designToken(id: 3, icon: Image("Typography"),name: Text("Typography"), description: Text("View typography tokens")),
            designToken(id: 4, icon: Image("Border"),name: Text("Border"), description: Text("View border tokens")),
            designToken(id: 5, icon: Image("Shadow"),name: Text("Shadow"), description: Text("View shadow tokens")),
            designToken(id: 6, icon: Image("Color"),name: Text("Duration"), description: Text("View duration tokens")),
        ]

    var color: Color = Color(UIColor.systemBlue);
    var gray: Color = Color(UIColor.lightGray).opacity(0.5);

    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                VStack (alignment: .leading) {
                    HStack (alignment: .top) {
                        NavigationView {
                            ScrollView {
                                ForEach(designTokens) { designToken in
                                    NavigationLink(destination: ColorView(designToken: designToken)) {
                                        HStack {
                                            designToken.icon
                                                .resizable()
                                                .frame(width: 32, height:32)
                                                .padding()
                                            VStack(alignment: .leading) {
                                                designToken.name.font(.system(size: 18, weight: .heavy, design: .default))
                                                designToken.description.font(.subheadline)
                                            }
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8.0)
                                                .strokeBorder(gray,lineWidth: 1)
                                        )
                                    
                                    }
                                    .navigationBarTitle("Design Tokens")
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
        }
    }
}



extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct colorGroup: Identifiable {
    let id = UUID()
    let name: Text
}

struct ColorView: View {
    var designToken: designToken
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showSheet = false
    @State var name: String = ""
    @State var hex: String = ""
    @State private var refresh = false

    @State var colorList = []
    
    @FetchRequest(entity: ColorGroup.entity(), sortDescriptors: []) var color_group: FetchedResults<ColorGroup>
    
    func addColor() {
        colorList.append(colorGroup(name: Text("\(name)")))
//        self.name = ""
        self.hideKeyboard()
        showSheet = false
        let color = ColorGroup(context: self.managedObjectContext)
        color.id = UUID()
        color.name = String("\(name)")
        
//          color.color = UIColor(hex: String("\(hex)"))
        
        try? self.managedObjectContext.save()
        self.refresh.toggle()
    }
    
    func removeRows(at offsets: IndexSet) {
        colorList.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        colorList.move(fromOffsets: source, toOffset: destination)
    }
    
    func removeColorGroups(at offsets: IndexSet) {
        for index in offsets {
            let colorGroup = color_group[index]
            managedObjectContext.delete(colorGroup)
        }
        try? managedObjectContext.save()
    }

    var body: some View {
        List {
              ForEach(color_group, id: \.self) { colorGroup in
                NavigationLink(destination: colorDetailView(token: colorGroup)) {
                    Text(colorGroup.name ?? "Unknown")
                }
              }.onDelete(perform: removeColorGroups)
            }

        .navigationBarTitle(designToken.name)
        .navigationBarItems(trailing:
        HStack {
            Button(action: {
                showSheet.toggle()
            }){
                Image(systemName: "plus")
                   .frame(width: 25, height: 25, alignment: .center)
                   .foregroundColor(.black)
            }.sheet(isPresented: $showSheet, content:
            {
                Form {
                    Text("Enter a Color Group")
                    TextField("(e.g. Greens, Primary, Text)" + (refresh ? "" : " "), text: $name)
                        .padding(16)
                    Button(action: addColor) {
                        Text("Add Color Group")
                    }
                    .padding(16)
                }
            })
        })
      //  .onDelete(perform: removeRows)
    }
}

struct colorVal: Codable {
    public var value: String
}

struct Value: Codable {
    let values: [String: colorVal]
}

var jsonString = ""

var data = jsonString.data(using: .utf8) ?? Data()


struct Colors: Codable, Identifiable {
    let id = UUID()
    let value: String
    let name: String
}

struct colorToken: Identifiable {
  let id = UUID()
  let name: Text
  let color: UIColor
}

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")

        // Helpers
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count

        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt32(&rgb)

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

struct colorDetailView: View {
    var token: ColorGroup
    @State var showSheet = false
    @State private var color = [colorVal]()
    @State var colors: [Colors] = (try? JSONDecoder().decode([Colors].self, from: data)) ?? []
    @State var value: String = ""
    @State var name: String = ""
    @State var hex: String = ""
    @State private var refresh = false
    
    func populateArray() {
        showSheet = false
        jsonString = value
        data = jsonString.data(using: .utf8) ?? Data()
        colors = (try? JSONDecoder().decode([Colors].self, from: data)) ?? []
        
        for _ in 0..<0 {
            colors.append(Colors(value: value, name: name))
        }
    }

    @State var colorList = [
 
    ]
    
    func addColor() {
        colorList.append(colorToken(name: Text("\(name)"), color: UIColor(hex: String("\(hex)"))!))

        showSheet = false

        self.name = ""
        self.hex = ""
        self.hideKeyboard()

        self.refresh.toggle()
    }
    
    func removeRows(at offsets: IndexSet) {
        colorList.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        colorList.move(fromOffsets: source, toOffset: destination)
    }
    var body: some View {
        List (colors) { color in
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: String(color.value)))
                .frame(width: 24, height: 24)
            Text(color.name)
        }
        .navigationBarTitle(self.token.name ?? "Unknown")
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    showSheet.toggle()
                }){
                    Image(systemName: "plus")
                       .frame(width: 25, height: 25, alignment: .center)
                       .foregroundColor(.black)
                }.sheet(isPresented: $showSheet, content: {
                    Form {
                        Text("Enter a Color")
                        TextField("(e.g. blue.100)" + (refresh ? "" : " "), text: $name)
                            .padding(16)
                        Text("Enter a Hex Code")
                        TextField("(e.g. FF0000)" + (refresh ? "" : " "), text: $hex)
                            .padding(16)

                        Button(action: addColor) {
                            Text("Add Color Group")
                        }
                        .padding(16)
                    }
                    Divider()
                    Form {
                        
                        Text("Enter JSON: [{\"value\": \"hex\"}]")
                        TextEditor(text: $value)
                        Button(action: populateArray) {
                            Text("Add Colors")
                        }
                        .padding(16)
                    }
                })
            }
        )
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


