#include "guns_base.as"
namespace GunGame
{
	namespace Guns
	{
		void Setup()
		{
			gg_weapons = {
				CGunGameWeapon( "ak74", 2 ),
				CGunGameWeapon( "ar15", 3 ),
				CGunGameWeapon( "scar", 3 ),
				CGunGameWeapon( "blr", 2 ),
				CGunGameWeapon( "m1garand", 3 ),
				CGunGameWeapon( "sniper", 2 ),
				CGunGameWeapon( "overunder", 4 ),
				CGunGameWeapon( "autoshotgun", 5 ),
				CGunGameWeapon( "remington870", 2 ),
				CGunGameWeapon( "mossberg", 3 ),
				CGunGameWeapon( "mp5k", 4 ),
				CGunGameWeapon( "kg9", 2 ),
				CGunGameWeapon( "mac10", 2 ),
				CGunGameWeapon( "sig", 2 ),
				CGunGameWeapon( "revolver", 3 ),
				CGunGameWeapon( "1911", 3 ),
				CGunGameWeapon( "handcannon", 4 ),
				CGunGameWeapon( "crossbow", 2 ),
				CGunGameWeapon( "compbow", 2 ),
				CGunGameWeapon( "grenadelauncher", 5 ),
				CGunGameWeapon( "grenade", 4 ),
				CGunGameWeapon( "flamethrower", 3 ),
				CGunGameWeapon( "crowbar_green", 1 )
			};
		}
		
		int GetMaxWeaponLevels() { return gg_weapons.length(); }
		
		bool GiveNextWeapon( int player_level, int player_kills )
		{
			// Grab current weapon from our level, and check its needed amount of kills.
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return false;
			return pGGWeapon.GiveNewWeapon( player_kills );
		}
		
		bool IsWinner( int player_level )
		{
			if ( player_level >= GetMaxWeaponLevels() ) return true;
			return false;
		}
		
		string GetWeapon( int player_level )
		{
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return "";
			return pGGWeapon.GetWeapon();
		}
		
		int GetNeededKills( int player_level )
		{
			CGunGameWeapon@ pGGWeapon = gg_weapons[player_level];
			if ( pGGWeapon is null ) return 0;
			return pGGWeapon.kills;
		}
	}
}