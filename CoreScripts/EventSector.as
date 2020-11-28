#include "EventCore"

void onInit(CRules@ this)
{
	onReload(this);
}

SectorHandler@ handler;

void onReload(CRules@ this)
{
	getMap().RemoveAllSectors();

	@handler = SectorHandler();

	handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(95, 419), Vec2f(184, 471))
	);

	handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(260, 410), Vec2f(411, 469), false)
	);

	handler.AddNewEvent(
		SectorEvent(HelloWorld, Vec2f(474, 410), Vec2f(617, 466), BombCheck, false)
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

void onTick(CRules@ this)
{

	CBlob@ blob = getLocalPlayerBlob();

	if (handler is null || blob is null)
		return;
		
	handler.OnTick(blob);
}

void onRender(CRules@ this)
{
	GUI::DrawText("One time use event", getDriver().getScreenPosFromWorldPos(Vec2f(115, 400)), SColor(255,255,255,255));

	GUI::DrawText("Infinite use event", getDriver().getScreenPosFromWorldPos(Vec2f(300, 400)), SColor(255,255,255,255));

	GUI::DrawText("Event with condition check", getDriver().getScreenPosFromWorldPos(Vec2f(520, 400)), SColor(255,255,255,255));
}


class SectorEvent : Event	
{
	// Map sector, we don't want external sources messing with this
	private CMap::Sector@ EventSector;

	// An id is needed, we cant use Sector ownerid unless you 
	// want sectors to go when a blob despawns randomly
	u16 id = 0; 

	SectorEvent(EventFunc@ mainEvent, Vec2f topLeft, Vec2f botRight, PreEventCheck@ checkEvent = null, bool removeAfterUse = true)
	{
		@EventSector = getMap().server_AddSector(topLeft, botRight, id + '');
		Event(mainEvent, checkEvent, removeAfterUse);
	}

	SectorEvent(EventFunc@ mainEvent, Vec2f topLeft, Vec2f botRight, bool removeAfterUse = true, PreEventCheck@ checkEvent = null)
	{
		this = SectorEvent(mainEvent, topLeft, botRight, checkEvent, removeAfterUse);
	}

	void SetNewSector(CMap::Sector@ newSector, bool removeOld = true)
	{
		if (removeOld && EventSector !is null)
			RemoveSector();

		@EventSector = newSector;
	}

	const CMap::Sector@ getSector()
	{
		return EventSector;
	}

	void ChangeId(const u16 newId)
	{
		EventSector.name = newId+'';
		id = newId;
	}

	void RemoveSector()
	{
		getMap().RemoveSectorsAtPosition(EventSector.center, EventSector.name);
	}
};

class SectorHandler
{
	array<SectorEvent> EventList;
	CMap@ map;

	SectorHandler() 
	{
		@map = getMap();
	}
	
	void AddNewEvent(SectorEvent@ newEvent)
	{
		if (newEvent !is null)
		{
			newEvent.ChangeId(EventList.length);
			EventList.push_back(newEvent);
		}
	}

	void PushBack(SectorEvent@ newEvent)
	{
		AddNewEvent(newEvent);
	}

	void Clear()
	{
		EventList.clear();
	}

	// Make sure you call RepairIndex's after
	void RemoveNoRepair(int index)
	{
		if (index < EventList.length)
		{
			EventList[index].RemoveSector();
			EventList.erase(index);
		}
	}

	void Remove(int index)
	{
		if (index < EventList.length)
		{
			EventList[index].RemoveSector();
			EventList.erase(index);

			RepairIndexIds();
		}
	}

	// Stop's a common crash
	void Reverse(int newSize)
	{
		if (EventList.length > 0)
		{
			EventList.reverse();
			RepairIndexIds();
		}
	}

	void RepairIndexIds()
	{
		for (u16 a = 0; a < EventList.length; a++)
		{
			EventList[a].ChangeId(a);
		}
	}

	void OnTick(CBlob@ blob)
	{
		CMap::Sector@[] sectors;

		// Returns true if sectors are found
		if (map.getSectorsAtPosition(blob.getPosition(), @sectors))
		{
			for(int a = 0; a < sectors.length; a++)
			{
				u16 id = parseInt(sectors[a].name);
				SectorEvent@ event = EventList[id];
				
				// Returns true if we should destroy after calling
				if (event.CheckAndEvent(blob))
					Remove(id);
			}
		}
	}

	void Destroy()
	{
		for (int a = 0; a < EventList.length; a++)
		{
			if (EventList[a] !is null)
			{
				EventList[a].RemoveSector();
			}
		}
	}

};