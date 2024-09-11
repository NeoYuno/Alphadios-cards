--Mist Valley Overseer
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_WIND),1,99)
	--Gain LP & damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Foolish and Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(aux.selfreleasecost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPreviousLocation(LOCATION_DECK)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.Recover(tp,300,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end

function s.tgfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) 
        and not c:IsCode(code,id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,g:GetFirst():GetCode()):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
	end
end