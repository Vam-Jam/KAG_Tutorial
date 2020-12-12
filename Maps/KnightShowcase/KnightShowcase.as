#include "MapsCore"

void onInit(CMap@ this)
{
	onRestart(this);
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	onRestart(this);
}

CBlob@ blob = null;

// NOT A HOOK
void onRestart(CMap@ this)
{
	if(!AddSpawns(this, "blue main spawn", "tent") && AddSpawns(this, "blue spawn", "tent"))
	{
		error("Could not find spawn markers to place!");
	}

	//SpawnInCharacter("knight", 1, Vec2f(538, 560), "generic knight main");
	//SpawnInCharacter("archer", 0, Vec2f(555, 560), "generic archer main");
	//SpawnInCharacter("builder", 3, Vec2f(575, 560), "generic builder main");
	@blob = null;
	TrySpawnBlob();
}

void onTick(CMap@ map)
{
	TrySpawnBlob();

	CBlob@ us = getLocalPlayerBlob();
	if (us is null || blob is null)
		return;

	if (getControls().isKeyPressed(KEY_KEY_Z)) {
		print(blob.getName() + " | " + blob.getHeadNum());
		SetRandomKnightHelm(blob);
		print(blob.getName() + " | " + blob.getHeadNum());
	}
}


// TEMP
void TrySpawnBlob()
{
	if (blob is null)
	{
		CBlob@[] list;
		getBlobsByName("knight", list);
		for (int a = 0; a < list.length(); a++)
		{
			list[a].server_Die();
		}

		@blob = server_CreateBlob("knight", 0, Vec2f(538, 560));
		addCharacterToBlob(blob, "generic knight main", "knight.cfg");
		SetRandomKnightHelm(blob);
	}
}