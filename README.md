# GodotProjectTemplate
A quick-start project with settings, credits, main menu and scene transition.

## Usage

1. Download the archive of the repository.
2. Unzip it somewhere.

3. Create a new godot project and add the `autoload` and `scenes` folder into your `./res` folder.
    - Optionally, drag the `assets` folder in `./res`.
5. Set `res://autoloads/custom_root/root.tscn` as your launch scene.
6. Launch the project !

## Features

### Scenes transition

Scenes transition are handled by the root scene.  
When a scene is added, the root will connect to a transition signal : `signal transition(new_scene: PackedScene, animation: String)` if it exist.  
If a scene want to transition to another scene, emit `transition` with a loaded `PackedScene` and the name of an animation (or "" if you don't want any animations). The only animation implemented in the template is "scene_transition".  
Each animations must be separated in 2 steps, which end with "_in" and "_out" respectively. For example, if I use "scene_transition" in my transition signal, the played animation will be "scene_transition_in" then "scene_transition_out".  
Theses animations are defined and created in an `AnimationPlayer` in the root mode.

Here is an example of how to transition to a new scene.

```gdscript
## Define the transition signal
signal transition(new_scene: PackedScene, animation: String)

## Preload the next scene. You can also pass a filepath and load() the scene when needed
@export var back_scene: PackedScene = preload("res://scenes/menu/main_menu.tscn")
@export var scene_path: String = "res://scenes/menu/main_menu.tscn"

## Emit the signal
func random_func() -> void:
    ## Regular
    transition(back_scene, "scene_transition")
    ## If you don't want any animation
    transition(back_scene, "")
    ## From a scene path without animation
    var scene: PackedScene = load(scene_path)
    transition(scene, "")
```

By default, the animations have a 0.2s timer between the end of `_in` and the start of `_out`. You can change this by tweaking `root.gd`.

### Settings

The settings are already implemented, with a focus on extensibility and ease of implementation.

#### Settings File
Settings are saved to a file and are set from it if the file exist. The file is an INI-style file, which is human readable-and-editable. Settings can have the same name as long as they aren't in the same section.
```INI
[SECTION1]
SETTING1=VALUE1
SETTING2=VALUE2
SETTING3=VALUE3

[SECTION2]
SETTING1=VALUE1
SETTING2="STRINGVALUE"
SETTING3=VALUE3
```
By default, that path to the settings file is defined in `settings.gd`.
```gdscript
@export var user_settings_file_path: String = "user://settings/game_settings.cfg"
```
You can change this either by changing the string in the code or by using the export in the inspector.

Saving and Loading the settings from file is doable with the following `Settings` function :
```gdscript
load_settings_from_file()
save_settings_to_file()
```

#### Settings Scene
All the settings are stored as a node tree in a scene. The root node house the `Settings.gd` script. Each node expect the root is either a Section, like Window, Sound, Game... or a Setting like MaxFPS, Resolution or MasterVolume.
- Sections are simple nodes.
     - I use `node.name` to create the setting file sections and the setting screen tabs.
- Settings are nodes with a script attached.
    - This script must `extends Setting.gd` and implement `func apply() -> void`.

#### Defining a Setting

##### [Setting.gd](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/autoloads/settings/setting.gd)
This file define an individual setting.

- `key` is the name of the setting.
    - You should write the key in SCREAMING_SNAKE_CASE to comply with most INI-style conventions.
    - You can convert the key to a cleaner, display-friendlier string by using [`key.capitalize()`](https://docs.godotengine.org/en/stable/classes/class_string.html#class-string-method-capitalize)
- `tooltip` is the tooltip text.
    - Set the label tooltip housing the setting name to this.
- `value` is a `Variant`, representing the value of the setting.
- `default_value` is a `Variant`, representing the default value of the setting.
    -  Due to `Variant` not being an exportable type in editor, we use a workaround in our setting scripts to set `value` and `default_value`.
- `type` define the setting type.
    - `SettingType.BOOLEAN` is for Yes/No settings. This is the default value of `type`.
    - `SettingType.RANGE` is mostly used for volume, but can be used for any settings which need to define a range.
    - `SettingType.OPTIONS` let the user pick between different options.

- `min_value`, `max_value` and `step` are `float` used by `RANGE`.
- `possible_values` and `possibles_values_strings` are `Array` used by `OPTIONS`.
    - You can let `possible_values_strings` empty, and the Settings display scene will automatically fallback to use `possible_values`.

##### Extending Setting.gd
Now that you know how a setting is built, let's create a new setting ! For this example, I am going to create the FrameRate OPTIONS setting.

1. Create a new node under the section you want.
    1. (optional) Name it FrameRate.
2. Add a new script to the node, and fill it with the minimum extended Setting code below :
```gdscript
extends Setting

@export var base_value: CHANGEME =

## A little cheat to be able to change the value and default_value from the editor.
## It's also easier to define possible_values here than in the editor.
func _ready():
	value = base_value
	default = base_value

## Called when settings.apply_settings() is triggered
    func apply() -> void:
        pass
```
I recommend that you add this script as a [script template](https://docs.godotengine.org/en/stable/tutorials/scripting/creating_script_templates.html)  

3. Define the options and the `base_value` add them to the relevant `setting` variables.

```gdscript
extends Setting

const MAX_FRAME_RATE: Array = [30, 60, 120, 144, 0]
const VALUE_STRING: Array = ["30", "60", "120", "144", "Uncapped"]
@export var base_value: int = 60

## A little cheat to be able to change the value and default_value from the editor.
## It's also easier to define possible_values here than in the editor.
func _ready():
	value = base_value
	default = base_value
	possible_values = MAX_FRAME_RATE
	possible_values_strings = VALUE_STRING
```

4. Add functionality with `apply()`

```gdscript
## Called when settings.apply_settings() is triggered
func apply() -> void:
	# setting this to 0 uncap the FPS
	if value is String:
		Engine.set_max_fps(value)
```

That's it ! You've created a setting ! Your setting will be applied when starting the project and when `Settings.apply_settings()` is called. Changing the value of the setting do not automatically trigger `apply()`, but could by tweaking a few things.

For more informations, look at the source code of [every pre-integrated settings](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/tree/main/project/autoloads/settings/settings_scripts).

ADD A SCREENSHOT OF THE SETTINGS SCENE HERE

#### SettingsScreen Scene

The SettingScreen scene is a graphical interface to interact with settings, also known as a setting screen... This is what the player will use to tweak them.

This part is straightforward. We have 3 differents scenes :
1. `SettingsScreen`
    - Create 1 SettingsTab per Section Node.
2. `SettingTab`
    - Create 1 SettingLine per Setting in the Section.
3. `SettingsLine`
    - Create a line with the setting name, its tooltip, and a selector to change the setting depending on this type.

SettingLine change the selector based on the type :
- `SettingType.BOOLEAN` will create a `CheckButton`.
- `SettingType.RANGE` will create a `HSlider`.
- `SettingType.OPTIONS` will create an `OptionButton`.

The save button in `SettingsScreen` spawn a `ConfirmationDialog` asking if you want to apply the settings. The quit button in `SettingsScreen` spawn a `ConfirmationDialog` that warns you that you will lose your modifications if you proceed.

For more informations, look at the source code of [SettingScreen](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/scenes/menu/settings/settings_screen.gd), [SettingTab](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/scenes/menu/settings/setting_tab.gd) and [SettingsLine](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/scenes/menu/settings/settings_line.gd)

### MainMenu

The main menu is a simple scene with buttons to transition to others scenes.

### Title Sequence

The title sequence currently animate the Blessed Sleep Studio's logo. You can replace it by whatever you want (please do not modify the logo's animation itself, either remove it entirely or leave it as that and add others animations before or after).  
The sequence is skipped if any keyboard, mouse buttons or controller input is pressed.

After the title sequence, a transition to the main menu is emitted.

For more informations, look at the source code of [TitleSequence](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/scenes/title_sequence/title_sequence.gd)

### Credits

Credits are a simple blank scene that will be transitioned to when the `CreditsButton` of the `MainMenu` is pressed. The `Button` in the scene will trigger a transition to the main menu.

For more informations, look at the source code of [CreditsScene](https://github.com/BlessedSleepSeeker/GodotProjectTemplate/blob/main/project/scenes/menu/credit_scene.gd)
