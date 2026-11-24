# Sidebar and app bar integration

Place the `stag_sidebar` and `stag_appbar` checkouts next to each other. From
this directory, generate the web platform files and start the example:

```bash
flutter create --platforms=web .
flutter run -d chrome
```

Use the toolbar buttons to switch the layout and light/dark theme. The sidebar
supports navigation and can be collapsed independently.
