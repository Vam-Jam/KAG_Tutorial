///////////////////////////////////////////////////////////
////
////  Character Core 
////
////  This contains a classes that is used to create
////  characters with text dialogue. 
////
////  HEAVILY IN WIP
////
///////////////////////////////////////////////////////////

mixin class Character 
{
	dictionary ResponseMap = dictionary();
	
	string PreferedFont = "Menu";
	string CharacterName = "";
	
	string CurrentRenderText = "";
	string CurrentText = "";

	int WriteSpeed = 1;

	void SetName(string name)
	{
		CharacterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, text);
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
		CurrentText = getResponse(eventName);
		WriteSpeed = textSpeed;
	}

	void SetPreferedFont(string name)
	{
		PreferedFont = name;
	}

	const string getName()
	{
		return CharacterName;
	}

	void UpdateText()
	{
		if (getGameTime() % WriteSpeed == 0)
		{
			string char = CurrentText.substr(CurrentRenderText.length, 1);

			// Grab the full token so users dont see a part of it when reading
			if (char == '$') 
			{
				for (int a = CurrentRenderText.length + 1; a < CurrentText.length; a++)
				{
					string currentchar = CurrentText.substr(a, 1);
					char += currentchar;

					if (currentchar == "$") 
					{
						// Add in the next char so adding a token doesnt waste a text update
						char += CurrentText.substr(a + 1, 1);
						break;
					}
				}
			}
			else if (char != ' ') // TODO -> Set custom audio and sort out what we are doing with audio
			{
				Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
			}

			CurrentRenderText += char;
		}
	}

	// TODO -> Sort this junk out, clear our sHeight and sWidth n stuff
	void RenderBox() 
	{
		GUI::SetFont(PreferedFont);
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawFramedPane(Vec2f(leftX, topY), Vec2f(leftX + hardValue, topY + hardValue));

        leftX += hardValue;
        GUI::DrawRectangle(Vec2f(leftX, topY), Vec2f(leftX + hardValue + 500, topY + hardValue), SColor(150,0,0,0));
        GUI::DrawText(CurrentRenderText, Vec2f(leftX + 25, topY + 10), Vec2f(leftX + hardValue + 475, topY + hardValue), SColor(255, 255, 255, 255), false, false, false);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
class GlobalCharacter : Character
{

}