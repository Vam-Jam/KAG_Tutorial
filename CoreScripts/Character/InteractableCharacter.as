/// This script handles how we can interact with a class (by using buttons currently)

// TODO -> Create Token

#include "BlobCharacter"

void onInit(CBlob@ this)
{
	if (getCharacter(this) is null)
	{
		error("Blob " + this.getName() + " has InteractableCharacter.as with no character!");
		this.RemoveScript("InteractableCharacter");
		return;
	}

	this.addCommandID("TalkingTo");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// Unsure if this can even go null
	if (caller is null || this.hasTag("dead"))
		return;

	CButton@ button = caller.CreateGenericButton("$trade$", Vec2f_zero, this, this.getCommandID("TalkingTo"), "Test");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("TalkingTo"))
	{
		BlobCharacter@ char = getCharacter(this);

		char.SetCurrentResponse("test");
	}
}



void onHealthChange( CBlob@ this, f32 oldHealth )
{
	// Work around to 'Invalid networkid' for trying to tell CRules to remove our character
	if (this.hasTag("dead"))
	{
		CBitStream cbs = CBitStream();
		cbs.write_u16(this.getNetworkID());
		getRules().SendCommand(getRules().getCommandID("character_unbound"), cbs);
	}
}