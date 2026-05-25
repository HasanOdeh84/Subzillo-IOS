//
//  InboxScanningView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 20/05/26.
//
import SwiftUI

struct InboxScanningView: View {
    
    //MARK: - Properties
    @State var logId: String
    @StateObject var viewModel                      = EmailSyncProgressViewModel()
    @State private var isPulsing                    = false
    @State private var isNavigatingToManualEntry    = false
    @State private var progress                     : CGFloat = 0
    @State private var step                         : Int = 0
    @State private var total                        : Double = 0
    @State private var caught                       : [ScanningEmailsData] = []
    @State private var activeCardBounce             = false
    @EnvironmentObject var themeManager             : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                headerView
                
                titleView
                
                scannerView
                
                statsView
                
                progressView
                    .padding(.bottom, 120)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationBarBackButtonHidden()
            .onAppear {
                viewModel.startPolling(logId: logId)
                startAnimation()
            }
            .onDisappear {
                viewModel.stopPolling()
            }
            .sheet(isPresented: $viewModel.showErrorPopup, onDismiss: {
                if !isNavigatingToManualEntry {
                    AppIntentRouter.shared.pop()
                }
                isNavigatingToManualEntry = false
            }) {
                UploadErrorImageSheet(
                    isImage         : false,
                    fromEmailSync   : true,
                    onDelegate      : {
                        isNavigatingToManualEntry = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false, fromEmailSync: true))
                        }
                    },
                    onDismiss       : {
                    }
                )
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(500)])
            }
        }
        .applyAppBackground()
    }
    
    //MARK: - Button actions
    private func goBack() {
        viewModel.goBack()
        AppIntentRouter.shared.pop()
    }
}

// MARK: - Header
extension InboxScanningView {
    var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    goBack()
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.success0EA8705CE4A8)
                        .frame(width: 6, height: 6)
                        .shadow(color: Color.success0EA8705CE4A8.opacity(0.80), radius: 5)
                    
                    Text("\(viewModel.syncStatusData?.latestService?.uppercased() ?? "GMAIL") · READ-ONLY")
                        .font(.jetBrainsMedium(10))
                        .foregroundStyle(Color.success0EA8705CE4A8)
                        .tracking(1.5)
                }
                
                Spacer()
                
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

// MARK: - Title
extension InboxScanningView {
    var titleView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("Scanning your ")
                    .foregroundStyle(themeManager.black_white)
                
                Text("inbox")
                    .font(.jetBrainsSemiBoldItalic(26))
                    .italic()
                    .foregroundStyle(
                        themeManager.accentGradient
                    )
            }
            .font(.geistSemiBold(26))
            
            Text(activeEmailText)
                .font(.jetBrainsMedium(14))
                .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                .lineLimit(1)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }
    
    var activeEmailText: String {
        let stack = emailStack
        guard stack.count > 2 else { return "Scanning..." }
        let active = stack[2]
        let fromText = active.from ?? active.title ?? ""
        let subjText = active.subject ?? ""
        return "Reading: \(fromText) — \(subjText)"
    }
}

// MARK: - Scanner View
extension InboxScanningView {
    var scannerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            themeManager.white_black.opacity(0.45),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 8) {
                
                ForEach(Array(emailStack.enumerated()), id: \.offset) { index, email in
                    
                    emailRow(
                        email: email,
                        index: index
                    )
                }
            }
            .padding(.horizontal, 24)
            
            scanBeam
            
            scannerCorners
            
            //floatingTags
        }
        .frame(height: 250)
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    var scanBeam: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            themeManager.selectedAccent.senColor.opacity(0.15),
                            themeManager.selectedAccent.senColor.opacity(0.35),
                            themeManager.selectedAccent.senColor.opacity(0.15),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 60)
            
            Rectangle()
                .fill(themeManager.selectedAccent.senColor)
                .frame(height: 1)
                .shadow(color: themeManager.selectedAccent.senColor, radius: 14)
        }
    }
    
    var scannerCorners: some View {
        VStack {
            HStack {
                cornerView(top: true, left: true)
                Spacer()
                cornerView(top: true, left: false)
            }
            
            Spacer()
            
            HStack {
                cornerView(top: false, left: true)
                Spacer()
                cornerView(top: false, left: false)
            }
        }
        .padding(16)
    }
    
    func cornerView(top: Bool, left: Bool) -> some View {
        Path { path in
            let size: CGFloat = 14
            
            if top {
                
                path.move(to: CGPoint(x: left ? size : 0, y: 0))
                path.addLine(to: CGPoint(x: left ? 0 : size, y: 0))
                path.addLine(to: CGPoint(x: left ? 0 : size, y: size))
                
            } else {
                
                path.move(to: CGPoint(x: left ? 0 : size, y: 0))
                path.addLine(to: CGPoint(x: left ? 0 : size, y: size))
                path.addLine(to: CGPoint(x: left ? size : 0, y: size))
            }
        }
        .stroke(themeManager.selectedAccent.senColor, lineWidth: 2)
        .frame(width: 14, height: 14)
    }
}

// MARK: - Email Stack
extension InboxScanningView {
    var emailStack: [ScanningEmailsData] {
        let emails = viewModel.syncStatusData?.scanningEmails ?? []
        guard !emails.isEmpty else { return [] }
        return Array(0..<5).map {
            emails[(step + $0) % emails.count]
        }
    }
    
    func emailRow(email: ScanningEmailsData, index: Int) -> some View {
        
        let isActive = index == 2
        //        let isMatched = (email.isSubcription == true) && isActive
        let isMatched = false
        let distance = abs(index - 2)
        
        return HStack(spacing: 10) {
            
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    isMatched
                    ? AnyShapeStyle(
                        themeManager.accentGradient
                    )
                    : AnyShapeStyle(themeManager.white_white4)
                )
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(
                            isMatched
                            ? themeManager.white_white4
                            : themeManager.black_white.opacity(0.6)
                        )
                }
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(email.from ?? email.title ?? "")
                    .font(.geistSemiBold(11))
                    .foregroundStyle(themeManager.black_white)
                
                Text(email.subject ?? "")
                    .font(.geistRegular(10))
                    .foregroundStyle(themeManager.black_white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isMatched {
                
                Text("MATCH")
                    .font(.jetBrainsMedium(9))
                    .foregroundStyle(Color.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    themeManager.white_white4
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isMatched
                    ? themeManager.selectedAccent.senColor
                    : themeManager.black_white.opacity(0.08),
                    lineWidth: 1
                )
        }
        //        .scaleEffect(1 - CGFloat(distance) * 0.04)
        .scaleEffect(
            isActive
            ? (activeCardBounce ? 0.92 : 1.02)
            : (1 - CGFloat(distance) * 0.04)
        )
        .opacity(1 - CGFloat(distance) * 0.3)
        .shadow(
            color: isMatched
            ? themeManager.selectedAccent.senColor.opacity(0.4)
            : .clear,
            radius: 16
        )
        //            .animation(.easeInOut(duration: 0.35), value: step)
        .animation(
            isActive
            ? .interpolatingSpring(
                mass: 0.5,
                stiffness: 180,
                damping: 8,
                initialVelocity: 4
            )
            : .easeInOut(duration: 0.35),
            value: activeCardBounce
        )
        .animation(.easeInOut(duration: 0.35), value: step)
        //        .scaleEffect(isActive ? (isPulsing ? 1.05 : 0.95) : 1.0)
        //        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isPulsing)
    }
}

// MARK: - Floating Tags
extension InboxScanningView {
    var floatingTags: some View {
        ZStack(alignment: .topTrailing) {
            ForEach(Array(caught.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 4) {
                    
                    Image(systemName: "checkmark")
                        .font(.geistBold(8))
                    
                    Text(item.from ?? item.title ?? "")
                        .font(.geistSemiBold(10))
                }
                .foregroundStyle(themeManager.white_white4)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    themeManager.accentGradient
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(
                    color: themeManager.selectedAccent.senColor.opacity(0.4),
                    radius: 10
                )
                .offset(
                    x: CGFloat(-index * 4),
                    y: CGFloat(index * -30)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 18)
        .padding(.trailing, 18)
    }
}

// MARK: - Stats
extension InboxScanningView {
    var statsView: some View {
        HStack(spacing: 10) {
            statCard(
                title: "FOUND",
                value: "\(viewModel.subscriptionsFoundCount)",
                gradient: true
            )
            
            statCard(
                title: "SCANNED",
                value: "\(viewModel.emailsScannedCount)"
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }
    
    func statCard(
        title: String,
        value: String,
        gradient: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.jetBrainsMedium(10))
                .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                .tracking(1)
            
            if gradient {
                Text(value)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        themeManager.accentGradient
                    )
            } else {
                Text(value)
                    .font(.geistSemiBold(28))
                    .foregroundStyle(.textPrimary0E101AF4F1FB)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(themeManager.white_white4)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.textPrimaryLight8_white8)
        }
    }
}

// MARK: - Progress
extension InboxScanningView {
    var progressView: some View {
        VStack(spacing: 10) {
            
            GeometryReader { geo in
                
                ZStack(alignment: .leading) {
                    
                    Capsule()
                        .fill(themeManager.black_white.opacity(0.12))
                    
                    Capsule()
                        .fill(
                            themeManager.accentGradient
                        )
                        .frame(width: geo.size.width * progress)
                        .shadow(
                            color: themeManager.selectedAccent.senColor.opacity(0.4),
                            radius: 8
                        )
                }
            }
            .frame(height: 4)
            
            HStack {
                
                Text("END-TO-END ENCRYPTED")
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
            }
            .font(.jetBrainsMedium(10))
            .foregroundStyle(themeManager.black_white.opacity(0.4))
            .tracking(1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

// MARK: - Animation
extension InboxScanningView {
    func startAnimation() {
        //        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
        //            isPulsing.toggle()
        //        }
        //
        Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            
            withAnimation(.linear(duration: 0.07)) {
                
                progress += CGFloat(0.014 + Double.random(in: 0...0.018))
                
                if progress >= 1 {
                    progress = 0
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.42, repeats: true) { timer in
            let emails = viewModel.syncStatusData?.scanningEmails ?? []
            guard !emails.isEmpty else { return }
            
            let email = emails[step % emails.count]
            
            //            if email.isSubcription == true {
            //                if !caught.contains(where: { $0.id == email.id }) {
            //                    withAnimation(.spring(duration: 0.5)) {
            //                        caught.append(email)
            //                        if caught.count > 4 {
            //                            caught.removeFirst()
            //                        }
            //                    }
            //                }
            //            }
            
            //            step += 1
            
            withAnimation {
                activeCardBounce = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation {
                    activeCardBounce = false
                }
                
                step += 1
            }
        }
    }
}
