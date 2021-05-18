#include "player_base.as"
namespace GunGame
{
	namespace Player
	{
		int iMaxPlayers;
		
		void ClearData()
		{
			iMaxPlayers = Globals.GetMaxClients();
			gg_players.resize(iMaxPlayers + 1);	
		}
		
		void Reset()
		{
			for ( uint i = 0; i < gg_players.length(); i++ )
			{
				CGunGamePlayer@ pGGPlayer = gg_players[i];
				if ( pGGPlayer is null ) continue;
				pGGPlayer.Reset();
			}
			GunGame::ResetLeader();
		}
		
		void RespawnWeapons()
		{
			for ( uint i = 0; i < gg_players.length(); i++ )
			{
				CGunGamePlayer@ pGGPlayer = gg_players[i];
				if ( pGGPlayer is null ) continue;
				pGGPlayer.GiveWeapons();
			}
		}
		
		void Spawned( int player_index )
		{
			CGunGamePlayer@ pGGPlayer = gg_players[player_index];
			if ( pGGPlayer is null ) return;
			pGGPlayer.GiveWeapons();
		}
		
		bool HasDMGFlag( int flags, int flag )
		{
			return ((flags&flag) == flag);
		}
		
		void KilledPlayer( int victim, int attacker, int flags )
		{
			// Our victim was killed with a melee?
			bool bMelee = false;
			if ( HasDMGFlag( flags, DMG_CLUB ) || HasDMGFlag( flags, DMG_SLASH ) )
			{
				CGunGamePlayer@ pGGPlayer = gg_players[victim];
				if ( pGGPlayer !is null )
					pGGPlayer.KilledByMelee();
				bMelee = true;
			}
			bool bSelfKill = false;
			if ( victim == attacker )
				bSelfKill = true;
			CGunGamePlayer@ pGGPlayer = gg_players[attacker];
			if ( pGGPlayer is null ) return;
			pGGPlayer.OnKilledPlayer(bSelfKill, bMelee);
		}
		
		void AnnounceKiller( int killer )
		{
			if ( CheckForNewLeader( gg_players[killer] ) ) return;
			CGunGamePlayer @pLeader = GunGame::GetLeader();
			int leader_level = pLeader.level;
			CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( killer );
			// The killer is the leader, announce their success
			if ( killer == pLeader.PlayerIndex )
			{
				leader_level += 1;
				Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {green}is leading on level {default}" + leader_level );
			}
			// Not the leader, check if they are tied
			else
			{
				CGunGamePlayer @pPlayer = gg_players[killer];
				int lvl_behind = leader_level - pPlayer.level;
				if ( lvl_behind == 0 )
					Chat.PrintToChat( all, "{azure}" + pTerrorPlayer.GetPlayerName() + " {green}is tied with the leader on level {default}" + pPlayer.CurrentLevel() );
			}
		}
		
		void CheckStatus( int player )
		{
			CGunGamePlayer @pPlayer = gg_players[player];
			CGunGamePlayer @pLeader = GunGame::GetLeader();
			if ( pLeader is null ) return;
			int leader_level = pLeader.level;
			int lvl_behind = leader_level - pPlayer.level;
			if ( lvl_behind > 0 )
			{
				CTerrorPlayer@ pTerrorPlayer = ToTerrorPlayer( player );
				CBasePlayer@ pBasePlayer = pTerrorPlayer.opCast();
				string szLevels;
				if ( lvl_behind > 1 )
					szLevels = "levels";
				else
					szLevels = "level";
				Chat.PrintToChat( pBasePlayer, "{azure}You are {green}" + lvl_behind + " {azure}" + szLevels + " behind the leader!" );
			}
		}
	}
}