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
	dictionary responseMap = dictionary();
	
	string preferedFont = "Menu";
	string characterName = "";
	
	string currentRenderText = "";
	string currentText = "";

	int writeSpeed = 1;

	Vertex[] char_box;

	void SetName(string name)
	{
		characterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		responseMap.set(eventName, text);
	}

	string getResponse(string eventName)
	{
		string text = "";
		responseMap.get(eventName, text);
		return text;
	}

	void GetResponse(string eventName, string &out text)
	{
		responseMap.get(eventName, text);
	}

	void SetCurrentResponse(string eventName, int textSpeed = 1)
	{
		currentText = getResponse(eventName);
		writeSpeed = textSpeed;
	}

	void SetPreferedFont(string name)
	{
		preferedFont = name;
	}

	void UpdateText()
	{
		if (currentRenderText.length != currentText.length && getGameTime() % writeSpeed == 0)
		{
			string char = currentText.substr(currentRenderText.length, 1);

			// Grab the full token so users dont see a part of it when reading
			if (char == '$') 
			{
				for (int a = currentRenderText.length + 1; a < currentText.length; a++)
				{
					string currentchar = currentText.substr(a, 1);
					char += currentchar;

					if (currentchar == "$") 
					{
						// Add in the next char so adding a token doesnt waste a text update
						char += currentText.substr(a + 1, 1);
						break;
					}
				}
			}
			else if (char != ' ') // TODO -> Set custom audio and sort out what we are doing with audio
			{
				Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
			}

			currentRenderText += char;
		}
	}

	// TODO -> Sort this junk out, clear our sHeight and sWidth n stuff
	void RenderBox() 
	{
		GUI::SetFont(preferedFont);
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawFramedPane(Vec2f(leftX, topY), Vec2f(leftX + hardValue, topY + hardValue));

        leftX += hardValue;
        GUI::DrawRectangle(Vec2f(leftX, topY), Vec2f(leftX + hardValue + 500, topY + hardValue), SColor(150,0,0,0));
        GUI::DrawText(currentRenderText, Vec2f(leftX + 25, topY + 10), Vec2f(leftX + hardValue + 475, topY + hardValue), SColor(255, 255, 255, 255), false, false, false);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
class GlobalCharacter : Character
{

}