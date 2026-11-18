# Toffoli Troubles

A playable Godot 4.7.2 tabletop adventure with five encounters and an outdoor cave approach. Painted practice targets, a wooden waterwheel, clay furnaces and a glazed fruit orchard lead to a brass conservatory guarded by the Crowned Split Slime.

## Play on desktop

On this Linux workstation, run the following in a terminal. The import step prepares a fresh checkout. On subsequent launches, just run the last command from the project directory.

```sh
cd ~/Projects/toffoli-troubles
~/Godot/Godot_v4.7.2-stable_linux.x86_64 --headless --editor --import --xr-mode off
~/Godot/Godot_v4.7.2-stable_linux.x86_64 --path . --xr-mode off
```

On another machine, open `project.godot` in Godot **4.7.2 stable** and press **F5**. If Godot is on your PATH, you can use `godot` in place of the executable path above.

Choose **Begin** or **New run** at the title. Hadamard the Archemage explains why the vault went dark and why the Practice Yard comes first. After his briefing, choose whether to show board coordinates and whether you would use hand gestures. The briefing shows the planned gesture mappings—point to move, pinch to select, thumbs-up to advance, open palm to block, and flick to strike—but gestures are not ready to test yet. Coordinates start hidden and can be toggled later with **Labels on/off** in Pause. **Continue** resumes a saved run.

Pauli is stranded on the far bank of the Practice Yard. Walk up to the glowing **Bridge winch** and select it. Its register starts at 0, which holds the deck upright. **Invert → Measure** produces 1 and lowers the first bridge. At the second layer, stand next to either raised bridge to use its local winch: the round result lowers the detour and the diamond result lowers the shortcut. You can resolve either bridge in place, with no central relay or forced route choice.

The rune tray shows the input ket, applied gates from left to right, and predicted Z-basis outcomes. **Set angle** configures the next phase gate. **Apply phase** adds it to the circuit. In the yard, **Hadamard → Apply phase (π) → Hadamard** takes the wisp from |0⟩ through |+⟩ and |−⟩ to |1⟩. Both middle states give 50/50 exit odds. Their relative phase determines what happens at the second Hadamard. **Measure** samples the displayed distribution. Cyan and pink arcs rise from the active mechanism for the two basis amplitudes. Their intensity and pointer angles reflect the amplitudes and phase.

After finding Pauli, choose **To the meadow**. Cross the grass field along the stepping-stone trail to the torchlit cave. **Enter cave** takes you into Tidemark Mill. At the entrance, choose **Resolve sluice** (goal **Round |0⟩ = 100%**: apply H, then Measure) to open a clear narrow passage before the creatures, or **Fight through** to take the longer route without solving the circuit. The tonic sits farther along the creature route and heals after that turn’s damage, up to 5 HP. The meadow has its own room-boundary checkpoint.

In Navigate, watch the guardian's intent. Move one square horizontally or vertically per turn. Stone barriers block the occupied squares. Dungeon shortcuts are optional; when one stays sealed, the game points you toward the open stones around it. Beside a hostile guardian, **Block** absorbs an incoming strike and **Strike** wears down its guard. Three roaming monsters share each dungeon with its guardian. Mossbacks, cinder newts and Bell Moths patrol on movement and combat turns, pursue within three squares, and threaten adjacent squares. Circuit editing and pausing hold their positions. The two yard creatures stay in the channels. The boss holds the vault exit until defeated. From Ember Kilns onward the resolve target (kiln core, wisp pair, or vault seals) sits at the right end of the board, and each puzzle shows its desired end state — **Diamond |1⟩ = 100%** for the dungeons. The mill awards one Lucky Coin for a noisy measurement attempt. Correctly resolving the Ember Kilns phase puzzle awards a Phase Lens; its next empowered strike deals one extra damage and consumes the charge. Choose a keepsake after defeating the guardian to see Hadamard’s epilogue. Nearby monsters occasionally call during dungeon turns. Progress saves when entering each room and when collecting the treasure. Escape or **Pause** opens the board controls, including a mute toggle for ambient sound and monster calls.

Start each run with **5 HP**. Tonics in Tidemark Mill and the Glaze Orchard restore up to **2 HP** when you walk onto them below full health. The game checkpoints a consumed tonic or a defeated guardian, so reloading preserves that progress.

## Quest interaction prototype

The scene switches to a seated floating board when OpenXR initializes. Either tracked hand can aim from the wrist through the index knuckle and pinch to choose a highlighted control. The pause menu provides recenter, scale and tilt. The prototype uses a virtual background. Native Quest deployment, hand-selection reliability, comfort and run duration still need headset validation.

## Verify the route

After importing the project, run the headless smoke test with isolated Godot user data so its checkpoints stay separate from your playthrough. On Linux:

```sh
XDG_DATA_HOME="$(mktemp -d)" ~/Godot/Godot_v4.7.2-stable_linux.x86_64 --headless --xr-mode off --script tests/world_smoke.gd
```

The test covers the title, wizard briefing, coordinate options, ending, mouse picking, circuit outcomes, both routes to Pauli, the meadow checkpoint, cave entry, the dungeon run, tonic pickup, guard defeat across reload, and treasure restoration.

## Build the Quest 3S APK

One-time prerequisites: JDK 17, the Android SDK, Godot 4.7.2 export templates, and the OpenXR Vendors plugin. Run these on Linux:

```sh
# JDK 17 (Godot's Gradle build requires it)
sudo apt install -y openjdk-17-jdk

# Android SDK
mkdir -p ~/Android/Sdk/cmdline-tools
curl -fL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip
unzip -q /tmp/cmdline-tools.zip -d ~/Android/Sdk/cmdline-tools
mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest
export ANDROID_HOME=~/Android/Sdk
yes | ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --licenses
~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-35" "build-tools;34.0.0"

# Godot 4.7.2 export templates
curl -fL https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz -o /tmp/templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.7.2.stable
unzip -q /tmp/templates.tpz -d /tmp/godot_templates
cp -r /tmp/godot_templates/templates/* ~/.local/share/godot/export_templates/4.7.2.stable/
```

Install the **OpenXR Vendors** plugin (v5.1.0) from the Godot Asset Library or the [GodotVR releases](https://github.com/GodotVR/godot_openxr_vendors/releases) into `addons/godot_openxr_vendors/`, then enable it in Project Settings → Plugins. This supplies the Quest hand-tracking and passthrough manifest entries.

Create the Android export preset once: **Project → Export… → Add… → Android**, set a unique package name such as `com.yourname.toffolitroubles`, set **XR Mode → OpenXR**, and fill the debug keystore (leave empty to auto-generate) or a release keystore. Then build and install:

```sh
~/Godot/Godot_v4.7.2-stable_linux.x86_64 --headless --export-debug "Android" ~/toffoli_troubles.apk
adb devices        # expect "device", not "unauthorized"
adb install -r ~/toffoli_troubles.apk
```

`scripts/build_apk.sh` runs the same export with prerequisite checks; set `INSTALL=1` to also push to the connected Quest.

## Project docs

- [01 Game proposal](docs/01_GAME_PROPOSAL.md)
- [02 End-to-end checklist](docs/02_END_TO_END_CHECKLIST.md)

The Codex and DeepSeek handovers are local Markdown files under `docs/` and are ignored by Git.
