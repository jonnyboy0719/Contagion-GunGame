array<CGunGamePlayer@> gg_players;
const float CONST_PLAYER_THINK_WAIT = 0.005f;

class CGunGamePlayer
{
	int PlayerIndex;
	int level;
	int kills;

	CGunGamePlayer(int index)
	{
		PlayerIndex = index;
		Reset();
	}

	void Reset()
	{
		level = 0;
		kills = 0;
	}

	int CurrentLevel() { return level+1; }

	void GiveWeapons()
	{
		CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( PlayerIndex );
		if ( pTerrorPlayer is null ) return;
		DropWeapons( pTerrorPlayer );
		pTerrorPlayer.GiveWeapon( GunGame::Guns::GetWeapon( level ) );
	}

	// Lose a level
	void KilledByMelee()
	{
		kills = 0;
		int curlevel = level;
		OnKilledPlayer(true, false);
	}

	void OnKilledPlayer(bool killed_self, bool melee)
	{
		if ( killed_self )
		{
			kills--;
			if ( kills < 0 )
			{
				kills = 0;
				if ( level <= 0 ) return;
				level--;
				CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( PlayerIndex );
				DropWeapons( pTerrorPlayer );
				GiveWeapons();
				GunGame::Music::LevelDown( pTerrorPlayer );
				CBasePlayer@ pBasePlayer = pTerrorPlayer.opCast();
				Chat.PrintToChat( pBasePlayer, "{red}You lost a level!" );
				GunGame::Player::AnnounceKiller( PlayerIndex );
			}
			return;
		}
		// Steal their level!
		if ( melee )
			kills += 99;
		else
			kills++;
		CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( PlayerIndex );
		CBasePlayer@ pBasePlayer = pTerrorPlayer.opCast();
		pTerrorPlayer.AddScore( melee ? 2 : 1 );
		if ( GunGame::Cvars::HealthOnKill() )
		{
			CBaseEntity@ pEntityPlayer = pBasePlayer.opCast();
			int iHealthMax = pEntityPlayer.GetMaxHealth();
			int iHealth = pEntityPlayer.GetHealth() + GunGame::Cvars::HealthAmount();
			pEntityPlayer.SetHealth( Math::clamp( iHealth, 0, iHealthMax ) );
		}
		string szKillMsg;
		int kills_needed = GunGame::Guns::GetNeededKills( level ) - kills;
		if ( kills_needed > 1 )
			szKillMsg = "kills";
		else
			szKillMsg = "kill";
		if ( GunGame::Guns::GiveNextWeapon( level, kills ) )
		{
			CalculateNextLevel();
			return;
		}
		Chat.PrintToChat( pBasePlayer, "{green}You need {gold}" + kills_needed + "{green} " + szKillMsg + " to advance to the next level. Level :: {default}" + CurrentLevel() + " {green} / {default}" + GunGame::Guns::GetMaxWeaponLevels() );
	}

	void CalculateNextLevel()
	{
		CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( PlayerIndex );
		level++;
		kills = 0;
		if ( GunGame::Guns::IsWinner( level ) )
			GunGame::SetWinner( PlayerIndex );
		else
		{
			// Play our level up sound, throw away previous weapons, and give new ones!
			GunGame::Music::LevelUp( pTerrorPlayer );
			DropWeapons( pTerrorPlayer );
			GiveWeapons();
			GunGame::Player::AnnounceKiller( PlayerIndex );
		}
	}
}