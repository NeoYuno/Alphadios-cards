--Shrine to the Elemental Lords
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --reduce battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
    --to hand or special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thspcon)
	e4:SetTarget(s.thsptg)
	e4:SetOperation(s.thspop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ELEMENTSABER,SET_ELEMENTAL_LORD}
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard({SET_ELEMENTSABER,SET_ELEMENTAL_LORD})
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetAttribute)
	return ct>0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)
	local ct=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetAttribute)
	if ct<1 or dam<=0 then return end
	dam=dam-(ct*200)
	if dam<0 then dam=0 end
	Duel.ChangeBattleDamage(tp,dam)
end

function s.thspfilter(c,e,tp,ft)
	return c:IsSetCard(SET_ELEMENTSABER) and c:IsFaceup() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
        and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(20357457,4)
	)
end