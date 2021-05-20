//////////////////////
///
/// Preview map
/// 
/// Experimental setup of the new tutorial
/// W I P

#include "EventSector"

SectorHandler handler;

bool ENABLE_HUD = false;

void onInit(CMap@ this)
{
	onRulesRestart(this, null);
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	handler = SectorHandler();

	/*handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(95, 419), Vec2f(184, 471), true)
	);*/
}

void onTick(CMap@ this)
{
	CBlob@ blob = getLocalPlayerBlob();

	if (handler is null || blob is null)
		return;
		
	handler.OnTick(blob);
}