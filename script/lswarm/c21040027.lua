-- Second Step Towards Infestation
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    -- Banish self from GY to replace destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

-- Mentions "lswarm", "Steelswarm" and "Infestation" Archetypes
s.listed_series={0xa,0x100a,0x65}

-- Search
function s.thfilter(c)
	return c:IsSetCard(0xa) and c:IsMonster() and c:IsAbleToHand()
end
function s.nsfilter(c)
	return c:IsSetCard(0x100a) and c:IsSummonable(true,nil)
end
function s.rtfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x65) and c:IsSpellTrap() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        Duel.BreakEffect()
        local b1=Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,0))) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		if op==1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
			Duel.Summon(tp,g:GetFirst(),true,nil)
        elseif op==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil)
            Duel.SendtoHand(g:GetFirst(),nil,REASON_EFFECT)
        end
	end
end

-- Banish self from GY to replace destruction
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsSetCard(0xa)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
