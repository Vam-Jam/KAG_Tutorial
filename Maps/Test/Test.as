//////////////////////
///
/// TEST MAP
/// 
/// This is a test with sector events.
/// This may break in the future

#include "EventSector"

SectorHandler@ handler;

void onInit(CMap@ this)
{
	onRulesRestart(this, null);
}

void onRulesRestart( CMap@ this, CRules@ rules )
{
	this.RemoveAllSectors();

	@handler = SectorHandler();

	handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(95, 419), Vec2f(184, 471), true)
	);

	handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(260, 410), Vec2f(411, 469), false)
	);

	handler.AddNewEvent(
		SectorEvent(HelloWorld, BombCheck, Vec2f(474, 410), Vec2f(617, 466), false)
	);
}

void HelloWorld(CBlob@ caller)
{
	server_CreateBlob("chicken", -1, caller.getPosition());
}

bool BombCheck(CBlob@ caller)
{
	CBlob@ blob = caller.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();

	if (blob !is null && blob.getName() == "mat_bombs")
	{
		return true;
	}

	return false;
}

void onTick(CMap@ this)
{
	CBlob@ blob = getLocalPlayerBlob();

	if (handler is null || blob is null)
		return;
		
	handler.OnTick(blob);
}

void onRender(CMap@ this)
{
	GUI::DrawText("One time use event", getDriver().getScreenPosFromWorldPos(Vec2f(115, 400)), SColor(255,255,255,255));

	GUI::DrawText("Infinite use event", getDriver().getScreenPosFromWorldPos(Vec2f(300, 400)), SColor(255,255,255,255));

	GUI::DrawText("Event with condition check", getDriver().getScreenPosFromWorldPos(Vec2f(520, 400)), SColor(255,255,255,255));
}