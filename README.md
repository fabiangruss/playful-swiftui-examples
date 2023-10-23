# playful-swiftui-examples

A growing collection of pretty SwiftUI code snippets to use in your projects based on code from my projects.

Most examples are focused on having a great UX and adding a little bit of fun for the user.

Feel free to star the repo and follow [@fabiangruss](https://twitter.com/fabiangruss) on Twitter - many more examples to come :)




---



#### [Playful, squishy play button](https://github.com/fabiangruss/swiftui-examples/blob/a37c34ec1e470e9b6ac03088b1c4c81bae22adec/playful_button.swift)


This button toggles between play and pause and is a squishy button that changes its shape when pressed. It uses a combination of animations and symbol effects to achieve a playful look.

https://github.com/fabiangruss/swiftui-examples/assets/22966490/6bba3c00-b21a-4f3e-bc69-a97642b6129a

[Go to code](https://github.com/fabiangruss/swiftui-examples/blob/a37c34ec1e470e9b6ac03088b1c4c81bae22adec/playful_button.swift)



---



#### [Squishy waveform button](https://github.com/fabiangruss/swiftui-examples/tree/main/waveform_button)


This button handles audio playback (provided as `Data`) and displays an animated waveform when music/voicenotes are playing. Works like this:
- audio data is divided into chunks
- each chunk's average amplitude is converted to decibels to create waveform bars
- these are rendered in SwiftUI


https://github.com/fabiangruss/swiftui-examples/assets/22966490/094e8db2-2d65-46bc-adbc-4dcd52eeb2b2


[Go to code](https://github.com/fabiangruss/swiftui-examples/tree/main/waveform_button)



---



#### [Highlighted search](https://github.com/fabiangruss/swiftui-examples/blob/a37c34ec1e470e9b6ac03088b1c4c81bae22adec/highlighted_search.swift)

This code snippet shows how to highlight the search term in a list of results. It builds a custom HStack with multiple text elements in which the search term is highlighted and contrasted against the rest of the text.

![Highlighted search](https://github.com/fabiangruss/swiftui-examples/blob/main/previews/highlighted_search.jpg?raw=true)

[Go to code](https://github.com/fabiangruss/swiftui-examples/blob/a37c34ec1e470e9b6ac03088b1c4c81bae22adec/highlighted_search.swift)




---



#### [Custom pull to refresh/action](https://github.com/fabiangruss/playful-swiftui-examples/blob/649765d4eebfa0d14f3d51062f9e08474b3230ea/custom_refresh_view.swift)

This code snippet shows how to build a custom pull to refresh and attach it to a scroll view. It replaces iOS' default `ProgressView` by your own view. This view receives the current pull down percentage from 0 to 1 to be used for custom interactions. Inspiration to this refresh view is based on [kavsoft.dev](https://kavsoft.dev/)


https://github.com/fabiangruss/playful-swiftui-examples/assets/22966490/dbdb39ac-f69e-412c-9a90-450a0652e329


[Go to code](https://github.com/fabiangruss/playful-swiftui-examples/blob/649765d4eebfa0d14f3d51062f9e08474b3230ea/custom_refresh_view.swift)



---



#### [Notification animation](https://github.com/fabiangruss/playful-swiftui-examples/blob/17033711c351da841b233c6820a8b35e80505a2e/notification_animation.swift)

This code snippet shows an animation of a stack of notifications that I used in a notification permission priming screen. Add custom image/avatar paths to make the file runnable.



https://github.com/fabiangruss/playful-swiftui-examples/assets/22966490/3d68a940-2dc9-4450-8f9f-858a6a3daeac



[Go to code](https://github.com/fabiangruss/playful-swiftui-examples/blob/17033711c351da841b233c6820a8b35e80505a2e/notification_animation.swift)
