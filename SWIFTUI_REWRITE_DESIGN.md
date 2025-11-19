# FaceMoji - SwiftUI 重写技术方案

> **项目目标**: 使用 Swift 和 SwiftUI 最新技术栈重写 Animoji 项目
>
> **文档版本**: 1.0
> **创建日期**: 2025-11-19
> **最低支持**: iOS 17+

---

## 📋 目录

- [项目概述](#项目概述)
- [当前项目分析](#当前项目分析)
- [技术栈升级方案](#技术栈升级方案)
- [项目结构设计](#项目结构设计)
- [核心代码设计](#核心代码设计)
- [功能规划](#功能规划)
- [UI/UX 设计原则](#uiux-设计原则)
- [技术实现细节](#技术实现细节)
- [开发路线图](#开发路线图)

---

## 项目概述

### 项目信息

- **新项目名称**: FaceMoji
- **原项目名称**: Animoji
- **目标**: 使用 iOS 17+ SwiftUI 技术栈重写现有 UIKit 项目
- **架构模式**: MVVM + Clean Architecture Lite
- **包管理**: Swift Package + Example App

### 核心功能

1. ✅ 选择 24+ 种 Animoji 角色（猴子、猫、狗、外星人等）
2. ✅ 实时面部追踪驱动 Animoji 动画
3. ✅ 录制 Animoji 视频（带音频）
4. ✅ 预览、删除、分享录制的视频
5. 🆕 录制时长实时显示
6. 🆕 背景颜色自定义
7. 🆕 录制历史管理（最多 5 个视频）
8. 🆕 导出为 GIF 格式

---

## 当前项目分析

### 现有技术栈

| 技术 | 用途 |
|------|------|
| UIKit | UI 框架 |
| Storyboard | 界面布局 |
| SceneKit | 3D 渲染引擎 |
| AvatarKit (私有框架) | 面部追踪和 Animoji 渲染 |
| Delegate 模式 | 状态回调 |
| UICollectionView | Puppet 选择网格 |

### 核心文件分析

```
Sources/
├── Animoji.swift          # 主类，继承 AVTRecordView，提供公开 API
├── AvatarKit.swift        # 私有框架加载，PuppetItem 定义
├── Extensions.swift       # Objective-C Runtime 方法调用工具

Example/
├── AppDelegate.swift      # UIKit App 入口
├── ViewController.swift   # 主视图控制器（约 160 行）
└── Base.lproj/
    └── Main.storyboard    # Interface Builder 布局
```

### 需要保留的代码

以下代码**无法用 SwiftUI 替代**，必须复用：

- ✅ `Extensions.swift` - Runtime 方法调用（访问私有 API）
- ✅ `AvatarKit.swift` - 私有框架加载逻辑
- ✅ `PuppetItem` enum - Puppet 名称定义
- ✅ SceneKit 渲染逻辑 - 需要通过 `UIViewRepresentable` 桥接

---

## 技术栈升级方案

### 对比表

| 原技术 | SwiftUI 方案 | 优势 |
|--------|-------------|------|
| UIKit | **SwiftUI** | 声明式 UI、代码量减少 60% |
| Delegate | **@Observable** (iOS 17) | 原生响应式状态管理 |
| UICollectionView | **LazyVGrid** | 原生组件、自动性能优化 |
| UIActivityViewController | **ShareLink** | 一行代码实现分享 |
| Callback 闭包 | **async/await** | 更清晰的异步代码 |
| Storyboard | **纯代码** | 更好的版本控制、团队协作 |
| Manual layout | **SwiftUI Layout** | 自动适配、动态类型支持 |
| SceneKit (保留) | **UIViewRepresentable** | 桥接到 SwiftUI |
| AvatarKit (保留) | 无法替代 | 私有 API 必须保留 |

### iOS 17+ 新特性利用

```swift
// ✅ @Observable 宏 - 简化状态管理
@Observable
class AnimojiViewModel {
    var currentPuppet: PuppetModel?
    var recordingState: RecordingState = .idle
}

// ✅ SF Symbols 动画
Image(systemName: "record.circle")
    .symbolEffect(.bounce, value: isRecording)

// ✅ #Preview 宏 - 实时预览
#Preview {
    ContentView()
}

// ✅ SwiftData（可选，用于录制历史）
@Model
class Recording {
    var date: Date
    var fileURL: URL
}
```

---

## 项目结构设计

### 目录结构

```
/home/user/Animoji/
├── FaceMoji/                           # 新项目根目录
│   ├── Package.swift                   # Swift Package 配置
│   │
│   ├── Sources/
│   │   └── FaceMoji/                   # 核心 Package
│   │       │
│   │       ├── Core/                   # 核心层（不依赖 UI）
│   │       │   ├── AvatarKit/
│   │       │   │   ├── AvatarKitLoader.swift      # 私有框架加载
│   │       │   │   ├── PuppetManager.swift        # Puppet 管理器
│   │       │   │   └── Extensions.swift           # Runtime 工具（复用）
│   │       │   │
│   │       │   ├── Recording/
│   │       │   │   ├── AnimojiRecorder.swift      # 录制引擎
│   │       │   │   ├── VideoExporter.swift        # 视频导出
│   │       │   │   └── GIFExporter.swift          # GIF 导出
│   │       │   │
│   │       │   └── Storage/
│   │       │       └── RecordingStorage.swift     # 本地存储管理
│   │       │
│   │       ├── Features/               # 功能模块（MVVM）
│   │       │   ├── Main/
│   │       │   │   ├── ContentView.swift
│   │       │   │   └── ContentViewModel.swift
│   │       │   │
│   │       │   ├── PuppetSelection/
│   │       │   │   ├── PuppetGridView.swift
│   │       │   │   └── PuppetGridViewModel.swift
│   │       │   │
│   │       │   ├── Recording/
│   │       │   │   ├── RecordingControlsView.swift
│   │       │   │   └── RecordingViewModel.swift
│   │       │   │
│   │       │   └── RecordingHistory/
│   │       │       ├── RecordingHistoryView.swift
│   │       │       └── RecordingHistoryViewModel.swift
│   │       │
│   │       ├── Shared/                 # 共享组件
│   │       │   ├── Components/         # 可复用 UI 组件
│   │       │   │   ├── AnimojiSceneView.swift
│   │       │   │   ├── RecordingButton.swift
│   │       │   │   └── BackgroundColorPicker.swift
│   │       │   │
│   │       │   ├── Extensions/         # Swift 扩展
│   │       │   │   ├── View+Extensions.swift
│   │       │   │   └── Color+Extensions.swift
│   │       │   │
│   │       │   └── Utilities/
│   │       │       ├── HapticManager.swift
│   │       │       └── PermissionManager.swift
│   │       │
│   │       └── Models/                 # 数据模型
│   │           ├── PuppetModel.swift
│   │           ├── RecordingModel.swift
│   │           └── RecordingState.swift
│   │
│   ├── Examples/
│   │   └── FaceMojiExample/            # Example App
│   │       ├── FaceMojiExampleApp.swift
│   │       ├── ContentView.swift
│   │       ├── Assets.xcassets/
│   │       └── Info.plist
│   │
│   ├── Tests/
│   │   └── FaceMojiTests/              # 单元测试
│   │       ├── ViewModelTests/
│   │       └── CoreTests/
│   │
│   └── README.md                       # 项目文档
│
└── [原项目文件保持不变]
```

### Package.swift 配置

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FaceMoji",
    platforms: [
        .iOS(.v17)  // iOS 17+
    ],
    products: [
        .library(
            name: "FaceMoji",
            targets: ["FaceMoji"]
        )
    ],
    dependencies: [
        // 未来可添加依赖，如 GIF 库
    ],
    targets: [
        .target(
            name: "FaceMoji",
            dependencies: []
        ),
        .testTarget(
            name: "FaceMojiTests",
            dependencies: ["FaceMoji"]
        )
    ]
)
```

### 架构设计原则

```
┌─────────────────────────────────────────────┐
│              SwiftUI Views                  │  ← 用户界面
│  (ContentView, PuppetGridView, etc.)       │
└───────────────┬─────────────────────────────┘
                │ 数据绑定 (@Observable)
┌───────────────▼─────────────────────────────┐
│            ViewModels                       │  ← 业务逻辑
│  (ContentViewModel, RecordingViewModel)    │
└───────────────┬─────────────────────────────┘
                │ 调用服务
┌───────────────▼─────────────────────────────┐
│           Core Services                     │  ← 核心服务
│  (PuppetManager, AnimojiRecorder)          │
└───────────────┬─────────────────────────────┘
                │ 桥接私有 API
┌───────────────▼─────────────────────────────┐
│          AvatarKit (私有框架)               │  ← 系统框架
│  (面部追踪、3D 渲染)                        │
└─────────────────────────────────────────────┘
```

**依赖关系**:
- Views → ViewModels (单向数据流)
- ViewModels → Core Services (业务逻辑调用)
- Core Services → AvatarKit (框架封装)
- **禁止**: Views 直接访问 Core Services

---

## 核心代码设计

### 1. 主视图 (ContentView.swift)

```swift
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Animoji 显示区域
                AnimojiSceneView(viewModel: viewModel)
                    .frame(height: 400)
                    .background(viewModel.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()

                // 录制时长显示
                if viewModel.recordingState == .recording {
                    RecordingDurationView(duration: viewModel.recordingDuration)
                        .transition(.scale.combined(with: .opacity))
                }

                // Puppet 选择网格
                PuppetGridView(
                    puppets: viewModel.availablePuppets,
                    selectedPuppet: viewModel.currentPuppet
                ) { puppet in
                    viewModel.selectPuppet(puppet)
                }
                .frame(height: 200)

                Spacer()

                // 录制控制按钮
                RecordingControlsView(viewModel: viewModel)
                    .padding()
            }
            .navigationTitle("FaceMoji")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}

#Preview {
    ContentView()
}
```

### 2. ViewModel (ContentViewModel.swift)

```swift
import SwiftUI
import Observation

@Observable
class ContentViewModel {
    // MARK: - State
    var currentPuppet: PuppetModel?
    var recordingState: RecordingState = .idle
    var availablePuppets: [PuppetModel] = []
    var backgroundColor: Color = .black
    var recordingDuration: TimeInterval = 0
    var showSettings = false
    var showError = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let puppetManager: PuppetManager
    private let recorder: AnimojiRecorder
    private let storage: RecordingStorage

    init(
        puppetManager: PuppetManager = .shared,
        recorder: AnimojiRecorder = .shared,
        storage: RecordingStorage = .shared
    ) {
        self.puppetManager = puppetManager
        self.recorder = recorder
        self.storage = storage

        Task {
            await loadPuppets()
        }
    }

    // MARK: - Actions

    @MainActor
    func loadPuppets() async {
        do {
            availablePuppets = try await puppetManager.loadAvailablePuppets()
            if let first = availablePuppets.first {
                currentPuppet = first
            }
        } catch {
            handleError(error)
        }
    }

    @MainActor
    func selectPuppet(_ puppet: PuppetModel) {
        HapticManager.impact(.light)
        currentPuppet = puppet

        Task {
            try? await puppetManager.setPuppet(puppet)
        }
    }

    @MainActor
    func toggleRecording() async {
        switch recordingState {
        case .idle:
            await startRecording()
        case .recording:
            await stopRecording()
        case .preview:
            break
        }
    }

    @MainActor
    private func startRecording() async {
        do {
            HapticManager.impact(.medium)
            try await recorder.startRecording()
            recordingState = .recording
            startDurationTimer()
        } catch {
            handleError(error)
        }
    }

    @MainActor
    private func stopRecording() async {
        HapticManager.notification(.success)
        await recorder.stopRecording()
        recordingState = .preview
        stopDurationTimer()
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        HapticManager.notification(.error)
    }

    // MARK: - Private Helpers

    private func startDurationTimer() {
        // Timer implementation
    }

    private func stopDurationTimer() {
        recordingDuration = 0
    }
}
```

### 3. SceneKit 桥接 (AnimojiSceneView.swift)

```swift
import SwiftUI
import SceneKit

struct AnimojiSceneView: UIViewRepresentable {
    let viewModel: ContentViewModel

    func makeUIView(context: Context) -> AnimojiRecordView {
        let view = AnimojiRecordView()
        view.backgroundColor = UIColor(viewModel.backgroundColor)
        return view
    }

    func updateUIView(_ uiView: AnimojiRecordView, context: Context) {
        // 更新 Puppet
        if let puppet = viewModel.currentPuppet {
            uiView.setPuppet(puppet)
        }

        // 更新背景色
        uiView.backgroundColor = UIColor(viewModel.backgroundColor)
    }
}

// 封装 AVTRecordView
class AnimojiRecordView: UIView {
    private let recordView: SCNView
    private let puppetManager = PuppetManager.shared

    override init(frame: CGRect) {
        // 使用私有 API 创建 AVTRecordView
        let AKRecordView = AvatarKitLoader.shared.recordViewClass
        recordView = AKRecordView.init() as! SCNView

        super.init(frame: frame)

        recordView.frame = bounds
        recordView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(recordView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPuppet(_ puppet: PuppetModel) {
        recordView.setValue(puppet.avatarInstance, forKeyPath: "avatar")
    }
}
```

### 4. Puppet 网格 (PuppetGridView.swift)

```swift
import SwiftUI

struct PuppetGridView: View {
    let puppets: [PuppetModel]
    let selectedPuppet: PuppetModel?
    let onSelect: (PuppetModel) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(puppets) { puppet in
                    PuppetCell(
                        puppet: puppet,
                        isSelected: puppet.id == selectedPuppet?.id
                    )
                    .onTapGesture {
                        onSelect(puppet)
                    }
                }
            }
            .padding()
        }
    }
}

struct PuppetCell: View {
    let puppet: PuppetModel
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: puppet.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(_):
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }

            Text(puppet.name.capitalized)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
```

### 5. 录制控制 (RecordingControlsView.swift)

```swift
import SwiftUI

struct RecordingControlsView: View {
    @Bindable var viewModel: ContentViewModel

    var body: some View {
        HStack(spacing: 30) {
            if viewModel.recordingState == .idle {
                // 录制按钮
                recordButton
            } else if viewModel.recordingState == .recording {
                // 停止按钮
                stopButton
            } else {
                // 预览控制
                previewControls
            }
        }
        .frame(height: 80)
    }

    private var recordButton: some View {
        Button {
            Task {
                await viewModel.toggleRecording()
            }
        } label: {
            Image(systemName: "record.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
                .symbolEffect(.bounce, value: viewModel.recordingState)
        }
    }

    private var stopButton: some View {
        Button {
            Task {
                await viewModel.toggleRecording()
            }
        } label: {
            Image(systemName: "stop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
                .symbolEffect(.pulse)
        }
    }

    private var previewControls: some View {
        HStack(spacing: 20) {
            // 删除
            Button {
                viewModel.deleteRecording()
            } label: {
                Image(systemName: "trash")
                    .font(.title)
            }

            // 播放/暂停
            Button {
                viewModel.togglePreview()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
            }

            // 分享
            ShareLink(item: viewModel.recordingURL!) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title)
            }
        }
    }
}
```

### 6. 数据模型

```swift
// PuppetModel.swift
import Foundation

struct PuppetModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let thumbnailURL: URL?
    var avatarInstance: Any?  // AVTAnimoji instance

    init(name: String, thumbnailURL: URL? = nil) {
        self.id = UUID()
        self.name = name
        self.thumbnailURL = thumbnailURL
    }
}

// RecordingState.swift
enum RecordingState {
    case idle
    case recording
    case preview
}

// RecordingModel.swift
import Foundation

struct RecordingModel: Identifiable, Codable {
    let id: UUID
    let date: Date
    let fileURL: URL
    let duration: TimeInterval
    let puppetName: String

    init(fileURL: URL, duration: TimeInterval, puppetName: String) {
        self.id = UUID()
        self.date = Date()
        self.fileURL = fileURL
        self.duration = duration
        self.puppetName = puppetName
    }
}
```

### 7. 工具类

```swift
// HapticManager.swift
import UIKit

enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// PermissionManager.swift
import AVFoundation

enum PermissionManager {
    static func requestCameraAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    static func requestMicrophoneAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .audio)
    }

    static func checkAllPermissions() async -> Bool {
        let camera = await requestCameraAccess()
        let microphone = await requestMicrophoneAccess()
        return camera && microphone
    }
}
```

### 8. 错误处理

```swift
// FaceMojiError.swift
import Foundation

enum FaceMojiError: LocalizedError {
    case cameraPermissionDenied
    case microphonePermissionDenied
    case faceTrackingNotAvailable
    case avatarKitLoadFailed
    case recordingFailed(Error)
    case exportFailed(Error)
    case storageError(Error)

    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required for face tracking. Please enable it in Settings."
        case .microphonePermissionDenied:
            return "Microphone access is required for recording audio. Please enable it in Settings."
        case .faceTrackingNotAvailable:
            return "Face tracking is not available on this device. iPhone X or later is required."
        case .avatarKitLoadFailed:
            return "Failed to load AvatarKit framework. This feature requires iOS 11.1 or later."
        case .recordingFailed(let error):
            return "Recording failed: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Export failed: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraPermissionDenied, .microphonePermissionDenied:
            return "Go to Settings > Privacy & Security to enable permissions."
        case .faceTrackingNotAvailable:
            return "This feature requires iPhone X or later with TrueDepth camera."
        default:
            return nil
        }
    }
}
```

---

## 功能规划

### Phase 0 - 项目设置 (P0)

- [ ] 创建 Swift Package 结构
- [ ] 配置 Package.swift
- [ ] 创建 Example App
- [ ] 配置 Info.plist（权限说明）
- [ ] 设置 Git 分支和文档

### Phase 1 - 核心功能 (P0 - 必须实现)

#### 1.1 AvatarKit 集成
- [ ] 复用 `Extensions.swift` (Runtime 工具)
- [ ] 重写 `AvatarKitLoader.swift`
- [ ] 封装 `PuppetManager`
- [ ] 实现 `AnimojiRecordView` (UIKit → SwiftUI 桥接)

#### 1.2 基础 UI
- [ ] ContentView 主视图
- [ ] AnimojiSceneView (SceneKit 桥接)
- [ ] PuppetGridView (LazyVGrid)
- [ ] RecordingControlsView

#### 1.3 MVVM 架构
- [ ] ContentViewModel (使用 @Observable)
- [ ] RecordingState 枚举
- [ ] PuppetModel 数据模型

#### 1.4 录制功能
- [ ] 实现 AnimojiRecorder
- [ ] 开始/停止录制
- [ ] 视频预览
- [ ] 视频导出
- [ ] 分享功能 (ShareLink)

#### 1.5 错误处理
- [ ] 权限检查 (PermissionManager)
- [ ] FaceMojiError 错误类型
- [ ] Alert 错误提示

### Phase 2 - 体验优化 (P1 - 强烈推荐)

#### 2.1 视觉效果
- [ ] 深色模式完整适配
- [ ] 流畅的 Spring 动画
- [ ] SF Symbols 动画效果
- [ ] 状态转场动画

#### 2.2 交互反馈
- [ ] Haptic Feedback (录制、选择、删除)
- [ ] 加载状态指示器
- [ ] 空状态视图

#### 2.3 增强功能
- [ ] 录制时长实时显示
- [ ] 背景颜色选择器（5-8 种预设颜色）
- [ ] 录制历史管理（最多 5 个视频）
- [ ] 视频缩略图生成

### Phase 3 - 高级功能 (P2 - 锦上添花)

- [ ] 导出 GIF 格式
- [ ] 更多背景选项（渐变背景）
- [ ] 录制质量设置（720p/1080p）
- [ ] iCloud 同步（可选）

### 非功能需求

- [ ] 单元测试覆盖（Core 层 > 80%）
- [ ] UI 测试（关键流程）
- [ ] 性能优化（60 FPS 录制）
- [ ] 内存管理（避免泄漏）
- [ ] 文档完善（代码注释 + README）

---

## UI/UX 设计原则

### 设计哲学

**核心原则**: 现代化简洁设计 - 既利用 iOS 17 新特性，又保持界面简洁

### 视觉设计

#### 颜色系统

```swift
// 主色调
- 强调色: .blue (系统蓝)
- 危险色: .red (录制、删除)
- 成功色: .green (导出成功)

// 背景色（自动适配深色模式）
- 主背景: Color(.systemBackground)
- 次背景: Color(.secondarySystemBackground)
- 组背景: Color(.systemGroupedBackground)

// SceneKit 背景（可自定义）
- 默认: .black
- 可选: 纯色 5 种、渐变 3 种
```

#### 字体系统

```swift
- 导航标题: .largeTitle (iOS 默认)
- 按钮文字: .headline
- 说明文字: .caption
- Puppet 名称: .caption2

// 动态类型支持
.font(.headline)  // 自动支持用户字体大小设置
```

#### 间距系统

```swift
- 极小间距: 4pt
- 小间距: 8pt
- 标准间距: 16pt
- 大间距: 24pt
- 极大间距: 32pt
```

### 动画设计

#### 推荐使用的动画

```swift
// ✅ 状态转场
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)

// ✅ SF Symbols 动画
.symbolEffect(.bounce, value: isRecording)       // 录制按钮
.symbolEffect(.pulse)                            // 录制中状态
.symbolEffect(.variableColor)                    // 加载状态

// ✅ 视图出现/消失
.transition(.scale.combined(with: .opacity))
.transition(.move(edge: .bottom))

// ✅ 按钮点击反馈
.scaleEffect(isPressed ? 0.95 : 1.0)
```

#### 避免的动画

```swift
// ❌ 过度动画
- 不在 ScrollView 滚动时添加动画
- 不在 SceneKit 视图上叠加复杂动画
- 不使用超过 0.5 秒的长动画
```

### Haptic Feedback 使用场景

| 操作 | Haptic 类型 | 时机 |
|------|------------|------|
| 选择 Puppet | `.light` | 点击时 |
| 开始录制 | `.medium` | 录制开始 |
| 停止录制 | `.success` | 录制停止 |
| 删除视频 | `.warning` | 确认删除前 |
| 导出成功 | `.success` | 导出完成 |
| 错误发生 | `.error` | 错误提示时 |

### 深色模式适配

```swift
// ✅ 使用语义化颜色
Color.primary              // 自动适配
Color.secondary
Color(.systemBackground)

// ✅ SceneKit 场景适配
func sceneBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.95)
}

// ✅ 图标适配
Image(systemName: "moon.fill")  // SF Symbols 自动适配
```

### 无障碍支持

```swift
// ✅ VoiceOver 支持
.accessibilityLabel("Record Animoji")
.accessibilityHint("Double tap to start recording")

// ✅ 动态字体支持
.font(.headline)  // 自动缩放

// ✅ 高对比度适配
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
```

---

## 技术实现细节

### 1. AvatarKit 私有框架集成

#### 框架加载

```swift
// AvatarKitLoader.swift
import Foundation
import SceneKit

class AvatarKitLoader {
    static let shared = AvatarKitLoader()

    private let bundle: Bundle
    let animojiClass: NSObject.Type
    let recordViewClass: SCNView.Type

    private init() {
        guard let bundle = Bundle(path: "/System/Library/PrivateFrameworks/AvatarKit.framework") else {
            fatalError("AvatarKit framework not found")
        }

        guard bundle.load() else {
            fatalError("Failed to load AvatarKit framework")
        }

        self.bundle = bundle

        guard let animojiClass = NSClassFromString("AVTAnimoji") as? NSObject.Type else {
            fatalError("AVTAnimoji class not found")
        }
        self.animojiClass = animojiClass

        guard let recordViewClass = NSClassFromString("AVTRecordView") as? SCNView.Type else {
            fatalError("AVTRecordView class not found")
        }
        self.recordViewClass = recordViewClass
    }

    func createPuppet(named name: String) -> Any? {
        extractMethod(animojiClass, Selector(("animojiNamed:")), name)
    }

    func getPuppetNames() -> [String] {
        animojiClass.value(forKeyPath: "animojiNames") as? [String] ?? []
    }

    func getThumbnail(forPuppetNamed name: String) -> UIImage? {
        extractMethod(animojiClass, Selector(("thumbnailForAnimojiNamed:options:")), name, nil) as? UIImage
    }
}
```

#### Puppet 管理

```swift
// PuppetManager.swift
import Foundation
import SwiftUI

@Observable
class PuppetManager {
    static let shared = PuppetManager()

    private let loader = AvatarKitLoader.shared
    private(set) var availablePuppets: [PuppetModel] = []

    private init() {}

    func loadAvailablePuppets() async throws -> [PuppetModel] {
        let names = loader.getPuppetNames()

        let puppets = names.compactMap { name -> PuppetModel? in
            guard let thumbnail = loader.getThumbnail(forPuppetNamed: name) else {
                return nil
            }

            // 保存缩略图到临时目录
            let url = saveThumbnail(thumbnail, name: name)

            var puppet = PuppetModel(name: name, thumbnailURL: url)
            puppet.avatarInstance = loader.createPuppet(named: name)

            return puppet
        }

        availablePuppets = puppets
        return puppets
    }

    private func saveThumbnail(_ image: UIImage, name: String) -> URL? {
        guard let data = image.pngData() else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name).png")

        try? data.write(to: url)
        return url
    }
}
```

### 2. 录制管理

```swift
// AnimojiRecorder.swift
import AVFoundation
import SceneKit

@Observable
class AnimojiRecorder {
    static let shared = AnimojiRecorder()

    private(set) var isRecording = false
    private(set) var currentRecordingURL: URL?

    private var recordView: Any?  // AVTRecordView instance

    private init() {}

    func setRecordView(_ view: Any) {
        self.recordView = view
    }

    func startRecording() async throws {
        // 检查权限
        guard await PermissionManager.checkAllPermissions() else {
            throw FaceMojiError.cameraPermissionDenied
        }

        // 调用私有 API 开始录制
        guard let recordView = recordView as? NSObject else {
            throw FaceMojiError.recordingFailed(NSError(domain: "RecordView not set", code: -1))
        }

        recordView.perform(Selector(("startRecording")))
        isRecording = true
    }

    func stopRecording() async {
        guard let recordView = recordView as? NSObject else { return }

        recordView.perform(Selector(("stopRecording")))
        isRecording = false

        // 获取录制文件路径
        if let url = recordView.value(forKeyPath: "recordedFileURL") as? URL {
            currentRecordingURL = url
        }
    }

    func exportMovie(to url: URL) async throws {
        guard let recordView = recordView as? NSObject else {
            throw FaceMojiError.exportFailed(NSError(domain: "RecordView not set", code: -1))
        }

        await withCheckedContinuation { continuation in
            recordView.perform(
                Selector(("exportMovieToURL:options:completionHandler:")),
                with: url,
                with: nil,
                with: { continuation.resume() }
            )
        }
    }
}
```

### 3. 视频导出

```swift
// VideoExporter.swift
import AVFoundation
import UIKit

class VideoExporter {
    static func exportToGIF(videoURL: URL, outputURL: URL) async throws {
        let asset = AVAsset(url: videoURL)
        let duration = try await asset.load(.duration)
        let videoTrack = try await asset.loadTracks(withMediaType: .video).first

        guard let track = videoTrack else {
            throw FaceMojiError.exportFailed(NSError(domain: "No video track", code: -1))
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        // 生成每秒 10 帧
        let frameRate = 10
        let totalFrames = Int(duration.seconds * Double(frameRate))

        var images: [UIImage] = []

        for i in 0..<totalFrames {
            let time = CMTime(seconds: Double(i) / Double(frameRate), preferredTimescale: 600)

            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }

        // 创建 GIF（需要第三方库或自定义实现）
        // 这里简化为伪代码
        // try await GIFWriter.write(images: images, to: outputURL, frameDelay: 0.1)
    }
}
```

### 4. 存储管理

```swift
// RecordingStorage.swift
import Foundation

@Observable
class RecordingStorage {
    static let shared = RecordingStorage()

    private(set) var recordings: [RecordingModel] = []
    private let maxRecordings = 5

    private let storageDirectory: URL

    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        storageDirectory = documentsPath.appendingPathComponent("Recordings")

        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)

        loadRecordings()
    }

    func saveRecording(_ recording: RecordingModel) throws {
        recordings.insert(recording, at: 0)

        // 限制最大数量
        if recordings.count > maxRecordings {
            let removed = recordings.removeLast()
            try? FileManager.default.removeItem(at: removed.fileURL)
        }

        saveMetadata()
    }

    func deleteRecording(_ recording: RecordingModel) throws {
        try FileManager.default.removeItem(at: recording.fileURL)
        recordings.removeAll { $0.id == recording.id }
        saveMetadata()
    }

    private func loadRecordings() {
        let metadataURL = storageDirectory.appendingPathComponent("metadata.json")

        guard let data = try? Data(contentsOf: metadataURL),
              let recordings = try? JSONDecoder().decode([RecordingModel].self, from: data) else {
            return
        }

        self.recordings = recordings
    }

    private func saveMetadata() {
        let metadataURL = storageDirectory.appendingPathComponent("metadata.json")

        guard let data = try? JSONEncoder().encode(recordings) else { return }
        try? data.write(to: metadataURL)
    }
}
```

### 5. 权限管理

```swift
// PermissionManager.swift (完整版)
import AVFoundation
import UIKit

enum PermissionManager {
    static func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    static func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    static func checkAllPermissions() async -> (camera: Bool, microphone: Bool) {
        async let camera = requestCameraAccess()
        async let microphone = requestMicrophoneAccess()

        return await (camera, microphone)
    }

    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
```

### 6. 性能优化

#### 缩略图缓存

```swift
actor ThumbnailCache {
    private var cache: [String: UIImage] = [:]

    func image(for key: String) -> UIImage? {
        cache[key]
    }

    func setImage(_ image: UIImage, for key: String) {
        cache[key] = image

        // 限制缓存大小
        if cache.count > 50 {
            cache.removeValue(forKey: cache.keys.first!)
        }
    }
}
```

#### 内存管理

```swift
// 在 ViewModel 中
deinit {
    // 清理资源
    recorder.cleanup()
    puppetManager.cleanup()
}

// 监听内存警告
.onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
    clearCache()
}
```

---

## 开发路线图

### Sprint 1: 项目设置和基础架构 (预计 2-3 天)

**目标**: 搭建项目结构，确保编译通过

- [ ] 创建 Swift Package 结构
- [ ] 配置 Package.swift 和 Info.plist
- [ ] 创建 Example App
- [ ] 设置目录结构（Core, Features, Shared, Models）
- [ ] 配置 Git 和文档
- [ ] 复用原项目的 `Extensions.swift`

**验收标准**:
- ✅ 项目可以在 Xcode 中打开并编译
- ✅ Example App 可以在模拟器中运行（空白界面）
- ✅ Package.swift 配置正确

---

### Sprint 2: AvatarKit 集成 (预计 3-4 天)

**目标**: 成功加载私有框架，显示 Animoji

- [ ] 实现 `AvatarKitLoader.swift`
- [ ] 实现 `PuppetManager.swift`
- [ ] 创建 `AnimojiRecordView` (UIKit 封装)
- [ ] 实现 `AnimojiSceneView` (SwiftUI 桥接)
- [ ] 测试 Puppet 加载和切换

**验收标准**:
- ✅ 能够加载所有 24+ 个 Puppet
- ✅ 能够在 SwiftUI 视图中显示 Animoji
- ✅ 切换 Puppet 时动画流畅
- ✅ 面部追踪正常工作（需要真机测试）

---

### Sprint 3: 基础 UI 实现 (预计 2-3 天)

**目标**: 实现主要 UI 组件

- [ ] ContentView 主视图
- [ ] PuppetGridView (LazyVGrid)
- [ ] RecordingControlsView
- [ ] 基础导航和布局

**验收标准**:
- ✅ UI 布局符合设计稿
- ✅ Puppet 网格可以滚动和选择
- ✅ 按钮响应点击事件
- ✅ 深色模式自动适配

---

### Sprint 4: MVVM 架构和状态管理 (预计 2-3 天)

**目标**: 实现 ViewModel 和状态流转

- [ ] ContentViewModel (使用 @Observable)
- [ ] RecordingState 状态机
- [ ] 数据模型（PuppetModel, RecordingModel）
- [ ] View 和 ViewModel 绑定

**验收标准**:
- ✅ 状态变化能正确反映到 UI
- ✅ 选择 Puppet 时视图更新
- ✅ 录制状态转换正确

---

### Sprint 5: 录制功能核心 (预计 4-5 天)

**目标**: 实现录制、预览、导出功能

- [ ] AnimojiRecorder 实现
- [ ] 开始/停止录制
- [ ] 视频预览
- [ ] 视频导出到文件
- [ ] ShareLink 分享

**验收标准**:
- ✅ 能够录制 Animoji 视频（需要真机）
- ✅ 录制的视频包含音频
- ✅ 能够预览录制的视频
- ✅ 能够通过 ShareLink 分享视频

---

### Sprint 6: 错误处理和权限 (预计 1-2 天)

**目标**: 完善错误处理和权限管理

- [ ] PermissionManager 实现
- [ ] FaceMojiError 错误类型
- [ ] Alert 错误提示
- [ ] 权限引导界面

**验收标准**:
- ✅ 首次启动时请求权限
- ✅ 权限被拒绝时显示引导
- ✅ 录制失败时显示错误信息
- ✅ 不支持的设备显示友好提示

---

### Sprint 7: 体验优化 (预计 3-4 天)

**目标**: 添加动画、Haptic、录制时长等

- [ ] Spring 动画和转场
- [ ] SF Symbols 动画效果
- [ ] Haptic Feedback
- [ ] 录制时长实时显示
- [ ] 加载状态指示器

**验收标准**:
- ✅ 所有状态转换都有流畅动画
- ✅ 关键操作有触觉反馈
- ✅ 录制时显示实时时长
- ✅ 加载 Puppet 时显示进度

---

### Sprint 8: 增强功能 (预计 3-4 天)

**目标**: 实现背景选择、录制历史

- [ ] 背景颜色选择器（5-8 种预设）
- [ ] RecordingStorage 实现
- [ ] 录制历史视图
- [ ] 视频缩略图生成

**验收标准**:
- ✅ 能够更换 Animoji 背景颜色
- ✅ 能够查看历史录制（最多 5 个）
- ✅ 能够删除历史录制
- ✅ 历史录制显示缩略图

---

### Sprint 9: 测试和优化 (预计 2-3 天)

**目标**: 单元测试、性能优化

- [ ] Core 层单元测试（覆盖率 > 80%）
- [ ] ViewModel 单元测试
- [ ] UI 测试（关键流程）
- [ ] 内存泄漏检查
- [ ] 性能优化（60 FPS）

**验收标准**:
- ✅ 所有测试通过
- ✅ 无内存泄漏
- ✅ 录制时保持 60 FPS
- ✅ 应用包大小合理

---

### Sprint 10: 文档和发布 (预计 1-2 天)

**目标**: 完善文档，准备发布

- [ ] 代码注释补充
- [ ] README.md 更新
- [ ] API 文档生成
- [ ] 示例代码完善
- [ ] 发布说明编写

**验收标准**:
- ✅ 所有公开 API 都有文档注释
- ✅ README 包含使用说明
- ✅ Example App 功能完整
- ✅ 发布说明清晰

---

### 高级功能（可选，Sprint 11+）

- [ ] GIF 导出功能
- [ ] 渐变背景选项
- [ ] 录制质量设置
- [ ] iCloud 同步
- [ ] Widget 支持

---

## 总计时间估算

- **核心功能 (Sprint 1-6)**: 约 14-20 天
- **体验优化 (Sprint 7-8)**: 约 6-8 天
- **测试和文档 (Sprint 9-10)**: 约 3-5 天

**总计**: 约 23-33 天（约 1-1.5 个月）

---

## 风险和挑战

### 技术风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| 私有 API 在新 iOS 版本失效 | 高 | 每个 iOS 版本测试，准备降级方案 |
| SceneKit → SwiftUI 桥接性能问题 | 中 | 使用 Instruments 性能分析 |
| 面部追踪精度不足 | 低 | 依赖 Apple 原生实现，无需优化 |
| 视频编码质量问题 | 低 | 使用 AVFoundation 标准设置 |

### 非技术风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| App Store 审核拒绝（使用私有 API） | 高 | 仅用于学习和内部使用 |
| 设备兼容性问题 | 中 | 明确标注设备要求 |
| 用户隐私问题 | 中 | 完善隐私说明，不上传数据 |

---

## 附录

### A. 开发环境要求

- **macOS**: 14.0+ (Sonoma)
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS 测试设备**: iPhone X 或更新（支持 TrueDepth 摄像头）

### B. 第三方依赖（可选）

目前计划**不使用**第三方依赖，完全基于 Apple 原生技术栈。

如果未来需要 GIF 导出，可考虑：
- `SwiftyGif` - GIF 编码库
- 或自定义实现（使用 ImageIO）

### C. 参考资料

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Observation Framework](https://developer.apple.com/documentation/observation)
- [SceneKit Programming Guide](https://developer.apple.com/documentation/scenekit)
- [AVFoundation Programming Guide](https://developer.apple.com/documentation/avfoundation)

### D. 代码规范

- **命名**: 遵循 Swift API Design Guidelines
- **格式**: 使用 SwiftFormat 自动格式化
- **注释**: 使用 `///` 文档注释
- **访问控制**: 最小化公开 API

### E. Git 工作流

- **主分支**: `main`
- **开发分支**: `claude/rewrite-facemoji-swiftui-*`
- **提交规范**:
  - `feat:` 新功能
  - `fix:` Bug 修复
  - `refactor:` 重构
  - `docs:` 文档更新
  - `test:` 测试相关

---

## 总结

本技术方案详细规划了使用 iOS 17+ SwiftUI 重写 Animoji 项目的完整路线，包括：

1. ✅ **现代化技术栈**: SwiftUI + @Observable + async/await
2. ✅ **清晰的架构**: MVVM + Clean Architecture Lite
3. ✅ **完整的功能**: 从基础录制到增强体验
4. ✅ **专业的细节**: 深色模式、动画、Haptic、错误处理
5. ✅ **可行的路线图**: 分 10 个 Sprint，预计 1-1.5 个月完成

**核心原则**: 现代化但不过度，专业但保持简洁。

---

**文档状态**: ✅ 已确认
**下一步**: 开始 Sprint 1 - 项目设置和基础架构
