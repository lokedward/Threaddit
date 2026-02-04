// AddItemView.swift
// Add new clothing item flow with image picker and metadata entry

import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.displayOrder) private var categories: [Category]
    
    // Image selection
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingImageSourcePicker = true
    @State private var showingCamera = false
    
    // Metadata
    @State private var name = ""
    @State private var selectedCategory: Category?
    @State private var brand = ""
    @State private var size = ""
    @State private var tagsText = ""
    
    @State private var isSaving = false
    
    var canSave: Bool {
        selectedImage != nil && !name.isEmpty && selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Image Section
                Section {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        Button("Change Photo") {
                            showingImageSourcePicker = true
                        }
                    } else {
                        Button {
                            showingImageSourcePicker = true
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("Add Photo")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                
                // Required Info
                Section("Item Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select a category").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                }
                
                // Optional Info
                Section("Additional Info (Optional)") {
                    TextField("Brand", text: $brand)
                    TextField("Size", text: $size)
                    TextField("Tags (comma separated)", text: $tagsText)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave || isSaving)
                }
            }
            .confirmationDialog("Choose Photo Source", isPresented: $showingImageSourcePicker) {
                Button("Take Photo") {
                    showingCamera = true
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Choose from Library")
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $selectedImage)
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = uiImage
                        }
                    }
                }
            }
            .onAppear {
                // Default to first category if available
                if selectedCategory == nil, let first = categories.first {
                    selectedCategory = first
                }
            }
        }
    }
    
    private func saveItem() {
        guard let image = selectedImage,
              let category = selectedCategory else { return }
        
        isSaving = true
        
        // Process image (crop to square)
        let croppedImage = cropToSquare(image)
        
        // Save image to disk
        guard let imageID = ImageStorageService.shared.saveImage(croppedImage) else {
            isSaving = false
            return
        }
        
        // Parse tags
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Create item
        let item = ClothingItem(
            name: name,
            category: category,
            brand: brand.isEmpty ? nil : brand,
            size: size.isEmpty ? nil : size,
            imageID: imageID,
            tags: tags
        )
        
        modelContext.insert(item)
        
        dismiss()
    }
    
    private func cropToSquare(_ image: UIImage) -> UIImage {
        let size = min(image.size.width, image.size.height)
        let x = (image.size.width - size) / 2
        let y = (image.size.height - size) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size, height: size)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

// Camera View using UIImagePickerController
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
