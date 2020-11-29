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
}