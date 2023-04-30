//
//  MeView.swift
//  HotProspects
//
//  Created by Maximilian Berndt on 2023/04/30.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    
    @State private var name = "Anonymous"
    @State private var email = "you@yoursite.com"
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateQRCode)
            .onChange(of: name) { _ in updateQRCode() }
            .onChange(of: email) { _ in updateQRCode() }
        }
    }
    
    func updateQRCode() {
        qrCode = generateQRCode(from: "\(name)\n\(email)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        guard let outpuImage = filter.outputImage,
              let cgImage = context.createCGImage(outpuImage, from: outpuImage.extent) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
