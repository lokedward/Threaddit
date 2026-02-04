// ItemThumbnailView.swift
// Reusable thumbnail component for clothing items

import SwiftUI

enum ThumbnailSize {
    case small
    case large
    
    var dimension: CGFloat {
        switch self {
        case .small: return 120
        case .large: return 0 // flexible
        }
    }
}

struct ItemThumbnailView: View {
    let item: ClothingItem
    var size: ThumbnailSize = .small
    
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            
            // Overlay with name
            VStack(alignment: .leading, spacing: 2) {
                if let brand = item.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text(item.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: size == .small ? size.dimension : nil)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        image = ImageStorageService.shared.loadImage(withID: item.imageID)
    }
}

#Preview {
    let item = ClothingItem(name: "Vintage Denim Jacket", brand: "Levi's")
    return ItemThumbnailView(item: item)
        .padding()
}
