--Mist Valley Tempest Ruler
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_WIND),1,99)
    --extra summon
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x37))
	c:RegisterEffect(e1)
    --Apply effect
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetCost(s.effcost)
    e2:SetTarget(s.efftg)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end
s.listed_series={0x37}
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHandAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
    e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=c:GetMaterial()
    local b1=Duel.IsPlayerCanDraw(tp,1) and g:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
    local b2=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and g:IsExists(Card.IsRace,1,nil,RACE_WINGEDBEAST)
    local b3=Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and g:IsExists(Card.IsRace,1,nil,RACE_THUNDER)
    if chk==0 then return b1 or b2 or b3 end
    local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
    e:SetLabel(op)
    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
    if op==2 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_ONFIELD)
    end
    if op==3 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_ONFIELD)
    end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if e:GetLabel()==1 then
        Duel.Draw(tp,1,REASON_EFFECT)
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
    if e:GetLabel()==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
    if e:GetLabel()==3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end