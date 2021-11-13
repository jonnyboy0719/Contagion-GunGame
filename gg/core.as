namespace GunGame
{
	int iWinner = -1;
	CGunGamePlayer @pLeader = null;
	void RemoveGlow( CGunGamePlayer @pPlayer )
	{
		if ( pPlayer is null ) return;
		CTerrorPlayer@ pTerrorOldLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
		if ( pTerrorOldLeader is null ) return;
		CBasePlayer@ pBasePlayer = pTerrorOldLeader.opCast();
		CBaseEntity@ pEntityPlayer = pBasePlayer.opCast();
		pEntityPlayer.SetOutline( -1, off );
	}
	void SetGlow( CGunGamePlayer @pPlayer )
	{
		if ( !GunGame::Cvars::AllowGlow() ) return;
		if ( pPlayer is null ) return;
		CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
		if ( pTerrorNewLeader is null ) return;
		CBasePlayer@ pBasePlayer = pTerrorNewLeader.opCast();
		CBaseEntity@ pEntityPlayer = pBasePlayer.opCast();
		pEntityPlayer.SetOutline( -1, on, occlude, Color(245, 66, 66) );
	}
	void SetGlowIfLeader( int playerindex )
	{
		if ( pLeader is null ) return;
		if ( pLeader.PlayerIndex != playerindex ) return;
		SetGlow( pLeader );
	}
	void ResetLeader()
	{
		RemoveGlow( pLeader );
		@pLeader = null;
	}
	void CheckWinner()
	{
		if ( iWinner == -1 ) return;
		CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( iWinner );
		Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {arcana}has won!" );
		GunGame::Music::Victory();
		ThePresident.ForceWinState( STATE_WIN );
		iWinner = -1;
	}
	void GrenadeFix()
	{
		array<int> collector = Utils.CollectPlayers();
		if ( collector.length() > 0 )
		{
			for ( uint i = 0; i < collector.length(); i++ )
			{
				// Make sure the player exist
				CTerrorPlayer @pTerror = ToTerrorPlayer( i );
				if ( pTerror is null ) continue;
				// If it's a grenade, make sure we always have a grenade
				CGunGamePlayer @pPlayer = @gg_players[i];
				if ( pPlayer is null ) continue;
				string szWeapon = GunGame::Guns::GetWeapon( pPlayer.level );
				if ( Utils.StrEql( szWeapon, "grenade", false ) )
				{
					// If we found nothing, give a new grenade!
					if ( pTerror.GetWeaponSlot( "weapon_grenade" ) == -1 )
						pPlayer.GiveWeapons();
				}
			}
		}
	}
	void SetWinner( int player ) { iWinner = player; }
	bool CheckForNewLeader( CGunGamePlayer @pPlayer )
	{
		if ( pLeader is null )
		{
			SetGlow( pPlayer );
			@pLeader = pPlayer;
			CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
			Chat.PrintToChat( all, "{green}" + pTerrorNewLeader.GetPlayerName() + " is now the new leader!" );
			return false;
		}
		if ( pPlayer.PlayerIndex == pLeader.PlayerIndex ) return false;
		if ( pLeader.level >= pPlayer.level ) return false;
		CTerrorPlayer@ pTerrorOldLeader = ToTerrorPlayer( pLeader.PlayerIndex );
		CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
		Chat.PrintToChat( all, "{red}" + pTerrorOldLeader.GetPlayerName() + " lost the lead!\n{green}" + pTerrorNewLeader.GetPlayerName() + " is now the new leader!" );
		RemoveGlow( pLeader );
		SetGlow( pPlayer );
		@pLeader = pPlayer;
		return true;
	}
	CGunGamePlayer @GetLeader() { return pLeader; }
}