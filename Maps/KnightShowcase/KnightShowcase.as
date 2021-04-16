//////////////////////
///
/// KnightShowcase map
/// 
/// This is a test level with blobs talking
/// Will clean when everything becomes more stable

#include "MapsCore"
#include "FireCommon"

void onInit(CMap@ this)
{
	string AveriaSerif = CFileMatcher("AveriaSerif-Bold.ttf").getFirst();
	GUI::LoadFont("AveriaSerif-Bold_22", AveriaSerif, 22, true);
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

	if (blob is null)
		return;

	if (getControls().isKeyPressed(KEY_KEY_Z)) 
		SetRandomKnightHelm(blob);
}


// TEMP
void TrySpawnBlob()
{
	if (blob is null)
	{
		CBlob@[] list;
		getBlobs(@list);
		for (int a = 0; a < list.length(); a++)
		{
			CBlob@ temp = list[a];
			if (temp is null || temp.getPlayer() !is null)
				continue;

			if (temp.getName() == "knight" || temp.getName() == "bush") 
				temp.server_Die();
		}

		@blob = server_CreateBlob("knight", 0, Vec2f(538, 560));
		addCharacterToBlob(blob, "Kevin the tester", "Kevin.cfg");
		SetRandomKnightHelm(blob);

		@blob = server_CreateBlob("bush", 0, Vec2f(144, 579));
		BlobCharacter@ char = addCharacterToBlob(blob, "Soren the bush", "Soren.cfg");

		char.AddFunction("self combust", Fireeee);
	}
}

// This is the blob with BlobCharacter, caller is our local player
// temp to soren bush
void Fireeee(CBlob@ this, CBlob@ caller)
{
	if (!this.hasScript("FireAnim.as"))
		this.AddScript("FireAnim.as");

	ParticleZombieLightning(this.getPosition());

	this.Tag("burning");
	this.Sync("burning", true);

	// Force fire to show up, the reason for this is because fireanim doesnt tick all too often
	CSpriteLayer@ fire = this.getSprite().getSpriteLayer("fire_animation_large");
	if (fire !is null)
	{
		fire.SetVisible(true);
		fire.SetAnimation("smallfire");
	}
}