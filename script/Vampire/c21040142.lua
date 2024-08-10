--Vampire Commander
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),8,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
    --negate
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.deckes)
	c:RegisterEffect(e1)
    --Your opponent cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e2:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_SPELL|TYPE_TRAP) and re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e2)
    --Apply Effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(function(e) return Duel.GetFlagEffect(0,id+100)>0 end)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x8e}
local mask=TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP
local types=0
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK) then
            types=types|(tc:GetType()&mask)
			Duel.RegisterFlagEffect(0,id+100,RESET_PHASE|PHASE_END,0,1)
		end
	end
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x8e,lc,SUMMON_TYPE_XYZ,tp) and c:IsSummonLocation(LOCATION_GRAVE,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end

function s.deckes(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,chain_id=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_CHAIN_ID)
	if not (ep==1-tp and trig_loc==LOCATION_MZONE|LOCATION_GRAVE and chain_id~=s[0] and re:IsMonsterEffect()) then return end
	s[0]=chain_id
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
		Duel.BreakEffect()
	else Duel.NegateEffect(ev) end
end

function s.spfilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lpfilter(c)
    return c:IsFaceup() and c:GetAttack()>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if types&TYPE_MONSTER>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local spc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp):GetFirst()
        if not spc then return end
        Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
    end
    if types&TYPE_SPELL>0 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local tgc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
        if not tgc then return end
        Duel.HintSelection(tgc)
        Duel.SendtoGrave(tgc,REASON_EFFECT)
    end
    if types&TYPE_TRAP>0 and Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local lpc=Duel.SelectMatchingCard(tp,s.lpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil):GetFirst()
        if not lpc then return end
        Duel.HintSelection(lpc)
        Duel.Recover(tp,lpc:GetAttack(),REASON_EFFECT)
    end
end
