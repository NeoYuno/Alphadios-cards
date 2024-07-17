-- Cyberdark Core Dragon
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x4093),2)
    -- Attack Twice
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetCondition(s.eqcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    -- Apply effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE|LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_series={0x4093}
function s.eqcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsSetCard(0x4093)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.filter(c)
    return c:IsSetCard(0x4093) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=0
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	if #g1>0 and #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
	elseif #g1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	elseif #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+2
	end
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	end
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
        Duel.SummonOrSet(tp,g:GetFirst(),true,nil)
	elseif e:GetLabel()==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end