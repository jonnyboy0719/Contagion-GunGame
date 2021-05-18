namespace GunGame
{
	int iWinner = -1;
	CGunGamePlayer @pLeader = null;
	void ResetLeader() { @pLeader = null; }
	void CheckWinner()
	{
		if ( iWinner == -1 ) return;
		CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( iWinner );
		Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {arcana}has won!" );
		GunGame::Music::Victory();
		ThePresident.ForceWinState( STATE_WIN );
		iWinner = -1;
	}
	void SetWinner( int player ) { iWinner = player; }
	bool CheckForNewLeader( CGunGamePlayer @pPlayer )
	{
		if ( pLeader is null )
		{
			@pLeader = pPlayer;
			return false;
		}
		if ( pPlayer.PlayerIndex == pLeader.PlayerIndex ) return false;
		if ( pLeader.level >= pPlayer.level ) return false;
		CTerrorPlayer@ pTerrorOldLeader = ToTerrorPlayer( pLeader.PlayerIndex );
		CTerrorPlayer@ pTerrorNewLeader = ToTerrorPlayer( pPlayer.PlayerIndex );
		Chat.PrintToChat( all, "{red}" + pTerrorOldLeader.GetPlayerName() + " lost the lead!\n{green}" + pTerrorNewLeader.GetPlayerName() + " is now the new leader!" );
		@pLeader = pPlayer;
		return true;
	}
	CGunGamePlayer @GetLeader() { return pLeader; }
}