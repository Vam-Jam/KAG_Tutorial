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

#include "EventSector"

SectorHandler@ handler;
Character@ char;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	onReload(this);
}

void onTick(CRules@ this)
{
	CBlob@ blob = getLocalPlayerBlob();
	if ( handler is null || blob is null)
		return;
		
	handler.OnTick(blob);

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
	@handler = SectorHandler();

	handler.AddNewEvent(
		SectorEvent(shitflute, Vec2f(535.098, 554.672), Vec2f(560.477, 575.501), true)
	);
}

void shitflute(CBlob@ caller)
{
	print("shuo");
	char.AddResponse("ok", "Say what you will about the Archer class, but I for one am glad they exist. I was born with a disability that means I \nonly have 1 finger on each hand. THD was extremely considerate to provide a class I can win with even \nwith this disability, very inclusive. \n\nOh also my disability left me blind and with only 3 brain cells but Archer allows me to get a high kdr rank. \nThank you THD for caring for the disabled like me");
	char.SetCurrentResponse("ok");
}

class Character 
{
	dictionary responseMap;
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

	void UpdateText()
	{
		if (getGameTime() % writeSpeed == 0)
		{
			currentRenderText += currentText.substr(currentRenderText.length, 1);
		}
	}

	//void Character() {}

	void RenderBox() 
	{
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawFramedPane(Vec2f(leftX, topY), Vec2f(leftX + hardValue, topY + hardValue));

        leftX += hardValue;
        GUI::DrawRectangle(Vec2f(leftX, topY), Vec2f(leftX + hardValue + 500, topY + hardValue), SColor(150,0,0,0));
        GUI::DrawText(currentRenderText, Vec2f(leftX + 25, topY + 25), SColor(255,255,255,255));
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