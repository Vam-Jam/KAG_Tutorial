
#include "EmotesCommon"

int SCREEN_HEIGHT = 0;
int SCREEN_WIDTH  = 0;

const u16 KEYS_TO_TAKE = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3;

mixin class Character 
{
	dictionary ResponseMap = dictionary();
	
	// Maybe you want this character to have a custom font
	string PreferedFont = "Menu";
	// Custom character name
	string CharacterName = "";
	
	// Text that is currently on the screen
	string CurrentRenderOutput = "";
	// The whole text that is being written to ^
	string CurrentText = "";
	// How fast should we write (needs changing)
	int WriteSpeed = 1;

	// Are we done writing text?
	bool FinishedWriting = false;
	// Is the client done talking to us?
	bool FinishedTalking = false;

	// CurrentRenderOutput Total length including special tokens that are not outputted
	int TextRenderLength = 0;

	void SetName(string name)
	{
		CharacterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, getTranslatedString(text));
	}

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
		// Clear last render response settings
		ResetTalkVars();

		// Set current response text
		CurrentText = getResponse(eventName);

		// Note -> This can get changed manually in text
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


	void RenderBox(Vec2f &in topLeft) 	
	{
		// Character pane in pixels
		const Vec2f pane = Vec2f(108, 100);
		// Text box background
		const int rectangleWidth = topLeft.x * 5;
		// Bottom right
		Vec2f botRight = Vec2f(topLeft.x + pane.x, topLeft.y + pane.y);

		// Pane to the left
		GUI::DrawFramedPane(topLeft, Vec2f(botRight.x, botRight.y + 8)); 

		// Move the rest slightly right since we got that pane
		topLeft.x += pane.x;

		// Shadowed box that sits behind the text
		GUI::DrawRectangle(topLeft, Vec2f(rectangleWidth, botRight.y + 6), SColor(150,0,0,0));

		// Render font (and make sure we set the font they want before hand)
		GUI::SetFont(PreferedFont);
		GUI::DrawText(CurrentRenderOutput, Vec2f(topLeft.x + 25, topLeft.y + 10), 
			Vec2f(rectangleWidth - 25, botRight.y + 6), color_white, true, false, false);

		GUI::DrawIcon("GUI/Keys.png", 8, Vec2f(24, 16), Vec2f(rectangleWidth - 25, botRight.y), 1.0f, color_white);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
/*class GlobalCharacter : Character
{

}*/