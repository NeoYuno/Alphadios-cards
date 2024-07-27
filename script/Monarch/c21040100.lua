--Stronghold of the Monarchs
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sslimit)
	c:RegisterEffect(e1)
	--Lizard check
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,s.lizfilter)
    --atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(600)
	c:RegisterEffect(e2)
    --Level 8 or higher monsters can be summoned for 1 less Tribute
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
    e4:SetCost(s.cost)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) end)
end

function s.filter(c)
    return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
    local att=0
	for gc in aux.Next(Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)) do
		att=att|gc:GetAttribute()
	end
	return c:IsLocation(LOCATION_EXTRA) and c:IsAttribute(att)
end
function s.lizfilter(e,c)
    local att=0
	for gc in aux.Next(Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)) do
		att=att|gc:GetAttribute()
	end
	return c:IsOriginalAttribute(att)
end
function s.atkcon(e)
    local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
    local tp=e:GetHandlerPlayer()
	if not (a and d) then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	local g=Group.FromCards(a,d)
	return a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and g:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.atktg(e,c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon from the Extra Deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,8))
	e1:SetValue(0x10001)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	Duel.RegisterEffect(e2,tp)
end