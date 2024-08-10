--Elementsaber Molehu Nexus
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Register effect when it is summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
local CARD_ELEMENTAL_PLACE=61557074
s.listed_series={SET_ELEMENTSABER,SET_ELEMENTAL_LORD}
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
		and (c:IsSetCard(SET_ELEMENTSABER) or c:IsLocation(LOCATION_HAND))
end
function s.regfilter(c,attr)
	return c:IsSetCard(SET_ELEMENTSABER) and c:GetOriginalAttribute()&attr~=0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,CARD_ELEMENTAL_PLACE)}) do
		fg:AddCard(pe:GetHandler())
	end
	local loc=LOCATION_HAND
	if #fg>0 then loc=LOCATION_HAND|LOCATION_DECK end
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,loc,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,loc,0,2,2,e:GetHandler())
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		local fc=nil
		if #fg==1 then
			fc=fg:GetFirst()
		else
			fc=fg:Select(tp,1,1,nil)
		end
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(CARD_ELEMENTAL_PLACE,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,0)
	end
	local flag=0
	if g:IsExists(s.regfilter,1,nil,ATTRIBUTE_WATER|ATTRIBUTE_WIND) then flag=flag|0x1 end
	if g:IsExists(s.regfilter,1,nil,ATTRIBUTE_EARTH|ATTRIBUTE_FIRE) then flag=flag|0x2 end
	if g:IsExists(s.regfilter,1,nil,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) then flag=flag|0x4 end
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(flag)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_ELEMENTSABER) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1 and e:GetLabelObject():GetLabel()~=0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if flag&0x1~=0 and Duel.IsPlayerCanDraw(tp,1) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if flag&0x2~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
	end
	if flag&0x4~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_DISABLE)
        e1:SetType(EFFECT_TYPE_QUICK_O)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetRange(LOCATION_MZONE)
        e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
        e1:SetCountLimit(1,{id,1})
        e1:SetTarget(s.distg)
        e1:SetOperation(s.disop)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e1)
	end
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	for tc in g:Iter() do
		--Negate its effects until the end of this turn
		tc:NegateEffects(c,RESET_PHASE|PHASE_END,true)
	end
end