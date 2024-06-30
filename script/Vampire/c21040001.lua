-- Vampire Commander
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Materials
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),8,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    -- Effect Negation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.deckdes)
	c:RegisterEffect(e1)
    -- Cannot Activate Effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
    e2:SetCondition(function(e) return c:IsSummonType(SUMMON_TYPE_XYZ) end)
    e2:SetTarget(function(e,c) return c:IsSpellTrap() end)
	e2:SetValue(function(_,re) return re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e2)
    -- Apply Effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
    e3:SetCondition(function(_,tp) return Duel.GetFlagEffect(tp,id)>0 end)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
    -- Check for cards sent to the GY
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

-- Mentions "Vampire" archetype
s.listed_series={SET_VAMPIRE}

-- Materials Filter
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_GRAVE) and c:IsSetCard(SET_VAMPIRE,xyzc,SUMMON_TYPE_XYZ,tp)
end

-- Check for cards sent to the GY
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK) then 
			if tc:IsMonster() then Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1) end
			if tc:IsSpell() then Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1) end
			if tc:IsTrap() then Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1) end
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

-- Effects Negation
function s.deckdes(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,chain_id=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_CHAIN_ID)
	if not (ep==1-tp and (trig_loc==LOCATION_MZONE or trig_loc==LOCATION_GRAVE) and chain_id~=s[0] and re:IsMonsterEffect()) then return end
	s[0]=chain_id
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
		Duel.BreakEffect()
	else Duel.NegateEffect(ev) end
end

-- Zombie Filter
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- LP Filter
function s.lpfilter(c)
    return c:IsMonster() and c:GetAttack()>0
end

-- Apply Effect
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if Duel.GetFlagEffect(tp,id+100)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,LOCATION_GRAVE,1,nil,e,tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_HAND,LOCATION_GRAVE,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    if Duel.GetFlagEffect(tp,id+200)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
    if Duel.GetFlagEffect(tp,id+300)>0 and Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local g=Duel.SelectMatchingCard(tp,s.lpfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Recover(tp,g:GetFirst():GetAttack(),REASON_EFFECT)
        end
    end
end