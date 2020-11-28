// Simple rules logic script
// no define required, localhost only, clients will be running this

void onInit(CRules@ this)
{
	this.AddScript("AutoRebuild.as"); // DEBUG -- REMEBER TO REMOVE 

	if (!this.exists("default class"))
	{
		this.set_string("default class", "knight");
	}

	onRestart(this);
}

void onRestart(CRules@ this)
{
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	AddMapScript();
}

void AddMapScript()
{
	string[] name = getMap().getMapName().split('/');
	string mapName = name[name.length() - 1];
	mapName = mapName.substr(0,mapName.length() - 4);

	getMap().AddScript(mapName);
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	Respawn(this, player);
}

CBlob@ Respawn(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		// remove previous players blob
		CBlob @blob = player.getBlob();

		if (blob !is null)
		{
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		CBlob @newBlob = server_CreateBlob(this.get_string("default class"), 0, getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
		return newBlob;
	}

	return null;
}

Vec2f getSpawnLocation(CPlayer@ player)
{
	if (player is null || getMap() is null) { return Vec2f(0,0); }
	Vec2f[] spawns;

	if (getMap().getMarkers("blue spawn", spawns))
	{
		return spawns[ XORRandom(spawns.length) ];
	}
	else if (getMap().getMarkers("blue main spawn", spawns))
	{
		return spawns[ XORRandom(spawns.length) ];
	}

	return Vec2f(0, 0);
}


void onRender(CRules@ this)
{
	CBlob@ b = getLocalPlayerBlob();
	CControls@ c = getControls();
	if (g_debug == 0 || b is null || c is null) { return; }
	
	GUI::DrawText(getDriver().getWorldPosFromScreenPos(c.getInterpMouseScreenPos()) + "", Vec2f(20,25), SColor(255,255,255,255));

	mousePressed = c.mousePressed1;
	Vec2f currentPos = getDriver().getWorldPosFromScreenPos(c.getInterpMouseScreenPos());
	if (mousePressed && !wasClicking)
	{
		lastMousePos = currentPos;
	}

	RenderSquare(currentPos);

	wasClicking = mousePressed;
}

void RenderSquare(Vec2f currentPos)
{
	Vec2f topLeft = lastMousePos;
	Vec2f botRight = currentPos;

	if (botRight.x < topLeft.x)
	{
		float temp = botRight.x;
		botRight.x = topLeft.x;
		topLeft.x = temp;

		if (botRight.y < topLeft.y)
		{
			temp = botRight.y;
			botRight.y = topLeft.y;
			topLeft.y = temp;
		}
	}
	else if (topLeft.y > botRight.y)
	{
		float temp = topLeft.y;
		topLeft.y = botRight.y;
		botRight.y = temp;
	}
	
	if (mousePressed)
	{
		GUI::DrawPane(getDriver().getScreenPosFromWorldPos(topLeft), getDriver().getScreenPosFromWorldPos(botRight), SColor(150, 0, 0, 0));
	}

	if (wasClicking && !mousePressed)
	{
		print("Sector pos:\nTop left:" + topLeft +"\nBottom right:" + botRight);
	}
}

bool wasClicking = false;
Vec2f lastMousePos = Vec2f(0,0);
bool mousePressed = false;

void onTick(CRules@ this)
{

}