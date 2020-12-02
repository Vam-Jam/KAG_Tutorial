int test = 1;

void onInit(CBlob@ this)
{
    print(test + '1st');
    test = getGameTime();
    print(test + ' 2nd');
}

void onTick(CBlob@ this)
{

}