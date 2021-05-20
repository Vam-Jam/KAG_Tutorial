//////////////////////
///
/// Preview map
/// 
/// Experimental setup of the new tutorial
/// W I P

#include "EventSector"

SectorHandler handler;

void onInit(CMap@ this)
{
	onRulesRestart(this, getRules());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	handler = SectorHandler();

	handler.AddNewEvent(
		SectorEvent(FirstSpawnIn, Vec2f(161, 687),  Vec2f(0, 621), false)
	);


	rules.set_bool("DisableHud", true);
}

void onTick(CMap@ this)
{
	CBlob@ blob = getLocalPlayerBlob();

	if (handler is null || blob is null)
		return;

	handler.OnTick(blob);
}




/// Callbacks


//
void FirstSpawnIn(CBlob@ caller)
{
	CSprite@ sprite = caller.getSprite();

	if (sprite is null)
		return;

	// TODO: getScripts() func
	sprite.RemoveScript(caller.getName()+"HUD");
	sprite.RemoveScript("RunnerHoverHUD");
	sprite.RemoveScript("DefaultActorHUD");
}
