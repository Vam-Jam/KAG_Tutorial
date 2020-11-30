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
	onRestart(this);
}

void onRestart(CRules@ this)
{
	onReload(this);
}

void onRender(CRules@ this)
{
	if (char is null || char.currentRenderText == "")
		return;
	
	char.RenderBox();
}

void onReload(CRules@ this)
{
	@char = Character();
	char.AddResponse("ok", "cool");
	char.SetCurrentResponse("ok");
}

class Character 
{
	dictionary responseMap;
	string characterName = "";
	
	string currentRenderText = "";

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

	void SetCurrentResponse(string eventName)
	{
		currentRenderText = getResponse(eventName);
	}

	//void Character() {}

	void RenderBox() 
	{
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 4;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawFramedPane(Vec2f(leftX, topY), Vec2f(leftX + hardValue, topY + hardValue));

        leftX += hardValue;
        GUI::DrawRectangle(Vec2f(leftX, topY), Vec2f(leftX + hardValue + 500, topY + hardValue), SColor(150,0,0,0));
        GUI::DrawText(currentRenderText, Vec2f(leftX + 25, topY + 45), SColor(255,255,255,255));
	}
}