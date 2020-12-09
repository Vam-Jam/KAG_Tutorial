#include "MapsCore"

void onInit(CMap@ this)
{
	
	onRestart(this);
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	onRestart(this);
}

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
}

void onTick(CMap@ map)
{
	if (getGameTime() % 120 == 0)
	{
		//SpawnInCharacter("archer", 0, Vec2f(538, 560), "archer");
	}
}
