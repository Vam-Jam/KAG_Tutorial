#include "CharacterCore"

class BlobCharacter : Character
{
	CBlob@ ourBlob; 
	BlobCharacter(CBlob@ owner, string name)
	{
		@ourBlob = owner;
		SetName(name);
	}

	void TempCharacterBind()
	{
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawIcon("GetiTest.png", 0, Vec2f(12,12), Vec2f(leftX + 5,topY + 5), 3.8f, SColor(150, 255, 255, 255));
	}
}
