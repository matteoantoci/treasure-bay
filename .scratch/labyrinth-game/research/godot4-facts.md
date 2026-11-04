# Godot 4 facts for the Labyrinth game

Checked on 2026-11-03 against primary sources. Version checked: **Godot 4.7.2-stable**.
The docs at `docs.godotengine.org/en/stable` are the 4.7 docs: their sidebar lists "New pages since version 4.6".
GitHub source links are pinned to the tag `4.7.2-stable`.
Shorthand: `SRC` = `https://github.com/godotengine/godot/blob/4.7.2-stable`, `DOCS` = `https://docs.godotengine.org/en/stable`.

Claims marked **[INFERENCE]** come from reading the source. Nobody ran them. Claims marked **Not confirmed** have no primary source.

---

## 1. Latest stable version and Homebrew

- The latest stable release is **4.7.2-stable**, published 2026-08-18. GitHub's "latest release" API returns it as non-prerelease.
  Source: https://github.com/godotengine/godot/releases/tag/4.7.2-stable
- The release has `Godot_v4.7.2-stable_macos.universal.zip`, 170,622,178 bytes (about 171 MB). It is a universal build for Apple Silicon and Intel.
  Source: same release page (asset list from https://api.github.com/repos/godotengine/godot/releases/latest).
- Homebrew has a **`godot` cask** (not a formula), version **4.7.2**. It downloads the same `macos.universal.zip`.
  Source: https://formulae.brew.sh/cask/godot and https://formulae.brew.sh/api/cask/godot.json
- The cask installs `/Applications/Godot.app`. It has a `binary` artifact that links `Godot.app/Contents/MacOS/Godot` to **`$HOMEBREW_PREFIX/bin/godot`**. So `brew install --cask godot` puts a `godot` command on PATH.
  Source: https://formulae.brew.sh/api/cask/godot.json (`artifacts` → `binary`, target `godot`). Cask file: https://github.com/Homebrew/homebrew-cask/blob/e50aea99c628c2681b7cd48782d1de11f1b2877e/Casks/g/godot.rb
- The Godot docs also say `brew install godot` makes Godot available in PATH. `godot-mono` is the C# build, which we do not need.
  Source: DOCS/tutorials/editor/command_line_tutorial.html (section "Path")
- Without Homebrew, the docs say to run `Godot.app/Contents/MacOS/Godot` directly.
  Source: same page, note at the top.
- The cask conflicts with `godot@3`.

## 2. Running with one command, and importing

Short answer: `godot --path <dir>` starts the game, not the editor, and runs `application/run/main_scene`. A project that was **never imported** only partly works. Scripts, `.tscn` and `.tres` files load. Imported asset types (PNG, SVG, OGG, WAV) do **not** load through `load()`/`preload()` until `godot --headless --path . --import` has run once.

Evidence:
- `--path <directory>`: "Path to a project (<directory> must contain a "project.godot" file)." Running the game: "execute Godot within the project directory or with the project path". Also: "passing in the project.godot file will always run the editor instead of running the game."
  Source: DOCS/tutorials/editor/command_line_tutorial.html ("Command line reference", "Running the game")
- `--import`: "Starts the editor, waits for any resources to be imported, and then quits. Implies --editor and --quit."
  Source: same page. Code: SRC/main/main.cpp#L1683-L1687 (sets `editor = true`, `wait_for_import = true`, `quit_after = 1`).
- Imported files live in `res://.godot/imported/` (for example `example.png-<hash>.ctex`), plus a `<asset>.import` file next to the source. The docs say: "the Resource Loader cannot access non-imported files. Only the FileAccess class can."
  Source: DOCS/tutorials/assets_pipeline/import_process.html
- Godot's own formats (`.tscn`, `.scn`, `.tres`, `.res`) are not imported. "Import parameters are only present in non-native Godot resource types."
  Source: same page.
- `ResourceLoader` finds the real file of an imported asset through the `.import` file, using its `[remap]` section.
  Source: SRC/core/io/resource_importer.cpp#L46 and #L120
- If no loader matches, `load()` fails with "No loader found for resource".
  Source: SRC/core/io/resource_loader.cpp#L332
- **Main scene set as `uid://`:** the game aborts with "Main scene's path could not be resolved from UID. Make sure the project is imported first." This happens when the UID cache in `.godot/` is missing. A plain `res://main.tscn` path for `application/run/main_scene` avoids it.
  Source: SRC/main/main.cpp#L4335-L4346
- **`class_name` globals:** at runtime they are read from `.godot/global_script_class_cache.cfg`. Without an import or editor run that file does not exist, so `class_name` types are unknown. **[INFERENCE]**
  Source: SRC/core/config/project_settings.cpp#L1446-L1470. The import scan writes the file: SRC/editor/file_system/editor_file_system.cpp#L2160-L2166
- A bug where headless import with `--quit` did not finish (issue #77508) was fixed in 4.3.
  Source: https://github.com/godotengine/godot/issues/77508 (closed, milestone 4.3)
- An open issue reports `--headless --import` hanging on HDRI files. It does not affect 2D PNG/SVG/OGG assets.
  Source: https://github.com/godotengine/godot/issues/116084
- Other choices:
  - (a) Run `godot --headless --path . --import` once, then `godot --path .`. For example, a two-step `run.sh`.
  - (b) Load raw files at runtime, with no import: `Image.load_from_file()` + `ImageTexture.create_from_image()`, `Image.load_svg_from_string(svg, scale)`, `DPITexture.create_from_string()`, `AudioStreamOggVorbis.load_from_file()`, `AudioStreamWAV.load_from_file()`, `AudioStreamMP3.load_from_file()`. See sections 4 and 6.
- `.godot/` is a cache. The docs advise against committing it: "If any of the files present in this folder is erased ... the asset or assets will be reimported automatically."
  Source: DOCS/tutorials/assets_pipeline/import_process.html
- The import and run commands need no network. **[INFERENCE]** No step in the code above does a download.

## 3. Fullscreen and quitting on macOS

**Start in fullscreen**
- `display/window/size/mode` (int, default 0) is the main window mode, with `WindowMode` values. `3` = `WINDOW_MODE_FULLSCREEN`, `4` = `WINDOW_MODE_EXCLUSIVE_FULLSCREEN`.
  Source: DOCS/classes/class_projectsettings.html (`display/window/size/mode`), DOCS/classes/class_displayserver.html (`WindowMode`)
- The engine reads it at startup: SRC/main/main.cpp#L2729. The CLI flag `-f` / `--fullscreen` also requests fullscreen: SRC/main/main.cpp#L1340-L1342
- Docs, macOS: in both fullscreen modes "A new desktop is used to display the running project". For EXCLUSIVE_FULLSCREEN: "prevents Dock and Menu from showing up when the mouse pointer is hovering the edge of the screen."
  Source: DOCS/classes/class_displayserver.html
- Code: exclusive fullscreen sets `NSApplicationPresentationHideDock | NSApplicationPresentationHideMenuBar`. Normal fullscreen uses `AutoHideMenuBar | AutoHideDock`, so the menu bar comes back when the mouse is at the top edge.
  Source: SRC/platform/macos/display_server_macos.mm#L2218-L2224 and #L2108-L2124
- Both modes use the native macOS `toggleFullScreen:`.
  Source: SRC/platform/macos/display_server_macos.mm#L2248 and #L2284
- **For a child, use mode 4** (exclusive), so the menu bar and its green button do not appear.

**Esc and fullscreen**
- Godot has no Esc-to-leave-fullscreen behavior. **[INFERENCE]**
- The macOS content view `keyDown:` turns the key into a Godot key event and does not call `super`. It only calls `interpretKeyEvents:` when IME is active, so Esc never reaches AppKit's `cancelOperation:`.
  Source: SRC/platform/macos/godot_content_view.mm#L677-L741
- No engine code toggles the window mode on Esc. Esc only fires the `ui_cancel` input action.
- Not confirmed: whether the macOS shortcut Ctrl+Cmd+F (or Globe+F) leaves Godot's fullscreen. AppKit may add an "Enter/Exit Full Screen" menu item automatically.

**Cmd+Q**
- Cmd+Q is the app menu item "Quit <app>" (`terminate:`, key `q`).
  Source: SRC/platform/macos/display_server_macos.mm#L3744-L3745
- `applicationShouldTerminate:` sends `WINDOW_EVENT_CLOSE_REQUEST` to the main window and returns `NSTerminateCancel`. It only returns `NSTerminateNow` when the engine itself asked to quit (`should_terminate`, set by `OS_MacOS_NSApp::terminate()`).
  Source: SRC/platform/macos/godot_application_delegate.mm#L319-L330, SRC/platform/macos/os_macos.mm#L1175-L1185
- The window turns that event into `NOTIFICATION_WM_CLOSE_REQUEST`: SRC/scene/main/window.cpp#L906-L910
- `SceneTree` quits only if `accept_quit` is true: SRC/scene/main/scene_tree.cpp#L893-L897
- So with `get_tree().set_auto_accept_quit(false)`, **Cmd+Q is ignored** unless the game calls `get_tree().quit()`. **[INFERENCE]** This is traced through the source, not tested.
- Docs: "by default, Godot apps have the built-in behavior to quit when quit is requested from the window manager. This can be changed ... `get_tree().set_auto_accept_quit(false)`".
  Source: DOCS/tutorials/inputs/handling_quit_requests.html
- Note: `applicationShouldTerminate:` also runs on logout and shutdown. With auto-accept off, the game would block logout until it quits. **[INFERENCE]**

**Shortcuts a Godot app cannot block on macOS**
- **Cmd+Tab** (app switcher) and **Cmd+Option+Esc** (Force Quit window) belong to the system. AppKit can turn them off only with the presentation options `disableProcessSwitching` and `disableForceQuit`.
  Source: https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disableprocessswitching and https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct/disableforcequit
- Godot never sets these. It only sets HideDock/HideMenuBar (exclusive) or AutoHide*/FullScreen.
  Source: SRC/platform/macos/display_server_macos.mm#L2120, #L2222
- Godot has no GDScript API for raw presentation options. So a Godot game **cannot block Cmd+Tab or Cmd+Option+Esc**.
- The DisplayServer docs say that in exclusive fullscreen "application switching will trigger a full screen transition", so switching still works.
  Source: DOCS/classes/class_displayserver.html
- **Cmd+H** ("Hide <app>", plus Cmd+Option+H "Hide Others") and **Cmd+M** ("Minimize") are default menu items that Godot creates.
  Source: SRC/platform/macos/display_server_macos.mm#L3734-L3738 and #L3748
- Godot's menu delegate only stops the default action for items with a Godot `representedObject`. These built-in items have none, so AppKit runs hide/minimize, and the game cannot block them. **[INFERENCE]**
  Source: SRC/platform/macos/godot_menu_delegate.mm#L81-L122
- Apple has `disableHideApplication`, but Godot does not use it.
  Source: Apple PresentationOptions list (https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions-swift.struct)
- The Window menu has no Cmd+W item, so Cmd+W does nothing. **[INFERENCE]** (same lines 3747-3751)
- Other system shortcuts (Cmd+Space, Mission Control, Ctrl+Cmd+Q lock screen, Cmd+Shift+3/4/5): Not confirmed against a primary source. They are system-level and Godot exposes nothing for them.

## 4. Audio

- **Autoplay:** `AudioStreamPlayer.autoplay`: "If true, this node calls play() when entering the tree."
  Source: DOCS/classes/class_audiostreamplayer.html
- The only autoplay restriction in the Godot docs is on the **Web** export: "Some browsers restrict autoplay for audio on websites..."
  Source: DOCS/tutorials/export/exporting_for_web.html (section "Audio")
- No user-gesture rule is documented for desktop. A native macOS run should play music at startup. **[INFERENCE]**
- In `--headless` mode the audio driver is Dummy, so there is no sound. `--headless` means `--display-driver headless --audio-driver Dummy`.
  Source: DOCS/tutorials/editor/command_line_tutorial.html, SRC/main/main.cpp#L1505-L1508
- **Bus layout file:** project setting `audio/buses/default_bus_layout` defaults to `"res://default_bus_layout.tres"`: "Default AudioBusLayout resource file to use in the project".
  Source: DOCS/classes/class_projectsettings.html
- The docs: "The default bus layout is automatically saved to the res://default_bus_layout.tres file."
  Source: DOCS/tutorials/audio/audio_buses.html
- `.tres` is a native text resource, so it needs no import (section 2).
- **Runtime buses:** `AudioServer.add_bus(at_position = -1)`, `set_bus_name(idx, name)`, `set_bus_send(idx, send)`, `set_bus_volume_db(idx, db)`, `set_bus_volume_linear(idx, v)`, `add_bus_effect(...)`, and the `bus_count` property.
  Source: DOCS/classes/class_audioserver.html
- Players pick a bus by name. If a bus is renamed, the player falls back to Master.
  Source: DOCS/tutorials/audio/audio_buses.html ("Bus rearrangement")
- **Audio without import:**
  - `AudioStreamOggVorbis.load_from_file(path)` / `load_from_buffer()`. Source: DOCS/classes/class_audiostreamoggvorbis.html
  - `AudioStreamWAV.load_from_file(path, options)`. Source: DOCS/classes/class_audiostreamwav.html
  - `AudioStreamMP3.load_from_file(path)`. Source: DOCS/classes/class_audiostreammp3.html

## 5. Particles and Tween

**CPUParticles2D** (DOCS/classes/class_cpuparticles2d.html)
- `one_shot` (bool, default false): "If true, only one emission cycle occurs. If set true during a cycle, emission will stop at the cycle's end."
- `emitting` (bool, **default true**): starts and stops emission. "if one_shot is true setting emitting to true will not restart the emission cycle until after all active particles finish processing."
  - For a burst on demand, set `emitting = false` at creation, or call `restart()`.
- `explosiveness` (float, default 0.0; setter `set_explosiveness_ratio`): "How rapidly particles in an emission cycle are emitted. If greater than 0, there will be a gap in emissions before the next cycle begins."
  - Not confirmed in the 4.7 text: the usual rule that 1.0 emits all particles at once. The class page wording above is all that was checked.
- `restart(keep_seed: bool = false)`: "Restarts the particle emitter."
- `amount` (int, default 8).
- Signal `finished()`: "Emitted when all active particles have finished processing." It never fires when `one_shot` is off.

**Tween**
- `Node.create_tween()`: "Creates a new Tween and binds it to this node." It equals `get_tree().create_tween().bind_node(self)`.
  Source: DOCS/classes/class_node.html
- `Tween.tween_property(object, property: NodePath, final_val, duration: float) -> PropertyTweener`.
  Source: DOCS/classes/class_tween.html
- `TRANS_BACK = 10` ("interpolated backing out at ends"). `EASE_OUT = 1` ("starts quickly and slows down towards the end").
  Source: DOCS/classes/class_tween.html
- `Tween.set_trans()` (default TRANS_LINEAR), `Tween.set_ease()` (default EASE_IN_OUT), `parallel()`, `set_parallel()`.
  Source: DOCS/classes/class_tween.html
- Per tweener: `PropertyTweener.set_trans()`, `set_ease()`, `from()`.
  Source: DOCS/classes/class_propertytweener.html

## 6. Assets without the editor

**SVG**
- "Godot uses the ThorVG library for SVG rendering." "By default, SVGs are rasterized at import-time." Text must be converted to paths.
  Source: DOCS/tutorials/assets_pipeline/importing_images.html
- Code: SRC/modules/svg/image_loader_svg.cpp#L35 (`#include <thorvg.h>`), #L82-L84
- **Scale option when imported as a texture:** `svg/scale` (float, default 1.0): "The scale the SVG should be rendered at, with 1.0 being the original design size."
  Source: DOCS/classes/class_resourceimportertexture.html, DOCS/tutorials/assets_pipeline/importing_images.html ("SVG > Scale")
  - Import options are stored in `<file>.import`, so they can be written as text without the editor GUI. Then run `--import`. **[INFERENCE]** Based on DOCS/tutorials/assets_pipeline/import_process.html ("Files generated").
- **Alternative importer:** `ResourceImporterSVG` creates a `DPITexture` with `base_scale` (default 1.0). It is re-rasterized at runtime for the oversampling factor.
  Source: DOCS/classes/class_resourceimportersvg.html
- **SVG at runtime with no import:**
  - `Image.load_svg_from_string(svg_str, scale = 1.0)` and `Image.load_svg_from_buffer(buffer, scale = 1.0)`. Source: DOCS/classes/class_image.html
  - `DPITexture.create_from_string(source, scale = 1.0, saturation = 1.0, color_map = {})`. Source: DOCS/classes/class_dpitexture.html

**PNG sprite sheets in code**
- `AtlasTexture`: `atlas` (Texture2D) + `region` (Rect2) cuts one frame from a sheet.
  Source: DOCS/classes/class_atlastexture.html
- `SpriteFrames`: `add_animation(anim)`, `add_frame(anim, texture, duration = 1.0, at_position = -1)`, `set_animation_speed(anim, fps)`, `set_animation_loop_mode(anim, loop_mode)` (`set_animation_loop` is deprecated).
  Source: DOCS/classes/class_spriteframes.html
- Raw PNG with no import: `Image.load_from_file(path)` + `ImageTexture.create_from_image(image)`.
  Source: DOCS/classes/class_image.html, DOCS/classes/class_imagetexture.html
  - Docs warning: `Image.load()` "should only be used in the editor or in cases when you need to load external images at run-time ... and may not work in exported projects." That is fine when running from source.

**TileMapLayer + TileSet in code**
- `TileSet.tile_size` (Vector2i, default 16x16), `TileSet.add_source(source, atlas_source_id_override = -1) -> int`, `TileSet.add_physics_layer()`.
  Source: DOCS/classes/class_tileset.html
- `TileSetAtlasSource.texture`, `texture_region_size` (default 16x16), `create_tile(atlas_coords, size = Vector2i(1,1))`.
  Source: DOCS/classes/class_tilesetatlassource.html
- `TileMapLayer.tile_set`, `TileMapLayer.set_cell(coords, source_id = -1, atlas_coords = Vector2i(-1,-1), alternative_tile = 0)`.
  Source: DOCS/classes/class_tilemaplayer.html

## 7. Tests and screenshots

**Headless gives no pixels**
- `--headless` uses the headless display server. Its only rendering driver is `"dummy"`.
  Source: SRC/main/main.cpp#L1505-L1508, SRC/servers/display/display_server_headless.h#L44-L46
- The dummy texture storage returns an empty RID from `render_target_create()` and `render_target_get_texture()`. `texture_proxy_initialize()` is a no-op.
  Source: SRC/servers/rendering/dummy/storage/texture_storage.h#L91, #L175, #L229
- So `get_viewport().get_texture().get_image()` gives no image in `--headless`, and **a headless run cannot save a real screenshot**. **[INFERENCE]**

**Windowed run**
- Capture code: `var img = get_viewport().get_texture().get_image()`.
  Source: DOCS/tutorials/rendering/viewports.html ("Capture")
- The Viewport class docs warn that the texture "might be completely black or outdated if used too early". Their example:
  ```gdscript
  await RenderingServer.frame_post_draw
  $Viewport.get_texture().get_image().save_png("user://Screenshot.png")
  ```
  Source: DOCS/classes/class_viewport.html (`get_texture`)

**CLI options**
- `--quit`: "Quit after the first iteration."
- `--quit-after <N>`: "Quit after the given number of iterations. Set to 0 to disable."
- `--write-movie <file>`: "Run the engine in a way that a movie is written (usually with .avi or .png extension). --fixed-fps is forced when enabled ... --quit-after can be used to specify the number of frames to write."
- `--fixed-fps <fps>`, `--resolution <W>x<H>`, `--time-scale`, `--disable-vsync`.
- `-s/--script` runs a script that extends `SceneTree` or `MainLoop`. `--check-only` parses for errors (with `--script`).
- Source for all of the above: DOCS/tutorials/editor/command_line_tutorial.html
- Movie Maker docs:
  - Command line: `godot --path /path/to/your_project --write-movie output.avi`. A relative output path is relative to the project folder.
  - A `.png` output writes a "PNG image sequence for video and WAV for audio".
  - `--quit-after N` sets "the number of frames to render before quitting".
  Source: DOCS/tutorials/animation/creating_movies.html
  - It needs a real renderer, so a window. **[INFERENCE]** Same dummy renderer reason as above.

**Input injection**
- `Input.parse_input_event(event)`: "Feeds an InputEvent to the game. Can be used to artificially trigger input events from code. Also generates Node._input() calls." The docs example uses `InputEventAction` with `action = "ui_cancel"`, `pressed = true`.
  Source: DOCS/classes/class_input.html
- `InputEventAction` "is not emitted by the engine. This class is useful to emit actions manually with Input.parse_input_event(), which are then received in Node._input()." Properties: `action`, `pressed`, `strength`, `event_index`.
  Source: DOCS/classes/class_inputeventaction.html
- `Input.action_press(action, strength)` makes `is_action_pressed()` / `is_action_just_pressed()` true. It does "not cause any Node._input() calls".
  Source: DOCS/classes/class_input.html
- Input accumulation is on by default. `Input.flush_buffered_events()` sends buffered events right away.
  Source: DOCS/classes/class_input.html
- Injected events should also work in `--headless`, because the `Input` singleton does not depend on the display server. **[INFERENCE]**
- An `InputEventKey` with a keycode can also be injected, since `parse_input_event` takes any InputEvent. **[INFERENCE]**

## 8. Export templates and running from source

- Export templates are needed to export: "Export templates must be installed to export projects."
  Source: DOCS/tutorials/export/exporting_projects.html
- The CLI page says `godot` "must be a Godot editor binary" and "export templates must be installed".
  Source: DOCS/tutorials/editor/command_line_tutorial.html ("Exporting")
- **Size, 4.7.2:**
  - `Godot_v4.7.2-stable_export_templates.tpz` = **1,281,349,702 bytes (about 1.28 GB)**. It covers all platforms.
  - The mono (C#) TPZ is 1,202,598,411 bytes.
  - Source: https://github.com/godotengine/godot/releases/tag/4.7.2-stable
- The template manager can also "check the box for the platform ... then click the Install Selected Templates", so only one platform is downloaded.
  Source: DOCS/tutorials/export/exporting_projects.html
  - Not confirmed: the download size of the macOS-only template.
- A macOS export also needs a bundle identifier. Unsigned and un-notarized exports "will be blocked by Gatekeeper if they are downloaded from unknown sources".
  Source: DOCS/tutorials/export/exporting_for_macos.html
- **Running from source avoids all of this.** `godot --path <project>` runs the game with the editor binary; no export and no templates are needed.
  Source: DOCS/tutorials/editor/command_line_tutorial.html ("Running the game")
  - The only extra step is the one-time `--import` from section 2. It runs offline. **[INFERENCE]**
- The editor binary itself (`macos.universal.zip`) is about 171 MB (section 1).
