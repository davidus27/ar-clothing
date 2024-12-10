//
//  CreateView.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//
import SwiftUI


struct AnimationData {
    var animationName: String = ""
    var animationDescription: String = ""
    var isPublic: Bool = true
    var physicalWidth: String = ""
    var physicalHeight: String = ""
}


struct CreateView: View {
    // animation data
//    @State private var animationName: String = ""
//    @State private var animationDescription: String = ""
//    @State private var isPublic: Bool = false
//    @State private var physicalWidth: String = ""
//    @State private var physicalHeight: String = ""
    
    @State private var animationData = AnimationData()
    
    @State private var showLoadingIndicator = false
    @State private var uploadSuccess = false
    @State private var errorMessage = ""
    @State private var validationMessage: String = ""
    @State private var isLoading: Bool = false
    
    // stores
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var appStateStore: AppStateStore
    
    // Data pickers
    @State private var selectedThumbnail: UIImage? = nil
    @State private var showThumbnailPicker = false
    
    @State private var showFilePicker = false
    @State private var selectedAnimation: UIImage? = nil // this should be Data? for generic data
    // TEMP solution

    var body: some View {
        VStack(spacing: 20) {
            // Fixed Header
            VStack {
                HStack(spacing: 5) {
                    Text("Create your own designs")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Image(systemName: "plus.square.on.square")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                // Custom bounce effect
                            }
                        }
                }
            }
            
            // Dynamic Content
            ScrollView {
                // Animation Name Section
                VStack(alignment: .leading) {
                    Text("Animation Name")
                        .font(.headline)
                        .padding(.bottom, 5)
                    TextField("Enter animation name", text: $animationData.animationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    Text("Give your animation a name for identification.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                // Animation Description Section
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                        .padding(.bottom, 5)
                    TextField("Enter description", text: $animationData.animationDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    Text("Provide a description of what the animation does or represents.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                // Public/Private Setting Section
                VStack {
                    Text("Public or Private?")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Toggle(isOn: $animationData.isPublic) {
                        Text(animationData.isPublic ? "Public" : "Private")
                            .font(.body)
                    }
                    .padding(.bottom, 10)
                    Text("Choose whether this animation will be publicly available or kept private.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                // File Upload Section (Image Picker)
                VStack {
                    Text("Upload Design")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Button(action: {
                        showFilePicker = true
                    }) {
                        Text("Select Image (jpg, png, gif, mov, mp4)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 10)
                    
//                    FilePicker(
//                        selectedFile: $selectedAnimation,
//                        isPresented: $showFilePicker
//                    )
                    
                    Text("Upload an image or video for your animation. Accepted formats: jpg, png, gif, mov, mp4.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                
                // Thumbnail Section
                VStack {
                    Text("Thumbnail")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Button(action: {
                        showThumbnailPicker.toggle()
                    }) {
                        Text(selectedThumbnail == nil ? "Select Thumbnail" : "Change Thumbnail")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 10)

                    if let thumbnail = selectedThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                    }

                    Text("Choose a thumbnail that represents your animation. This will appear on the Explore page.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }


                // Physical Size Section
                VStack(alignment: .leading) {
                    Text("Physical Size")
                        .font(.headline)
                        .padding(.bottom, 5)
                    HStack {
                        TextField("Width (cm)", text: $animationData.physicalWidth)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 150)
                        TextField("Height (cm)", text: $animationData.physicalHeight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 150)
                    }
                    .padding(.bottom, 10)
                    Text("Specify the real-world width and height of your animation in centimeters.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                
                // Loading Indicator
                if showLoadingIndicator {
                    ProgressView("Submitting...").padding()
                }

                // Success/Failure Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                } else if uploadSuccess {
                    Text("Design submitted successfully!")
                        .foregroundColor(.green)
                        .padding(.top)
                }
                
                if !validationMessage.isEmpty {
                    Text(validationMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                
                // Submit Button Section
                Button(action: {
                    validateAndSubmit()
                }) {
                    Text("Submit Design")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
            }
            .padding()
        }
        .sheet(isPresented: $showThumbnailPicker) {
            ImagePicker(
                selectedImage: $selectedThumbnail,
                sourceType: .photoLibrary,
                isPresented: $showThumbnailPicker
            )
        }
        .sheet(isPresented: $showFilePicker) {
            ImagePicker(selectedImage: $selectedAnimation, sourceType: .photoLibrary, isPresented: $showFilePicker)
        }
    }
    
    func checkImageQuality(image: UIImage) {
        // Check if selected media is valid and upload accordingly
        print("validation updated")
        
        validationMessage = ""
        if !isResolutionSufficient(image: image) {
            validationMessage = "Image resolution is too low. For better quality use at least 480x480 resolution."
        }
        
        if !isHistogramDistributionGood(image: image) {
            validationMessage += "\nRecognition works better on images with more unique colors and patterns."
        }
        
        validationMessage = "\n\nImage uploaded successfully."
    }
               
    private func validateAndSubmit() {
        // Validation Function
        print("validation started")
        guard !animationData.animationName.isEmpty, !animationData.animationDescription.isEmpty, !animationData.physicalWidth.isEmpty, !animationData.physicalHeight.isEmpty else {
            errorMessage = "Please fill out all required fields and upload a design."
            return
        }
        print("Validation passed")

        errorMessage = ""
        submitDesign()
    }
    
    // File type validation function
    private func isValidFileType(_ fileURL: URL) -> Bool {
        let allowedExtensions = ["mp3", "jpg", "png", "mov"]
        return allowedExtensions.contains(fileURL.pathExtension.lowercased())
    }
    
    private func flushAttributes() {
        animationData = AnimationData()
        uploadSuccess = false
        errorMessage = ""
        
        isLoading = false
        showFilePicker = false
    }


    private func successfulUpload() {
        uploadSuccess = true
        showLoadingIndicator = false
        flushAttributes()
        validationMessage = "Animation created successfully."

    }
    
    private func failedUpload() {
        uploadSuccess = false
        showLoadingIndicator = false
        validationMessage = "Something went wrong during creation of animation."
    }
    
    private func submitMockupDesign() {
        // Simulate submission with a delay for mockup
        showLoadingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock submission success
            successfulUpload()
        }
    }
    
    private func submitDesign() {
        print("going to submit")
        guard let selectedAnimation = selectedAnimation else {
            errorMessage = "Please upload an animation file."
            return
        }
        guard let selectedThumbnail = selectedThumbnail else {
            errorMessage = "Please select a thumbnail image."
            return
        }
        
        Task {
            do {
                showLoadingIndicator = true
                print("Sending design")
                // Assuming you have an APIClient for the network request
                try await APIClient.shared.sendAnimation(animation:animationData, thumbnail: selectedThumbnail, image: selectedAnimation, source: appStateStore)
                successfulUpload()
            }
            catch {
                failedUpload()
            }
        }
    }

    
}

#Preview {
    CreateView()
}
