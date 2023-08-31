#include <sourcemod>
#include <sdktools>
#include <dhooks>

//this is a most smallest code i have ever made... :)

public Plugin myinfo =
{
	name = "[TF2] mvm currency limit breaker",
	author = "CoolGuy_0000",
	description = "",
	version = "1.0",
	url = "https://github.com/CoolGuy-0000"
};

Address g_pCTFPlayer__AddCurrency;
DynamicDetour g_DH_CTFPlayer__AddCurrency;

ConVar c_tf_mvm_max_currency_limit;
ConVar c_tf_mvm_allow_minus_currency;

public void OnPluginStart(){
	
	GameData gc = LoadGameConfigFile("tf2.mvm_currency_limit_breaker");
	g_pCTFPlayer__AddCurrency = gc.GetMemSig("CTFPlayer::AddCurrency");
	
	if(g_pCTFPlayer__AddCurrency == 0){
		SetFailState("[TF2]mvm currency limit breaker: signature is dead.");
	}
	
	g_DH_CTFPlayer__AddCurrency = DHookCreateDetour(g_pCTFPlayer__AddCurrency, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookAddParam(g_DH_CTFPlayer__AddCurrency, HookParamType_Int, 4, DHookPass_ByVal, DHookRegister_Default);
	g_DH_CTFPlayer__AddCurrency.Enable(Hook_Pre, OnAddCurrency);
	
	CloseHandle(gc);
	
	c_tf_mvm_max_currency_limit = CreateConVar("tf_mvm_max_currency", "30000", "max currency", FCVAR_PROTECTED, false, 0.0, false, 0.0);
	c_tf_mvm_allow_minus_currency = CreateConVar("tf_mvm_allow_minus_currency", "0", "allows minus currency", FCVAR_PROTECTED, true, 0.0, true, 1.0);
}

public MRESReturn OnAddCurrency(int player, DHookParam hParams){
	int max_currency = c_tf_mvm_max_currency_limit.IntValue;
	int result = GetEntProp(player, Prop_Send, "m_nCurrency")+hParams.Get(1);

	if(result >= max_currency)SetEntProp(player, Prop_Send, "m_nCurrency", max_currency);
	else if(result <= 0 && !c_tf_mvm_allow_minus_currency.BoolValue)SetEntProp(player, Prop_Send, "m_nCurrency", 0);
	else SetEntProp(player, Prop_Send, "m_nCurrency", result);
	
	return MRES_Supercede;
}
