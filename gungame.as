#include "gg/music.as"
#include "gg/core.as"
#include "gg/core_cvars.as"
#include "gg/guns.as"
#include "gg/player.as"

const int TEAM_SURVIVORS = 2;

CBaseEntity@ ToBaseEntity( CTerrorPlayer@ pPlayer )
{
	CBasePlayer@ pBasePlayer = pPlayer.opCast();
	CBaseEntity@ pEntityPlayer = pBasePlayer.opCast();
	return pEntityPlayer;
}

void OnPluginInit()
{
	PluginData::SetVersion( "1.0" );
	PluginData::SetAuthor( "JonnyBoy0719" );
	PluginData::SetName( "GunGame" );

	GunGame::Cvars::Init();

	HuntedDMSetup();
	SetSomeGameRules();

	Events::ThePresident::OnRandomItemSpawn.Hook( @OnRandomItemSpawn_GG );
	Events::ThePresident::OnTerminateRound.Hook( @OnTerminateRound_GG );

	Events::Entities::OnEntityCreation.Hook( @OnEntCreated_GG );
	
	Events::Player::OnPlayerConnected.Hook( @OnPlayerConnected_GG );
	Events::Player::OnPlayerSpawn.Hook( @OnPlayerSpawn_GG );
	Events::Player::OnPlayerKilled.Hook( @OnPlayerKilled_GG );
	Events::Player::OnConCommand.Hook( @OnConCommand_GG );
	Events::Player::OnEntityDropped.Hook( @OnEntityDropped_GG );
	
	Events::Infected::OnInfectedSpawned.Hook( @OnInfectedSpawned_GG );
	
	GunGame::Player::ClearData();
	GunGame::Player::Reset();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnProcessRound()
{
	GunGame::CheckWinner();
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnRoundStart()
{
	HuntedDMSetup();
	GunGame::Player::Reset();
}

//------------------------------------------------------------------------------------------------------------------------//

void HuntedDMSetup()
{
	ThePresident::Hunted::SetDeathmatch( true );
	ThePresident.OverrideWeaponFastSwitch( true );
	ThePresident.IgnoreDefaultScoring( true );
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnRandomItemSpawn_GG(const string &in strClassname, CBaseEntity@ pEntity)
{
	pEntity.SUB_Remove();
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnTerminateRound_GG(int iTeam)
{
	GunGame::Player::Reset();
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnEntityDropped_GG(CTerrorPlayer@ pPlayer, CBaseEntity@ pEntity)
{
	pEntity.SUB_Remove();
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerSpawn_GG(CTerrorPlayer@ pPlayer)
{
	if ( pPlayer is null ) return HOOK_CONTINUE;
	CBaseEntity @pBase = ToBaseEntity( pPlayer );
	if ( pBase is null ) return HOOK_CONTINUE;
	if ( pBase.GetTeamNumber() == TEAM_SURVIVORS )
	{
		DropWeapons( pPlayer );
		GunGame::Player::Spawned( pBase.entindex() );
		GunGame::SetGlowIfLeader( pBase.entindex() );
	}
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerConnected_GG(CTerrorPlayer@ pPlayer)
{
	CBaseEntity @pBase = ToBaseEntity( pPlayer );
	if ( pBase is null ) return HOOK_CONTINUE;
	int iIndex = pBase.entindex();
	@gg_players[iIndex] = CGunGamePlayer(iIndex);
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnPlayerKilled_GG(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
{
	CBaseEntity @pBase = ToBaseEntity( pPlayer );
	CBaseEntity @pAttacker = DamageInfo.GetAttacker();
	const bool bIsPlayer = pAttacker.IsPlayer();
	if ( !bIsPlayer ) return HOOK_CONTINUE;
	if ( pAttacker !is null && pBase !is null )
		GunGame::Player::KilledPlayer( pBase.entindex(), pAttacker.entindex(), DamageInfo.GetDamageType() );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnInfectedSpawned_GG( Infected@ pInfected )
{
	if ( pInfected !is null )
		SetNewSpeed( pInfected );
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnEntCreated_GG( const string &in strClassname, CBaseEntity@ pEntity )
{
	if ( Utils.StrContains( "item_ammo", pEntity.GetClassname() ) )
		pEntity.SUB_Remove();
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

HookReturnCode OnConCommand_GG( CTerrorPlayer@ pPlayer, CASCommand@ pArgs )
{
	string arg1 = pArgs.Arg( 0 );
	CBasePlayer@ pBasePlayer = pPlayer.opCast();
	if ( Utils.StrEql( arg1, "drop" ) ) return HOOK_HANDLED;
	return HOOK_CONTINUE;
}

//------------------------------------------------------------------------------------------------------------------------//

void DropWeapons(CTerrorPlayer@ pPlayer)
{
	pPlayer.DropWeapon( 0 );
	pPlayer.DropWeapon( 1 );
	pPlayer.DropWeapon( 2 );
	pPlayer.DropWeapon( 3 );
	pPlayer.DropWeapon( 4 );
}

//------------------------------------------------------------------------------------------------------------------------//

void SetNewSpeed( Infected@ pInfected )
{
	if ( pInfected is null ) return;
	CNetworked@ pNetworked = Network::Get( "2012mod" );
	if ( pNetworked !is null )
	{
		if ( pNetworked.GetBool( "enabled" ) ) return;
	}

	// Randomize our animation set
	array<int> animset = {
		10,
		5,
		8,
		7
	};

	// Set our new animation set
	int iAnimSet = animset[ Math::RandomInt( 0, animset.length() - 1 ) ];
	pInfected.SetAnimationSet( iAnimSet );

	// Don't forget to make this zombie angry!
	pInfected.Enrage();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnMapInit()
{
	CBaseEntity@ pEntity = null;
	PurgeItems( "item_ammo*" );
	PurgeItems( "weapon_*" );
	GunGame::Player::ClearData();
	GunGame::Player::Reset();
	GunGame::Player::RespawnWeapons();
}

//------------------------------------------------------------------------------------------------------------------------//

void PurgeItems( const string &in szEnt )
{
	CBaseEntity@ pEntity = null;
	while( true )
	{
		// Find it!
		@pEntity = FindEntityByName( null, szEnt );
		// We found nothing, just stop
		if ( pEntity is null ) break;
		// BYE!
		pEntity.SUB_Remove();
	}
}

//------------------------------------------------------------------------------------------------------------------------//

void ThePresident_OnMapStart()
{
	ThePresident_OnRoundStart();
}

//------------------------------------------------------------------------------------------------------------------------//

void OnPluginUnload()
{
	Engine.EnableCustomSettings( false );
	GunGame::Cvars::OnUnload();
}

//------------------------------------------------------------------------------------------------------------------------//

void SetSomeGameRules()
{
	Engine.EnableCustomSettings( true );
	GunGame::Guns::Setup();

	CASConVar@ infinite_collected_ammo = ConVar::Find( "sv_infinite_collected_ammo" );
	if ( infinite_collected_ammo.HasFlag( FCVAR_CHEAT ) )
		infinite_collected_ammo.RemoveFlag( FCVAR_CHEAT );
	infinite_collected_ammo.SetValue( "1" );
}