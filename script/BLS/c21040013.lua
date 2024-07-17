-- Luster Squire
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- Send to GY or Set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
    -- Can be used for a Ritual Summoned while in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.mtcon)
	e3:SetValue(s.mtval)
	c:RegisterEffect(e3)
end

-- Mentions "Black Luster Soldier" Atchetype
s.listed_series={0x10cf}
function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(7)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Send to GY or Set
function s.tgfilter(c)
	return c:IsCode(79234734,54484652,14094090,45948430,73694478,799183,21040015,21040016) and (c:IsAbleToGrave() or c:IsSSetable())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
    local op=nil
    if tc:IsRitualMonster() then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    end
    if op==0 then
        if (tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			and tc:IsSSetable() then
			Duel.BreakEffect()
			Duel.SSet(tp,tc)
        end
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

--  Can be used for a Ritual Summoned while in the GY
function s.mtcon(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),CARD_SPIRIT_ELIMINATION)
end
function s.mtval(e,c)
	return c:IsSetCard(SET_BLACK_LUSTER_SOLDIER)
end