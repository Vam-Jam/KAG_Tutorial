
#include "EmotesCommon"

int SCREEN_HEIGHT = 0;
int SCREEN_WIDTH  = 0;

const u16 KEYS_TO_TAKE = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3;

mixin class Character 
{
	dictionary ResponseMap = dictionary();
	
	// Maybe you want this character to have a custom font
	//     - Set your own custom font, used before rendering text
	string PreferedFont = "pixeled";

	// Custom character name, added to the start of the text render
	//     - Note: Will get changed at some point
	string CharacterName = "";

	// How fast should we write by default
	//     - Note: text cfg's can change this with "{S_NUM}"
	int WriteSpeed = 1;

	// Are we done writing text?
	//     - Used to know if text is done updating
	bool FinishedWriting = false;

	// Is the client done talking to us?
	//     - Used to end talking to the character (gui goes bye)
	bool FinishedTalking = false;

	// CurrentRenderOutput Total length including special tokens that are not outputted
	//     - Used when updating text so we can grab the correct substr
	int TextRenderLength = 0;

	// Text that is currently on the screen
	string CurrentRenderOutput = "";
	// The whole text that is being written to ^
	string CurrentText = "";
	// Name of the something
	string NextInteractKey = "";

	void SetName(string name)
	{
		CharacterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, getTranslatedString(text));
	}

	// Both getResponses do the same thing, but give the string back in different ways
	string getResponse(string eventName)
	{
		string text = "";
		ResponseMap.get(eventName, text);
		return text;
	}

	void GetResponse(string eventName, string &out text)
	{
		ResponseMap.get(eventName, text);
	}

	void SetCurrentResponse(string eventName, int textSpeed = 1)
	{
		ResetTalkVars();
		CurrentText = getResponse(eventName);
		WriteSpeed = textSpeed;
	}

	void ResetTalkVars()
	{
		FinishedWriting = false;
		FinishedTalking = false;
		TextRenderLength = 0;
		CurrentRenderOutput = "";
	}

	void SetPreferedFont(string name)
	{
		PreferedFont = name;
	}

	const string getName()
	{
		return CharacterName;
	}

	void LoadTextConfig(string configName)
	{
		ConfigFile cf = ConfigFile(CFileMatcher(configName).getFirst());
		if (cf is null)
		{
			error("AttachedTextConfig " + configName + " is null (attached to character  " + CharacterName + ")");
			return;
		}

		if (cf.exists("main")) {
			string main = cf.read_string("main");
			
			AddResponse("main", main);
			NextInteractKey = "main";
		}

		// Temp work around until cfg has a get all keys func (would be named keys, but its an illegal name >:( )
		string[] configKeys = cf.read_string("keys").split(';');

		// Todo -> error if not found
		for (int a = 0; a < configKeys.length; a++)
		{
			string text = cf.read_string(configKeys[a]);
			AddResponse(configKeys[a], text);
		}
	}

	// Called when user interacts with said target
	void ButtonPress() 
	{
		SetCurrentResponse(NextInteractKey);
	}

	void Update()
	{
		CBlob@ blob = getLocalPlayerBlob();
		if (blob is null || FinishedTalking) 
			return;

		LockMovement(blob);
		bool skip = ClientInputs();

		if (skip)
		{
			// Fix loud audio when skipping
			if (!FinishedWriting)
			{
				while(!FinishedWriting)
					UpdateText();
			}
			else
			{
				FinishedTalking = true;
			}
		}
		else
		{
			if (!FinishedWriting && getGameTime() % WriteSpeed == 0)
				UpdateText();
		}
	}

	// TODO: Clean, fix some 'hacky/temp' stuff
	void UpdateText()
	{
		string chars = CurrentText.substr(TextRenderLength, 1);

		// Colour tokens
		if (chars == '$') 
		{
			for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
			{
				string currentChar = CurrentText.substr(a, 1);
				chars += currentChar;
				if (currentChar == "$")
				{
					string temp = CurrentText.substr(a + 1, 1);
					if (isSpecialChar(temp))
						chars = "";
					else
						chars = temp;
						
					break;
				}
			}
		}
		else if (chars == '{') // Emote/Custom text logic
		{
			// TODO -> Make more pretty
			string insides = "";

			for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
			{
				string currentChar = CurrentText.substr(a, 1);
			
				if (currentChar == "}")
				{
					// Add in the next char so adding a token doesnt waste a text update
					string temp = CurrentText.substr(a + 1, 1);
					if (isSpecialChar(temp))
						chars = "";
					else
						chars = temp;

					break;
				}

				insides += currentChar;
			}

			string action = insides.substr(0, 2);
			string content = insides.substr(2, insides.length);

			if (action == "E_")
			{
				set_emote(OwnerBlob, Emotes::names.find(content));
			}
			else if (action == "S_")
			{
				WriteSpeed = parseInt(content);
			}
			else if (action == "K_")
			{
			}

			TextRenderLength += 2 + action.length + content.length;
		}
		else if (chars != ' ') // TODO -> Set custom audio and sort out what we are doing with audio
		{
			Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
		}

		CurrentRenderOutput += chars;
		TextRenderLength += chars.length;

		// Need to fix (tokens excluding colours will make this invalid)
		if (TextRenderLength == CurrentText.length)
			FinishedWriting = true;
	}

	// TEMP
	bool isSpecialChar(string input)
	{
		return (input == "{" || input == "}" || input == "$");
	}

	// Maybe set velocity to 0?
	void LockMovement(CBlob@ blob)
	{
		blob.DisableKeys(KEYS_TO_TAKE);
		blob.setVelocity(Vec2f(
			0.0f,
			blob.getVelocity().y
		));
	}

	// Note: Space bar wont active bombs
	bool ClientInputs()
	{
		CControls@ controls = getControls();
		return controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION3));
	}


	void RenderBox() 	
	{
		//
		Vec2f topLeft(0,0);
		// Character pane in pixels
		const Vec2f pane = Vec2f(108, 100);
		// Text box background
		const int rectangleWidth = getDriver().getScreenWidth();
		// Bottom right
		Vec2f botRight = Vec2f(topLeft.x + pane.x, topLeft.y + pane.y + 8);

		// Pane to the left
		GUI::DrawFramedPane(topLeft, Vec2f(botRight.x, botRight.y)); 

		// Move the rest slightly right since we got that pane
		topLeft.x += pane.x;

		// Shadowed box that sits behind the text
		GUI::DrawRectangle(topLeft, Vec2f(rectangleWidth, botRight.y), SColor(200,0,0,0));

		// Render font (and make sure we set the font they want before hand)
		GUI::SetFont(PreferedFont);
		GUI::DrawText(CharacterName + " " + CurrentRenderOutput, Vec2f(topLeft.x + 25, topLeft.y + 10), 
			Vec2f(rectangleWidth - 25, botRight.y - 2), color_white, true, false, false);

		//GUI::DrawIcon("GUI/Keys.png", 8, Vec2f(24, 16), Vec2f(rectangleWidth - 25, botRight.y), 1.0f, color_white);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
/*class GlobalCharacter : Character
{

}*/