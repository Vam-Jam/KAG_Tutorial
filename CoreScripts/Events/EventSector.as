

#include "EventCore"

class SectorEvent : Event	
{
	// Map sector, we don't want external sources messing with this
	private CMap::Sector@ EventSector;

	// An id is needed, we cant use Sector ownerid unless you 
	// want sectors to go when a blob despawns randomly
	u16 id = 0; 

	SectorEvent(EventFunc@ mainEvent, PreEventCheck@ checkEvent, Vec2f topLeft, Vec2f botRight, bool removeAfterUse = true)
	{
		@EventSector = getMap().server_AddSector(topLeft, botRight, id + '');
		Event(mainEvent, checkEvent, removeAfterUse);
	}

	SectorEvent(EventFunc@ mainEvent, Vec2f topLeft, Vec2f botRight, bool removeAfterUse = true)
	{
		this = SectorEvent(mainEvent, null, topLeft, botRight, removeAfterUse);
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