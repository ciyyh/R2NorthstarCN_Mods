global function GamemodeChamber_Init

struct {

} file

void function GamemodeChamber_Init()
{
    SetSpawnpointGamemodeOverride( FFA )

	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( ChamberInitPlayer )
	AddCallback_OnPlayerKilled( ChamberOnPlayerKilled )
	AddCallback_OnPlayerRespawned( UpdateLoadout )

}

void function ChamberInitPlayer( entity player )
{
	UpdateLoadout( player )
}

void function ChamberOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( attacker.IsPlayer() )
    {
		attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
		AddTeamScore( attacker.GetTeam(), 1 )

        foreach ( entity weapon in attacker.GetMainWeapons() )
        {
            weapon.SetWeaponPrimaryAmmoCount(0)
			int clip = weapon.GetWeaponPrimaryClipCount() + 1
			if (weapon.GetWeaponPrimaryClipCountMax() < clip)
				weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCountMax())
			else
				weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCount() + 1)
        }

    }
}

void function UpdateLoadout( entity player )
{
	// set health to 1 to allow one shot kills
    if (IsAlive(player) && player != null) {
	player.SetMaxHealth( 1 )

	// set loadout
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	foreach ( entity weapon in player.GetOffhandWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	player.GiveWeapon( "mp_weapon_wingman" )
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )

	thread SetAmmo( player )
    }
}

void function SetAmmo( entity player )
{
	foreach ( entity weapon in player.GetMainWeapons() )
    {
        weapon.SetWeaponPrimaryAmmoCount(0)
        weapon.SetWeaponPrimaryClipCount(1)
    }
    WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}
