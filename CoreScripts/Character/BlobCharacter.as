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
	// List of all the blob characters in our game
	array<BlobCharacter@> BlobList;

	// Character we are going to render
	BlobCharacter@ CharacterToRender = null;
	
	// Dunno if we need this
	CMap@ map;

	BlobCharacterHandler()
	{
		@map = getMap();
	}

	void AddCharacter(BlobCharacter@ character)
	{
		BlobList.push_back(character);

		if (g_debug > 0)
		{
			print("Adding character \"" + character.getName() + "\"");
		}
	}

	void AddCharacter(CBlob@ blob)
	{
		BlobCharacter@ character = null;
		blob.get("character", @character);

		if (character is null) 
		{
			error("AddCharacter with blob " + blob.getName() + 
				" is null, please create character before hand!");

			return;
		}

		AddCharacter(character);
	}

	void SetBlobToRender(CBlob@ blob)
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

	void onTick()
	{
		if (CharacterToRender is null || !CharacterToRender.FinishedWriting)
			return;

		CharacterToRender.UpdateText();
	}

	void onRender()
	{
		if (CharacterToRender is null)
			return;

		CharacterToRender.RenderBox();
		CharacterToRender.TempCharacterBind();
	}

	// Todo: some other stuff?
	void Clear()
	{
		BlobList.clear();
	}
}