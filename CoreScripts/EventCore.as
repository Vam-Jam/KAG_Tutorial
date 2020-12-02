///////////////////////////////////////////////////////////
////
////  Event Core 
////
////  This will contain any important core classes
////  for making any event for kag levels
////
////  Other .as files will use this to make their own
////  Event
////
///////////////////////////////////////////////////////////

// Hook a func with CBlob
funcdef void EventFunc(CBlob@ caller);

// A pre callback check before we call whats above (e.g. do we meet said conditions)
funcdef bool PreEventCheck(CBlob@ caller);

// A class used so we can easily make custom wrappers around it
mixin class Event
{
	// Callback to a func for out event
	private EventFunc@ Callback;
	// A callback to see if we should run out event (not required)
	private PreEventCheck@ PreCheck;
	// Should we delete this event after its called
	bool destroyAfterCall = true;

	// Constructors for the event mixin so we can quickly call this
	void Event(EventFunc@ mainEvent, PreEventCheck@ checkEvent = null, bool removeAfterUse = true) 
	{
		@Callback = mainEvent;
		@PreCheck = checkEvent;
		destroyAfterCall = removeAfterUse;
	}

	// Should we call, if so call main event
	bool CheckAndEvent(CBlob@ caller)
	{
		if (PreCheck !is null)
		{
			if (PreCheck(caller))
				return CallEvent(caller);
		}
		else
		{
			return CallEvent(caller);
		}

		return false;
	}

	// Can we call it
	bool canWeCallEvent(CBlob@ caller)
	{
		return (PreCheck !is null ? PreCheck(caller) : false);
	}

	// Call the event, we dont care about pre check!
	bool CallEvent(CBlob@ caller)
	{
		Callback(caller);

		if (destroyAfterCall)
			return true;

		return false;
	}
};
