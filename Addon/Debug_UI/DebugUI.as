// ~~Admin~~ DEBUG UI by Vamist, with big thanks to KGui
//
// NOTE: This uses a custom KGUI.as file:
// Fixes:
//   - Dragging children of a window now works
//   - Null fixes
// Changes:
//   - Changed DrawWindow to DrawFramedPane
//   - DrawRulesFont changed to DrawText

// 100% did not just steal this and reuse this from my last mod :kag_wink:

#define CLIENT_ONLY

#include "KGui.as";

namespace Admin
{
    enum AdminMenu
    {
        NotOpened = 0, // Show icon
        Options,   // Show all the options
        Settings,  // Show game rule settings
    }
}

Admin::AdminMenu CurrentScreen;

//// Core Windows:
Icon NotOpened;
Window Options;
Window Settings;
Window Team;

//// Variables:
const SColor Options_NoHoveredColor = SColor(255, 200, 200, 200);
const SColor Options_HoverColor = SColor(255, 255, 255, 255);

/// Options Menu:
const string Options_Header_Main = "            Debug menu v1...";

const string Server_Text = "Server settings";
const string Team_Text = "Team picker";
const string Counter_Text = "Counter settings";


void onInit(CRules@ this)
{
    AddColorToken("!gold!", SColor(255, 255, 215, 0));
    AddColorToken("!white!", SColor(255, 255, 255, 255));
    AddColorToken("!grey!", SColor(255, 100, 100, 100));
    AddColorToken("!red!", SColor(255, 192, 36, 36));
    AddColorToken("!blu!", SColor(255, 0, 128, 255));

    AddIconToken("$ArrowLeft$", "ArrowLeft.png", Vec2f(8,8), 0);
    AddIconToken("$ArrowRight$", "ArrowRight.png", Vec2f(8,8), 0);

    onReload(this);
}

void onReload(CRules@ this)
{
    // Set the current screen to be closed
    CurrentScreen = Admin::NotOpened;

#ifdef STAGING
    warn("Staging build has not been tested with AdminUI, you may experience weird errors!");
    warn("Example: Screen resizing is currently not supported!");
#endif

    /// Common vars
    Driver@ driver = getDriver();
    int screenWidth = driver.getScreenWidth();
    int screenHeight = driver.getScreenHeight();

    /// Not opened:
    {
        NotOpened = Icon(
            Vec2f(screenWidth - 16, (screenHeight / 2)),
            Vec2f(20, 20),
            "$ArrowLeft$"
        );

        NotOpened.addClickListener(NotOpened_onClick);
    }


    /// Options:
    {
        Options = Window(
            Vec2f(screenWidth - 194, (screenHeight / 2) - 100 ),
            Vec2f(200, 200)
        );

        Label header = Label(
            Vec2f(0, 5),
            Vec2f(200, 40),
            Options_Header_Main,
            color_white,
            false
        );

        Icon goBack = Icon(
            Vec2f(180, 100),
            Vec2f(20, 20),
            "$ArrowRight$"
        );

        Label serverSettings = Label(
            Vec2f(10, 50),
            Vec2f(200, 25),
            "- " + Server_Text,
            Options_NoHoveredColor,
            false
        );



        serverSettings.addHoverStateListener(LabelColor_onHover);

        serverSettings.addClickListener(ServerSettings_onClick);
        goBack.addClickListener(GoBack_onClick);

        Options.addChild(serverSettings);
        Options.addChild(header);
        Options.addChild(goBack);
    }

    /// Settings:
    {
        Settings = Window(
            Vec2f(screenWidth - 244, (screenHeight / 2) - 100 ),
            Vec2f(250, 200)
        );

        Icon goBack = Icon(
            Vec2f(230, 100),
            Vec2f(20, 20),
            "$ArrowRight$"
        );

        Label reloadText = Label(
            Vec2f(10, 50),
            Vec2f(200, 25),
            "- Reload character texts",
            Options_NoHoveredColor,
            false
        );

        Label pathfindingText = Label(
            Vec2f(10, 75),
            Vec2f(200, 25),
            "- Pathfinding stuff",
            Options_NoHoveredColor,
            false
        );

        goBack.addClickListener(GoBack_onClick);

        reloadText.addHoverStateListener(LabelColor_onHover);
        reloadText.addClickListener(ReloadBlobConfigs_onClick);
        
        pathfindingText.addHoverStateListener(LabelColor_onHover);
        pathfindingText.addClickListener(TogglePathfinding_onClick);

        Settings.addChild(goBack);
        Settings.addChild(reloadText);
        Settings.addChild(pathfindingText);
    }

}

// We render different menu's based on what one we currently got active
void onRender(CRules@ this)
{
    switch (CurrentScreen)
    {
        case Admin::Options:
            GUI::SetFont("menu");
            Options.draw();
            break;

        case Admin::Settings:
            GUI::SetFont("menu");
            Settings.draw();
            break;

        case Admin::NotOpened:
        default:
            NotOpened.draw();
            break;
    }
}

/// CALLBACKS:

// Back icon
void GoBack_onClick(int x, int y, int button, IGUIItem@ source)
{
    switch (CurrentScreen)
    {
        case Admin::Settings:
            CurrentScreen = Admin::Options;
            break;

        case Admin::Options:
            CurrentScreen = Admin::NotOpened;
            getRules().set_bool("AdminMenuOpened",false);
            break;
    }
}

// Used to highlight selected text
// Warning: You need to change the text or the colour will never change #blameirrlicht
void LabelColor_onHover(bool isHovered, IGUIItem@ source)
{
    // Cast this back into a label (since it inherits from IGuitItem)
    Label@ label = cast<Label@>(source);

    if (isHovered)
    {
        label.color = Options_HoverColor;

        // if it contains -, replace it with -- or add space to the end
        if (label.label.substr(0, 1) == "-")
            label.label = label.label.replace("-", "--");
        else
            label.label = label.label + " ";
    }
    else
    {
        label.color = Options_NoHoveredColor;

        // if it contains --, convert it to -, otherwise remove space at the end
        if (label.label.substr(0, 1) == "-")
            label.label = label.label.replace("--", "-");
        else
            label.label = label.label.substr(0, label.label.size() - 1);
    }
}



// Not Opened:
void NotOpened_onClick(int x, int y, int button, IGUIItem@ source)
{
    CurrentScreen = Admin::Options;
    getRules().set_bool("AdminMenuOpened",true);
}

// Options:
void ServerSettings_onClick(int x, int y, int button, IGUIItem@ source)
{
    CurrentScreen = Admin::Settings;
}


// Settings:
void ReloadBlobConfigs_onClick(int x, int y, int button, IGUIItem@ source)
{
    getRules().SendCommand(getRules().getCommandID("DebugReloadConfigs"), CBitStream());
}

void TogglePathfinding_onClick(int x, int y, int button, IGUIItem@ source)
{
    getRules().SendCommand(getRules().getCommandID("TogglePathfinding"), CBitStream());
}