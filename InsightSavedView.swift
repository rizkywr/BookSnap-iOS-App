//
//  InsightSavedView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import UIKit
import PhotosUI
import AVFoundation
import SwiftData

struct InsightSavedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var books: [BookRecord]
    let draft: InsightDraft

    @State private var animateSuccess = false
    @State private var showAssignSheet = false
    @State private var showLibrary = false

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.top, 16)
                    .padding(.leading, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                VStack(spacing: 12) {
                    FolderSuccessIllustration(isAnimated: animateSuccess)
                        .scaleEffect(animateSuccess ? 1 : 0.88)
                        .opacity(animateSuccess ? 1 : 0)
                        .offset(y: animateSuccess ? 0 : 18)

                    HStack(spacing: 0) {
                        Text("Insight")
                            .font(.system(size: 31, weight: .heavy))
                            .foregroundStyle(.black)

                        Text(" Saved")
                            .font(.system(size: 31, weight: .light))
                            .foregroundStyle(Color.black.opacity(0.68))

                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color(red: 0.28, green: 0.60, blue: 0.98))
                            .padding(.leading, 4)
                            .symbolEffect(.bounce, value: animateSuccess)
                    }
                    .opacity(animateSuccess ? 1 : 0)
                    .offset(y: animateSuccess ? 0 : 10)
                }

                Spacer()

                VStack(spacing: 16) {
                    Button(action: { showAssignSheet = true }) {
                        Text("Assign to Existing Book")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 236, height: 50)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color(red: 0.03, green: 0.53, blue: 0.97))
                            )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color(red: 0.11, green: 0.45, blue: 0.90).opacity(0.24), radius: 18, x: 0, y: 10)
                    .disabled(books.isEmpty)
                    .opacity(books.isEmpty ? 0.45 : 1)

                    NavigationLink {
                        CreateBookCoverView(draft: draft)
                    } label: {
                        Text("New Book")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black.opacity(0.88))
                            .frame(width: 236, height: 42)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.72))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 70)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.62, dampingFraction: 0.78)) {
                animateSuccess = true
            }
        }
        .sheet(isPresented: $showAssignSheet) {
            AssignBookSheetView(books: books, onSelect: assignToBook)
                .presentationDetents([.height(480)])
        }
        .navigationDestination(isPresented: $showLibrary) {
            InsightLibraryView()
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))

                Text("Back")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.black.opacity(0.6))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(Color.white.opacity(0.72))
            .clipShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func assignToBook(_ book: BookRecord) {
        book.insights.append(draft)
        showAssignSheet = false
        showLibrary = true
    }
}

struct CreateBookCoverView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let draft: InsightDraft

    @State private var bookTitle = ""
    @State private var author = ""
    @State private var selectedGenre: BookGenre = .coreKnowledge
    @State private var showCamera = false
    @State private var showPhotoOptions = false
    @State private var image: UIImage?
    @State private var showPhotoLibraryPicker = false
    @State private var showLibrary = false

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.top, 16)
                    .padding(.leading, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Button(action: { showPhotoOptions = true }) {
                    Group {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.black.opacity(0.04))

                                Image(systemName: "camera")
                                    .font(.system(size: 82, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.12))
                            }
                        }
                    }
                    .frame(width: 164, height: 246)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)

                VStack(spacing: 16) {
                    bookTextField("Title", text: $bookTitle)
                    bookTextField("Author", text: $author)

                    Menu {
                        ForEach(BookGenre.allCases, id: \.self) { genre in
                            Button(genre.displayTitle) {
                                selectedGenre = genre
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGenre.displayTitle)
                                .foregroundStyle(Color.black.opacity(0.75))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.28))
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 18)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.black.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 36)
                .padding(.horizontal, 40)

                Spacer()

                Button(action: saveBookAndNavigate) {
                    Text("Save Book")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 194, height: 50)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color(red: 0.03, green: 0.53, blue: 0.97))
                        )
                }
                .buttonStyle(.plain)
                .disabled(
                    bookTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    image == nil
                )
                .opacity(
                    bookTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    image == nil ? 0.45 : 1
                )
                .shadow(color: Color(red: 0.11, green: 0.45, blue: 0.90).opacity(0.24), radius: 18, x: 0, y: 10)
                .padding(.bottom, 64)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Choose Cover Source", isPresented: $showPhotoOptions) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    showCamera = true
                }
            }
            Button("Choose from Library") {
                showPhotoLibraryPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            NativeCameraPicker(image: $image)
        }
        .sheet(isPresented: $showPhotoLibraryPicker) {
            NativePhotoLibraryPicker(image: $image)
        }
        .navigationDestination(isPresented: $showLibrary) {
            InsightLibraryView()
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))

                Text("Back")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.black.opacity(0.6))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(Color.white.opacity(0.72))
            .clipShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func bookTextField(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.plain)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.78))
            .padding(.horizontal, 18)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.05))
            )
    }

    private func saveBookAndNavigate() {
        let imageData = image?.jpegData(compressionQuality: 0.8)

        let newBook = BookRecord(
            title: bookTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            genre: selectedGenre,
            coverImageData: imageData,
            insights: [draft]
        )

        modelContext.insert(newBook)
        showLibrary = true
    }
}

struct NativeCameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = PortraitOnlyImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: NativeCameraPicker

        init(_ parent: NativeCameraPicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let picked = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            self.parent.image = picked?.normalizedPortraitImage()
            self.parent.dismiss()
        }
    }
}

private class PortraitOnlyImagePickerController: UIImagePickerController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

private extension UIImage {
    func normalizedPortraitImage() -> UIImage {
        let fixedImage = self.fixOrientation()
        
        if fixedImage.size.height >= fixedImage.size.width {
            return fixedImage
        } else {
            guard let cgImage = fixedImage.cgImage else { return fixedImage }
            let rotated = UIImage(cgImage: cgImage, scale: fixedImage.scale, orientation: .right)
            return rotated.fixOrientation()
        }
    }

    private func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

struct NativePhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: NativePhotoLibraryPicker

        init(_ parent: NativePhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let itemProvider = results.first?.itemProvider else {
                self.parent.dismiss()
                return
            }

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { img, _ in
                    DispatchQueue.main.async {
                        let uiImage = img as? UIImage
                        self.parent.image = uiImage?.normalizedPortraitImage()
                        self.parent.dismiss()
                    }
                }
            } else {
                self.parent.dismiss()
            }
        }
    }
}
