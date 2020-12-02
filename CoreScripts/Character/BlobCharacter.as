#include "CharacterCore"

class BlobCharacter : Character
{
	CBlob@ OwnerBlob; 
	BlobCharacter(CBlob@ owner, string name)
	{
		@OwnerBlob = owner;
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


class BlobCharacterHandler
{
	array<BlobCharacter@> BlobList;
	BlobCharacter@ CharacterToRender = null;
	CMap@ map;

	BlobCharacterHandler()
	{
		@map = getMap();
	}

	void RenderBlob(CBlob@ blob)
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];

			if (char.OwnerBlob is blob)
			{
				@CharacterToRender = @char;
				break;
			}
		}
	}

	void onRender()
	{
		if (CharacterToRender is null)
			return;

		CharacterToRender.RenderBox();
		CharacterToRender.TempCharacterBind();
	}

}