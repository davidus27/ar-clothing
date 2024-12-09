//
//  CreateView.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//
import SwiftUI

enum MediaType {
    case image, video, unknown
}

struct SelectedMedia {
    var data: Any
    var type: MediaType
}

struct CreateView: View {
    @State private var animationName: String = ""
    @State private var animationDescription: String = ""
    @State private var isPublic: Bool = false
//    @State private var selectedImage: UIImage? = nil
    @State private var selectedAnchor: UIImage? = nil // if custom clothing is selected
    @State private var physicalWidth: String = ""
    @State private var physicalHeight: String = ""
    @State private var selectedMode: String = "Custom Clothing"
    @State private var showImagePicker = false
    @State private var showLoadingIndicator = false
    @State private var uploadSuccess = false
    @State private var errorMessage = ""
    @State private var showCreateAnchor = false
    @State private var selectedGarment: LinkedGarmentData?
    
    @EnvironmentObject var userDataStore: UserDataStore
    
    @State private var selectedAnimation: SelectedMedia?
    @State private var validationMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showFilePicker: Bool = false
    
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
                    TextField("Enter animation name", text: $animationName)
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
                    TextField("Enter description", text: $animationDescription)
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
                    Toggle(isOn: $isPublic) {
                        Text(isPublic ? "Public" : "Private")
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
                        showImagePicker.toggle()
                    }) {
                        Text("Select Image (jpg, png, gif, mov, mp4)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 10)

                    Text("Upload an image or video for your animation. Accepted formats: jpg, png, gif, mov, mp4.")
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
                        TextField("Width (cm)", text: $physicalWidth)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(width: 150)
                        TextField("Height (cm)", text: $physicalHeight)
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
        .sheet(isPresented: $showImagePicker) {
        }
    }
    
    func onUploadAnchor() {
        // Check if selected media is valid and upload accordingly
        print("validation updated")
        
        if let image = selectedAnchor {
            validationMessage = ""
            if !isResolutionSufficient(image: image) {
                validationMessage = "Image resolution is too low. For better quality use at least 480x480 resolution."
            }
            
            if !isHistogramDistributionGood(image: image) {
                validationMessage += "\nRecognition works better on images with more unique colors and patterns."
            }
            
            validationMessage = "\n\nImage uploaded successfully."
        }
    }
               
    private func validateAndSubmit() {
        // Validation Function
        guard !animationName.isEmpty, !animationDescription.isEmpty, !physicalWidth.isEmpty, !physicalHeight.isEmpty else {
            errorMessage = "Please fill out all required fields and upload a design."
            return
        }

        errorMessage = ""
        submitDesign()
    }

    private func submitDesign() {
        // Simulate submission with a delay for mockup
        showLoadingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock submission success
            uploadSuccess = true
            showLoadingIndicator = false
            flushAttributes()
        }
    }
    
    private func flushAttributes() {
        
        animationName = ""
        animationDescription = ""
        isPublic = false
        selectedAnimation = nil
        selectedAnchor = nil
        
        physicalWidth = ""
        physicalHeight = ""
        selectedMode = "Custom Clothing"
        showImagePicker = false
        uploadSuccess = false
        errorMessage = ""
        showCreateAnchor = false
        
        isLoading = false
        showFilePicker = false
        validationMessage = "Animation created successfully."
    }
}

#Preview {
    CreateView()
}
