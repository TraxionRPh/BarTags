# BarTags

BarTags is a lightweight World of Warcraft addon designed to streamline your action bar management. With BarTags, you can organize your action buttons into customizable groups—each with its own name, color, and button range—making it easier than ever to locate and use your key abilities during gameplay.

## Features

- **Customizable Groups**  
  Create and manage groups of action buttons. Assign unique names, set button ranges, and choose distinctive colors to visually differentiate your actions.

- **Dynamic Visual Highlights**  
  Automatically apply color highlights to your action buttons based on group settings, ensuring that your UI remains clear and organized.

- **Interactive Tooltips**  
  Enable group tooltips that display the group name when hovering over an action button, offering quick reference without cluttering the interface.

- **Action Bar ID Labels**  
  Optionally display numeric labels next to your action bars for easier configuration and troubleshooting.

- **User-Friendly Configuration**  
  Access a built-in options panel via slash commands (`/bartags` or `/bt`) or by clicking the minimap icon. Changes update your UI in real time.

## Installation

1. **Download:**
   - Clone this repository or download the latest release as a ZIP file.

2. **Installation:**
   - Extract the ZIP file (if applicable).
   - Copy the `BarTags` folder into your World of Warcraft `Interface/AddOns/` directory.
     - **Windows Example:**  
       `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
     - **macOS Example:**  
       `/Applications/World of Warcraft/_retail_/Interface/AddOns/`

3. **Enable the Addon:**
   - Launch World of Warcraft.
   - On the character selection screen, click the "AddOns" button and ensure that BarTags is enabled.

## Usage

- **Access the Options Panel:**
  - Type `/bartags` or `/bt` in the chat.
  - Alternatively, click the minimap icon to open the configuration panel.

- **Configuration Options:**
  - **Groups:** Create new groups, rename them, and assign specific ranges of action buttons.
  - **Visuals:** Set custom colors for each group to easily distinguish them on your action bars.
  - **Tooltips & Labels:** Toggle group tooltips and action bar ID labels on or off as needed.

- **Automatic Updates:**
  - The addon updates the visual highlights and tooltips automatically when you modify the settings.

## Dependencies

BarTags is built using the Ace3 framework and relies on the following libraries:
- **AceAddon-3.0**
- **AceConsole-3.0**
- **AceEvent-3.0**
- **AceDB-3.0**
- **AceConfig-3.0**
- **AceConfigDialog-3.0**
- **AceConfigRegistry-3.0**

Additional libraries:
- **LibDataBroker-1.1**
- **LibDBIcon-1.0**

These dependencies are typically bundled with other addons or can be installed via popular addon managers.

## Contributing

Contributions, bug reports, and feature requests are welcome! If you have ideas for improvement or encounter any issues, please:
- Open an issue in this repository.
- Submit a pull request with your proposed changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

- Built using the robust Ace3 framework.
- Thanks to the WoW community for continuous feedback and support.

---

Enjoy a more organized and visually enhanced World of Warcraft experience with BarTags!
