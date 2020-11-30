///////////////////////////////////////////////////////////
////
////  Character Core 
////
////  This contains a classes that is used to create
////  characters with text dialogue. 
////
////  HEAVILY IN WIP
////
///////////////////////////////////////////////////////////

void onInit(CRules@ this)
{

}

class Character 
{
	dictionary<string, string> responseMap = "";
	string characterName = "";

	Character(string name) 
	{
		characterName = name;
	}

	//void Character() {}

	void RenderBox() {}
}