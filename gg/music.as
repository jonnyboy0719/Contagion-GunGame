namespace GunGame
{
	namespace Music
	{
		void Victory()
		{
			// winner winner zombie ate my dinner
		}
		void LevelUp(CTerrorPlayer@ pTerrorPlayer)
		{
			// Player leveled up
			pTerrorPlayer.PlayWwiseSound( "SFX_AmmoPickup", "" );
		}
		void LevelDown(CTerrorPlayer@ pTerrorPlayer)
		{
			// Player lost a level, what a shame
			pTerrorPlayer.PlayWwiseSound( "SFX_Button_Denied", "" );
		}
	}
}