# PopupKit

`PopupKit` is a tool designed for enhanced view presentation within a `SwiftUI` app.

> [!WARNING]
> With the public release of `iOS 18.0`, Apple modified the internal behavior of `UIView.hitTest()`, which has
> affected the `UIWindow-layering` pattern that `PopupKit` relies on. 
> As a result, `PopupKit`'s interactive `cover` presentation no longer function as expected. 
> Currently, they block all user interactions with the content underneath while they are presented.
> I'm working on the solution.

## Compatibility
`SwiftUI` application targeted to **iOS 15+**.

## Motivation
I have a passion for `SwiftUI` and use it daily for work. While I appreciate its design, 
some components — especially the presentation APIs — still (**iOS 18**) lack the flexibility developers 
often require. `PopupKit` is my attempt to bridge these gaps while respecting `SwiftUI` design principles, but 
with added freedom and flexibility where needed.

## What is PopupKit?
`PopupKit` offers several useful and fully-customizable view presentation methods that can be useful 
in app development:


<table>
    <tbody>
        <tr>
            <td> <p align="center"> <strong>Notification</strong> </p> </td>
            <td> <p align="center"> <strong>Cover</strong> </p> </td>
        </tr>
        <tr>
            <td>
              <img src="https://github.com/user-attachments/assets/1bb247e7-83b0-44b4-b4ca-a103aaf1af14" width="250">
            </td>
            <td>
              <img src="https://github.com/user-attachments/assets/ed50b67a-6ca6-4f4e-bec2-8a09a221e44c" width="250">
            </td>
        </tr>
        <tr>
            <td> <p align="center"> <strong>Confirm</strong> </p> </td>
            <td> <p align="center"> <strong>Fullscreen</strong> </p> </td>
        </tr>
        <tr>
            <td>
              <img src="https://github.com/user-attachments/assets/6f44e6db-ff56-4b22-826e-4f1e86511ba6" width="250">
            </td>
            <td>
              <img src="https://github.com/user-attachments/assets/1d110614-c162-4431-9bae-4d460932159b" width="250">
            </td>
        </tr>
        <tr>
            <td> <p align="center"> <strong>Popup</strong> </p> </td>
            <td> <p align="center"> <strong>Alert</strong> </p> </td>
        </tr>
        <tr>
            <td>
              <img src="https://github.com/user-attachments/assets/9a9321f2-4456-4a32-b29c-14f0f78e37b8" width="250">
            </td>
            <td>
              <img src="https://github.com/user-attachments/assets/f6c2d950-7863-4be8-9763-823726c9d2f6" width="250">
            </td>
        </tr>
    </tbody>
</table>

- **Notification**: a popup notification with text or an image styled similarly to a system push notification.
It is displayed above the app's view hierarchy.
  - Customizable transition, appearance animations, and visual style.
  - Notifications can expire after a set time and automatically dismiss.
  - Supports user-initiated dismissal by a scroll-away gesture, just like system notifications.

- **Cover**: analogue of the system `.sheet` presentation style with several enhancements:
  - Customizable transition, appearance animations, and background.
  - Configurable height (system `.sheet` supports this only since iOS 16).
  - The cover's anchor point can be placed on any screen edge, not just the bottom.
  - Flexible modality: allows you to block user interaction with content beneath the cover or with the cover itself(not working in iOS 18).

- **Fullscreen**: analogue of the system `.fullscreenCover` presentation style, but with enhanced customizability of:
  - Transition and appearance animations
  - Background
  - Optional *scroll-down-to-dismiss* gesture for dismissing the current fullscreen view
 
- **Confirm**: analogue of the system `.confirmationDialog` with several features. Customize:
  - Transition, appearance animations, and visual style
  - Header content
  - Actions appearence
  - Confirm supports haptic feedback
 
- **Popup**: popup modal window with ability to be stacked and customize parameters:
  - Transition, appearance animations, and visual style
  - Content
  - Popups are stackable
 
- **Alert**: modal window similar to system `.alert`. You can customize:
  - Transition, appearance animations, and visual style
  - Header content
  - Actions appearance
  - Alerts are stackable

## Usage
Although in `SwiftUI` it's possible to display views above your app's view hierarchy, system sheets and fullscreen 
covers will still overlay these views. To bypass these restrictions and unlock the full potential of `PopupKit`, 
it's necessary to integrate it into the app's lifecycle.

**Federico Zanetello** brilliantly covers the topic of overlaying `SwiftUI` content above the presentation layer in 
his article, [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows). `PopupKit` 
leverages the ideas presented in this article, and I would like to extend my thanks to the author for his research.

> [!TIP]
> Before diving into the integration steps and usage tips, I’d like to highlight that I’ve created an
> [example project](https://github.com/leekurg/PopupKitExample) showcasing the complete integration
> of `PopupKit`. This example project includes working demonstrations of all the
> available features, allowing you to explore and better understand how to implement `PopupKit`'s tools in your project.

### Integration into the app

Integrating `PopupKit` into your app's lifecycle requires a bit of setup. 
The basic principle is to configure a chain: **App** → **AppDelegate** → **SceneDelegate** → **View layer**. 
This creates a second transparent `UIWindow` in your app, configures `PopupKit` presentation layers within it, 
and injects the presenter objects into your view layer.

To achieve this, follow the steps outlined below:

1. `SceneDelegate` setup
2. `AppDelegate` setup
3. `App` struct setup
4. View layer injections


#### 1. `SceneDelegate` Setup<a id='sceneDelegate-setup'></a>
The first step is to create(if you don't have one already) a dedicated `SceneDelegate` to manage the second `UIWindow`, 
which `PopupKit` will use for presentation.

##### Default setup
If you are fine with the default settings for transitions, animations, and anchor points, you can use the built-in 
`PopupKitSceneDelegate` class. If your app does not yet have a `SceneDelegate`, use this class directly. 
If you already have a `SceneDelegate`, inherit from `PopupKitSceneDelegate` and call the superclass method:

<details><summary>Code</summary><p>

```
class YourSceneDelegate: PopupKitSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        // Your custom code here
    }
}
```

</p></details>
And you are good to go to the next step.

##### Advanced setup
For a more advanced approach, you can fully customize the presentation behavior by copying 
and modifying the `PopupKitSceneDelegate` code into your own `SceneDelegate`:
<details><summary>Code</summary><p>

```
class YourSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    private var popupKitWindow: UIWindow?

    public lazy var coverPresenter = CoverPresenter()
    public lazy var fullscreenPresenter = FullscreenPresenter()
    public lazy var notificationPresenter = NotificationPresenter()
    public lazy var confirmPresenter = ConfirmPresenter()
    public lazy var popupPresenter = PopupPresenter()
    
    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let scene = scene as? UIWindowScene {
            let popupKitWindow = PassThroughUIWindow(windowScene: scene)

            let popupKitViewController = PopupKitHostingController(
                rootView: Color.clear
                    .coverRoot()
                    .ignoresSafeArea(.all, edges: [.all])
                    .fullscreenRoot()
                    .notificationRoot()
                    .confirmRoot()
                    .popupRoot()
                    .environmentObject(coverPresenter)
                    .environmentObject(fullscreenPresenter)
                    .environmentObject(notificationPresenter)
                    .environmentObject(confirmPresenter)
                    .environmentObject(popupPresenter)
                    .popupActionTint(.blue)
            )

            popupKitViewController.view.backgroundColor = .clear
            popupKitWindow.rootViewController = popupKitViewController
            popupKitWindow.isHidden = false
            self.popupKitWindow = popupKitWindow
        }
    }
}
```
</p></details>

This code sets up a secondary `UIWindow` that will hold and display the `PopupKit` presentation layers. The  
components of each presentation layer setup include:

- Presenter: The logical core that manages presenting and dismissing views, and keeps track of the stack.
- Root: The frame used to display the presented views. <a id='root-view-explanation'>
- Environment: This connects the presenter to the `SwiftUI` view layer.

For example, to use a *cover* presentation, you will need to:

- Create a `CoverPresenter` object.
- Add the `coverRoot()` modifier to the secondary window.
- Inject the created `CoverPresenter` into the `SwiftUI` environment.

> [!TIP]
> Each `...Root()` modifier allows for configuration options, such as anchor points, transitions,
> and animations, which can be tailored to your specific needs. You can also adjust the safe areas using
> the `.ignoresSafeArea(_)` modifier between `...Root()` calls.

Once you have set up your presenters and their environment, you're ready to move on to the [next step](#appDelegate-setup).

#### 2. `AppDelegate` setup<a id='appDelegate-setup'></a>

On this step, it is necessary to create (if you don't have one already) a dedicated `AppDelegate` 
to make use of the `SceneDelegate` that you set up in the previous step.

If you opted for the default setup in the previous step and there is no existing `AppDelegate` in your app, 
you can proceed to the [next step](#app-struct-setup) with the default `PopupKitAppDelegate` class.

However, if you already have an `AppDelegate`, ensure that you are using the `SceneDelegate` you configured in 
the [earlier step](#sceneDelegate-setup):

<details><summary>Code</summary><p>

```
class YourAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = YourSceneDelegate.self
        return sceneConfig
    }
}
```
</p></details>
Once this is done, you are ready to proceed to the [next step](#app-struct-setup).

#### 3. `App` struct setup<a id='app-struct-setup'></a>
On this step, you need to ensure that you tell to `SwiftUI` to use the configured `AppDelegate` as the delegate 
for your app. To do this, add (or verify that it's already present) the following line of code in your `App` struct. 
Replace `YourAppDelegate` with the actual `AppDelegate` class you configured in the [previous step](#appDelegate-setup):

```
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor var adaptor: YourAppDelegate  //this

    var body: some Scene {
        WindowGroup {
            // App root view
        }
    }
}
```
This line ensures that your custom `AppDelegate` is properly set as the app’s delegate, allowing it to manage 
lifecycle events and integrate `PopupKit`. Once added, you can proceed to the last integration step.

#### 4. View layer injections
At this point, your app's `SceneDelegate` holds a set of presenters responsible for `PopupKit`'s presentation 
functionality. Now, you need to inject these presenters into the view hierarchy. To achieve this, create a 
dedicated root view in your `App` struct, such as a `MainSceneView`:

```
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor var adaptor: YourAppDelegate

    var body: some Scene {
        WindowGroup {
            MainSceneView()  //this
        }
    }
}
```

In the `MainSceneView`, inject all the necessary `PopupKit` presenters into the `SwiftUI` environment as follows:

```
struct MainSceneView: View {
    @EnvironmentObject var sceneDelegate: YourSceneDelegate

    var body: some View {
        ContentView()
            .environmentObject(sceneDelegate.coverPresenter)   // Injects the cover presenter
            .environmentObject(sceneDelegate.fullscreenPresenter)  // Injects the fullscreen presenter
            .environmentObject(sceneDelegate.notificationPresenter)  // Injects the notification presenter
            .environmentObject(sceneDelegate.confirmPresenter)  // Injects the confirm presenter
            .environmentObject(sceneDelegate.popupPresenter)    // Injects the popup presenter
    }
}
```

> [!TIP]
> Alternatively, you can perform this injection within your `ContentView`, but there is something to keep in mind:
> 1. Injection requires access to `EnvironmentObject` and`SwiftUI` does not allow such access directly
> within the `App` struct.
> 2. Ensure that all presenters are injected *before* any calls to `PopupKit`'s presentation methods are made.

### Presenting a view
Once the integration process is complete, `PopupKit` enables you to present views with a variety of tools, similar 
to how system views are presented. You can easily implement these features by adding a `PopupKit` modifier to your 
view, passing a `Binding` variable to control its state, and toggling that `Binding` to trigger the presentation.

<br/>

#### Fullscreen
To present a view in fullscreen mode, you can use the `fullscreen()` modifier. Here's an example:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            Button("Show PopupKit fullscreen") {
                isPresented.toggle()
            }
            .fullscreen(
                isPresented: $isPresented,  // 1. Controls the presentation state
                background: .ultraThinMaterial,  // 2. Defines the background style
                ignoresEdges: [.bottom, .leading],  // 3. Specifies which edges to ignore
                dismissalScroll: .dismiss(predictedThreshold: 300)  // 4. Enables swipe-to-dismiss with threshold
            ) {
                Color.red  // Content of the fullscreen view
            }
        }
    }
}
```
</p></details>

Let's break down the key elements of the `fullscreen()` modifier: \
✅ **Background Customization** (background): You can define the fullscreen background using a `ShapeStyle` of 
your choice (e.g., `.ultraThinMaterial` for a blur effect). \
✅ **Safe Area Ignoring** (ignoresEdges): By default, the content respects the safe areas of the device, 
but you can specify which edges should be ignored if desired. \
✅ **Swipe-to-Dismiss Gesture** (dismissalScroll): Enable a *swipe-down-to-dismiss* gesture with a customizable 
threshold, controlling how much scrolling is required to dismiss the fullscreen view.

<br/>

#### Cover
To display a view using a *cover* presentation mode, you can utilize the `cover()` modifier provided by `PopupKit`. 
Here's how you can implement it:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show PopupKit Cover") {
                isPresented.toggle()
            }
            .cover(
                isPresented: $isPresented,  // 1. Controls the presentation state
                background: .ultraThinMaterial,  // 2. Defines the background style
                modal: .modal(interactivity: .interactive),  // 3. Configures modality (interactive/noninteractive or none)
                cornerRadius: 15  // 4. Sets the corner radius for the cover view
            ) {
                Color.red  // 5. Content of the cover view
            }
        }
    }
}
```
</p></details>

Key elements of `cover()` modifier:

✅ **Background Customization** (background): You can choose the cover's background style, such as `.ultraThinMaterial` to add a subtle blur effect, or any other `ShapeStyle`. \
✅ **Modal behavior** (modal):
  - **Non-modal**: The cover view does not block interaction with other views on the screen.
  - **Modal-interactive**: A dimmed background appears around the cover, and the cover can be dismissed by 
  tapping the dimmed area or scrolling it down.
  - **Modal-noninteractive**: Similar to the interactive modal, but the cover cannot be dismissed by tapping 
  outside the cover or scrolling.
✅ **Corner Radius** (cornerRadius): You can adjust the corner radius of the cover to create a smooth, rounded edge 
for the view.

The content inside the cover view is provided as a trailing closure. The height of the cover is determined by the 
content you provide. If the content’s height exceeds the device’s screen height, the cover will occupy the full 
screen, and its content will align to the top of the screen.

<br/>

#### Notification
You can display a view with a notification presentation style by using the `notification()` view modifier. 
Here’s an example implementation:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show PopupKit Notification") {
                isPresented.toggle()
            }
            .notification(
                isPresented: $isPresented,  // 1. Controls the presentation state
                expiration: .timeout(.seconds(2))  // 2. Defines how long the notification remains visible
            ) {
                RoundedRectangle(cornerRadius: 15).fill(.yellow)  // Content of the notification view
            }
        }
    }
}
```
</p></details>

Key Elements of `notification()` modifier:

✅ **Expiration Time** (expiration): You can set an expiration time using `.timeout()` to specify how long the notification 
remains visible. For instance, `.seconds(2)` means the notification will automatically dismiss after 2 seconds. 
If no expiration is set, the notification will remain until dismissed manually (e.g., by swiping).

Dismissal behaviour:

✅ **Manual Dismissal**: All notifications can be manually dismissed by the user with swipe, similar to system push
notifications. If no expiration time is set, manual dismissal will be the only method of removal. \
✅ **Automatic Dismissal**: When an expiration time is set, the notification will automatically dismiss itself once 
the timer expires.

> [!TIP]
> If multiple notifications are presented in sequence, the timer resets when a new notification is shown.
> For example, if Notification A is still active when Notification B appears, A’s timer will restart when B is
> dismissed.

<br/>

#### Confirm
When you need to make user pick one of actions you can use a *confirm* presentation mode, utilizing the `confirm()` modifier provided by `PopupKit`. 
Here's how you can implement it:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show PopupKit Cover") {
                isPresented.toggle()
            }
            .confirm(isPresented: $isPresented) {
                Text("Are you sure?")
            } actions: {
                Regular(
                    text: Text("Maybe not"),
                    action: { print("Maybe not was picked") }
                )
                Cancel(text: Text("Not this time"))
                Destructive(
                    text: Text("I am sure"),
                    action: { print("I am sure was picked") }
                )
            }
        }
    }
}
```
</p></details>

Key elements of `confirm()` modifier:

✅ **Header Customization** (header): You can use any `View` to present as dialog's header. \
✅ **ActionBuilder**: Simplified syntax with `@ActionBuilder` for implementig actions. \
✅ **Auto-sorting**: Order of actions during dialog's presentation is the same as you provides, except the **cancel** actions listed below. \

You can customize actions font appearence using dedicated `EnvironmentValues` through `View` extension functions - `.popupActionTint(_)` and `.popupActionFonts(_)`. Also, a number of parameters can be customized with passing parameters to `.confirmRoot()` call:

✅ **background** - background of dialog \
✅ **cancelBackground** - background of section with *cancel* actions. \
✅ **cornerRadius** - a corner radius of section with header and *regular* actions and section with *cancel* actions. \
> [!NOTE]
> It is possible to present only one *confirm* at a time, any attempts to present a dialog, while there is presented one, will be ignored.

<br/>

#### Popup
To present some information to user, request text input or some action to pick you can utilize `.popup()` presentation modifier provided by `PopupKit`. 
Here's how you can implement it:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show PopupKit Cover") {
                isPresented.toggle()
            }
            .popup(
                isPresented: $isPresented,    // 1. Controls the presentation state
                outTapBehavior: .dismiss,     // 2. Determines behaviour when user tap outside the view
                ignoresEdges: []              // 3. Ignore specified edges of the safe area
            ) {
                PopupView()                   // Content of the popup view
            }
        }
    }
}
```
</p></details>

Key elements of `popup()` modifier:
- **Presentation Control** (isPresented): A `Binding<Bool>` variable controls when the popup is presented or dismissed. Toggling this binding will trigger the presentation state.
- **Tap Outside Behaviour** (outTapBehavior): Popup could be dismissed on outside tap.
- **Safe Area Ignoring** (ignoresEdges): By default, the content respects the safe areas of the device, 
but you can specify which edges should be ignored if desired.

<br/>

#### Alert
`popupAlert()` is right tool for you if you want more freedom than system `.alert()` has to offer.
Here's how you can implement it:

<details><summary>Example</summary><p>

```
struct YourView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show PopupKit Cover") {
                isPresented.toggle()
            }
            .popupAlert(isPresented: $isPresented) {     // 1. Controls the presentation state
                YouCustomHeader()                        // 2. Content of the popup view
            } actions: {
                Regular(                                 // 3. Actions to offer
                    text: Text("Okt"),
                    action: { print("Ok") }
                )
            )
        }
    }
}
```
</p></details>

Key elements of `popupAlert()` modifier:

✅ **Respects safe area insets** \
✅ **Auto scrollable**: Alert's actions list becames scrollable if height of the screen is not enough. \
✅ **ActionBuilder**: Simplified syntax with `@ActionBuilder` for implementig actions. \
✅ **Auto-sorting**: Order of actions during dialog's presentation is the same as you provides, except the **cancel** actions listed below. \

Actions font can be changed appearence using dedicated `EnvironmentValues` through `View` extension functions - `.popupActionTint(_)` and `.popupActionFonts(_)`.

### Controlling Presentation with `Presenter`
In addition to view modifiers, `PopupKit` offers another powerful tool for managing presentations: the `Presenter`. 
Each presentation layer in `PopupKit` has its own `Presenter`, which is injected into the `SwiftUI` environment system
during the integration process. `Presenter` acts as the logical core that manages presentation operations, offering a 
set of methods to control presentation flow and access the presentation stack.

Key functions of `Presenter`:
- `present()`: Triggers a new presentation, adding a view to the top of the presentation stack.
- `dismiss()`: Dismisses the current (top-most) view on the presentation stack.
- `popToRoot()`: Dismisses all presented views.
- and more
 
Each `Presenter` also maintains a presentation stack, which holds all currently presented entities in the order they 
were shown. This stack can be checked at any time to determine which view is currently being presented.

#### Debugging
`PopupKit` provides an easy way to debug presentation behavior using the *verbose* mode on `Presenter`. By enabling 
verbose mode, any changes to the presentation stack are logged in the Xcode console, making it easy to track 
presentation events and troubleshoot any issues.

You can activate verbose mode when initializing any `Presenter` by passing the `isVerbose` argument in the `Presenter`'s 
initializer:

```
let presenter = CoverPresenter(isVerbose: true)
```

>[!NOTE]
> Verbose mode is limited to `DEBUG` builds, ensuring that redundant logs do not appear in `RELEASE` builds.
> This helps you maintain clean, production-ready logs while benefiting from detailed output during development.

## PopupKit in SwiftUI Preview

Due to its deep integration at a higher app level, unfortunately, `PopupKit` 
doesn’t fully act as expected within `SwiftUI` `Previews` as it do in simulator or on a device. 
I’ve worked to minimize the inconvenience, but some limitations remain. You can choose one of two options
which is more suitable in your case.

### Disabling `PopupKit` in `Previews`
If you don’t need `PopupKit` to work in `Previews`, you can easily disable it. Go to the 
`Package.swift` file in `PopupKit` package and uncomment the section that includes the line:

```
.define(«DISABLE_POPUPKIT_IN_PREVIEWS»)
```

This will completely disable `PopupKit` from running in `Previews` and (as desribed below) will free you from writing
a bolierplate code.

### Enabling `PopupKit` in `Previews`

If you **do want to preview** `PopupKit` presentation methods, use the following modifiers in 
your previews:
- previewPopupKit(_)
- previewPopupKit(ignoresSafeAreaEdges)

These modifiers should be applied in every preview macro or `PreviewProvider` where `PopupKit` 
is expected to function. It's important to attach these modifiers as high as possible in the 
view hierarchy. The view you attach the modifier to is treated as the [*root view*](#root-view-explanation), 
so make sure this root view occupies the full screen — otherwise, the presentation views won’t behave as expected.

## Install
`SPM` installation: in Xcode tap **File → Add packages…**, paste is search field the URL of this page and 
press **Add package**. After that, you should complete the [integration](#integration-into-the-app).

## Known issues
❌ `NavigationStack` is not working inside a `cover`\
❌ `NavigationStack` is not working inside a dismissable `fullscreen`. Fullscreen with `DismissalScroll.none` is fine.\
❌ Interactive covers is not letting you to interact with the content beneath on `iOS 18`.

## Roadmap
- [x] Notification
- [x] Cover
- [x] Fullscreen
- [x] Confirmation dialog
- [x] Popup
- [x] Alert
- [ ] Confirm support for album orientation
- [ ] Fix [known issues](#known-issues)
