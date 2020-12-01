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

Character@ char;

void onInit(CRules@ this)
{
	//AddColorToken("$RED$", SColor(255, 105, 25, 5));
	//AddColorToken("$GREEN$", SColor(255, 5, 105, 25));
	//AddColorToken("$GREY$", SColor(255, 195, 195, 195)); // MOVE TO CORRECT PLACE
	AddColorToken("$WHITE$", SColor(255, 255, 255, 255));
	AddColorToken("$RED2$", SColor(255, 255, 0, 0));
	AddIconToken("$KAG_ANGRY$", "kag_angry.png", Vec2f(16, 16), 0);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	onReload(this);
}

void onTick(CRules@ this)
{
	if (char is null || char.currentText == "" )
		return;

	char.UpdateText();	
}

void onRender(CRules@ this)
{
	if (char is null || char.currentText == "")
		return;
	
	char.RenderBox();
	char.TempCharacterBind();
}

void onReload(CRules@ this)
{
	getMap().RemoveAllSectors();
	@char = Character();
	shitflute(null);
}

void shitflute(CBlob@ caller)
{
	char.AddResponse("ok", "Say what you will about the $RED2$Archer$WHITE$ class, but I for one am glad they exist. I was born with a disability that means I only have 1 finger on each hand. THD was extremely considerate to provide a class I can win with even with this disability, very inclusive. \n\nOh also my disability left me blind and with only 3 brain cells but Archer allows me to get a high kdr rank. Thank you THD for caring for the disabled like me");
	char.SetCurrentResponse("ok", 1);
}

class Character 
{
	dictionary responseMap;
	string preferedFont = "Menu";
	string characterName = "";
	
	string currentRenderText = "";
	string currentText = "";
	int writeSpeed = 1;

	Character(string name) 
	{
		characterName = name;
		responseMap = dictionary();
		currentRenderText = "";
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
						currentchar = currentText.substr(a + 1, 1);
						break;
					}
				}
			}
			else if (char != ' ')
			{
				Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
			}

			currentRenderText += char;
		}
	}

	//void Character() {}

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

	void TempCharacterBind()
	{
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawIcon("ArcherTest.png", 0, Vec2f(12,12), Vec2f(leftX + 5,topY + 5), 3.8f, SColor(150, 255, 255, 255));
	}
}